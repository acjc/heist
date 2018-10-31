// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a messages locale. All the
// messages from the main program should be duplicated here with the same
// function name.

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

// ignore: unnecessary_new
final messages = new MessageLookup();

// ignore: unused_element
final _keepAnalysisHappy = Intl.defaultLocale;

// ignore: non_constant_identifier_names
typedef MessageIfAbsent(String message_str, List args);

class MessageLookup extends MessageLookupByLibrary {
  get localeName => 'messages';

  static m0(maxBalances) => "You can also see the balance of up to ${maxBalances} people";

  static m1(numPlayers) => "There are ${numPlayers} spots available! Highest, then fastest, bids win!";

  static m2(name, result) => "You checked if ${name} is Brenda. This is ${result}";

  static m3(length, numPlayers) => "Bidders so far (${length} / ${numPlayers})";

  static m4(brendaDisplayName) => "...received by ${brendaDisplayName}";

  static m5(roomCode) => "Room ${roomCode}: Choose the game roles";

  static m6(bertie, brenda) => "${brenda} and ${bertie} have to be in the game.";

  static m7(numRoles) => "FRIENDLY TEAM (${numRoles})";

  static m8(amount, recipientName) => "You have already sent a gift this round of ${amount} to ${recipientName}";

  static m9(price) => "Price: ${price}";

  static m10(order) => "Haunt ${order}";

  static m11(name, role) => "${name} is ${role} \n";

  static m12(playersPicked, teamSize) => "TEAM (${playersPicked} / ${teamSize})";

  static m13(order) => "Player ${order}";

  static m14(name, role) => "${name} (${role}) ->";

  static m15(order) => "Round ${order}";

  static m16(numRoles) => "SCARY TEAM (${numRoles})";

  static m17(bertieDisplayName, stealOption) => "...shared between ${bertieDisplayName} and any players who chose ${stealOption} on the haunt";

  static m18(roomCode, owner) => "Room ${roomCode}: ${owner} is choosing the game roles";

  static m19(thiefScore, agentScore) => "${thiefScore} - ${agentScore}";

  static m20(playersSoFar, totalPlayers) => "Waiting for players (${playersSoFar} / ${totalPlayers})";

  static m21(leaderName) => "Waiting for ${leaderName} to submit their team";

