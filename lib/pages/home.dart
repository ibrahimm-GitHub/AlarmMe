import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:loc/data/app_states.dart';
import 'package:loc/main.dart';
import 'package:loc/pages/choose_location.dart';
import 'package:loc/pages/fav_places.dart';
import 'package:loc/pages/settings_dart';
import 'package:loc/pages/about.dart';
import 'package:loc/pages/add_reminder.dart';
import 'package:loc/utils/location.dart';
import 'package:loc/widgets/home/reminders_list.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appStates = Provider.of<AppStates>(context);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (context.mounted) {
        if (appStates.listening == false) {
          getCurrentLocation().then((value) {
            appStates.setCurrent(value.position);
            handlePositionUpdates(context);
            appStates.setListening(true);
          });
        }
        if (appStates.notify == true) {
          if (appStates.arrivedAll().isNotEmpty) {
            if (appStates.ringing == false) {
              FlutterRingtonePlayer.playAlarm(
                asAlarm: true,
                looping: true,
                volume: 1.0,
              );
              appStates.setRinging(true);
            }
          } else {
            if (appStates.ringing == true) {
              FlutterRingtonePlayer.stop();
              appStates.setRinging(false);
            }
          }
        }
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (context) {
                    return const AboutPage();
                  },
                ),
              );
            },
            icon: const Icon(
              Icons.info_rounded,
              size: 32,
            ),
          ),
          IconButton(
            onPressed: () {
              if (appStates.notify == true) {
                FlutterRingtonePlayer.stop();
                appStates.setRinging(false);
                appStates.setNotify(false);
              } else {
                appStates.setNotify(true);
              }
            },
            icon: Icon(
              appStates.notify == true
                  ? Icons.alarm_on_rounded
                  : Icons.alarm_off_rounded,
              color: appStates.notify == true
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).colorScheme.onTertiary,
              size: 32,
            ),
          ),
        ],
        elevation: 0,
        leading: null,
        title: const Text(
          'Loc',
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: appStates.bottomNavBarIndex,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_rounded,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.favorite_border_rounded,
            ),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.map_rounded,
            ),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings_rounded,
            ),
            label: 'Settings',
          ),
        ],
        onTap: (index) {
          if (appStates.bottomNavBarIndex == index) return;
          appStates.setBottomNavBarIndex(index);
          switch (index) {
            case 0:
              Navigator.of(context).popAndPushNamed('/');
              break;
            case 1:
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (context) {
                    return const FavPlacesPage();
                  },
                ),
              );
              break;
            case 2:
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (context) {
                    return const ChooseLocationPage();
                  },
                ),
              );
              break;
            case 3:
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (context) {
                    return const SettingsPage();
                  },
                ),
              );
              break;
            default:
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        onPressed: () {
          Navigator.of(context).push<void>(
            MaterialPageRoute<void>(
              builder: (context) {
                return AddReminderPage();
              },
            ),
          );
        },
        child: const Icon(
          Icons.add_alarm_rounded,
        ),
      ),
      body: SafeArea(
        child: appStates.reminderAll().isEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Expanded(
                    flex: 2,
                    child: RiveAnimation.asset(
                      'assets/raw/cat.riv',
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'No reminders yet',
                      style: TextStyle(
                        fontSize: 32,
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                  ),
                ],
              )
            : const RemindersList(),
      ),
    );
  }
}
