import 'dart:async';

import 'package:battery/battery.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<Color> _colorAnimation;
  Animation<int> _batteryAnimation;
  bool _reverseAnimation = false;

  final _battery = Battery();
  int _batteryLevel = 100;
  BatteryState _batteryState = BatteryState.full;

  Timer _timer;
  StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();

    listenBatteryLevel();
    listenBatteryState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5),
    );

    _batteryAnimation = IntTween(begin: 0, end: _batteryLevel).animate(_controller)..addListener(() {
      if ((_batteryLevel.toDouble()/100).toString() == _controller.value.toStringAsFixed(2)){
        setState(() {
          _controller.stop();
        });
      }});


    _colorAnimation = ColorTween(
      begin: Colors.redAccent,
      end: Colors.lightGreen,
    ).animate(_controller)
      ..addListener(() {
        setState(() {
        });
      });

   _controller.forward();


   
  }

  void listenController() =>  _controller.addListener(() {
    if ((_batteryLevel.toDouble()/100).toString() == _controller.value.toStringAsFixed(2)){
    setState(() {
      _controller.stop();
    });
  }});




  void listenBatteryState() =>
      _subscription = _battery.onBatteryStateChanged.listen(
            (batteryState) => setState(() => this._batteryState = batteryState),
      );

  void listenBatteryLevel() {
    updateBatteryLevel();

    _timer = Timer.periodic(
      Duration(seconds: 10),
          (_) async => updateBatteryLevel(),
    );
  }

  Future updateBatteryLevel() async {

    final batteryLevel = await _battery.batteryLevel;
    setState(() => this._batteryLevel = batteryLevel);
  }


  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    _subscription.cancel();
    super.dispose();
  }

  _buildBatteryWidget() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
    _batteryAnimation.value.toString()+'%'
            /*(_controller.value * 100).toStringAsFixed(0) + '%'*/,
            style: TextStyle(fontSize: 40.0),
          ),
          const SizedBox(
            width: 10.0,
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Container(
              width: 150.0,
              child: LinearProgressIndicator(
                minHeight: 80.0,
                value: _controller.value,
                valueColor:
                    AlwaysStoppedAnimation<Color>(_colorAnimation.value),
                backgroundColor: Colors.grey[300],
              ),
            ),
          ),
          const SizedBox(
            width: 3.0,
          ),
          Container(
            height: 50.0,
            width: 10.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1.0),
              color: _batteryState == BatteryState.full
                  ? Colors.lightGreen
                  : Colors.grey[300],
            ),
          ),
        ],
      );

  _buildBodyWidget() => SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 32.0, right: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildBatteryWidget(),
              ],
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            setState(() {
              _reverseAnimation = !_reverseAnimation;
            });
            if (_reverseAnimation) {
              _controller.reverse();
            } else
              _controller.forward();
          },
          icon: Icon(_reverseAnimation ? Icons.battery_alert : Icons.battery_charging_full_sharp, color: _reverseAnimation ? Colors.redAccent: Colors.lightGreen ,),
          label: Text(_reverseAnimation ? 'Discharging' : 'Charging', style: TextStyle(color: _reverseAnimation ? Colors.redAccent: Colors.lightGreen ,),)),
      appBar: AppBar(
        title: const Text('Battery Animation Demo'),
        centerTitle: true,
      ),
      body: _buildBodyWidget(),
    );
  }
}
