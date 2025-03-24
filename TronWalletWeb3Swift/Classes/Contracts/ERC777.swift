
import Foundation
import BigInt

/**
 Native implementation of ERC777 token
 - Important: NOT main thread friendly
 */
public class ERC777 {
	/// Token address
	public let address: Address
	/// Transaction options
	public var options: Web3Options = .default
	/// Password to unlock private key for sender address
	public var password: String = "BANKEXFOUNDATION"
	/**
	* Gas price functions if you want to see that
	* Automatically calls if options.gasPrice == nil */
	public var gasPrice: GasPrice { return GasPrice(self) }
	
	/// Represents Address as ERC777 token (with standard password and options)
	/// - Parameter address: Token address
	public init(_ address: Address) {
		self.address = address
	}
	
	/// Represents Address as ERC777 token
	/// - Parameter address: Token address
	/// - Parameter from: Sender address
	/// - Parameter address: Password to decrypt sender's private key
	public init(_ address: Address, from: Address, password: String) {
		self.address = address
		self.password = password
		options.from = from
	}
    
    /// Returns token name / description
    public func name() throws -> String {
        return try address.call("name()", web3: Web3.default).wait().string()
    }
    
    /// Returns token symbol
    public func symbol() throws -> String {
        return try address.call("symbol()", web3: Web3.default).wait().string()
    }
    
    /// Returns token total supply
    public func totalSupply() throws -> BigUInt {
        return try address.call("totalSupply()", web3: Web3.default).wait().uint256()
    }
    
    /// Returns token decimals
    public func decimals() throws -> BigUInt {
        return try address.call("decimals()", web3: Web3.default).wait().uint256()
    }
    
    
    /// - Returns: User balance in wei
    public func balance(of user: Address) throws -> BigUInt {
        return try address.call("balanceOf(address)",user, web3: Web3.default).wait().uint256()
    }
    
    /**
     Shows how much balance you approved spender to get from your account.
     
     - Returns: Balance that one user can take from another user
     - Parameter owner: Balance holder
     - Parameter spender: Spender address
     
     Solidity interface:
     ``` solidity
     allowance(address,address)
     ```
     */
    public func allowance(from owner: Address, to spender: Address) throws -> BigUInt {
        let arguments = [owner, spender]
        let web3 = Web3.default
        return try address.call("allowance(address,address)", arguments, web3: web3).wait().uint256()
    }
    
    /**
     Transfers to user amount of balance
     
     - Important: Transaction | Requires password
     - Returns: TransactionSendingResult
     - Parameter user: Recipient address
     - Parameter amount: Amount in wei to send. If you want to send 1 token (not 0.00000000001) use NaturalUnits(amount) instead
     
     Solidity interface:
     ``` solidity
     transfer(address,uint256)
     ```
     */
    public func transfer(to user: Address, amount: BigUInt) throws -> TransactionSendingResult {
        let arguments = [user, amount] as [Any]
        let web3 = Web3.default
        return try address.send("transfer(address,uint256)", arguments, password: password, web3: web3, options: options).wait()
    }
    
    /**
     Approves user to take \(amount) tokens from your account.
     
     - Important: Transaction | Requires password
     - Returns: TransactionSendingResult
     - Parameter user: Recipient address
     - Parameter amount: Amount in wei to send. If you want to send 1 token (not 0.00000000001) use NaturalUnits(amount) instead
     
     Solidity interface:
     ``` solidity
     approve(address,uint256)
     ```
     */
    public func approve(to user: Address, amount: BigUInt) throws -> TransactionSendingResult {
        let arguments = [user, amount] as [Any]
        let web3 = Web3.default
        return try address.send("approve(address,uint256)", arguments, password: password, web3: web3, options: options).wait()
    }
    
    /**
     Transfers from user1 to user2.
     
     - Important: Transaction | Requires password | Contract owner only.
     ERC777(address, from: me).transfer(to: user, amount: NaturalUnits(0.1)) is not the same as
     ERC777(address).transferFrom(owner: me, to: user, amount: NaturalUnits(0.1))
     - Returns: TransactionSendingResult
     - Parameter user: Recipient address
     - Parameter amount: Amount in wei to send. If you want to send 1 token (not 0.00000000001) use NaturalUnits(amount) instead
     
     Solidity interface:
     ``` solidity
     transferFrom(address,address,uint256)
     ```
     */
    public func transfer(from: Address, to: Address, amount: BigUInt) throws -> TransactionSendingResult {
        let arguments = [from, to, amount] as [Any]
        let web3 = Web3.default
        return try address.send("transferFrom(address,address,uint256)", arguments, password: password, web3: web3, options: options).wait()
    }
    
    /**
     Sends to user some amount of tokens
     
     - Important: Transaction | Requires password
     - Parameter user: Recipient address
     - Parameter amount: Amount in wei to send
     
     Solidity interface:
     ``` solidity
     send(address,uint256)
     ```
     */
    public func send(to user: Address, amount: BigUInt) throws -> TransactionSendingResult {
        let arguments = [user, amount] as [Any]
        let web3 = Web3.default
        return try address.send("send(address,uint256)", arguments, password: password, web3: web3, options: options).wait()
    }
    /**
     Sends to user some amount of tokens and call some function
     
     - Important: Transaction | Requires password
     - Parameter user: Recipient address
     - Parameter amount: Amount in wei to send
     - Parameter userData: Encoded function that contract calls
     
     Solidity interface:
     ``` solidity
     send(address,uint256,bytes)
     ```
     */
    public func send(to user: Address, amount: BigUInt, userData: Data) throws -> TransactionSendingResult {
        let arguments = [user, amount, userData] as [Any]
        let web3 = Web3.default
        return try address.send("send(address,uint256,bytes)", arguments, password: password, web3: web3, options: options).wait()
    }
    
