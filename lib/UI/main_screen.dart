import 'package:flutter/material.dart';
import 'package:restaurant_nearby/DataLayer/location.dart';
import 'package:restaurant_nearby/UI/restaurant_screen.dart';
import 'package:restaurant_nearby/bloc/bloc_provider.dart';
import 'package:restaurant_nearby/bloc/location_bloc.dart';


import 'location_screen.dart';

class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Location>(
      stream: BlocProvider.of<LocationBloc>(context).locationStream,
      builder: (context, snapshot) {
        final location = snapshot.data;

        if (location == null) {
          return LocationScreen();
        }

        return RestaurantScreen(location: location);
      }
    );
  }
}