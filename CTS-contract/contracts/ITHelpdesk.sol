//SPDX-License-Identifier: UNLICENSED

//Name 1: Joshua Wajnryb
//UBIT 1: jwajnryb
//Person Number 1: 50366137

//Name 2: Naglis Paunksnis
//UBIT 2: naglispa
//Person Number 2: 50306281

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/*
interface ERC721 {

   event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);
   event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);
   event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

   function balanceOf(address _owner) external view returns (uint256);
   function ownerOf(uint256 _tokenId) external view returns (address);

   function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) external payable;
   function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
   function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

   function approve(address _approved, uint256 _tokenId) external payable;
   function setApprovalForAll(address _operator, bool _approved) external;
   function getApproved(uint256 _tokenId) external view returns (address);
   function isApprovedForAll(address _owner, address _operator) external view returns (bool);

}

interface ERC721Metadata {

    function name() external view returns (string memory _name);
    function symbol() external view returns (string memory _symbol);
    function tokenURI(uint256 _tokenId) external view returns (string memory);

}
*/

pragma solidity ^0.8.0;

contract ITHelpdesk is ERC721("CryptoTechSupport", "CTS") {

    enum DeviceType {Laptop, Desktop, Mobile}
    enum TicketStatus {Open, InProgress, Resolved}
    enum Difficulty {Easy, Medium, Hard}

    struct Ticket {
        uint256 id;
        address user;
        string title;
        string issue;
        string description;
        bool resolved;
        Difficulty difficulty;
        DeviceType deviceType;
        string solution;
        string[] notes;
    }

    uint256 public ticketCount;
    mapping(uint256 => Ticket) public tickets;

    address payable public contractOwner;

    constructor() {
        contractOwner = payable(msg.sender);
    }

    event TicketCreated(uint256 indexed ticketId, string title, string issue, string description, uint8 difficulty, uint8 deviceType);

    function createTicket(string memory _title, string memory _issue, string memory _description, uint8 _difficulty, uint8 _deviceType) public payable returns (uint256) {
        uint256 paymentAmount = 10**16; // 0.01 ETH

        Ticket memory newTicket = Ticket(ticketCount, msg.sender, _title, _issue, _description, false, Difficulty(_difficulty), DeviceType(_deviceType), "", new string[](0));
        tickets[ticketCount] = newTicket;
        ticketCount++;

        // Transfer payment to contract owner
        contractOwner.transfer(paymentAmount);

        uint256 newTicketId = ticketCount - 1;

        emit TicketCreated(newTicketId, _title, _issue, _description, _difficulty, _deviceType);
        return newTicketId;
    }

    function updateTicket(uint256 _ticketId, string memory _title, string memory _issue, string memory _description, Difficulty _difficulty, DeviceType _deviceType) public {
        require(tickets[_ticketId].user == msg.sender, "Only ticket creator can update ticket");
        tickets[_ticketId].title = _title;
        tickets[_ticketId].issue = _issue;
        tickets[_ticketId].description = _description;
        tickets[_ticketId].difficulty = _difficulty;
        tickets[_ticketId].deviceType = _deviceType;
    }

    function changeStatus(uint256 _ticketId, bool _resolved) public {
        require(msg.sender == contractOwner, "Only contract owner can change ticket status");
        require(_ticketId < ticketCount, "Invalid ticket ID");
        tickets[_ticketId].resolved = _resolved;
    }

    function ticketSolution(uint256 _ticketId, string memory _solution) public {
        require(tickets[_ticketId].resolved, "Ticket must be resolved to submit a solution");
        require(tickets[_ticketId].user == msg.sender, "Only ticket creator can submit a solution");
        tickets[_ticketId].solution = _solution;
    }

    function ticketNotes(uint256 _ticketId, string memory _note) public {
        tickets[_ticketId].notes.push(_note);
    }

    function resolveTicket(uint256 _ticketId) public {
        require(tickets[_ticketId].user == msg.sender, "Only ticket creator can resolve ticket");
        require(!tickets[_ticketId].resolved, "Ticket already resolved");
        tickets[_ticketId].resolved = true;
        payable(msg.sender).transfer(1 ether);
    }

    function getTicketStatus(uint256 _ticketId) public view returns (bool) {
        return tickets[_ticketId].resolved;
    }

    function getTicketDifficulty(uint256 _ticketId) public view returns (Difficulty) {
        return tickets[_ticketId].difficulty;
    }

    function getNumberOfTickets() public view returns (uint256) {
        return ticketCount;
    }
}