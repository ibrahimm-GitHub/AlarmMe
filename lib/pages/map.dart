// Copyright (C) 2022 https://github.com/AbduzZami
// Copyright (C) 2023 Abd El-Twab M. Fakhry

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:loc/data/models/place.dart';
import 'package:loc/data/repository/maps.dart';
import 'package:loc/themes/color_scheme.dart';
import 'package:loc/utils/location.dart';
import 'package:loc/widgets/map/buttons.dart';
import 'package:rive/rive.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _OsmMapViewScreen();
}

class _OsmMapViewScreen extends State<MapPage> {
  MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<Place> _options = <Place>[];
  Timer? _debounce;
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();

    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

    _mapController = MapController();
    _mapController.mapEventStream.listen((event) async {
      if (event is MapEventMoveEnd) {
        // Handle event.center.
      }
    });
  }

  @override
  void dispose() async {
    _connectivitySubscription.cancel();

    _mapController.dispose();
    super.dispose();
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    result = await _connectivity.checkConnectivity();

    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Pick Destination'),
      ),
      body: SafeArea(
        child: _connectionStatus == ConnectivityResult.none
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(
                      flex: 2,
                      child: SizedBox(
                        child: RiveAnimation.asset(
                          'assets/raw/404.riv',
                          fit: BoxFit.fitWidth,
                          alignment: Alignment.center,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Check connections',
                        style: TextStyle(
                          fontSize: 32,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : FutureBuilder<Place>(
                future: getCurrentLocation(),
                builder: (BuildContext context, AsyncSnapshot<Place> snapshot) {
                  if (snapshot.hasData || snapshot.hasError) {
                    return Stack(
                      children: [
                        Positioned.fill(
                          child: FlutterMap(
                            options: MapOptions(
                              center: LatLng(
                                snapshot.data!.position.latitude,
                                snapshot.data!.position.longitude,
                              ),
                              zoom: 15,
                              maxZoom: 18,
                              minZoom: 0,
                              keepAlive: true,
                            ),
                            mapController: _mapController,
                            children: [
                              TileLayer(
                                urlTemplate:
                                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                subdomains: const ['a', 'b', 'c'],
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: MediaQuery.of(context).size.height * 0.5,
                          left: 0,
                          right: 0,
                          child: IgnorePointer(
                            child: Center(
                              child: StatefulBuilder(
                                builder: (context, setState) {
                                  return Text(
                                    _searchController.text,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,
                                      fontFamily: 'Fantasque',
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        const Positioned.fill(
                          child: IgnorePointer(
                            child: Center(
                              child: Icon(
                                Icons.location_pin,
                                color: GruvboxLightPalette.darkPurple,
                                size: 56,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 224,
                          right: 8,
                          child: ZoomInFloatingButton(
                            onPressed: () {
                              _mapController.move(_mapController.center,
                                  _mapController.zoom + 1);
                            },
                          ),
                        ),
                        Positioned(
                          bottom: 152,
                          right: 8,
                          child: ZoomOutFloatingButton(
                            onPressed: () {
                              _mapController.move(_mapController.center,
                                  _mapController.zoom - 1);
                            },
                          ),
                        ),
                        Positioned(
                          bottom: 80,
                          right: 8,
                          child: MyLocationFloatingButton(
                            onPressed: () async {
                              final currentLocation =
                                  await getCurrentLocation().onError(
                                (error, stackTrace) =>
                                    Future.error(error!, stackTrace),
                              );
                              _mapController.move(
                                LatLng(currentLocation.position.latitude,
                                    currentLocation.position.longitude),
                                _mapController.zoom,
                              );
                            },
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextFormField(
                              controller: _searchController,
                              focusNode: _focusNode,
                              decoration: const InputDecoration(
                                filled: true,
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    width: 0,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(12),
                                  ),
                                ),
                                contentPadding: EdgeInsets.all(4),
                                hintText: 'Search Location',
                                hintStyle: TextStyle(
                                  fontFamily: 'Fantasque',
                                  fontSize: 18,
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                ),
                              ),
                              onChanged: (String value) {
                                if (_debounce?.isActive ?? false) {
                                  _debounce?.cancel();
                                }

                                _debounce = Timer(
                                  const Duration(milliseconds: 0),
                                  () async {
                                    try {
                                      _options = await Maps()
                                          .searchLocation(value)
                                          .onError(
                                            (error, stackTrace) => Future.error(
                                                error!, stackTrace),
                                          );
                                    } finally {
                                      if (mounted) {
                                        setState(() {});
                                      }
                                    }
                                  },
                                );
                              },
                              style: const TextStyle(
                                fontSize: 18,
                                fontFamily: 'NotoArabic',
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 57,
                          right: 8,
                          left: 8,
                          height: _options.length < 6
                              ? _options.length * 80
                              : _options.length > 6
                                  ? MediaQuery.of(context).size.height / 2 - 32
                                  : null,
                          child: Container(
                            margin: const EdgeInsets.only(
                              bottom: 8,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Theme.of(context).colorScheme.background,
                            ),
                            child: StatefulBuilder(
                              builder: ((context, setState) {
                                return ListView.builder(
                                  shrinkWrap: true,
                                  physics: const ScrollPhysics(),
                                  itemCount: _options.length,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      dense: true,
                                      title: Text(
                                        _options[index].displayName!,
                                        maxLines: 2,
                                        style: const TextStyle(
                                          fontFamily: 'NotoArabic',
                                          fontSize: 14,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '${_options[index].position.latitude}, ${_options[index].position.longitude}',
                                        style: const TextStyle(
                                          fontFamily: 'Fantasque',
                                          fontSize: 14,
                                        ),
                                      ),
                                      onTap: () {
                                        _mapController.move(
                                          LatLng(
                                            _options[index].position.latitude,
                                            _options[index].position.longitude,
                                          ),
                                          15.0,
                                        );

                                        _focusNode.unfocus();
                                        _options.clear();
                                        if (mounted) {
                                          setState(() {});
                                        }
                                      },
                                    );
                                  },
                                );
                              }),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child:
                                  SelectDestinationButton(onPressed: () async {
                                final LatLng position = LatLng(
                                  _mapController.center.latitude,
                                  _mapController.center.longitude,
                                );
                                await Maps()
                                    .getLocationInfo(position)
                                    .then((value) {
                                  if (mounted) {
                                    Navigator.of(context).pop<Place>(value);
                                  }
                                }).onError(
                                  (error, stackTrace) =>
                                      Future.error(error!, stackTrace),
                                );
                              }),
                            ),
                          ),
                        )
                      ],
                    );
                  } else {
                    return const Center(
                      child: SizedBox(
                        width: 200,
                        height: 200,
                        child: RiveAnimation.asset(
                          'assets/raw/spinner.riv',
                          fit: BoxFit.fitWidth,
                          alignment: Alignment.center,
                        ),
                      ),
                    );
                  }
                }),
      ),
    );
  }
}
