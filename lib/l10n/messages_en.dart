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

  static m8(kingpinDisplayName) => "...received by ${kingpinDisplayName}";

  static m9(name, result) => "You checked if ${name} is the Kingpin. This is ${result}";

  static m10(playersPicked, teamSize) => "Pick a team: ${playersPicked} / ${teamSize}";

  static m11(playersPicked, teamSize) => "TEAM (${playersPicked} / ${teamSize})";

  static m12(name, amount) => "${name} bid ${amount}";

  static m13(order) => "Player ${order}";

  static m14(name, role) => "${name} (${role}) ->";

  static m15(order) => "Round ${order}";

  static m16(leadAgentDisplayName, stealOption) => "...shared between the ${leadAgentDisplayName}} and any players who chose ${stealOption} on the heist:";

  static m17(thiefScore, agentScore) => "${thiefScore} - ${agentScore}";

  static m18(pot, price) => "Total pot = ${pot} / ${price}";

  static m19(playersSoFar, totalPlayers) => "Waiting for players: ${playersSoFar} / ${totalPlayers}";

  static m20(winner) => "${winner} win!";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "accountant" : MessageLookupByLibrary.simpleMessage("Accountant"),
    "accountantConfirmPlayer" : MessageLookupByLibrary.simpleMessage("CONFIRM SELECTION"),
    "accountantExplanation" : m0,
    "accountantPickPlayer" : MessageLookupByLibrary.simpleMessage("PICK BALANCE TO SEE"),
    "agent" : MessageLookupByLibrary.simpleMessage("Agent"),
    "auctionDescription" : m1,
    "auctionTitle" : MessageLookupByLibrary.simpleMessage("Auction!"),
    "bidders" : m2,
    "bidding" : MessageLookupByLibrary.simpleMessage("BIDDING"),
    "cancelBid" : MessageLookupByLibrary.simpleMessage("CANCEL BID"),
    "chooseGiftRecipient" : MessageLookupByLibrary.simpleMessage("Choose a player to send a gift to:"),
    "chooseNumberOfPlayers" : MessageLookupByLibrary.simpleMessage("Choose number of players"),
    "continueButton" : MessageLookupByLibrary.simpleMessage("CONTINUE"),
    "convince" : MessageLookupByLibrary.simpleMessage("Convince "),
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
    "initialisingGame" : MessageLookupByLibrary.simpleMessage("Initialising game..."),
    "invalidCode" : MessageLookupByLibrary.simpleMessage("Invalid code"),
    "kingpin" : MessageLookupByLibrary.simpleMessage("Kingpin"),
    "kingpinReceived" : m8,
    "leadAgent" : MessageLookupByLibrary.simpleMessage("Lead agent"),
    "leadAgentConfirmPlayer" : MessageLookupByLibrary.simpleMessage("CONFIRM GUESS"),
    "leadAgentExplanation" : MessageLookupByLibrary.simpleMessage("You can try to guess who the Kingpin is ONCE during the game. If you get it right, you will no longer be restricted by maximum bid limits."),
    "leadAgentPickPlayer" : MessageLookupByLibrary.simpleMessage("SELECT YOUR KINGPIN GUESS"),
    "leadAgentResult" : m9,
    "leadAgentResultRight" : MessageLookupByLibrary.simpleMessage("CORRECT!"),
    "leadAgentResultWrong" : MessageLookupByLibrary.simpleMessage("INCORRECT! :("),
    "makeYourChoice" : MessageLookupByLibrary.simpleMessage("Make your choice..."),
    "noBid" : MessageLookupByLibrary.simpleMessage("No Bid"),
    "notPicked" : MessageLookupByLibrary.simpleMessage("You haven\'t been picked!"),
    "otherIdentities" : MessageLookupByLibrary.simpleMessage("You also know these identities:"),
    "pickATeam" : m10,
    "pickedTeamSize" : m11,
    "pickedYou" : MessageLookupByLibrary.simpleMessage(" picked you in the team!"),
    "playerBid" : m12,
    "playerOrder" : m13,
    "playerRole" : m14,
    "players" : MessageLookupByLibrary.simpleMessage("Players"),
    "pleaseEnterAName" : MessageLookupByLibrary.simpleMessage("Please enter a name"),
    "putYouInTeam" : MessageLookupByLibrary.simpleMessage(" to put you in the team!"),
    "roundTitle" : m15,
    "secretTab" : MessageLookupByLibrary.simpleMessage("SECRET"),
    "sharedBetween" : m16,
    "submitBid" : MessageLookupByLibrary.simpleMessage("SUBMIT BID"),
    "submitTeam" : MessageLookupByLibrary.simpleMessage("SUBMIT TEAM"),
    "success" : MessageLookupByLibrary.simpleMessage("Success"),
    "teamScores" : m17,
    "thief" : MessageLookupByLibrary.simpleMessage("Thief"),
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
