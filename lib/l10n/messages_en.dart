// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

// ignore: unused_element
final _keepAnalysisHappy = Intl.defaultLocale;

// ignore: non_constant_identifier_names
typedef MessageIfAbsent(String message_str, List args);

class MessageLookup extends MessageLookupByLibrary {
  get localeName => 'en';

  static m0(maxBalances) => "You can also see the balance of up to ${maxBalances} people:";

  static m1(numPlayers) => "There are ${numPlayers} spots available! Highest, then fastest, bids win!";

  static m2(length, numPlayers) => "Bidders so far (${length} / ${numPlayers}):";

  static m3(amount, recipientName) => "You have already sent a gift this round of ${amount} to ${recipientName}";

  static m4(pot) => "Pot: ${pot}";

  static m5(price) => "Price: ${price}";

  static m6(order) => "Heist ${order}";

  static m7(name, role) => "${name} is the ${role} \n";

  static m8(name, result) => "You checked if ${name} is the Kingpin. This is ${result}";

  static m9(maximumBid) => "Maximum bid: ${maximumBid}";

  static m10(playersPicked, teamSize) => "Pick a team: ${playersPicked} / ${teamSize}";

  static m11(playersPicked, teamSize) => "TEAM (${playersPicked} / ${teamSize})";

  static m12(name) => "${name} is picking a team...";

  static m13(name, amount) => "${name} bid ${amount}";

  static m14(order) => "Player ${order}";

  static m15(name, role) => "${name} (${role}) ->";

  static m16(code) => "Room: ${code}";

  static m17(order) => "Round ${order}";

  static m18(thiefScore, agentScore) => "${thiefScore} - ${agentScore}";

  static m19(pot, price) => "Total pot = ${pot} / ${price}";

  static m20(playersSoFar, totalPlayers) => "Waiting for players: ${playersSoFar} / ${totalPlayers}";

  static m21(winner) => "${winner} win!";

  static m22(bidAmount) => "Your bid: ${bidAmount}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "accountantConfirmPlayer" : MessageLookupByLibrary.simpleMessage("CONFIRM SELECTION"),
    "accountantExplanation" : m0,
    "accountantPickPlayer" : MessageLookupByLibrary.simpleMessage("PICK BALANCE TO SEE"),
    "assigningRoles" : MessageLookupByLibrary.simpleMessage("Assigning roles..."),
    "auctionDescription" : m1,
    "auctionTitle" : MessageLookupByLibrary.simpleMessage("Auction!"),
    "bidders" : m2,
    "bidding" : MessageLookupByLibrary.simpleMessage("BIDDING"),
    "cancelBid" : MessageLookupByLibrary.simpleMessage("CANCEL BID"),
    "chooseGiftRecipient" : MessageLookupByLibrary.simpleMessage("Choose a player to send a gift to:"),
    "chooseNumberOfPlayers" : MessageLookupByLibrary.simpleMessage("Choose number of players"),
    "continueButton" : MessageLookupByLibrary.simpleMessage("CONTINUE"),
    "createRoom" : MessageLookupByLibrary.simpleMessage("CREATE ROOM"),
    "createRoomTitle" : MessageLookupByLibrary.simpleMessage("Heist: Create new room"),
    "enterRoom" : MessageLookupByLibrary.simpleMessage("ENTER ROOM"),
    "enterRoomCode" : MessageLookupByLibrary.simpleMessage("Enter an existing room code"),
    "enterYourName" : MessageLookupByLibrary.simpleMessage("Enter your name"),
    "fail" : MessageLookupByLibrary.simpleMessage("Fail"),
    "gameTab" : MessageLookupByLibrary.simpleMessage("GAME"),
    "giftAlreadySent" : m3,
    "giftingTitle" : MessageLookupByLibrary.simpleMessage("GIFTING"),
    "heistInProgress" : MessageLookupByLibrary.simpleMessage("Heist in progress..."),
    "heistPot" : m4,
    "heistPrice" : m5,
    "heistTitle" : m6,
    "homepageTitle" : MessageLookupByLibrary.simpleMessage("Heist: Homepage"),
    "identity" : m7,
    "invalidCode" : MessageLookupByLibrary.simpleMessage("Invalid code"),
    "leadAgentConfirmPlayer" : MessageLookupByLibrary.simpleMessage("CONFIRM GUESS"),
    "leadAgentExplanation" : MessageLookupByLibrary.simpleMessage("You can try to guess who the Kingpin is once during the game. If you get it right, your bids can be higher than the maximum bid from then on."),
    "leadAgentPickPlayer" : MessageLookupByLibrary.simpleMessage("SELECT YOUR KINGPIN GUESS"),
    "leadAgentResult" : m8,
    "leadAgentResultRight" : MessageLookupByLibrary.simpleMessage("CORRECT!"),
    "leadAgentResultWrong" : MessageLookupByLibrary.simpleMessage("INCORRECT! :("),
    "loading" : MessageLookupByLibrary.simpleMessage("Loading..."),
    "makeYourChoice" : MessageLookupByLibrary.simpleMessage("Make your choice..."),
    "maximumBid" : m9,
    "none" : MessageLookupByLibrary.simpleMessage("None"),
    "otherIdentities" : MessageLookupByLibrary.simpleMessage("You also know these identities:"),
    "pickATeam" : m10,
    "pickedTeamSize" : m11,
    "pickingTeam" : m12,
    "playerBid" : m13,
    "playerOrder" : m14,
    "playerRole" : m15,
    "pleaseEnterAName" : MessageLookupByLibrary.simpleMessage("Please enter a name"),
    "resolvingAuction" : MessageLookupByLibrary.simpleMessage("Resolving auction..."),
    "roomTitle" : m16,
    "roundTitle" : m17,
    "secretTab" : MessageLookupByLibrary.simpleMessage("SECRET"),
    "submitBid" : MessageLookupByLibrary.simpleMessage("SUBMIT BID"),
    "submitTeam" : MessageLookupByLibrary.simpleMessage("SUBMIT TEAM"),
    "success" : MessageLookupByLibrary.simpleMessage("Success"),
    "teamScores" : m18,
    "title" : MessageLookupByLibrary.simpleMessage("Heist"),
    "totalPot" : m19,
    "unlimited" : MessageLookupByLibrary.simpleMessage("Unlimited"),
    "waitingForPlayers" : m20,
    "winner" : m21,
    "youAreOnAHeist" : MessageLookupByLibrary.simpleMessage("You are going on a heist with:"),
    "yourBid" : m22,
    "yourRole" : MessageLookupByLibrary.simpleMessage("Your role is:"),
    "yourTeam" : MessageLookupByLibrary.simpleMessage("You are in team:")
  };
}
