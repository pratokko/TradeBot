// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

error TradingBot__Stop();
error TradingBot__InvalidSellPrice();
error TradingBot__InvalidBuyPrice();
error TradeBot__NotOwner();

contract TradingBot {
    address public tokenAddress;
    uint256 public buyPrice;
    uint256 public sellPrice;
    address public owner;
    mapping(string => Token) public tokens;


    struct Token {
        address tokenAddress;
        uint256 buyPrice;
        uint256 sellPrice;
        uint256 lastUpdated;
    }

    constructor(address _tokenAddress, uint256 _buyPrice, uint256 _sellPrice) {
        if (_buyPrice <= 0) {
            revert TradingBot__InvalidBuyPrice();
        }
        if (_sellPrice <= 0) {
            revert TradingBot__InvalidSellPrice();
        }
        owner = msg.sender;
        tokenAddress = _tokenAddress;
        buyPrice = _buyPrice;
        sellPrice = _sellPrice;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert TradeBot__NotOwner();
        }
        _;
    }

    function setBuyPrice(uint256 _newBuyPrice) external onlyOwner {
        if (_newBuyPrice <= 0) {
            revert TradingBot__InvalidBuyPrice();
        }
        buyPrice = _newBuyPrice;
    }

    function setSellPrice(uint256 _newSellPrice) external onlyOwner {
        if (_newSellPrice <= 0) {
            revert TradingBot__InvalidSellPrice();
        }
        sellPrice = _newSellPrice;
    }

    function buyToken() external payable {
        if (msg.value >= buyPrice) {
            revert TradingBot__Stop();
        }
        IERC20 token = IERC20(tokenAddress);
        uint256 amount = msg.value / buyPrice;
        token.transfer(msg.sender, amount);
    }

    function sellToken(uint256 _amount) external {
        IERC20 token = IERC20(tokenAddress);
        require(
            token.transferFrom(msg.sender, address(this), _amount),
            "Transfer failed"
        );
        uint256 ethAmount = _amount * sellPrice;
        payable(msg.sender).transfer(ethAmount);
    }
}
