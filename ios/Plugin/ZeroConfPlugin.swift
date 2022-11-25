import Foundation
import Capacitor

@objc(ZeroConfPlugin)
public class ZeroConfPlugin: CAPPlugin {
    private let implementation = ZeroConf()

    @objc func getHostname(_ call: CAPPluginCall) {
        let value = implementation.getHostname()
        call.resolve(["hostname": value])
    }

    @objc func register(_ call: CAPPluginCall) {
        let typeParam = call.getString("type")
        let domainParam = call.getString("domain")
        let nameParam = call.getString("name")
        let portParam = call.getInt("port")
        let propsObjParam = call.getObject("props")
        let addressFamilyParam = call.getString("addressFamily")

        guard let type = typeParam,
              let domain = domainParam,
              let name = nameParam,
              let port = portParam,
              let propsObj = propsObjParam,
              let addressFamily = addressFamilyParam else {
            call.reject("Invalid parameters")
            return
        }

        var props: [String: String] = [:]
        propsObj.keys.forEach { key in
            if let value = propsObj[key] as? String {
                props[key] = value
            }
        }

        func callback(registered: Bool, error: [String: NSNumber]?) {
            if registered {
                call.resolve()
            } else {
                call.reject(error?.keys.joined(separator: ",") ?? "")
            }
        }

        DispatchQueue.main.async {
            self.implementation.registerService(
                type: type,
                domain: domain,
                name: name,
                port: port,
                props: props,
                addressFamily:
                    addressFamily,
                callback: callback
            )
        }
    }

    @objc func unregister(_ call: CAPPluginCall) {
        let typeParam = call.getString("type")
        let domainParam = call.getString("domain")
        let nameParam = call.getString("name")

        guard let type = typeParam, let domain = domainParam, let name = nameParam else {
            call.reject("Invalid parameters")
            return
        }

        func callback(unregistered: Bool) {
            if unregistered {
                call.resolve()
            } else {
                call.reject("")
            }
        }

        DispatchQueue.main.async {
            self.implementation.unregisterService(type: type, domain: domain, name: name, callback: callback)
        }
    }

    @objc func stop(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            self.implementation.stop()
            call.resolve()
        }
    }

    @objc func watch(_ call: CAPPluginCall) {
        call.keepAlive = true
        let typeParam = call.getString("type")
        let domainParam = call.getString("domain")

        guard let type = typeParam, let domain = domainParam else {
            call.reject("Invalid parameters")
            return
        }

        func callback(action: ZeroConfPublisherAction, service: NetService?, error: [String: NSNumber]?) {
            var actionStr = ""
            switch action {
            case .added:
                actionStr = "added"
            case .removed:
                actionStr = "removed"
            case .resolved:
                actionStr = "resolved"
            case .error:
                call.reject(error?.keys.joined(separator: ", ") ?? "")
                return
            }
            if let unwrappedService: NetService = service {
                call.resolve(["action": actionStr, "service": jsonifyService(unwrappedService)])
            }
        }

        DispatchQueue.main.async {
            self.implementation.watch(type: type, domain: domain, callback: callback)
        }
    }

    @objc func unwatch(_ call: CAPPluginCall) {
        let typeParam = call.getString("type")
        let domainParam = call.getString("domain")

        guard let type = typeParam, let domain = domainParam else {
            call.reject("Invalid parameters")
            return
        }

        func callback(service: NetService?) {
            call.resolve()
        }

        DispatchQueue.main.async {
            self.implementation.unwatch(type: type, domain: domain, callback: callback)
        }
    }

    fileprivate func jsonifyService(_ netService: NetService) -> NSDictionary {
        var ipv4Addresses: [String] = []
        var ipv6Addresses: [String] = []
        if let addresses = netService.addresses {
            for address in addresses {
                if let family = extractFamily(address) {
                    if  family == 4 {
                        if let addr = extractAddress(address) {
                            ipv4Addresses.append(addr)
                        }
                    } else if family == 6 {
                        if let addr = extractAddress(address) {
                            ipv6Addresses.append(addr)
                        }
                    }
                }
            }
        }

        if ipv6Addresses.count > 1 {
            ipv6Addresses = Array(Set(ipv6Addresses))
        }

        var txtRecord: [String: String] = [:]
        if let txtRecordData = netService.txtRecordData() {
            txtRecord = dictionary(fromTXTRecord: txtRecordData)
        }

        let hostName = netService.hostName ?? ""

        let service: NSDictionary = NSDictionary(
            objects: [netService.domain, netService.type, netService.name, netService.port, hostName, ipv4Addresses, ipv6Addresses, txtRecord],
            forKeys: [
                "domain" as NSCopying,
                "type" as NSCopying,
                "name" as NSCopying,
                "port" as NSCopying,
                "hostname" as NSCopying,
                "ipv4Addresses" as NSCopying,
                "ipv6Addresses" as NSCopying,
                "txtRecord" as NSCopying
            ])

        return service
    }

    fileprivate func extractFamily(_ addressBytes: Data) -> Int? {
        let addr = (addressBytes as NSData).bytes.load(as: sockaddr.self)
        if addr.sa_family == sa_family_t(AF_INET) {
            return 4
        } else if addr.sa_family == sa_family_t(AF_INET6) {
            return 6
        } else {
            return nil
        }
    }

    fileprivate func extractAddress(_ addressBytes: Data) -> String? {
        var addr = (addressBytes as NSData).bytes.load(as: sockaddr.self)
        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
        if getnameinfo(&addr, socklen_t(addr.sa_len), &hostname,
                       socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST) == 0 {
            return String(cString: hostname)
        }
        return nil
    }

    fileprivate func dictionary(fromTXTRecord txtData: Data) -> [String: String] {

        var result = [String: String]()
        var data = txtData

        while !data.isEmpty {
            // The first byte of each record is its length, so prefix that much data
            let recordLength = Int(data.removeFirst())
            guard data.count >= recordLength else { return [:] }
            let recordData = data[..<(data.startIndex + recordLength)]
            data = data.dropFirst(recordLength)

            guard let record = String(bytes: recordData, encoding: .utf8) else { return [:] }
            // The format of the entry is "key=value"
            // (According to the reference implementation, = is optional if there is no value,
            // and any equals signs after the first are part of the value.)
            // `ommittingEmptySubsequences` is necessary otherwise an empty string will crash the next line
            let keyValue = record.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: false)
            let key = String(keyValue[0])
            // If there's no value, make the value the empty string
            switch keyValue.count {
            case 1:
                result[key] = ""
            case 2:
                result[key] = String(keyValue[1])
            default:
                fatalError("ZeroConf: Malformed or unexpected TXTRecord keyValue")
            }
        }

        return result
    }
}
