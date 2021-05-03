import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  Offset _startLastOffset = Offset.zero;
  Offset _lastOffset = Offset.zero;
  Offset _currentOffset = Offset.zero;
  double _lastScale = 1.0;
  double _currentScale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestures & Scale'),
      ),
      body: _buildBody(context),
    );
  }

  Transform _transformScaleAndTranslate(){
    return Transform.scale(
      scale: _currentScale,
      child: Transform.translate(
        offset: _currentOffset,
        child: Image(
          image: AssetImage('assets/images/elephant.jpg'),
        ),
      ),
    );
  }

  Transform _transformMatrix4(){
    return Transform(
      transform: Matrix4.identity()
          ..scale(_currentScale,_currentScale)
          ..translate(_currentOffset.dx,_currentOffset.dy),
      alignment: FractionalOffset.center,
      child: Image(
        image: AssetImage('assets/images/elephant.jpg'),
      ),
    );
  }

  Positioned _positionedStatusBar(BuildContext context){
    return Positioned(
      top: 0.0,
      width: MediaQuery.of(context).size.width,
      child: Container(
        color: Colors.white54,
        height: 50.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              'Scale: ${_currentScale.toStringAsFixed(4)}'),
            Text(
              'Current: $_currentOffset',
            ),
          ],
        ),
      ),
    );
  }

  void _onScaleStart(ScaleStartDetails details){
    print('ScaleStartDetails: $details');

    _startLastOffset = details.focalPoint;
    _lastOffset = _currentOffset;
    _lastScale = _currentScale;
  }

  void _onScaleUpdate(ScaleUpdateDetails details){
    print('ScaleUpdateDetails: $details - Scale: ${details.scale}');
    if(details.scale != 1.0){
      //Scaling
      double currentScale = _lastScale * details.scale;
      if(currentScale < 0.5){
        currentScale = 0.5;
      }
      setState(() {
        _currentScale = currentScale;
      });
      print('_scale: $_currentScale - lastScale: $_lastScale');
    }else if(details.scale == 1.0){
      //we are not scaling but dragging around screen
      //calculate offset depending on current image scaling.
      Offset offsetAdjustedForScale = (_startLastOffset - _lastOffset)/_lastScale;
      Offset currentOffset = details.focalPoint - (offsetAdjustedForScale * _currentScale);
      setState(() {
        _currentOffset = currentOffset;
      });
      print('offsetAdjustedForScale: $offsetAdjustedForScale - _currentOffset: $_currentOffset');
    }
  }

  void _onDoubleTap(){
    print('onDoubleTap');

    //calculate current scale and populate the _lastScale with currentScale
    //if currentScale is greater than 16 times the original image, reset scale to default, 1.0
    double currentScale = _lastScale * 2.0;
    if(currentScale > 16.0){
      currentScale = 1.0;
      _resetToDefaultValues();
    }
    _lastScale = currentScale;

    setState(() {
      _currentScale = currentScale;
    });
  }

  void _onLongPress(){
    print('onLongPress');
    setState(() {
      _resetToDefaultValues();
    });
  }

  void _resetToDefaultValues(){
    _startLastOffset = Offset.zero;
    _lastOffset = Offset.zero;
    _currentOffset = Offset.zero;
    _lastScale = 1.0;
    _currentScale = 1.0;
  }

  Widget _buildBody(BuildContext context){
      return GestureDetector(
        child: Stack(
          fit: StackFit.expand,
          children: [
            _transformScaleAndTranslate(),
            //_transformMatrix4(),
            _positionedStatusBar(context)
          ],
        ),
        onScaleStart: _onScaleStart,
        onScaleUpdate: _onScaleUpdate,
        onDoubleTap: _onDoubleTap,
        onLongPress: _onLongPress,
      );
  }
}
