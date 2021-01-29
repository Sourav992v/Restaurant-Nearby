import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:restaurant_nearby/DataLayer/location.dart';
import 'package:restaurant_nearby/bloc/bloc_provider.dart';
import 'package:restaurant_nearby/bloc/location_bloc.dart';
import 'package:restaurant_nearby/bloc/location_query_bloc.dart';

class LocationScreen extends StatefulWidget {
  final bool isFullScreenDialog;

  const LocationScreen({Key key, this.isFullScreenDialog = false})
      : super(key: key);

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  Position position;

  GoogleMapController mapController;


  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();
    getLocation();
  }
  Set<Marker> _createMarker() {
    return <Marker>{
      Marker(
          markerId: MarkerId('My location'),
      position: LatLng(28, 78),
        icon: BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(title: 'You are here!')
      )
    };
  }

  void getLocation(){
    Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium
    ).then((value){
      setState(() {
        position = value;
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    final bloc = LocationQueryBloc();

    return BlocProvider<LocationQueryBloc>(
      bloc: bloc,
      child: Scaffold(
        appBar: AppBar(title: Text('Where do you want to eat?'),
        actions: [
          IconButton(icon: Icon(Icons.my_location, color: Colors.white,),
              onPressed: () async {
                await getLocation();
              })
        ],),
        body: Stack(
          children: <Widget>[
            GoogleMap(
              onMapCreated: _onMapCreated,
                initialCameraPosition:CameraPosition(
                  target: LatLng(28,78),
                  zoom: 12.0,
                ),
          markers: _createMarker(),),

            Positioned(
              top: 4.0,
              left: 4.0,
              right: 4.0,
              child: Card(
                elevation: 8.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(

                  children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: TextField(
                        decoration: InputDecoration(
                            border: OutlineInputBorder(), hintText: 'Enter a location'),
                        onChanged: (query) => bloc.submitQuery(query),
                      ),
                    ),
                  Container(
                      child: _buildResults(bloc),
                  ),
                  ],

                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildResults(LocationQueryBloc bloc) {
    return StreamBuilder<List<Location>>(
      stream: bloc.locationStream,
      builder: (context, snapshot) {

        // 1
        final results = snapshot.data;

        if (results == null) {
          return Center(child: Text('Enter a location'));
        }

        if (results.isEmpty) {
          return Center(child: Text('No Results'));
        }

        return _buildSearchResults(results);
      },
    );
  }

  Widget _buildSearchResults(List<Location> results) {
    // 2
    return Container(
      height: MediaQuery.of(context).size.height / (0.25 * results.length),
      child: ListView.separated(
        itemCount: results.length,
        separatorBuilder: (BuildContext context, int index) => Divider(),
        itemBuilder: (context, index) {
          final location = results[index];
          return ListTile(
            title: Text(location.title),
            onTap: () {
              final locationBloc = BlocProvider.of<LocationBloc>(context);
              locationBloc.selectLocation(location);

              if (widget.isFullScreenDialog) {
                Navigator.of(context).pop();
              }
            },
          );
        },
      ),
    );
  }
}
