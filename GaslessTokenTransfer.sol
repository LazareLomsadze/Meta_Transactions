// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.
abstract contract ERC20 {
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    string public name;
    string public symbol;
    uint8 public immutable decimals;
    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    uint256 internal immutable INITIAL_CHAIN_ID;
    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;

    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.
        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

        _transfer(from, to, amount);
        return true;
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        bytes32 structHash = keccak256(
            abi.encode(
                keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
                owner,
                spender,
                value,
                nonces[owner]++,
                deadline
            )
        );

        bytes32 digest = keccak256(
            abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR(), structHash)
        );

        address recoveredAddress = ecrecover(digest, v, r, s);
        require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");

        allowance[recoveredAddress][spender] = value;
        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(name)),
                keccak256("1"),
                block.chainid,
                address(this)
            )
        );
    }

    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;
        balanceOf[to] += amount;
        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;
        totalSupply -= amount;
        emit Transfer(from, address(0), amount);
    }

    function _transfer(address from, address to, uint256 amount) internal virtual {
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
    }
}

contract ERC20Permit is ERC20 {
    constructor(string memory _name, string memory _symbol, uint8 _decimals) 
        ERC20(_name, _symbol, _decimals) {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) public {
        _burn(from, amount);
    }
}















// The contract is designed to create a type of cryptocurrency,
//  following rules set by the ERC20 standard,
//   which is a common standard for creating tokens on the Ethereum blockchain. 
//   Additionally, it includes features from EIP-2612, which allows users to approve transactions in a more efficient way.

// Here are the main components of the contract:

// Contract Declaration:

// abstract contract ERC20 - This is the main part of your contract.
//  It's marked as abstract because it contains some functions that aren't fully defined and need to be implemented in a derived contract.

// Events: event Transfer and event Approval - These are notifications that the contract emits when tokens are transferred or when one account approves another to spend tokens on its behalf.

// State Variables: These are variables that store the state of the contract. Examples include name, symbol, decimals, totalSupply, balanceOf, and allowance.
// These variables keep track of the token's basic information, how many tokens exist, and how many tokens each account holds.

// Constructor: The constructor is a special function that is run when the contract is first created.
// It sets up the initial state of the contract, like the token's name, symbol, and decimals.

// Functions: The contract includes several functions:

// approve, transfer, transferFrom: These are standard functions for ERC20 tokens that allow users to transfer tokens and approve others to transfer tokens on their behalf.
// permit: This is a function introduced by EIP-2612. It allows users to approve a spender using a signed message instead of a transaction, which can save on transaction fees.
// DOMAIN_SEPARATOR, computeDomainSeparator: These functions are part of the EIP-2612 standard, helping to securely implement the permit function.
// ERC20Permit: This is a derived contract that extends the ERC20 contract. It includes additional functionality, like mint (to create new tokens) and burn (to destroy tokens).

// In summary, this contract is designed to create a type of digital currency (token)
//  with some standard features like transferring tokens, checking balances,
//   and approving others to spend tokens. It also includes advanced features
//    for approving transactions more efficiently. This kind of contract is
//     typically used in decentralized finance (DeFi) applications on the Ethereum blockchain.



        // !!!!!!
// For real bussiness useCase : 
// Imagine you have a dApp where users can stake your ERC20 tokens to earn rewards.
// Normally, a user would first approve the staking contract to use their tokens
// (costing gas) and then stake the tokens (costing more gas). With EIP-2612's permit,
// these two steps can be combined, reducing the gas cost for the user.
