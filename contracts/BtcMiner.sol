
pragma solidity 0.6.11;

import "./dependencies/IERC20.sol";
import "./dependencies/SafeMath.sol";

contract BtcMiner is IERC20 {
    using SafeMath for uint256;

    // --- ERC20 Data ---

    string constant internal _NAME = "BtcMiner";
    string constant internal _SYMBOL = "btcm";
    string constant internal _VERSION = "1";
    uint8 constant internal  _DECIMALS = 18;
    uint internal _WEI = 1e18;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;
    uint private _totalSupply;

    // main logic

    uint256 constant internal _INITBLOCKHEIGH = 0;

    uint256 public nextBlockTime;
    uint256 public lastBlockTime;
    uint256 public heigh;

    mapping (address => uint256) private lastMinerBlockHeigh;
    mapping (address => uint256) private minersReward;
    uint256 public _preMintTimeStamp;

    constructor () public {
        heigh = _INITBLOCKHEIGH + 1;
        lastBlockTime = now;
        nextBlockTime = lastBlockTime + 1 days;

        _totalSupply = 1e6 * _WEI;
        _balances[address(this)] = _totalSupply;
    }

    // --- External functions ---
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external override returns (bool) {        
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external override returns (bool) {        
        _approve(msg.sender, spender, _allowances[msg.sender][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, _allowances[sender][msg.sender].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function minerRegister() public returns (bool) {
        require(lastMinerBlockHeigh[msg.sender] < 1, "you have registered");


        lastMinerBlockHeigh[msg.sender] = _INITBLOCKHEIGH;
        minersReward[msg.sender] = 0;
    }


    // main logic
    // get 50 Token / day

    function mine() external returns (bool) {

        require(lastMinerBlockHeigh[msg.sender] < heigh, "miner can only mint a block per day");

        minersReward[msg.sender] = minersReward[msg.sender] + 50 * _WEI;
        lastMinerBlockHeigh[msg.sender] = heigh;

        // add block
        // the last miner can get more reward (block reward)

        if (now >= nextBlockTime) {
            minersReward[msg.sender] = minersReward[msg.sender] + 50 * _WEI;

            heigh = heigh + 1;
            lastBlockTime = now;
            nextBlockTime = lastBlockTime + 1 days;
        }
        
        return true;
    }

    function claimReward() public {
        require(minersReward[msg.sender] > 0, "address get no reward.");
        
        uint256 _reward = minersReward[msg.sender];

        // change status
        minersReward[msg.sender] = 0;

        // transfer
        _transfer( address(this), msg.sender, _reward);
    }

    // internal function 

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    // --- Optional functions ---

    function name() external view override returns (string memory) {
        return _NAME;
    }

    function symbol() external view override returns (string memory) {
        return _SYMBOL;
    }

    function decimals() external view override returns (uint8) {
        return _DECIMALS;
    }
}

 
