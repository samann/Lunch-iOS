import Foundation

public protocol GSRegularExpressionMatchable {
    func match(regex: Regex) -> Bool
    func match(regex: NSRegularExpression) -> Bool
}

public class Regex: StringLiteralConvertible {
    let regex: NSRegularExpression?

    private class func initialize(pattern: String) -> NSRegularExpression? {
        var error: NSError?
        if let expression = NSRegularExpression(pattern: pattern, options: .allZeros, error: &error) {
            return expression
        } else {
            println("HEY!  Invalid regex \(pattern) passed in: \(error)")
            return nil
        }
    }

    func match(string: String) -> Bool {
        if let r = regex {
            let num = r.numberOfMatchesInString(string, options: .allZeros, range: NSMakeRange(0, count(string)))

            return num != 0
        } else {
            return false
        }
    }

    // MARK: - Conversions -

    public typealias ExtendedGraphemeClusterLiteralType = ExtendedGraphemeClusterType
    required public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        regex = Regex.initialize(value)
    }

    public typealias UnicodeScalarLiteralType = UnicodeScalarType
    required public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        regex = Regex.initialize(value)
    }

    public required init(stringLiteral value: StringLiteralType) {
        regex = Regex.initialize(value)
    }

    func match(expression: NSRegularExpression) -> Bool {
        return true
    }
}

infix operator =~ { associativity left precedence 130 }
public func =~<T: GSRegularExpressionMatchable> (left: T, right: NSRegularExpression) -> Bool {
    return left.match(right)
}
public func =~<T: GSRegularExpressionMatchable> (left: T, right: Regex) -> Bool {
    return left.match(right)
}


extension String: GSRegularExpressionMatchable {
    public func match(regex: Regex) -> Bool {
        return regex.match(self)
    }

    public func match(regex: NSRegularExpression) -> Bool {
        return regex.numberOfMatchesInString(self, options: .allZeros, range: NSMakeRange(0, count(self))) != 0
    }
}
