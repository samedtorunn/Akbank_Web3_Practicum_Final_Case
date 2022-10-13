// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

contract Lottery {
    address public manager; // a manager address is defined
    address payable[] public players; // a dynamic array of players is defined here.

    mapping (address => int256) profits; // this mapping measures total profits or losses that an account has

    constructor() { // this is our constructor function
        manager = msg.sender; // constructor is the manager here.
    }

    function enter() public payable { // people can enter a lottery via this function.
        require(msg.value > .001 ether); // minimum limit to join the lottery is .001 ether. we could've defined a
        // standard amount here, but it would be harder for us to see the changes in the wallet. in real life, standard is better.

        players.push(payable(msg.sender)); // we add the person who enters the lottery to our players array

        profits[msg.sender] = profits[msg.sender] - int(msg.value); // we keep track of his/her profit or loss value.
    }

    function random() private view returns (uint) { // this function will pick the winner.
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players))); // this is a pseudorandom number generator. you cannot count on this.
    }

    function pickWinner() public restricted { // we pick winner with this function.
        uint index = random() % players.length; // a random index is defined.

        profits[players[index]] = profits[players[index]] + int(address(this).balance);  // profit is defined to winner's account.

        players[index].transfer(address(this).balance); // balance is transferred to the winner account.

        players = new address payable[](0);    // players are reset to be able to start the lottery from zero.

    }

    modifier restricted() { // this modifier is created to add on functions which can only be called by manager.
        require(msg.sender == manager);
        _;
    }

    function getPlayers() public view returns (address payable[] memory) { // shows the players at that moment.
        return players;
    }

    function profitLoss(address _theAddress) public view returns (int256) { // profit-loss sum can be tracked with this function.

        return profits[_theAddress];

    }
}
