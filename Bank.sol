pragma solidity >=0.4.0 <0.6.0;

contract Bank {
    address owner;
    mapping (address => uint) balances;
    mapping (address => uint) public status;// 0: account does not exist, 1: not protected, 2: password protected
    mapping (address => string) password;
    string str;
    modifier onlyOwner {
        require( 
            msg.sender == owner,
            "Only owner can invoke this function."
        );
        _;
    }
    
    modifier haveAccount {
        require(
            status[msg.sender] != 0,
            "You must have an account before you can invoke this function. "
        );
        _;
    }
    
    event LogDepositMade(address indexed accountAddress, uint amount);
    
    constructor() public {
        owner = msg.sender;
    }
    
    function checkOwner() public view returns (address){
        return owner;
    }
    
    function changeOwnership(address _newOwner) public onlyOwner{
        owner = _newOwner;
    }
    
    function openAccount(bool _protect, string memory _password) public returns (string memory){
        require(status[msg.sender] == 0, "Opening account failed, you already have an account. ");
        if (_protect){
            status[msg.sender] = 2;
            password[msg.sender] = _password;
        }else{
            status[msg.sender] = 1;
        }
        return "Opening account successful. ";
    }
    
    function closeAccount(string memory _password) public haveAccount returns(string memory){
        if (status[msg.sender] == 2){
            require(uint(keccak256(abi.encodePacked(password[msg.sender]))) == uint(keccak256(abi.encodePacked(_password))), "Password does not match");
        }
        msg.sender.transfer(balances[msg.sender]);
        balances[msg.sender] = 0;
        status[msg.sender] = 0;
        password[msg.sender] = "";
        return "Account closed, your remaining balance has been transfered to your wallet. ";
    }
    
    function depositAccount() public haveAccount payable returns (string memory){
        balances[msg.sender] += msg.value;
        emit LogDepositMade(msg.sender, msg.value);
        return "Deposit successful. ";
    }
    
    function withdrawAccount(uint _amount) public haveAccount returns (string memory){
        require(_amount <= balances[msg.sender], "Withdraw amount exceeds balance. ");
        balances[msg.sender] -= _amount;
        msg.sender.transfer(_amount);
        return "Withdraw successful. ";
    }
    
    function withdrawAccountBalance() public haveAccount returns (string memory){
        msg.sender.transfer(balances[msg.sender]);
        balances[msg.sender] = 0;
        status[msg.sender] = 0;
        password[msg.sender] = "";
        return "Your remaining balance has been transfered to your wallet. ";
    }
    
    function checkAccountBalance() public haveAccount view returns (uint){
        return balances[msg.sender];
    }
    
    function transfer(address _to, uint _amount) public haveAccount returns (string memory){
        require(status[_to] != 0, "Destination account does not exist. ");
        require(balances[msg.sender] >= _amount, "Transfer amount exceeds balance. ");
        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
        return "Transfer is successful. ";
    }
    
    function depositContract() public payable returns (string memory){
        return "Deposit made directly to this contract is successful. ";
    }
    
    function withdrawContract(uint _amount) public onlyOwner returns (string memory){
        require(address(this).balance >= _amount, "Withdraw amount exceeds balance. ");
        msg.sender.transfer(_amount);
        return "Withdraw made directly to this contract is successful. ";
    }
    
    function withdrawContractBalance() public onlyOwner returns (string memory){
        msg.sender.transfer(address(this).balance);
        return "Balance withdraw made directly to this contract is successful. ";
    }
    
    function checkContractBalance() public onlyOwner view returns (uint){
        return address(this).balance;
    }
    
    function returnInput(string memory _value) public returns(string memory output){
        str = _value;
        return str;
    }
    
}
