import { registerPlugin } from '@capacitor/core';

import type { ZeroConfPlugin } from './definitions';

const ZeroConf = registerPlugin<ZeroConfPlugin>('ZeroConf', {
  web: () => import('./web').then((m) => new m.ZeroConfWeb()),
  electron: () => (window as any).CapacitorCustomPlatform.plugins.ZeroConf,
});

export * from './definitions';
export { ZeroConf };
