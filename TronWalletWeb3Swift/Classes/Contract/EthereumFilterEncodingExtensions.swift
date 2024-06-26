
import BigInt
import Foundation

extension BigUInt: EventFilterEncodable {
    public func eventFilterEncoded() -> String? {
        return abiEncode(bits: 256)?.hex.withHex
    }
}

extension BigInt: EventFilterEncodable {
    public func eventFilterEncoded() -> String? {
        return abiEncode(bits: 256)?.hex.withHex
    }
}

extension Data: EventFilterEncodable {
    public func eventFilterEncoded() -> String? {
        guard let padded = self.setLengthLeft(32) else { return nil }
        return padded.hex.withHex
    }
}

extension Address: EventFilterEncodable {
    public func eventFilterEncoded() -> String? {
        guard let padded = self.addressData.setLengthLeft(32) else { return nil }
        return padded.hex.withHex
    }
}

extension String: EventFilterEncodable {
    public func eventFilterEncoded() -> String? {
        return data.keccak256().hex.withHex
    }
}
