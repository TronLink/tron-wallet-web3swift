import Foundation

/// A contract wrapper that needs the sender's keystore password before it can sign.
///
/// The password used to be a stored property carrying a hardcoded default, which meant a
/// caller that never set one still produced a signable transaction — protected by a string
/// published in this repository. It is now optional and starts out `nil`: read-only calls
/// (`balanceOf`, `decimals`, …) never needed it, and anything that signs must ask for it
/// explicitly via `requirePassword()` so a missing password fails loudly instead of falling
/// back to a known value.
protocol PasswordProtected {
    /// Password unlocking the sender's private key. `nil` until the caller supplies one.
    var password: String? { get }
}

extension PasswordProtected {
    /// Returns the password, or throws if the caller never supplied one.
    func requirePassword() throws -> String {
        guard let password = password, !password.isEmpty else {
            throw Web3Error.inputError("A password is required to sign this transaction. Set `password`, or use the initializer that takes one.")
        }
        return password
    }
}
