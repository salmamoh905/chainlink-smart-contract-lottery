// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

 /**
     *  @title A sample Raffle Contract
     * @author Salma Mohamed
     * @notice Tis contract is for creating raffle contract
     * @dev Implements chainlink VRFv2.5
     */

  import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
  import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";

   

contract Raffle is VRFConsumerBaseV2Plus{
    error SendMoreToEnterRaffle();

    //state variable - chainlink subscription variables
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint16 private constant REQUEST_CONFIRMATION = 3;
    uint32 private immutable i_callbackGasLimit;
    uint32 private constant NUM_WORDS =1;

    //lottery variables
    uint256 private immutable i_entraceFee;
    address payable [] private s_players;
    uint256 private immutable i_interval;
    uint256 private s_lastime;
    address immutable i_vrfCoordinator;

    /*Events*/ 
    event RaffleEntered(address indexed player);

    //inheriting the theVRFCorinator an aing the arguments()

    constructor (uint256 entraceFee, uint256 interval, uint256 lastime, address vrfCordinator, bytes32 gasLane, uint64 subscriptionId, uint32 callbackGasLimit )VRFConsumerBaseV2Plus(vrfCordinator){
        i_entraceFee = entraceFee;
        i_interval = interval;
        s_lastime = lastime;
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
    }
   //Function to enter the Raffle
   //Function to pick Winner
   
   function enterRaffle () public payable{
        if(msg.value < i_entraceFee){
            revert SendMoreToEnterRaffle();
        }
        s_players.push(payable (msg.sender));
        //reasons for Events
        //1. Making migration easier
        //2. Makes frontend "indexing" easier
        emit RaffleEntered((msg.sender));
       

   }
    //1. Get a random number
    //2. Use random number to pick a player
    //3. Be automatically called
    function pickWinner () public {
        //check to see if enough time has passed
        if((block.timestamp -s_lastime)< i_interval){
            revert();
        }
         uint256 requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: i_gasLane,
                subId: i_subscriptionId,
                requestConfirmations: REQUEST_CONFIRMATION,
                callbackGasLimit: i_callbackGasLimit,
                numWords: NUM_WORDS,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    // Set nativePayment to true to pay for VRF requests with Sepolia ETH instead of LINK
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            })
        );
        //Get a random number == hard because this is a deterministic chain
   }
   function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) internal override {}
  /**
   * Getter Functions
   */
  function getEntranceFee() public view returns(uint256){
    return i_entraceFee;
  }
}
