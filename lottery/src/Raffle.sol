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
    error Raffle_TransferFailed();
    error Raffle_RaffleNotOpen();

    enum RaffleState{
        OPEN,
        CALCULATING
    }
    RaffleState private s_raffleState;

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
    address payable private s_recentWinner;

    /*Events*/ 
    event RaffleEntered(address indexed player);
    event PickedWinner(address winner);

    //inheriting the theVRFCorinator an aing the arguments()

    constructor (uint256 entraceFee, uint256 interval, uint256 lastime, address vrfCordinator, bytes32 gasLane, uint64 subscriptionId, uint32 callbackGasLimit )VRFConsumerBaseV2Plus(vrfCordinator){
        i_entraceFee = entraceFee;
        i_interval = interval;
        s_lastime = lastime;
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        s_raffleState = RaffleState.OPEN;
    }
   //Function to enter the Raffle
   //Function to pick Winner
   
   function enterRaffle () public payable{
        if(msg.value < i_entraceFee)revert SendMoreToEnterRaffle();
        if (s_raffleState != RaffleState.OPEN) revert Raffle_RaffleNotOpen();
        s_players.push(payable (msg.sender));
        //reasons for Events
        //1. Making migration easier
        //2. Makes frontend "indexing" easier
        emit RaffleEntered((msg.sender));
       

   }
    /// @title A title that should describe the contract/interface
    /// @author The name of the author
    /// @notice Explain to an end user what this does
    /// @dev This is the function that the chainlink keeper nodes calls
    //They look for 'upkeepNeeded' to return True.abi
    
    //the following should be true for the return True
    //1. The time interval has passed between raffle runs
    //2. The lottery is open
    //3. The contract has Eth
    //4.There are players registered.
    //5. Implicity, your subscription is funded withLINK

    function checkUpKeep(bytes memory /*checkdata*/) public view returns (bool upkeepNeeded, bytes memory /*performData*/){
        bool isOpen = RaffleState.OPEN ==s_raffleState;
        bool timePassed = ((block.timestamp - s_lastime) > i_interval);
        bool hasPlayers = s_players.length > 0;
        bool hasBalance = address(this).balance > 0;
        upkeepNeeded= (timePassed && hasPlayers && hasBalance && isOpen);
        return (upkeepNeeded, "0xo");

    }

    //1. Get a random number
    //2. Use random number to pick a player
    //3. Be automatically called
    function pickWinner () public {
        //check to see if enough time has passed
        if((block.timestamp -s_lastime)< i_interval) revert();
        s_raffleState = RaffleState.OPEN;

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
   function
   function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal override {
        uint256 indexOfWinner =randomWords[0] % s_players.length;
        address payable winner = s_players[indexOfWinner];
        s_recentWinner = winner;
        s_players = new address payable[](0);
        s_lastime = block.timestamp;
        s_raffleState = RaffleState.OPEN;
        (bool success,) = winner.call{value:address(this).balance}("");
        if(!success){
            revert Raffle_TransferFailed();
        }
        emit PickedWinner(winner);
   }
  /**
   * Getter Functions
   */
  function getEntranceFee() public view returns(uint256){
    return i_entraceFee;
  }
  //CEI SYTLE EXAMPLE
  function coolFunction() public {
    //check for x and y 
    // then the effect/if true then()
    //then call and sends

    checkX();
    checkY();

    updateM();

    //Interactions
    callA();
    sendB();

  }

}