  static m22(winner) => "${winner} win!";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "accountantConfirmPlayer" : MessageLookupByLibrary.simpleMessage("CONFIRM SELECTION"),
    "accountantExplanation" : m0,
    "accountantPickPlayer" : MessageLookupByLibrary.simpleMessage("PICK BALANCE TO SEE"),
    "addPlayersInstructions" : MessageLookupByLibrary.simpleMessage("Add a player to your team by tapping JOIN TEAM on their screen"),
    "auctionDescription" : m1,
    "auctionTitle" : MessageLookupByLibrary.simpleMessage("Auction!"),
    "backHome" : MessageLookupByLibrary.simpleMessage("BACK TO HOME PAGE"),
    "bertie" : MessageLookupByLibrary.simpleMessage("Bertie"),
    "bertieConfirmPlayer" : MessageLookupByLibrary.simpleMessage("CONFIRM GUESS"),
    "bertieExplanation" : MessageLookupByLibrary.simpleMessage("You can try to guess who Brenda is ONCE during the game. If you get it right, you will no longer be restricted by maximum bid limits."),
    "bertiePickPlayer" : MessageLookupByLibrary.simpleMessage("SELECT YOUR BRENDA GUESS"),
    "bertieResult" : m2,
    "bertieResultRight" : MessageLookupByLibrary.simpleMessage("CORRECT!"),
    "bertieResultWrong" : MessageLookupByLibrary.simpleMessage("INCORRECT! :("),
    "bidders" : m3,
    "bidding" : MessageLookupByLibrary.simpleMessage("BIDDING"),
    "brenda" : MessageLookupByLibrary.simpleMessage("Brenda"),
    "brendaReceived" : m4,
    "cancelBid" : MessageLookupByLibrary.simpleMessage("CANCEL BID"),
    "chooseGameRoles" : m5,
    "chooseGiftRecipient" : MessageLookupByLibrary.simpleMessage("Choose a player to send a gift to"),
    "chooseNumberOfPlayers" : MessageLookupByLibrary.simpleMessage("Choose number of players"),
    "compulsoryRoles" : m6,
    "continueButton" : MessageLookupByLibrary.simpleMessage("CONTINUE"),
    "continueToBidding" : MessageLookupByLibrary.simpleMessage("CONTINUE TO BIDDING"),
    "convince" : MessageLookupByLibrary.simpleMessage("Convince "),
    "createRoom" : MessageLookupByLibrary.simpleMessage("CREATE NEW GAME"),
    "createRoomTitle" : MessageLookupByLibrary.simpleMessage("Create new game"),
    "enterRoomCode" : MessageLookupByLibrary.simpleMessage("Enter an existing game code"),
    "enterYourName" : MessageLookupByLibrary.simpleMessage("Enter your name"),
    "fail" : MessageLookupByLibrary.simpleMessage("Fail"),
    "formerAccountantGhost" : MessageLookupByLibrary.simpleMessage("Former Accountant Ghost"),
    "friendlyGhost" : MessageLookupByLibrary.simpleMessage("Friendly Ghost"),
    "friendlyTeam" : m7,
    "fullTeam" : MessageLookupByLibrary.simpleMessage("This team is full. Remove another role before adding this one."),
    "gameTab" : MessageLookupByLibrary.simpleMessage("GAME"),
    "giftAlreadySent" : m8,
    "giftingTitle" : MessageLookupByLibrary.simpleMessage("GIFTING"),
    "goingAhead" : MessageLookupByLibrary.simpleMessage("The haunt is going ahead without you!"),
    "hauntInProgress" : MessageLookupByLibrary.simpleMessage("Haunt in progress..."),
    "hauntPrice" : m9,
    "hauntTitle" : m10,
    "homepageTitle" : MessageLookupByLibrary.simpleMessage("Homepage"),
    "identity" : m11,
    "invalidCode" : MessageLookupByLibrary.simpleMessage("Invalid code"),
    "joinGame" : MessageLookupByLibrary.simpleMessage("JOIN GAME"),
    "joinTeam" : MessageLookupByLibrary.simpleMessage("JOIN TEAM"),
    "leaveTeam" : MessageLookupByLibrary.simpleMessage("LEAVE TEAM"),
    "makeYourChoice" : MessageLookupByLibrary.simpleMessage("Make your choice..."),
    "noBid" : MessageLookupByLibrary.simpleMessage("No Bid"),
    "noConnectionDialogText" : MessageLookupByLibrary.simpleMessage("You need to be connected to the internet to be able to play."),
    "noConnectionDialogTitle" : MessageLookupByLibrary.simpleMessage("No internet"),
    "notAllowed" : MessageLookupByLibrary.simpleMessage("You can\'t do that"),
    "notEnough" : MessageLookupByLibrary.simpleMessage("Not enough ectoplasm for this haunt!"),
    "notPicked" : MessageLookupByLibrary.simpleMessage("You haven\'t been picked!"),
    "okButton" : MessageLookupByLibrary.simpleMessage("OK"),
    "onlyOwnerModifies" : MessageLookupByLibrary.simpleMessage("Only the person who created the room can choose roles."),
    "otherIdentities" : MessageLookupByLibrary.simpleMessage("You also know these identities"),
    "pickATeam" : MessageLookupByLibrary.simpleMessage("It\'s your turn to pick a team!"),
    "pickedTeamSize" : m12,
    "pickedYou" : MessageLookupByLibrary.simpleMessage(" picked you in the team!"),
    "playerOrder" : m13,
    "playerRole" : m14,
    "players" : MessageLookupByLibrary.simpleMessage("Players"),
    "pleaseEnterAName" : MessageLookupByLibrary.simpleMessage("Please enter a name"),
    "pot" : MessageLookupByLibrary.simpleMessage("Pot"),
    "price" : MessageLookupByLibrary.simpleMessage("Price"),
    "putYouInTeam" : MessageLookupByLibrary.simpleMessage(" to pick you and tap JOIN TEAM below"),
    "roundTitle" : m15,
    "scaryGhost" : MessageLookupByLibrary.simpleMessage("Scary Ghost"),
    "scaryTeam" : m16,
    "secretTab" : MessageLookupByLibrary.simpleMessage("SECRET"),
    "sharedBetween" : m17,
    "someoneElseChoosesGameRoles" : m18,
    "submit" : MessageLookupByLibrary.simpleMessage("SUBMIT"),
    "submitBid" : MessageLookupByLibrary.simpleMessage("SUBMIT BID"),
    "submitTeam" : MessageLookupByLibrary.simpleMessage("SUBMIT TEAM"),
    "success" : MessageLookupByLibrary.simpleMessage("Success"),
    "teamScores" : m19,
    "title" : MessageLookupByLibrary.simpleMessage("Heist"),
    "unlimited" : MessageLookupByLibrary.simpleMessage("You have no maximum bid limit for this round"),
    "waitingForPlayers" : m20,
    "waitingForTeamSubmission" : m21,
    "winner" : m22,
    "youAreGoing" : MessageLookupByLibrary.simpleMessage("You\'re going on a haunt!"),
    "youHaveMadeYourChoice" : MessageLookupByLibrary.simpleMessage("You have made your choice!"),
    "yourBid" : MessageLookupByLibrary.simpleMessage("Your bid"),
    "yourRole" : MessageLookupByLibrary.simpleMessage("Your role"),
    "yourTeam" : MessageLookupByLibrary.simpleMessage("Your team")
  };
}
