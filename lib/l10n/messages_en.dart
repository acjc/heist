// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  get localeName => 'en';

  static m0(maxBalances) => "You can also see the balance of up to ${maxBalances} people";

  static m1(numPlayers) => "There are ${numPlayers} spots available! Highest, then fastest, bids win!";

  static m2(name, result) => "You guessed if ${name} is Brenda.\n\nThis was ${result}";

  static m3(length, numPlayers) => "Bids in so far (${length} / ${numPlayers})";

  static m4(brendaDisplayName) => "...received by ${brendaDisplayName}";

  static m5(roomCode) => "Room ${roomCode}: Choose the game roles";

  static m6(bertie, brenda) => "${brenda} and ${bertie} have to be in the game.";

  static m7(numRoles) => "FRIENDLY TEAM (${numRoles})";

  static m8(amount, recipientName) => "You have already sent a gift this round of ${amount} to ${recipientName}";

  static m9(order) => "Haunt ${order}";

  static m10(name, role) => "${name} is ${role} \n";

  static m11(playersPicked, teamSize) => "TEAM (${playersPicked} / ${teamSize})";

  static m12(order) => "Player ${order}";

  static m13(order) => "Round ${order}";

  static m14(numRoles) => "SCARY TEAM (${numRoles})";

  static m15(bertieDisplayName, stealOption) => "...shared between ${bertieDisplayName} and any players who chose ${stealOption} on the haunt";

  static m16(roomCode, owner) => "Room ${roomCode}: ${owner} is choosing the game roles";

  static m17(thiefScore, agentScore) => "${thiefScore} - ${agentScore}";

  static m18(playersSoFar, totalPlayers) => "Waiting for players (${playersSoFar} / ${totalPlayers})";

  static m19(leaderName) => "Waiting for ${leaderName} to submit their team";

  static m20(winner) => "${winner} win!";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "accountantConfirmPlayer" : MessageLookupByLibrary.simpleMessage("CONFIRM SELECTION"),
    "accountantExplanation" : m0,
    "accountantPickPlayer" : MessageLookupByLibrary.simpleMessage("PICK BALANCE TO SEE"),
    "addPlayersInstructions" : MessageLookupByLibrary.simpleMessage("Add a player to your team by tapping JOIN TEAM on their screen"),
    "auctionDescription" : m1,
    "auctionHeaderDescription" : MessageLookupByLibrary.simpleMessage("You\'ve failed to agree on a team 4 times in a row, so now it\'s time for an auction instead!\n\nThe players who bid the highest will get to go on the haunt. Tied bids will favour whoever submitted their bid first.\n\nYou can also gift ectoplasm to other players here (but only once per round). Gift to a teammate so they can go on the haunt with you!"),
    "auctionTitle" : MessageLookupByLibrary.simpleMessage("Auction!"),
    "backHome" : MessageLookupByLibrary.simpleMessage("BACK TO HOME PAGE"),
    "bertie" : MessageLookupByLibrary.simpleMessage("Bertie"),
    "bertieConfirmPlayer" : MessageLookupByLibrary.simpleMessage("CONFIRM GUESS"),
    "bertieExplanation" : MessageLookupByLibrary.simpleMessage("You are Bertie and that means you have ONE guess as to the identity of Brenda the Scariest Ghost which you can use at any point during the game. If you guess correctly, you will no longer be restricted by maximum bid limits!"),
    "bertiePickPlayer" : MessageLookupByLibrary.simpleMessage("SELECT YOUR BRENDA GUESS"),
    "bertieResult" : m2,
    "bertieResultRight" : MessageLookupByLibrary.simpleMessage("CORRECT!"),
    "bertieResultWrong" : MessageLookupByLibrary.simpleMessage("INCORRECT! :("),
    "bidders" : m3,
    "bidding" : MessageLookupByLibrary.simpleMessage("Bidding"),
    "biddingHeader" : MessageLookupByLibrary.simpleMessage("Bidding is open!"),
    "biddingHeaderDescription" : MessageLookupByLibrary.simpleMessage("Now that a team has been selected for this haunt, it\'s time to bid on that team! If you like the look of the team, bid high, or bid low to show your displeasure.\n\nYou can also gift ectoplasm to other players here (but only once per round). Gift to a teammate so you can both bid high on a team you agree on!"),
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
    "decision" : MessageLookupByLibrary.simpleMessage("Decision"),
    "enterRoomCode" : MessageLookupByLibrary.simpleMessage("Enter an existing game code"),
    "enterYourName" : MessageLookupByLibrary.simpleMessage("Enter your name"),
    "fail" : MessageLookupByLibrary.simpleMessage("Fail"),
    "formerAccountantGhost" : MessageLookupByLibrary.simpleMessage("Former Accountant Ghost"),
    "friendlyGhost" : MessageLookupByLibrary.simpleMessage("Friendly Ghost"),
    "friendlyTeam" : m7,
    "fullTeam" : MessageLookupByLibrary.simpleMessage("This team is full. Remove another role before adding this one."),
    "gameResult" : MessageLookupByLibrary.simpleMessage("Game Result"),
    "giftAlreadySent" : m8,
    "giftingTitle" : MessageLookupByLibrary.simpleMessage("Gifting"),
    "goingAhead" : MessageLookupByLibrary.simpleMessage("The haunt is going ahead without you!"),
    "hauntInProgress" : MessageLookupByLibrary.simpleMessage("Haunt in progress"),
    "hauntInfo" : MessageLookupByLibrary.simpleMessage("Haunt Info"),
    "hauntResult" : MessageLookupByLibrary.simpleMessage("Haunt Result"),
    "hauntTitle" : m9,
    "homepageTitle" : MessageLookupByLibrary.simpleMessage("Homepage"),
    "identity" : m10,
    "invalidCode" : MessageLookupByLibrary.simpleMessage("Invalid code"),
    "joinGame" : MessageLookupByLibrary.simpleMessage("JOIN GAME"),
    "joinTeam" : MessageLookupByLibrary.simpleMessage("JOIN TEAM"),
    "leaveTeam" : MessageLookupByLibrary.simpleMessage("LEAVE TEAM"),
    "makeYourChoice" : MessageLookupByLibrary.simpleMessage("Make your choice..."),
    "noBid" : MessageLookupByLibrary.simpleMessage("-"),
    "noConnectionDialogText" : MessageLookupByLibrary.simpleMessage("You need to be connected to the internet to be able to play."),
    "noConnectionDialogTitle" : MessageLookupByLibrary.simpleMessage("No internet"),
    "notAllowed" : MessageLookupByLibrary.simpleMessage("You can\'t do that"),
    "notEnough" : MessageLookupByLibrary.simpleMessage("Not enough ectoplasm for this haunt!"),
    "notPicked" : MessageLookupByLibrary.simpleMessage("You haven\'t been picked!"),
    "okButton" : MessageLookupByLibrary.simpleMessage("OK"),
    "onlyOwnerModifies" : MessageLookupByLibrary.simpleMessage("Only the person who created the room can choose roles."),
    "otherIdentities" : MessageLookupByLibrary.simpleMessage("You also know these identities"),
    "pickATeam" : MessageLookupByLibrary.simpleMessage("It\'s your turn to pick a team!"),
    "pickedTeamSize" : m11,
    "pickedYou" : MessageLookupByLibrary.simpleMessage(" picked you in the team!"),
    "playerInfo" : MessageLookupByLibrary.simpleMessage("Player Info"),
    "playerList" : MessageLookupByLibrary.simpleMessage("Player List"),
    "playerOrder" : m12,
    "playerRoles" : MessageLookupByLibrary.simpleMessage("Player Roles"),
    "players" : MessageLookupByLibrary.simpleMessage("Players"),
    "pleaseEnterAName" : MessageLookupByLibrary.simpleMessage("Please enter a name"),
    "pot" : MessageLookupByLibrary.simpleMessage("Pot"),
    "price" : MessageLookupByLibrary.simpleMessage("Price"),
    "putYouInTeam" : MessageLookupByLibrary.simpleMessage(" to pick you and tap JOIN TEAM below"),
    "role" : MessageLookupByLibrary.simpleMessage("Role"),
    "roleInfo" : MessageLookupByLibrary.simpleMessage("Role Info"),
    "room" : MessageLookupByLibrary.simpleMessage("Room"),
    "roundTitle" : m13,
    "scaryGhost" : MessageLookupByLibrary.simpleMessage("Scary Ghost"),
    "scaryTeam" : m14,
    "secretActions" : MessageLookupByLibrary.simpleMessage("Secret Actions"),
    "secretHeader" : MessageLookupByLibrary.simpleMessage("Secret"),
    "secretHeaderDescription" : MessageLookupByLibrary.simpleMessage("This screen contains information which should be known only to you. Be careful not to accidentally show it to any other players!\n\nHere, you can see your ectoplasm, your team and your role. You\'ll find details about any secret information or actions available to you.\n\nThere are also helpful reminders about the other players and roles in this game."),
    "sharedBetween" : m15,
    "someoneElseChoosesGameRoles" : m16,
    "submit" : MessageLookupByLibrary.simpleMessage("SUBMIT"),
    "submitBid" : MessageLookupByLibrary.simpleMessage("SUBMIT BID"),
    "submitTeam" : MessageLookupByLibrary.simpleMessage("SUBMIT TEAM"),
    "success" : MessageLookupByLibrary.simpleMessage("Success"),
    "team" : MessageLookupByLibrary.simpleMessage("Team"),
    "teamScores" : m17,
    "teamSelection" : MessageLookupByLibrary.simpleMessage("Team Selection"),
    "title" : MessageLookupByLibrary.simpleMessage("Heist"),
    "unlimited" : MessageLookupByLibrary.simpleMessage("You have no maximum bid limit for this round"),
    "waitingForPlayers" : m18,
    "waitingForTeamSubmission" : m19,
    "winner" : m20,
    "youAreGoing" : MessageLookupByLibrary.simpleMessage("You\'re going on a haunt!"),
    "youHaveMadeYourChoice" : MessageLookupByLibrary.simpleMessage("You have made your choice!"),
    "yourBid" : MessageLookupByLibrary.simpleMessage("Your bid")
  };
}
