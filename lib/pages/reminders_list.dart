import 'package:flutter/material.dart';
import 'package:loc/data/app_states.dart';
import 'package:loc/data/models/place.dart';
import 'package:loc/utils/format_strings.dart';
import 'package:loc/utils/location.dart';
import 'package:loc/widgets/empty_plce_holder.dart';
import 'package:provider/provider.dart';

class RemindersList extends StatelessWidget {
  const RemindersList({super.key});

  @override
  Widget build(BuildContext context) {
    final appStates = Provider.of<AppStates>(context);

    return appStates.reminderAll().isEmpty
        ? const EmptyPlaceHolder(comment: 'No reminders yet')
        : FutureBuilder<Place>(
            future: getCurrentLocation(),
            builder: (BuildContext context, AsyncSnapshot<Place> snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                    physics: const ScrollPhysics(),
                    itemCount: appStates.reminderAll().length,
                    itemBuilder: (context, index) {
                      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                        final remainderDistance = appStates
                            .reminderRead(index)!
                            .remainderDistance(appStates.getCurrent());
                        final radius =
                            appStates.reminderRead(index)!.place.radius;
                        if (remainderDistance <= radius!) {
                          appStates.reminderUpdate(appStates
                              .reminderRead(index)!
                              .copy(isArrived: true));
                        } else {
                          appStates.reminderUpdate(appStates
                              .reminderRead(index)!
                              .copy(isArrived: false));
                        }
                      });

                      return Container(
                        decoration: BoxDecoration(
                          border: appStates.reminderOptions == true &&
                                  appStates.selected == index
                              ? Border.all(
                                  color:
                                      Theme.of(context).colorScheme.onTertiary,
                                  strokeAlign: BorderSide.strokeAlignCenter,
                                )
                              : null,
                          borderRadius: BorderRadius.circular(16),
                          color: appStates.reminderOptions == true &&
                                  appStates.selected != index
                              ? Theme.of(context).colorScheme.tertiary
                              : Theme.of(context).colorScheme.onSecondary,
                        ),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        child: GestureDetector(
                          onTap: () {},
                          onLongPress: () {
                            if (appStates.reminderOptions == true) {
                              appStates.setReminderOptions(false);
                              appStates.setSelected(-1);
                            } else {
                              appStates.setReminderOptions(true);
                              appStates.setSelected(index);
                            }
                          },
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                        topRight: Radius.circular(16),
                                        topLeft: Radius.circular(16),
                                      ),
                                      child: LinearProgressIndicator(
                                        minHeight: 26,
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .tertiary,
                                        value: appStates
                                            .reminderRead(index)!
                                            .traveledDistancePercent(
                                                appStates.getCurrent()),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${intFormat(appStates.reminderRead(index)!.remainderDistance(appStates.getCurrent()).round())} meters away',
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                                width: double.infinity,
                                child: Text(
                                  appStates.reminderRead(index)!.title,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                  left: 12,
                                  right: 12,
                                ),
                                decoration: const BoxDecoration(),
                                child: ListTile(
                                  dense: true,
                                  leading: Switch(
                                    onChanged: (value) {
                                      appStates.reminderUpdate(appStates
                                          .reminderRead(index)!
                                          .copy(isTracking: value));
                                    },
                                    value: appStates
                                        .reminderRead(index)!
                                        .isTracking,
                                  ),
                                  shape: const RoundedRectangleBorder(
                                    side: BorderSide.none,
                                  ),
                                  subtitle: Text(
                                    '${appStates.reminderRead(index)!.place.position.latitude}, ${appStates.reminderRead(index)!.place.position.longitude}',
                                    maxLines: 1,
                                    style: const TextStyle(
                                      fontFamily: 'Fantasque',
                                      fontSize: 12,
                                      height: 2,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  title: Text(
                                    appStates
                                        .reminderRead(index)!
                                        .place
                                        .displayName!,
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontFamily: 'NotoArabic',
                                      fontSize: 16,
                                      height: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    });
              } else {
                return const EmptyPlaceHolder(comment: 'No reminders yet');
              }
            });
  }
}
