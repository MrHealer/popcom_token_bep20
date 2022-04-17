// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

contract Ownable {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    modifier onlyOwner() {
        require(
            _owner == msg.sender,
            "Ownable: only owner can call this function"
        );
        // This _; is not a TYPO, It is important for the compiler;
        _;
    }

    constructor() {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract PropComToken is Ownable {
    uint256 private _totalSupply;
    uint8 private _decimals;
    string private _symbol;
    string private _name;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    constructor(
        string memory token_name,
        string memory short_symbol,
        uint8 token_decimal,
        uint256 token_totalSupply
    ) {
        _name = token_name;
        _symbol = short_symbol;
        _decimals = token_decimal;
        _totalSupply = token_totalSupply;

        _balances[msg.sender] = _totalSupply;

        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function decials() external view returns (uint8) {
        return _decimals;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount)
        external
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        require(
            sender != address(0),
            "PropComToken: transfer from zero address"
        );
        require(
            recipient != address(0),
            "PropComToken: transfer to zero address"
        );
        require(
            _balances[sender] >= amount,
            "PropComToken: cant transfer more than your account holds"
        );

        _balances[sender] = _balances[sender] - amount;
        _balances[recipient] = _balances[recipient] + amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal {
        require(
            account != address(0),
            "PropComToken: cannot mint to zero address"
        );

        // Increase total supply
        _totalSupply = _totalSupply + (amount);
        // Add amount to the account balance using the balance mapping
        _balances[account] = _balances[account] + amount;
        // Emit our event to log the action
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal {
        require(
            account != address(0),
            "IhouzzToken: cannot burn from zero address"
        );
        require(
            _balances[account] >= amount,
            "IhouzzToken: Cannot burn more than the account owns"
        );

        // Remove the amount from the account balance
        _balances[account] = _balances[account] - amount;
        // Decrease totalSupply
        _totalSupply = _totalSupply - amount;
        // Emit event, use zero address as reciever
        emit Transfer(account, address(0), amount);
    }

    function burn(address account, uint256 amount)
        public
        onlyOwner
        returns (bool)
    {
        _burn(account, amount);
        return true;
    }

    function mint(address account, uint256 amount)
        public
        onlyOwner
        returns (bool)
    {
        _mint(account, amount);
        return true;
    }

    function getOwner() external view returns (address) {
        return owner();
    }

    function allowance(address owner, address spender)
        external
        view
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(
            owner != address(0),
            "PropComToken: approve cannot be done from zero address"
        );
        require(
            spender != address(0),
            "PropComToken: approve cannot be to zero address"
        );
        _allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);
    }

    function transferFrom(
        address spender,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        // Make sure spender is allowed the amount
        require(
            _allowances[spender][msg.sender] >= amount,
            "PropComToken: You cannot spend that much on this account"
        );
        // Transfer first
        _transfer(spender, recipient, amount);
        // Reduce current allowance so a user cannot respend
        _approve(
            spender,
            msg.sender,
            _allowances[spender][msg.sender] - amount
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 amount)
        public
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender] + amount
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 amount)
        public
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender] - amount
        );
        return true;
    }
}
