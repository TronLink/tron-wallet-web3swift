
import Foundation

struct Base58 {
    static let base58Alphabet = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"

    // Encode
    static func base58FromBytes(_ bytes: [UInt8]) -> String {
        var bytes = bytes
        var zerosCount = 0
        var length = 0

        for b in bytes {
            if b != 0 { break }
            zerosCount += 1
        }

        bytes.removeFirst(zerosCount)

        let size = bytes.count * 138 / 100 + 1

        var base58: [UInt8] = Array(repeating: 0, count: size)
        for b in bytes {
            var carry = Int(b)
            var i = 0

            for j in 0 ..< base58.count where carry != 0 || i < length {
                carry += 256 * Int(base58[base58.count - j - 1])
                base58[base58.count - j - 1] = UInt8(carry % 58)
                carry /= 58
                i += 1
            }

            // 138/100 exceeds log(256)/log(58), so the buffer always holds the result.
            // A leftover carry would silently truncate an address, so fail closed here
            // rather than in an assert the release build strips out.
            precondition(carry == 0, "Base58 encoding overflowed its buffer")

            length = i
        }

        // skip leading zeros
        var zerosToRemove = 0
        var str = ""
        for b in base58 {
            if b != 0 { break }
            zerosToRemove += 1
        }
        base58.removeFirst(zerosToRemove)

        while 0 < zerosCount {
            str = "\(str)1"
            zerosCount -= 1
        }

        for b in base58 {
            str = "\(str)\(base58Alphabet[String.Index(encodedOffset: Int(b))])"
        }

        return str
    }

    // Decode
    static func bytesFromBase58(_ base58: String) -> [UInt8] {
        // remove leading and trailing whitespaces
        let string = base58.trimmingCharacters(in: CharacterSet.whitespaces)

        guard !string.isEmpty else { return [] }

        var zerosCount = 0
        var length = 0
        for c in string {
            if c != "1" { break }
            zerosCount += 1
        }

        // Leading '1's decode to zero bytes that are prepended at the end, so they are
        // excluded from the count instead of subtracted from it: subtracting made the
        // size negative for inputs that are mostly '1's.
        let size = (string.count - zerosCount) * 733 / 1000 + 1
        var base58: [UInt8] = Array(repeating: 0, count: size)
        for c in string where c != " " {
            // search for base58 character
            guard let base58Index = base58Alphabet.index(of: c) else { return [] }

            var carry = base58Index.encodedOffset
            var i = 0
            for j in 0 ..< base58.count where carry != 0 || i < length {
                carry += 58 * Int(base58[base58.count - j - 1])
                base58[base58.count - j - 1] = UInt8(carry % 256)
                carry /= 256
                i += 1
            }

            // Input is untrusted here, so an overflow is a malformed string rather than
            // a programming error: report it the same way an invalid character is.
            guard carry == 0 else { return [] }
            length = i
        }

        // skip leading zeros
        var zerosToRemove = 0

        for b in base58 {
            if b != 0 { break }
            zerosToRemove += 1
        }
        base58.removeFirst(zerosToRemove)

        var result: [UInt8] = Array(repeating: 0, count: zerosCount)
        for b in base58 {
            result.append(b)
        }
        return result
    }
}

extension Array where Element == UInt8 {
    /**
     - Returns: base58 encoded string from byte array
     */
    public var base58EncodedString: String {
        guard !isEmpty else { return "" }
        return Base58.base58FromBytes(self)
    }
    
    /**
     - Returns: base58 encoded string with checksum its hash at the end
     */
    public var base58CheckEncodedString: String {
        var bytes = self
        bytes.append(contentsOf: Array(Data(self).sha256().sha256()[0..<4]))

        return Base58.base58FromBytes(bytes)
    }
}

extension String {
    /**
     - Returns: base 58 encoded string of its utf8 representation
    */
    public var base58EncodedString: String {
        return [UInt8](utf8).base58EncodedString
    }

    /**
     - Returns: data converted from base58 string
     */
    public var base58DecodedData: Data? {
        let bytes = Base58.bytesFromBase58(self)
        return Data(bytes)
    }

    /**
     - Returns: data converted from base58 string encoded with hash
     */
    public var base58CheckDecodedData: Data? {
        guard let bytes = self.base58CheckDecodedBytes else { return nil }
        return Data(bytes)
    }

    
    /**
     - Returns: data converted from base58 string encoded with hash
     */
    public var base58CheckDecodedBytes: [UInt8]? {
        var bytes = Base58.bytesFromBase58(self)
        guard 4 <= bytes.count else { return nil }

        let checksum = [UInt8](bytes[bytes.count - 4 ..< bytes.count])
        bytes = [UInt8](bytes[0 ..< bytes.count - 4])

        let calculatedChecksum = Array(Data(bytes).sha256().sha256()[0..<4])
        if checksum != calculatedChecksum { return nil }

        return bytes
    }

//    public var littleEndianHexToUInt: UInt {
//        let data = Data.fromHex(self)!
//        let revensed =
//        return UInt(sel)
//        return UInt(self.dataWithHexString().bytes.reversed().fullHexString,radix: 16)!
//    }
}
