#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

// Define the plugin using the CAP_PLUGIN Macro, and
// each method the plugin supports using the CAP_PLUGIN_METHOD macro.
CAP_PLUGIN(ZeroConfPlugin, "ZeroConf",
           CAP_PLUGIN_METHOD(getHostname, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(register, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(unregister, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(stop, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(watch, CAPPluginReturnCallback);
           CAP_PLUGIN_METHOD(unwatch, CAPPluginReturnPromise);
)

