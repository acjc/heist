// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a es locale. All the
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
  get localeName => 'es';

  static m0(maxBalances) => "You can also see the balance of up to ${maxBalances} people";

  static m1(playersPicked, teamSize) => "Add a player to your team by tapping JOIN TEAM on their screen (${playersPicked} / ${teamSize})";

  static m2(numPlayers) => "There are ${numPlayers} spots available! Highest, then fastest, bids win!";

  static m3(name, result) => "You checked if ${name} is Brenda. This is ${result}";

  static m4(length, numPlayers) => "Bidders so far (${length} / ${numPlayers})";

  static m5(brendaDisplayName) => "...received by ${brendaDisplayName}";

  static m6(roomCode) => "Room ${roomCode}: Choose the game roles";

  static m7(bertie, brenda) => "${brenda} and ${bertie} have to be in the game.";

  static m8(numRoles) => "FRIENDLY TEAM (${numRoles})";

  static m9(amount, recipientName) => "You have already sent a gift this round of ${amount} to ${recipientName}";

  static m10(price) => "Price: ${price}";

  static m11(order) => "Haunt ${order}";

  static m12(name, role) => "${name} is ${role} \n";

  static m13(playersPicked, teamSize) => "TEAM (${playersPicked} / ${teamSize})";

  static m14(order) => "Player ${order}";

  static m15(name, role) => "${name} (${role}) ->";

  static m16(order) => "Round ${order}";

  static m17(numRoles) => "SCARY TEAM (${numRoles})";

  static m18(bertieDisplayName, stealOption) => "...shared between ${bertieDisplayName} and any players who chose ${stealOption} on the haunt";

  static m19(roomCode, owner) => "Room ${roomCode}: ${owner} is choosing the game roles";

  static m20(thiefScore, agentScore) => "${thiefScore} - ${agentScore}";

  static m21(playersSoFar, totalPlayers) => "Waiting for players (${playersSoFar} / ${totalPlayers})";

  static m22(leaderName) => "Waiting for ${leaderName} to submit their team";

  static m23(winner) => "${winner} win!";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "accountantConfirmPlayer" : MessageLookupByLibrary.simpleMessage("CONFIRM SELECTION"),
    "accountantExplanation" : m0,
    "accountantPickPlayer" : MessageLookupByLibrary.simpleMessage("PICK BALANCE TO SEE"),
    "addPlayersInstructions" : m1,
    "auctionDescription" : m2,
    "auctionTitle" : MessageLookupByLibrary.simpleMessage("Auction!"),
    "bertie" : MessageLookupByLibrary.simpleMessage("Bertie"),
    "bertieConfirmPlayer" : MessageLookupByLibrary.simpleMessage("CONFIRM GUESS"),
    "bertieExplanation" : MessageLookupByLibrary.simpleMessage("You can try to guess who Brenda is ONCE during the game. If you get it right, you will no longer be restricted by maximum bid limits."),
    "bertiePickPlayer" : MessageLookupByLibrary.simpleMessage("SELECT YOUR BRENDA GUESS"),
    "bertieResult" : m3,
    "bertieResultRight" : MessageLookupByLibrary.simpleMessage("CORRECT!"),
    "bertieResultWrong" : MessageLookupByLibrary.simpleMessage("INCORRECT! :("),
    "bidders" : m4,
    "bidding" : MessageLookupByLibrary.simpleMessage("BIDDING"),
    "brenda" : MessageLookupByLibrary.simpleMessage("Brenda"),
    "brendaReceived" : m5,
    "cancelBid" : MessageLookupByLibrary.simpleMessage("CANCEL BID"),
    "chooseGameRoles" : m6,
    "chooseGiftRecipient" : MessageLookupByLibrary.simpleMessage("Choose a player to send a gift to"),
    "chooseNumberOfPlayers" : MessageLookupByLibrary.simpleMessage("Choose number of players"),
    "compulsoryRoles" : m7,
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
    "friendlyTeam" : m8,
    "fullTeam" : MessageLookupByLibrary.simpleMessage("This team is full. Remove another role before adding this one."),
    "gameTab" : MessageLookupByLibrary.simpleMessage("GAME"),
    "giftAlreadySent" : m9,
    "giftingTitle" : MessageLookupByLibrary.simpleMessage("GIFTING"),
    "goingAhead" : MessageLookupByLibrary.simpleMessage("The haunt is going ahead without you!"),
    "hauntInProgress" : MessageLookupByLibrary.simpleMessage("Haunt in progress..."),
    "hauntPrice" : m10,
    "hauntTitle" : m11,
    "homepageTitle" : MessageLookupByLibrary.simpleMessage("Homepage"),
    "identity" : m12,
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
    "pickedTeamSize" : m13,
    "pickedYou" : MessageLookupByLibrary.simpleMessage(" picked you in the team!"),
    "playerOrder" : m14,
    "playerRole" : m15,
    "players" : MessageLookupByLibrary.simpleMessage("Players"),
    "pleaseEnterAName" : MessageLookupByLibrary.simpleMessage("Please enter a name"),
    "pot" : MessageLookupByLibrary.simpleMessage("Pot"),
    "price" : MessageLookupByLibrary.simpleMessage("Price"),
    "putYouInTeam" : MessageLookupByLibrary.simpleMessage(" to pick you and tap JOIN TEAM below"),
    "roundTitle" : m16,
    "scaryGhost" : MessageLookupByLibrary.simpleMessage("Scary Ghost"),
    "scaryTeam" : m17,
    "secretTab" : MessageLookupByLibrary.simpleMessage("SECRET"),
    "sharedBetween" : m18,
    "someoneElseChoosesGameRoles" : m19,
    "submit" : MessageLookupByLibrary.simpleMessage("SUBMIT"),
    "submitBid" : MessageLookupByLibrary.simpleMessage("SUBMIT BID"),
    "submitTeam" : MessageLookupByLibrary.simpleMessage("SUBMIT TEAM"),
    "success" : MessageLookupByLibrary.simpleMessage("Success"),
    "teamScores" : m20,
    "title" : MessageLookupByLibrary.simpleMessage("Heist"),
    "unlimited" : MessageLookupByLibrary.simpleMessage("You have no maximum bid limit for this round"),
    "waitingForPlayers" : m21,
    "waitingForTeamSubmission" : m22,
    "winner" : m23,
    "youAreGoing" : MessageLookupByLibrary.simpleMessage("You\'re going on a haunt!"),
    "youHaveMadeYourChoice" : MessageLookupByLibrary.simpleMessage("You have made your choice!"),
    "yourBid" : MessageLookupByLibrary.simpleMessage("Your bid"),
    "yourRole" : MessageLookupByLibrary.simpleMessage("Your role"),
    "yourTeam" : MessageLookupByLibrary.simpleMessage("Your team")
  };
}
