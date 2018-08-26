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

  // TODO because I don't know how to get the context there

  // Common

  String get loading {
    return Intl.message(
      'Loading...',
      name: 'loading',
      desc: 'Shown while loading',
    );
  }

  String get continueButton {
    return Intl.message(
      'CONTINUE',
      name: 'continueButton',
      desc: 'Button for the game organiser to move to the next round or heist',
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

  String heistTitle(int order) {
    return Intl.message(
      'Heist $order',
      name: 'heistTitle',
      args: [order],
      desc: 'Heist title',
    );
  }

  String roomTitle(String code) {
    return Intl.message(
      'Room: $code',
      name: 'roomTitle',
      args: [code],
      desc: 'Room title',
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
      desc: 'Status of a successful heist',
    );
  }

  String get fail {
    return Intl.message(
      'Fail',
      name: 'fail',
      desc: 'Status of a failed heist',
    );
  }

  // Homepage

  String get homepageTitle {
    return Intl.message(
      'Heist: Homepage',
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

  String get enterRoom {
    return Intl.message(
      'ENTER ROOM',
      name: 'enterRoom',
      desc: 'Button to enter an existing room',
    );
  }

  String get enterRoomCode {
    return Intl.message(
      'Enter an existing room code',
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
      'Heist: Create new room',
      name: 'createRoomTitle',
      desc: 'Title for the page to create a room',
    );
  }

  String get createRoom {
    return Intl.message(
      'CREATE ROOM',
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

  String get none {
    return Intl.message(
      'None',
      name: 'none',
      desc: 'What your bid is when you haven\'t bid yet',
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

  String yourBid(String bidAmount) {
    return Intl.message(
      'Your bid: $bidAmount',
      name: 'yourBid',
      args: [bidAmount],
      desc: 'A player\'s current bid',
    );
  }

  String maximumBid(String maximumBid) {
    return Intl.message(
      'Maximum bid: $maximumBid',
      name: 'maximumBid',
      args: [maximumBid],
      desc: 'The maximum allowed bid',
    );
  }

  String get unlimited {
    return Intl.message(
      'Unlimited',
      name: 'unlimited',
      desc: 'The lead agent\'s maximum bid when they have found the kingpin',
    );
  }

  String playerBid(String name, int amount) {
    return Intl.message(
      '$name bid $amount',
      name: 'playerBid',
      args: [name, amount],
      desc: 'How much a player has bid',
    );
  }

  String totalPot(int pot, int price) {
    return Intl.message(
      'Total pot = $pot / $price',
      name: 'totalPot',
      args: [pot, price],
      desc: 'Round pot over round price',
    );
  }

  // Decision

  String get heistInProgress {
    return Intl.message(
      'Heist in progress...',
      name: 'heistInProgress',
      desc: 'Shown while a heist is in progress',
    );
  }

  String get makeYourChoice {
    return Intl.message(
      'Make your choice...',
      name: 'makeYourChoice',
      desc: 'Shown when you have to choose your result in a heist',
    );
  }

  String get youAreOnAHeist {
    return Intl.message(
      'You are going on a heist with:',
      name: 'youAreOnAHeist',
      desc: 'Says who your partners in a heist are',
    );
  }

  // Game

  String get assigningRoles {
    return Intl.message(
      'Assigning roles...',
      name: 'assigningRoles',
      desc: 'Shown while roles are being assigned',
    );
  }

  String get resolvingAuction {
    return Intl.message(
      'Resolving auction...',
      name: 'resolvingAuction',
      desc: 'Shown while the result of an auction is calculated',
    );
  }

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

  String get leadAgentExplanation {
    return Intl.message(
      'You can try to guess who the Kingpin is once during the game.'
      ' If you get it right, your bids can be higher than the maximum'
      ' bid from then on.',
      name: 'leadAgentExplanation',
      desc: 'Tells the lead agent what they can do',
    );
  }

  String get leadAgentPickPlayer {
    return Intl.message(
      'SELECT YOUR KINGPIN GUESS',
      name: 'leadAgentPickPlayer',
      desc: 'Dropdown button where the lead agent selects a player',
    );
  }

  String get leadAgentConfirmPlayer {
    return Intl.message(
      'CONFIRM GUESS',
      name: 'leadAgentConfirmPlayer',
      desc: 'Button for the lead agent to confirm the selected player',
    );
  }

  String leadAgentResult(String name, String result) {
    return Intl.message(
      'You checked if $name is the Kingpin. This is $result',
      name: 'leadAgentResult',
      args: [name, result],
      desc: 'Tells the lead agent whether they found the kingpin after their guess',
    );
  }

  String get leadAgentResultRight {
    return Intl.message(
      'CORRECT!',
      name: 'leadAgentResultRight',
      desc: 'The lead agent guessed who the kingpin is',
    );
  }

  String get leadAgentResultWrong {
    return Intl.message(
      'INCORRECT! :(',
      name: 'leadAgentResultWrong',
      desc: 'The lead agent didn\'t guess who the kingpin is',
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

  String pickingTeam(String name) {
    return Intl.message(
      '$name is picking a team...',
      name: 'pickingTeam',
      args: [name],
      desc: 'A player is picking a team',
    );
  }

  String pickATeam(int playersPicked, int teamSize) {
    return Intl.message(
      'Pick a team: $playersPicked / $teamSize',
      name: 'pickATeam',
      args: [playersPicked, teamSize],
      desc: 'Current team size over number of players needed, as seen by the team picker',
    );
  }

  String pickedTeamSize(int playersPicked, int teamSize) {
    return Intl.message(
      'TEAM ($playersPicked / $teamSize)',
      name: 'pickedTeamSize',
      args: [playersPicked, teamSize],
      desc: 'Current team size over number of players needed, as seen by the players who aren\'t picking a team',
    );
  }

  String get submitTeam {
    return Intl.message(
      'SUBMIT TEAM',
      name: 'submitTeam',
      desc: 'Button for the team picker to confirm their team selection',
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

  String heistPrice(int price) {
    return Intl.message(
      'Price: $price',
      name: 'heistPrice',
      args: [price],
      desc: 'Price of a heist',
    );
  }

  String heistPot(int pot) {
    return Intl.message(
      'Pot: $pot',
      name: 'heistPot',
      args: [pot],
      desc: 'Pot of a heist',
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