    /**
     Authorize user to manager your tokens
     
     - Important: Transaction | Requires password
     - Parameter user: Operator address
     
     Solidity interface:
     ``` solidity
     authorizeOperator(address)
     ```
     */
    public func authorize(operator user: Address) throws -> TransactionSendingResult {
        return try address.send("authorizeOperator(address)",user, password: password, web3: Web3.default, options: options).wait()
    }
    /**
     Revokes operator
     
     - Important: Transaction | Requires password
     - Parameter user: Operator address
     
     Solidity interface:
     ``` solidity
     revokeOperator(address)
     ```
     */
    public func revoke(operator user: Address) throws -> TransactionSendingResult {
        return try address.send("revokeOperator(address)",user, password: password, web3: Web3.default, options: options).wait()
    }
    
    /**
     Returns true if user is operator of tokenHolder
     
     - Important: Transaction | Requires password
     - Parameter user: Operator
     - Parameter tokenHolder: Token holder
     
     Solidity interface:
     ``` solidity
     isOperatorFor(address,address)
     ```
     */
    public func isOperatorFor(operator user: Address, tokenHolder: Address) throws -> Bool {
        let arguments = [user, tokenHolder]
        let web3 = Web3.default
        return try address.call("isOperatorFor(address,address)", arguments, web3: web3).wait().bool()
    }
    
    /**
     Sends from one user to another some amount of tokens and call some function
     
     - Important: Transaction | Requires password
     - Parameter from: Token holder address
     - Parameter to: Recipient address
     - Parameter amount: Amount in wei to send
     - Parameter userData: Encoded function that contract calls
     
     Solidity interface:
     ``` solidity
     operatorSend(address,address,uint256,bytes)
     ```
     */
    public func operatorSend(from: Address, to: Address, amount: BigUInt, userData: Data) throws -> TransactionSendingResult {
        let arguments = [from, to, amount, userData] as [Any]
        let web3 = Web3.default
        return try address.send("operatorSend(address,address,uint256,bytes)", arguments, password: password, web3: web3, options: options).wait()
    }
	
	/**
	Gas price functions for erc721 token requests
	*/
	public struct GasPrice {
		let parent: ERC777
		var address: Address { return parent.address }
		var options: Web3Options { return parent.options }
		
		/**
		Native implementation of ERC777 token
		- Important: NOT main thread friendly
		- Returns: full information for all pending and queued transactions
		*/
		init(_ parent: ERC777) {
			self.parent = parent
		}
		
		/// - Returns: gas price for transfer(address,uint256) transaction
        public func transfer(to user: Address, amount: BigUInt) throws -> BigUInt {
            let arguments = [user, amount] as [Any]
            let web3 = Web3.default
            return try address.estimateGas("transfer(address,uint256)", arguments, web3: web3, options: options).wait()
        }
		/// - Returns: gas price for approve(address,uint256) transaction
        public func approve(to user: Address, amount: BigUInt) throws -> BigUInt {
            let arguments = [user, amount] as [Any]
            let web3 = Web3.default
            return try address.estimateGas("approve(address,uint256)", arguments, web3: web3, options: options).wait()
        }
		/// - Returns: gas price for transferFrom(address,address,uint256) transaction
        public func transfer(from: Address, to: Address, amount: BigUInt) throws -> BigUInt {
            let arguments = [from, to, amount] as [Any]
            let web3 = Web3.default
            return try address.estimateGas("transferFrom(address,address,uint256)", arguments, web3: web3, options: options).wait()
        }
		
		/// - Returns: gas price for send(address,uint256) transaction
        public func send(to user: Address, amount: BigUInt) throws -> BigUInt {
            let arguments = [user, amount] as [Any]
            let web3 = Web3.default
            return try address.estimateGas("send(address,uint256)", arguments, web3: web3, options: options).wait()
        }
		/// - Returns: gas price for send(address,uint256,bytes) transaction
        public func send(to user: Address, amount: BigUInt, userData: Data) throws -> BigUInt {
            let arguments = [user, amount, userData] as [Any]
            let web3 = Web3.default
            return try address.estimateGas("send(address,uint256,bytes)", arguments, web3: web3, options: options).wait()
        }
		
		/// - Returns: gas price for authorizeOperator(address) transaction
		public func authorize(operator user: Address) throws -> BigUInt {
            return try address.estimateGas("authorizeOperator(address)",user, web3: Web3.default, options: options).wait()
		}
		/// - Returns: gas price for revokeOperator(address) transaction
		public func revoke(operator user: Address) throws -> BigUInt {
            return try address.estimateGas("revokeOperator(address)",user, web3: Web3.default, options: options).wait()
		}
		
		/// - Returns: gas price for operatorSend(address,address,uint256,bytes) transaction
        public func operatorSend(from: Address, to: Address, amount: BigUInt, userData: Data) throws -> BigUInt {
            let arguments = [from, to, amount, userData] as [Any]
            let web3 = Web3.default
            return try address.estimateGas("operatorSend(address,address,uint256,bytes)", arguments, web3: web3, options: options).wait()
        }
	}
}
