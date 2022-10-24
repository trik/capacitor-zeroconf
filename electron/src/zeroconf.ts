import * as bonjourMod from 'bonjour';
import type { Browser, Bonjour, RemoteService, Service } from 'bonjour';
import { EventEmitter } from 'events';
import { hostname } from 'os';

import type {
  CallbackID,
  ZeroConfPlugin,
  ZeroConfRegisterRequest,
  ZeroConfService,
  ZeroConfUnregisterRequest,
  ZeroConfUnwatchRequest,
  ZeroConfWatchCallback,
  ZeroConfWatchRequest,
} from '../../src/definitions';

let callbackId = 0;

const bonjour = ((bonjourMod as any).default || bonjourMod) as typeof bonjourMod;

const bonjourToZeroConfService = (service: RemoteService): ZeroConfService => ({
  domain: service.host,
  type: service.type,
  name: service.name,
  port: service.port,
  hostname: service.fqdn,
  ipv4Addresses: service.addresses,
  ipv6Addresses: service.addresses,
  txtRecord: service.txt,
});

type EvtListener = (...args: any[]) => void;
let listenerId = 0;

export class ZeroConf extends EventEmitter implements ZeroConfPlugin {
  private _bonjour: Bonjour;
  private _services: Service[] = [];
  private _browsers: {
    [key: string]: { request: ZeroConfWatchRequest; browser: Browser };
  } = {};
  private listenersMap = new Map<number, EvtListener>();

  constructor() {
    super();
    this._bonjour = bonjour();
  }

  addListener(eventName: string | symbol, listener: (...args: any[]) => void): any {
    super.addListener(eventName, listener);
    const id = listenerId++;
    this.listenersMap.set(id, listener);
    return {
      remove: () => {
        const l = this.listenersMap.get(id);
        this.removeListener(eventName, l);
      },
    };
  }

  getHostname(): Promise<{ hostname: string }> {
    return Promise.resolve({ hostname: hostname() });
  }
  register(request: ZeroConfRegisterRequest): Promise<void> {
    const { name, type, domain, port, props } = request;
    const service = this._bonjour.publish({
      name,
      type,
      host: domain,
      port,
      txt: props,
    });
    this._services.push(service);
    service.start();
    return Promise.resolve();
  }
  unregister(request: ZeroConfUnregisterRequest): Promise<void> {
    return new Promise((resolve) => {
      const serviceIdx = this._services.findIndex(
        (service) => service.name === request.name && service.type === request.type && service.fqdn == request.domain
      );
      if (serviceIdx > -1) {
        const service = this._services[serviceIdx];
        service.stop(() => resolve());
        this._services = [...this._services.slice(0, serviceIdx), ...this._services.slice(serviceIdx + 1)];
      } else {
        resolve();
      }
    });
  }
  stop(): Promise<void> {
    return new Promise((resolve) => {
      this._bonjour.unpublishAll(() => resolve());
    });
  }
  async watch(request: ZeroConfWatchRequest, callback?: ZeroConfWatchCallback): Promise<CallbackID> {
    if (callback != null) {
      throw new Error(`You cannot use callback in electron. Please subscribe to discover events`);
    }
    return new Promise<CallbackID>((resolve) => {
      const search = request.type.split('.');
      const type = search[0].replace(/^_/, '');
      const protocol = search.length > 1 ? search[1].replace(/^_/, '') : 'tcp';
      const browser = this._bonjour.find({ type, protocol });
      const id = `${callbackId++}`;
      browser.on('up', (service) =>
        this.emit('discover', {
          action: 'added',
          service: bonjourToZeroConfService(service),
        })
      );
      browser.on('down', (service) =>
        this.emit('discover', {
          action: 'removed',
          service: bonjourToZeroConfService(service),
        })
      );
      this._browsers[id] = { request, browser };
      browser.services.forEach((service) => {
        this.emit('discover', {
          action: 'added',
          service: bonjourToZeroConfService(service),
        });
      });
      browser.start();
      resolve(id);
    });
  }
  unwatch(request: ZeroConfUnwatchRequest): Promise<void> {
    return new Promise<void>((resolve) => {
      const browserId = Object.keys(this._browsers).find((id) => {
        const { domain, type } = this._browsers[id].request;
        return domain === request.domain && type === request.type;
      });
      if (browserId != null) {
        const { browser } = this._browsers[browserId];
        browser.stop();
        delete this._browsers[browserId];
      }
      resolve();
    });
  }
  close(): Promise<void> {
    return Promise.resolve();
  }
}
