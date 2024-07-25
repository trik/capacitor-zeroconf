# capacitor-zeroconf

Capacitor ZeroConf plugin

This plugin allows you to browse and publish ZeroConf/Bonjour/mDNS services from applications developed using Ionic's Capacitor.

This is not a background service. When the cordova view is destroyed/terminated, publish and watch operations are stopped.

Android, iOS and [Electron](https://github.com/capacitor-community/electron) platforms are supported.

The has been ported from [Cordova ZeroConf Plugin](https://github.com/becvert/cordova-plugin-zeroconf).

## Install

```bash
npm install capacitor-zeroconf
npx cap sync
```

or

```bash
yarn add capacitor-zeroconf
yarn cap sync
```

## API

<docgen-index>

* [`addListener('discover', ...)`](#addlistenerdiscover-)
* [`getHostname()`](#gethostname)
* [`register(...)`](#register)
* [`unregister(...)`](#unregister)
* [`stop()`](#stop)
* [`watch(...)`](#watch)
* [`unwatch(...)`](#unwatch)
* [`close()`](#close)
* [Interfaces](#interfaces)
* [Type Aliases](#type-aliases)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### addListener('discover', ...)

```typescript
addListener(eventName: 'discover', listenerFunc: (result: ZeroConfWatchResult) => void) => Promise<PluginListenerHandle>
```

| Param              | Type                                                                                     |
| ------------------ | ---------------------------------------------------------------------------------------- |
| **`eventName`**    | <code>'discover'</code>                                                                  |
| **`listenerFunc`** | <code>(result: <a href="#zeroconfwatchresult">ZeroConfWatchResult</a>) =&gt; void</code> |

**Returns:** <code>Promise&lt;<a href="#pluginlistenerhandle">PluginListenerHandle</a>&gt;</code>

--------------------


### getHostname()

```typescript
getHostname() => Promise<{ hostname: string; }>
```

**Returns:** <code>Promise&lt;{ hostname: string; }&gt;</code>

--------------------


### register(...)

```typescript
register(request: ZeroConfRegisterRequest) => Promise<void>
```

| Param         | Type                                                                        |
| ------------- | --------------------------------------------------------------------------- |
| **`request`** | <code><a href="#zeroconfregisterrequest">ZeroConfRegisterRequest</a></code> |

--------------------


### unregister(...)

```typescript
unregister(request: ZeroConfUnregisterRequest) => Promise<void>
```

| Param         | Type                                                                            |
| ------------- | ------------------------------------------------------------------------------- |
| **`request`** | <code><a href="#zeroconfunregisterrequest">ZeroConfUnregisterRequest</a></code> |

--------------------


### stop()

```typescript
stop() => Promise<void>
```

--------------------


### watch(...)

```typescript
watch(request: ZeroConfWatchRequest, callback?: ZeroConfWatchCallback | undefined) => Promise<CallbackID>
```

| Param          | Type                                                                    |
| -------------- | ----------------------------------------------------------------------- |
| **`request`**  | <code><a href="#zeroconfwatchrequest">ZeroConfWatchRequest</a></code>   |
| **`callback`** | <code><a href="#zeroconfwatchcallback">ZeroConfWatchCallback</a></code> |

**Returns:** <code>Promise&lt;string&gt;</code>

--------------------


### unwatch(...)

```typescript
unwatch(request: ZeroConfUnwatchRequest) => Promise<void>
```

| Param         | Type                                                                  |
| ------------- | --------------------------------------------------------------------- |
| **`request`** | <code><a href="#zeroconfwatchrequest">ZeroConfWatchRequest</a></code> |

--------------------


### close()

```typescript
close() => Promise<void>
```

--------------------


### Interfaces


#### PluginListenerHandle

| Prop         | Type                                      |
| ------------ | ----------------------------------------- |
| **`remove`** | <code>() =&gt; Promise&lt;void&gt;</code> |


#### ZeroConfService

| Prop                | Type                                    |
| ------------------- | --------------------------------------- |
| **`domain`**        | <code>string</code>                     |
| **`type`**          | <code>string</code>                     |
| **`name`**          | <code>string</code>                     |
| **`port`**          | <code>number</code>                     |
| **`hostname`**      | <code>string</code>                     |
| **`ipv4Addresses`** | <code>string[]</code>                   |
| **`ipv6Addresses`** | <code>string[]</code>                   |
| **`txtRecord`**     | <code>{ [key: string]: string; }</code> |


#### ZeroConfRegisterRequest

| Prop        | Type                                    |
| ----------- | --------------------------------------- |
| **`port`**  | <code>number</code>                     |
| **`props`** | <code>{ [key: string]: string; }</code> |


#### ZeroConfUnregisterRequest

| Prop       | Type                |
| ---------- | ------------------- |
| **`name`** | <code>string</code> |


#### ZeroConfWatchRequest

| Prop         | Type                |
| ------------ | ------------------- |
| **`type`**   | <code>string</code> |
| **`domain`** | <code>string</code> |


### Type Aliases


#### ZeroConfWatchResult

<code>{ action: <a href="#zeroconfwatchaction">ZeroConfWatchAction</a>; service: <a href="#zeroconfservice">ZeroConfService</a>; }</code>


#### ZeroConfWatchAction

<code>'added' | 'removed' | 'resolved'</code>


#### ZeroConfWatchCallback

<code>(event: <a href="#zeroconfwatchresult">ZeroConfWatchResult</a>): void</code>


#### CallbackID

<code>string</code>


#### ZeroConfUnwatchRequest

<code><a href="#zeroconfwatchrequest">ZeroConfWatchRequest</a></code>

</docgen-api>
