import 'package:flutter/material.dart';
import 'package:restaurant_nearby/bloc/bloc_provider.dart';
import 'package:restaurant_nearby/bloc/favorite_bloc.dart';
import 'package:restaurant_nearby/bloc/location_bloc.dart';

import 'UI/main_screen.dart';


void main() => runApp(RestaurantNearBy());

class RestaurantNearBy extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<LocationBloc>(
      bloc: LocationBloc(),
      child: BlocProvider<FavoriteBloc>(
        bloc: FavoriteBloc(),
        child: MaterialApp(
          title: 'Restaurant Finder',
          theme: ThemeData(
            primarySwatch: Colors.red,
          ),
          home: MainScreen(),
        ),
      ),
    );
  }
}
