import 'dart:async';

import 'package:flutter/material.dart';
import 'package:heist/l10n/messages_all.dart';
import 'package:intl/intl.dart';

// To add a new string or edit an existing one:
// - Add a get method that returns an Intl.message here or modify the string in the existing method
// - Run 'flutter pub pub run intl_translation:extract_to_arb --output-dir=lib/l10n lib/app_localizations.dart'
//   This will update lib/l10n/intl_messages.arb
// - Replace the content of lib/l10n/intl_en.arb with the content of the updated intl_messages.arb
// - Manually update lib/l10n/intl_*.arb (where * isn't English) to reflect the changes
// - Run 'flutter pub pub run intl_translation:generate_from_arb --output-dir=lib/l10n --no-use-deferred-loading lib/app_localizations.dart lib/l10n/intl_*.arb'
//   This will update or create lib/l10n/messages_*.dart
//
// To add a new language, you need to copy lib/l10n/intl_messages.arb into a
// new file lib/l10n/intl_*.arb file, where * is the code of the new language.
// You also need to update the list of supported languages at the bottom of this
// file (in isSupported) and the supportedLocales in main.dart.
class AppLocalizations {
  static Future<AppLocalizations> load(Locale locale) {
    final String name = locale.countryCode.isEmpty ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      return AppLocalizations();
    });
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  String get title {
    return Intl.message(
      'Heist',
      name: 'title',
      desc: 'Title for the Heist application',
    );
  }

  // Roles

  String get bertie {
    return Intl.message(
      'Bertie',
      name: 'bertie',
      desc: 'Bertie role',
    );
  }

  String get friendlyGhost {
    return Intl.message(
      'Friendly Ghost',
      name: 'friendlyGhost',
      desc: 'Friendly Ghost role',
    );
  }

  String get brenda {
    return Intl.message(
      'Brenda',
      name: 'brenda',
      desc: 'Brenda',
    );
  }

  String get formerAccountantGhost {
    return Intl.message(
      'Former Accountant Ghost',
      name: 'formerAccountantGhost',
      desc: 'Former Accountant Ghost role',
    );
  }

  String get scaryGhost {
    return Intl.message(
      'Scary Ghost',
      name: 'scaryGhost',
      desc: 'Scary Ghost role',
    );
  }

  // Common

  String get okButton {
    return Intl.message(
      'OK',
      name: 'okButton',
      desc: 'OK button in a dialog',
    );
  }

  String get continueButton {
    return Intl.message(
      'CONTINUE',
      name: 'continueButton',
      desc: 'Button for the game organiser to move to the next round or haunt',
    );
  }

  String get auctionTitle {
    return Intl.message(
      'Auction!',
      name: 'auctionTitle',
      desc: 'Auction title',
    );
  }

  String roundTitle(int order) {
    return Intl.message(
      'Round $order',
      name: 'roundTitle',
      args: [order],
      desc: 'Round title',
    );
  }

  String hauntTitle(int order) {
    return Intl.message(
      'Haunt $order',
      name: 'hauntTitle',
      args: [order],
      desc: 'Haunt title',
    );
  }

  String get players {
    return Intl.message(
      'Players',
      name: 'players',
      desc: 'Title of a list of players in the game',
    );
  }

  String playerOrder(int order) {
    return Intl.message(
      'Player $order',
      name: 'playerOrder',
      args: [order],
      desc: 'Player order',
    );
  }

  String get success {
    return Intl.message(
      'Success',
      name: 'success',
      desc: 'Status of a successful haunt',
    );
  }

  String get fail {
    return Intl.message(
      'Fail',
      name: 'fail',
      desc: 'Status of a failed haunt',
    );
  }

  // Homepage

  String get homepageTitle {
    return Intl.message(
      'Homepage',
      name: 'homepageTitle',
      desc: 'Title for the homepage',
    );
  }

  String get enterYourName {
    return Intl.message(
      'Enter your name',
      name: 'enterYourName',
      desc: 'Above the text field where the player writes their name',
    );
  }

  String get pleaseEnterAName {
    return Intl.message(
      'Please enter a name',
      name: 'pleaseEnterAName',
      desc: 'After the player has submitted an empty name',
    );
  }

  String get joinGame {
    return Intl.message(
      'JOIN GAME',
      name: 'joinGame',
      desc: 'Button to enter an existing room',
    );
  }

  String get enterRoomCode {
    return Intl.message(
      'Enter an existing game code',
      name: 'enterRoomCode',
      desc: 'Above the text field where the player writes an existing room code',
    );
  }

  String get invalidCode {
    return Intl.message(
      'Invalid code',
      name: 'invalidCode',
      desc: 'After the player has entered an invalid room code',
    );
  }

  // Create room screen

  String get createRoomTitle {
    return Intl.message(
      'Create new game',
      name: 'createRoomTitle',
      desc: 'Title for the page to create a room',
    );
  }

  String get createRoom {
    return Intl.message(
      'CREATE NEW GAME',
      name: 'createRoom',
      desc: 'Button to create a new room',
    );
  }

  String get chooseNumberOfPlayers {
    return Intl.message(
      'Choose number of players',
      name: 'chooseNumberOfPlayers',
      desc: 'Above the selector of the number of players',
    );
  }

  // Bidding

  String get bidding {
    return Intl.message(
      'BIDDING',
      name: 'bidding',
      desc: 'Title of the bidding section',
    );
  }

  String get submitBid {
    return Intl.message(
      'SUBMIT BID',
      name: 'submitBid',
      desc: 'Button to submit a bid',
    );
  }

  String get cancelBid {
    return Intl.message(
      'CANCEL BID',
      name: 'cancelBid',
      desc: 'Button to cancel a bid',
    );
  }

  String get noBid {
    return Intl.message(
      'No Bid',
      name: 'noBid',
      desc: "Player hasn't made a bid yet",
    );
  }

  String auctionDescription(int numPlayers) {
    return Intl.message(
      'There are $numPlayers spots available! Highest, then fastest, bids win!',
      name: 'auctionDescription',
      args: [numPlayers],
      desc: 'Description of an auction',
    );
  }

  String bidders(int length, int numPlayers) {
    return Intl.message(
      'Bidders so far ($length / $numPlayers):',
      name: 'bidders',
      args: [length, numPlayers],
      desc: 'Number of players that have bid over the total number of players',
    );
  }

  String get unlimited {
    return Intl.message(
      'You have no maximum bid limit for this round',
      name: 'unlimited',
      desc: 'The Lead Agent\'s maximum bid when they have found the Kingpin (or it is an auction)',
    );
  }

  String get pot {
    return Intl.message(
      'Pot',
      name: 'pot',
    );
  }

  String get price {
    return Intl.message(
      'Price',
      name: 'price',
    );
  }

  String get yourBid {
    return Intl.message(
      'Your bid',
      name: 'yourBid',
    );
  }

  String get youAreGoing {
    return Intl.message(
      "You're going on a haunt!",
      name: 'youAreGoing',
      desc: 'Bidding phase result',
    );
  }

  String get goingAhead {
    return Intl.message(
      'The haunt is going ahead without you!',
      name: 'goingAhead',
      desc: 'Bidding phase result',
    );
  }

  String get notEnough {
    return Intl.message(
      'Not enough ectoplasm for this haunt!',
      name: 'notEnough',
      desc: 'Bidding phase result',
    );
  }

  // Decision

  String get hauntInProgress {
    return Intl.message(
      'Haunt in progress...',
      name: 'hauntInProgress',
      desc: 'Shown while a haunt is in progress',
    );
  }

  String get makeYourChoice {
    return Intl.message(
      'Make your choice...',
      name: 'makeYourChoice',
      desc: 'Shown when you have to choose your result in a haunt',
    );
  }

  String get youHaveMadeYourChoice {
    return Intl.message(
      'You have made your choice!',
      name: 'youHaveMadeYourChoice',
      desc: 'Shown when a player on a haunt has made a decision',
    );
  }

  String brendaReceived(String brendaDisplayName) {
    return Intl.message(
      '...received by $brendaDisplayName',
      name: 'brendaReceived',
      args: [brendaDisplayName],
      desc: 'Describe how much money Brenda receives after a haunt',
    );
  }

  String sharedBetween(String bertieDisplayName, String stealOption) {
    return Intl.message(
      '...shared between $bertieDisplayName} and any players who chose $stealOption on the haunt:',
      name: 'sharedBetween',
      args: [bertieDisplayName, stealOption],
      desc: 'Describe how much money gets split between Bertie and those who stole',
    );
  }

  // Game

  String get gameTab {
    return Intl.message(
      'GAME',
      name: 'gameTab',
      desc: 'Title of the game tab',
    );
  }

  String get secretTab {
    return Intl.message(
      'SECRET',
      name: 'secretTab',
      desc: 'Title of the secret tab',
    );
  }

  String get yourTeam {
    return Intl.message(
      'You are in team:',
      name: 'yourTeam',
      desc: 'Next to your team in the secret board',
    );
  }

  String get yourRole {
    return Intl.message(
      'Your role is:',
      name: 'yourRole',
      desc: 'Next to your role in the secret board',
    );
  }

  String get otherIdentities {
    return Intl.message(
      'You also know these identities:',
      name: 'otherIdentities',
      desc: 'Next to other identities a player might know',
    );
  }

  String identity(String name, String role) {
    return Intl.message(
      '$name is the $role \n',
      name: 'identity',
      args: [name, role],
      desc: 'Identity a player might know',
    );
  }

  String accountantExplanation(int maxBalances) {
    return Intl.message(
      'You can also see the balance of up to $maxBalances people:',
      name: 'accountantExplanation',
      args: [maxBalances],
      desc: 'Tells the accountant what they can do',
    );
  }

  String get accountantPickPlayer {
    return Intl.message(
      'PICK BALANCE TO SEE',
      name: 'accountantPickPlayer',
      desc: 'Dropdown button where the accountant selects a player',
    );
  }

  String get accountantConfirmPlayer {
    return Intl.message(
      'CONFIRM SELECTION',
      name: 'accountantConfirmPlayer',
      desc: 'Button for the accountant to confirm the selected player',
    );
  }

  String get bertieExplanation {
    return Intl.message(
      'You can try to guess who Brenda is ONCE during the game.'
          ' If you get it right, you will no longer be restricted by maximum bid limits.',
      name: 'bertieExplanation',
      desc: 'Tells Bertie what they can do',
    );
  }

  String get bertiePickPlayer {
    return Intl.message(
      'SELECT YOUR KINGPIN GUESS',
      name: 'bertiePickPlayer',
      desc: 'Dropdown button where Bertie selects a player',
    );
  }

  String get bertieConfirmPlayer {
    return Intl.message(
      'CONFIRM GUESS',
      name: 'bertieConfirmPlayer',
      desc: 'Button for Bertie to confirm the selected player',
    );
  }

  String bertieResult(String name, String result) {
    return Intl.message(
      'You checked if $name is Brenda. This is $result',
      name: 'bertieResult',
      args: [name, result],
      desc: 'Tells Bertie whether they found Brenda after their guess',
    );
  }

  String get bertieResultRight {
    return Intl.message(
      'CORRECT!',
      name: 'bertieResultRight',
      desc: 'Bertie correctly guessed who Brenda is',
    );
  }

  String get bertieResultWrong {
    return Intl.message(
      'INCORRECT! :(',
      name: 'bertieResultWrong',
      desc: 'Bertie failed to guess who Brenda is',
    );
  }

  String waitingForPlayers(int playersSoFar, int totalPlayers) {
    return Intl.message(
      'Waiting for players: $playersSoFar / $totalPlayers',
      name: 'waitingForPlayers',
      args: [playersSoFar, totalPlayers],
      desc: 'Shown while players are joining the room',
    );
  }

  // Gifting

  String get giftingTitle {
    return Intl.message(
      'GIFTING',
      name: 'giftingTitle',
      desc: 'Title of the gifting section',
    );
  }

  String get chooseGiftRecipient {
    return Intl.message(
      'Choose a player to send a gift to:',
      name: 'chooseGiftRecipient',
      desc: 'Next to the list of players where you select who to send a gift to',
    );
  }

  String giftAlreadySent(int amount, String recipientName) {
    return Intl.message(
      'You have already sent a gift this round of $amount to $recipientName',
      name: 'giftAlreadySent',
      args: [amount, recipientName],
      desc: 'The player has already sent a gift this round',
    );
  }

  // Picking a team

  String get pickedYou {
    return Intl.message(
      ' picked you in the team!',
      name: 'pickedYou',
      desc: 'Leader picked you in the team',
    );
  }

  String get notPicked {
    return Intl.message(
      "You haven't been picked!",
      name: 'notPicked',
      desc: 'Leader has not picked you in the team',
    );
  }

  String get convince {
    return Intl.message(
      'Convince ',
      name: 'convince',
      desc: 'Convince leader to pick you in the team (1 / 2)',
    );
  }

  String get putYouInTeam {
    return Intl.message(
      ' to put you in the team!',
      name: 'putYouInTeam',
      desc: 'Convince leader to pick you in the team (2 / 2)',
    );
  }

  String waitingForTeamSubmission(String leaderName) {
    return Intl.message(
      'Waiting for $leaderName to submit team',
      name: 'waitingForTeamSubmission',
      args: [leaderName],
      desc: 'Waiting for leader to submit team',
    );
  }

  String pickATeam(int playersPicked, int teamSize) {
    return Intl.message(
      'Pick a team: $playersPicked / $teamSize',
      name: 'pickATeam',
      args: [playersPicked, teamSize],
      desc: 'Team picker title',
    );
  }

  String pickedTeamSize(int playersPicked, int teamSize) {
    return Intl.message(
      'TEAM ($playersPicked / $teamSize)',
      name: 'pickedTeamSize',
      args: [playersPicked, teamSize],
      desc: 'Selection board title',
    );
  }

  String get submitTeam {
    return Intl.message(
      'SUBMIT TEAM',
      name: 'submitTeam',
      desc: 'Button for the team picker to confirm their team selection',
    );
  }

  String get continueToBidding {
    return Intl.message(
      'CONTINUE TO BIDDING',
      name: 'continueToBidding',
      desc: 'Button for local continue from team selection',
    );
  }

  // End of the game

  String playerRole(String name, String role) {
    return Intl.message(
      '$name ($role) ->',
      name: 'playerRole',
      args: [name, role],
      desc: 'The name and role of a player',
    );
  }

  String hauntPrice(int price) {
    return Intl.message(
      'Price: $price',
      name: 'hauntPrice',
      args: [price],
      desc: 'Price of a haunt',
    );
  }

  String hauntPot(int pot) {
    return Intl.message(
      'Pot: $pot',
      name: 'hauntPot',
      args: [pot],
      desc: 'Pot of a haunt',
    );
  }

  String winner(String winner) {
    return Intl.message(
      '$winner win!',
      name: 'winner',
      args: [winner],
      desc: 'Winner team',
    );
  }

  String teamScores(int thiefScore, int agentScore) {
    return Intl.message(
      '$thiefScore - $agentScore',
      name: 'teamScores',
      args: [thiefScore, agentScore],
      desc: 'The scores of both teams - might need to reverse the order in RTL',
    );
  }

  // No connection

  String get noConnectionDialogTitle {
    return Intl.message(
      'No internet',
      name: 'noConnectionDialogTitle',
      desc: 'Title of the dialog telling the user they have lost their internet connection',
    );
  }

  String get noConnectionDialogText {
    return Intl.message(
      'You need to be connected to the internet to be able to play.',
      name: 'noConnectionDialogText',
      desc: 'Body of the dialog telling the user they have lost their internet connection',
    );
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'es'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) => AppLocalizations.load(locale);

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
