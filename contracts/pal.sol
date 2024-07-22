// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract PayWeb3 {

    struct Request {
        string name;
        address from;
        uint256 amount;
        string message;
    }

    struct Txn {
        string action;
        string anotherName;
        address anotherWallet;
        uint256 pay;
        string message;
    }

    struct WalletName {
        string name;
        bool hasName;
    }

    mapping(address => WalletName) public addressToWalletName;
    mapping(address => Request[]) public addressRequests;
    mapping(address => Txn[]) public addressTxns;

    address public admin;

    constructor() {
        admin = msg.sender;
    }

    modifier hasNoName() {
        require(!addressToWalletName[msg.sender].hasName, "Your wallet already has a name!");
        _;
    }

    function addWalletName(string memory _walletName) public hasNoName {
        addressToWalletName[msg.sender] = WalletName(_walletName, true);
    }

    function createRequest(address _to, uint256 _amount, string memory _msg) public {
        require(_amount > 0, "Amount should be greater than 0 ETH");
        string memory fromWalletName = addressToWalletName[msg.sender].hasName ? addressToWalletName[msg.sender].name : "";
        addressRequests[_to].push(Request(fromWalletName, msg.sender, _amount, _msg));
    }

    function requestPay(uint256 _requestId) public payable {
        require(addressRequests[msg.sender].length > 0, "No request is there");
        require(_requestId < addressRequests[msg.sender].length, "Invalid request ID");

        Request memory requestToFulfill = addressRequests[msg.sender][_requestId];
        bool isDone = createPay(requestToFulfill.from, requestToFulfill.amount, requestToFulfill.message);
        require(isDone, "Request failed!");

        // Remove the fulfilled request
        addressRequests[msg.sender][_requestId] = addressRequests[msg.sender][addressRequests[msg.sender].length - 1];
        addressRequests[msg.sender].pop();
    }

    function createPay(address _to, uint256 _amount, string memory _msg) public payable returns(bool) {
        require(msg.value == _amount, "Sent amount does not match the requested amount");
        require(_amount > 0, "Amount should be greater than 0 ETH");

        string memory fromWalletName = addressToWalletName[msg.sender].hasName ? addressToWalletName[msg.sender].name : "";
        string memory toWalletName = addressToWalletName[_to].hasName ? addressToWalletName[_to].name : "";

        (bool isDone, ) = payable(_to).call{value: _amount}("");
        require(isDone, "Transaction failed");

        addressTxns[msg.sender].push(Txn("outgoing", toWalletName, _to, _amount, _msg));
        addressTxns[_to].push(Txn("incoming", fromWalletName, msg.sender, _amount, _msg));
        return true;
    }

    function getAllRequests() public view returns(Request[] memory) {
        return addressRequests[msg.sender];
    }

    function getAllTxns() public view returns(Txn[] memory) {
        return addressTxns[msg.sender];
    }

    receive() external payable {}
}
