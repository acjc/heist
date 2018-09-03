// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a es locale. All the
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
  get localeName => 'es';

  static m0(maxBalances) => "You can also see the balance of up to ${maxBalances} people:";

  static m1(numPlayers) => "There are ${numPlayers} spots available! Highest, then fastest, bids win!";

  static m2(length, numPlayers) => "Bidders so far (${length} / ${numPlayers}):";

  static m3(amount, recipientName) => "You have already sent a gift this round of ${amount} to ${recipientName}";

  static m4(pot) => "Pot: ${pot}";

  static m5(price) => "Price: ${price}";

  static m6(order) => "Atraco ${order}";

  static m7(name, role) => "${name} is the ${role} \n";

  static m8(name, result) => "You checked if ${name} is the Kingpin. This is ${result}";

  static m9(playersPicked, teamSize) => "Pick a team: ${playersPicked} / ${teamSize}";

  static m10(playersPicked, teamSize) => "TEAM (${playersPicked} / ${teamSize})";

  static m11(name) => "${name} is picking a team...";

  static m12(name, amount) => "${name} bid ${amount}";

  static m13(order) => "Jugador ${order}";

  static m14(name, role) => "${name} (${role}) ->";

  static m15(code) => "Sala: ${code}";

  static m16(order) => "Ronda ${order}";

  static m17(thiefScore, agentScore) => "${thiefScore} - ${agentScore}";

  static m18(pot, price) => "Total pot = ${pot} / ${price}";

  static m19(playersSoFar, totalPlayers) => "Waiting for players: ${playersSoFar} / ${totalPlayers}";

  static m20(winner) => "${winner} win!";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "accountantConfirmPlayer" : MessageLookupByLibrary.simpleMessage("CONFIRM SELECTION"),
    "accountantExplanation" : m0,
    "accountantPickPlayer" : MessageLookupByLibrary.simpleMessage("PICK BALANCE TO SEE"),
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
    "enterYourName" : MessageLookupByLibrary.simpleMessage("Escribe tu nombre"),
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
    "initialisingGame" : MessageLookupByLibrary.simpleMessage("Initialising game..."),
    "invalidCode" : MessageLookupByLibrary.simpleMessage("Invalid code"),
    "leadAgentConfirmPlayer" : MessageLookupByLibrary.simpleMessage("CONFIRM GUESS"),
    "leadAgentExplanation" : MessageLookupByLibrary.simpleMessage("You can try to guess who the Kingpin is ONCE during the game. If you get it right, you will no longer be restricted by maximum bid limits."),
    "leadAgentPickPlayer" : MessageLookupByLibrary.simpleMessage("SELECT YOUR KINGPIN GUESS"),
    "leadAgentResult" : m8,
    "leadAgentResultRight" : MessageLookupByLibrary.simpleMessage("CORRECT!"),
    "leadAgentResultWrong" : MessageLookupByLibrary.simpleMessage("INCORRECT! :("),
    "makeYourChoice" : MessageLookupByLibrary.simpleMessage("Make your choice..."),
    "noBid" : MessageLookupByLibrary.simpleMessage("No Bid"),
    "otherIdentities" : MessageLookupByLibrary.simpleMessage("You also know these identities:"),
    "pickATeam" : m9,
    "pickedTeamSize" : m10,
    "pickingTeam" : m11,
    "playerBid" : m12,
    "playerOrder" : m13,
    "playerRole" : m14,
    "pleaseEnterAName" : MessageLookupByLibrary.simpleMessage("Please enter a name"),
    "roomTitle" : m15,
    "roundTitle" : m16,
    "secretTab" : MessageLookupByLibrary.simpleMessage("SECRET"),
    "submitBid" : MessageLookupByLibrary.simpleMessage("SUBMIT BID"),
    "submitTeam" : MessageLookupByLibrary.simpleMessage("SUBMIT TEAM"),
    "success" : MessageLookupByLibrary.simpleMessage("Success"),
    "teamScores" : m17,
    "title" : MessageLookupByLibrary.simpleMessage("Heist"),
    "totalPot" : m18,
    "unlimited" : MessageLookupByLibrary.simpleMessage("You have no maximum bid limit for this round"),
    "waitingForPlayers" : m19,
    "winner" : m20,
    "youHaveMadeYourChoice" : MessageLookupByLibrary.simpleMessage("You have made your choice!"),
    "yourRole" : MessageLookupByLibrary.simpleMessage("Your role is:"),
    "yourTeam" : MessageLookupByLibrary.simpleMessage("You are in team:")
  };
}
