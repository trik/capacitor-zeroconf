import { WebPlugin } from '@capacitor/core';

import type {
  CallbackID,
  ZeroConfPlugin,
  ZeroConfRegisterRequest,
  ZeroConfUnregisterRequest,
  ZeroConfUnwatchRequest,
  ZeroConfWatchCallback,
  ZeroConfWatchRequest,
} from './definitions';

const errorString = 'The plugin is not available on this platform';
const errorFn = Promise.reject(errorString);

export class ZeroConfWeb extends WebPlugin implements ZeroConfPlugin {
  getHostname(): Promise<{ hostname: string }> {
    return errorFn;
  }
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  register(_request: ZeroConfRegisterRequest): Promise<void> {
    return errorFn;
  }
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  unregister(_request: ZeroConfUnregisterRequest): Promise<void> {
    return errorFn;
  }
  stop(): Promise<void> {
    return errorFn;
  }
  watch(
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    _request: ZeroConfWatchRequest,
    // eslint-disable-next-line @typescript-eslint/no-unused-vars
    _callback: ZeroConfWatchCallback
  ): Promise<CallbackID> {
    return errorFn;
  }
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  unwatch(_request: ZeroConfUnwatchRequest): Promise<void> {
    return errorFn;
  }
  close(): Promise<void> {
    return errorFn;
  }
}
