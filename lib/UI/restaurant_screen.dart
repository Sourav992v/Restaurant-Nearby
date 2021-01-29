import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:restaurant_nearby/DataLayer/location.dart';
import 'package:restaurant_nearby/DataLayer/restaurant.dart';
import 'package:restaurant_nearby/UI/favorite_screen.dart';
import 'package:restaurant_nearby/UI/location_screen.dart';
import 'package:restaurant_nearby/UI/restaurant_tile.dart';
import 'package:restaurant_nearby/bloc/bloc_provider.dart';
import 'package:restaurant_nearby/bloc/restaurant_screen.dart';

class RestaurantScreen extends StatefulWidget {
  final Location location;

  const RestaurantScreen({Key key, @required this.location}) : super(key: key);

  @override
  _RestaurantScreenState createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  final Map<String, Marker> _markers = {};

  GoogleMapController mapController;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _setMarker(List<Restaurant> restaurant){
      _markers.clear();
      for(var restaurantLocation in restaurant){
        final marker = Marker(
          markerId: MarkerId(restaurantLocation.name),
          position: LatLng(double.parse(restaurantLocation.locationResponse.latitude),
                            double.parse(restaurantLocation.locationResponse.longitude),),
        infoWindow: InfoWindow(
          title: restaurantLocation.name,
          snippet: restaurantLocation.address
        ));
      _markers[restaurantLocation.name] = marker;
      }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.location.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.favorite_border),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => FavoriteScreen())),
          )
        ],
      ),
      body: _buildSearch(context),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.edit_location),
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => LocationScreen(
                  // 1
                  isFullScreenDialog: true,
                ),
            fullscreenDialog: true)),
      ),
    );
  }

  Widget _buildSearch(BuildContext context) {
    final bloc = RestaurantBloc(widget.location);

    return BlocProvider<RestaurantBloc>(
      bloc: bloc,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'What do you want to eat?'),
              onChanged: (query) => bloc.submitQuery(query),
            ),
          ),
          Expanded(
            child: _buildStreamBuilder(bloc),
          )
        ],
      ),
    );
  }

  Widget _buildStreamBuilder(RestaurantBloc bloc) {
    return StreamBuilder(
      stream: bloc.stream,
      builder: (context, snapshot) {
        final results = snapshot.data;

        if (results == null) {
          return Center(child: Text('Enter a restaurant name or cuisine type'));
        }

        if (results.isEmpty) {
          return Center(child: Text('No Results'));
        }

        //return _buildSearchResults(results);
        return _buildSearchResultsMap(results);
      },
    );
  }

  Widget _buildSearchResults(List<Restaurant> results) {
    return ListView.separated(
      itemCount: results.length,
      separatorBuilder: (context, index) => Divider(),
      itemBuilder: (context, index) {
        final restaurant = results[index];
        return RestaurantTile(restaurant: restaurant);
      },
    );
  }

  Widget _buildSearchResultsMap(results) {
    _setMarker(results);
    return GoogleMap(
      onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: const LatLng(28.7317,77.1249),
          zoom: 12,
        ),
      markers: _markers.values.toSet(),
    );
  }
}
