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

  static m2(name, result) => "You checked if ${name} is Brenda. This is ${result}";

  static m3(length, numPlayers) => "Bidders so far (${length} / ${numPlayers}):";

  static m4(brendaDisplayName) => "...received by ${brendaDisplayName}";

  static m5(amount, recipientName) => "You have already sent a gift this round of ${amount} to ${recipientName}";

  static m6(pot) => "Pot: ${pot}";

  static m7(price) => "Price: ${price}";

  static m8(order) => "Haunt ${order}";

  static m9(name, role) => "${name} is the ${role} \n";

  static m10(playersPicked, teamSize) => "Pick a team: ${playersPicked} / ${teamSize}";

  static m11(playersPicked, teamSize) => "TEAM (${playersPicked} / ${teamSize})";

  static m12(order) => "Player ${order}";

  static m13(name, role) => "${name} (${role}) ->";

  static m14(order) => "Round ${order}";

  static m15(bertieDisplayName, stealOption) => "...shared between ${bertieDisplayName}} and any players who chose ${stealOption} on the haunt:";

  static m16(thiefScore, agentScore) => "${thiefScore} - ${agentScore}";

  static m17(owner) => "Waiting for ${owner} to continue...";

  static m18(playersSoFar, totalPlayers) => "Waiting for players: ${playersSoFar} / ${totalPlayers}";

  static m19(winner) => "${winner} win!";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "accountantConfirmPlayer" : MessageLookupByLibrary.simpleMessage("CONFIRM SELECTION"),
    "accountantExplanation" : m0,
    "accountantPickPlayer" : MessageLookupByLibrary.simpleMessage("PICK BALANCE TO SEE"),
    "auctionDescription" : m1,
    "auctionTitle" : MessageLookupByLibrary.simpleMessage("Auction!"),
    "bertie" : MessageLookupByLibrary.simpleMessage("Bertie"),
    "bertieConfirmPlayer" : MessageLookupByLibrary.simpleMessage("CONFIRM GUESS"),
    "bertieExplanation" : MessageLookupByLibrary.simpleMessage("You can try to guess who Brenda is ONCE during the game. If you get it right, you will no longer be restricted by maximum bid limits."),
    "bertiePickPlayer" : MessageLookupByLibrary.simpleMessage("SELECT YOUR KINGPIN GUESS"),
    "bertieResult" : m2,
    "bertieResultRight" : MessageLookupByLibrary.simpleMessage("CORRECT!"),
    "bertieResultWrong" : MessageLookupByLibrary.simpleMessage("INCORRECT! :("),
    "bidders" : m3,
    "bidding" : MessageLookupByLibrary.simpleMessage("BIDDING"),
    "brenda" : MessageLookupByLibrary.simpleMessage("Brenda"),
    "brendaReceived" : m4,
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
    "formerAccountantGhost" : MessageLookupByLibrary.simpleMessage("Former Accountant Ghost"),
    "friendlyGhost" : MessageLookupByLibrary.simpleMessage("Friendly Ghost"),
    "gameTab" : MessageLookupByLibrary.simpleMessage("GAME"),
    "giftAlreadySent" : m5,
    "giftingTitle" : MessageLookupByLibrary.simpleMessage("GIFTING"),
    "goingAhead" : MessageLookupByLibrary.simpleMessage("The haunt is going ahead!"),
    "hauntInProgress" : MessageLookupByLibrary.simpleMessage("Haunt in progress..."),
    "hauntPot" : m6,
    "hauntPrice" : m7,
    "hauntTitle" : m8,
    "homepageTitle" : MessageLookupByLibrary.simpleMessage("Heist: Homepage"),
    "identity" : m9,
    "initialisingGame" : MessageLookupByLibrary.simpleMessage("Initialising game..."),
    "invalidCode" : MessageLookupByLibrary.simpleMessage("Invalid code"),
    "makeYourChoice" : MessageLookupByLibrary.simpleMessage("Make your choice..."),
    "noBid" : MessageLookupByLibrary.simpleMessage("No Bid"),
    "noConnectionDialogText" : MessageLookupByLibrary.simpleMessage("You need to be connected to the internet to be able to play."),
    "noConnectionDialogTitle" : MessageLookupByLibrary.simpleMessage("No internet"),
    "notEnough" : MessageLookupByLibrary.simpleMessage("Not enough ectoplasm for this haunt!"),
    "notPicked" : MessageLookupByLibrary.simpleMessage("You haven\'t been picked!"),
    "okButton" : MessageLookupByLibrary.simpleMessage("OK"),
    "otherIdentities" : MessageLookupByLibrary.simpleMessage("You also know these identities:"),
    "pickATeam" : m10,
    "pickedTeamSize" : m11,
    "pickedYou" : MessageLookupByLibrary.simpleMessage(" picked you in the team!"),
    "playerOrder" : m12,
    "playerRole" : m13,
    "players" : MessageLookupByLibrary.simpleMessage("Players"),
    "pleaseEnterAName" : MessageLookupByLibrary.simpleMessage("Please enter a name"),
    "pot" : MessageLookupByLibrary.simpleMessage("Pot"),
    "price" : MessageLookupByLibrary.simpleMessage("Price"),
    "putYouInTeam" : MessageLookupByLibrary.simpleMessage(" to put you in the team!"),
    "roundTitle" : m14,
    "scaryGhost" : MessageLookupByLibrary.simpleMessage("Scary Ghost"),
    "secretTab" : MessageLookupByLibrary.simpleMessage("SECRET"),
    "sharedBetween" : m15,
    "submitBid" : MessageLookupByLibrary.simpleMessage("SUBMIT BID"),
    "submitTeam" : MessageLookupByLibrary.simpleMessage("SUBMIT TEAM"),
    "success" : MessageLookupByLibrary.simpleMessage("Success"),
    "teamScores" : m16,
    "title" : MessageLookupByLibrary.simpleMessage("Heist"),
    "unlimited" : MessageLookupByLibrary.simpleMessage("You have no maximum bid limit for this round"),
    "waitingForOwner" : m17,
    "waitingForPlayers" : m18,
    "winner" : m19,
    "youAreGoing" : MessageLookupByLibrary.simpleMessage("You\'re going on a haunt!"),
    "youHaveMadeYourChoice" : MessageLookupByLibrary.simpleMessage("You have made your choice!"),
    "yourBid" : MessageLookupByLibrary.simpleMessage("Your bid"),
    "yourRole" : MessageLookupByLibrary.simpleMessage("Your role is:"),
    "yourTeam" : MessageLookupByLibrary.simpleMessage("You are in team:")
  };
}
