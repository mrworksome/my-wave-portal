// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {
    uint256 totalWaves;
    mapping(address => uint256) wavesUser;
    mapping(address => uint256) public lastWavedAt;
    uint256 private seed;

    event NewWave(
        address indexed from,
        uint256 timestamp,
        string message,
        bool winner
    );

    struct Wave {
        address waver;
        string message;
        uint256 timestamp;
        bool winner;
    }

    Wave[] waves;



    constructor() payable {
      console.log("We have been constructed!");

    }

    function wave(string memory _message) public {
        require(lastWavedAt[msg.sender] + 30 seconds < block.timestamp, "Must wait 30 seconds before waving again.");

        lastWavedAt[msg.sender] = block.timestamp;
        totalWaves += 1;
        wavesUser[msg.sender] += 1;
        console.log("%s has waved!", msg.sender);


        uint256 randomNumber = (block.difficulty + block.timestamp + seed) %
            100;
        console.log("Random # generated: %s", randomNumber);

        seed = randomNumber;

        /*
         * Give a 50% chance that the user wins the prize.
         */
        if (randomNumber <= 50) {
            console.log("%s won!", msg.sender);

            /*
             * The same code we had before to send the prize.
             */
            uint256 prizeAmount = 0.0001 ether;
            require(
                prizeAmount <= address(this).balance,
                "Trying to withdraw more money than the contract has."
            );
            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to withdraw money from contract.");
        }
        bool isWinner = randomNumber < 50;

        waves.push(Wave(msg.sender, _message, block.timestamp,  isWinner));

        emit NewWave(msg.sender, block.timestamp ,_message,  isWinner);
    }

    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getTotalWaves() public view returns (uint256) {
        console.log("We have %d total waves!", totalWaves);
        return totalWaves;
    }
    function getUserWaves() public view returns (uint256) {
        return wavesUser[msg.sender];
    }
}
