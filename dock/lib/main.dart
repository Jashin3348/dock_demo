import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DockDemo(),
    );
  }
}

class DockDemo extends StatefulWidget {
  @override
  _DockDemoState createState() => _DockDemoState();
}

class _DockDemoState extends State<DockDemo> {
  List<IconData> icons = [
    Icons.home,
    Icons.search,
    Icons.settings,
    Icons.star,
    Icons.favorite,
  ];

  int? draggedIndex;
  int? targetIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[800],
      body: Center(
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(icons.length, (index) {
              return _buildDraggableIcon(index);
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildDraggableIcon(int index) {
    return LongPressDraggable<int>(
      data: index,
      child: DragTarget<int>(
        onAccept: (fromIndex) {
          setState(() {
            final temp = icons[fromIndex];
            icons[fromIndex] = icons[index];
            icons[index] = temp;
            targetIndex = null; 
          });
        },
        onWillAccept: (fromIndex) {
          setState(() {
            targetIndex = index;
          });
          return true;
        },
        onLeave: (_) {
          setState(() {
            targetIndex = null;
          });
        },
        builder: (context, acceptedData, rejectedData) {
          double scale = targetIndex == index ? 1.2 : 1.0;
          return AnimatedContainer(
            duration: Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            margin: EdgeInsets.symmetric(horizontal: 8),
            child: Transform.scale(
              scale: scale,
              child: Icon(
                icons[index],
                color: Colors.white,
                size: 50,
              ),
            ),
          );
        },
      ),
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.1,
          child: Icon(
            icons[index],
            color: Colors.white.withOpacity(0.75),
            size: 50,
          ),
        ),
      ),
      onDragStarted: () => setState(() => draggedIndex = index),
      onDragCompleted: () => setState(() => draggedIndex = null),
      onDraggableCanceled: (velocity, offset) => setState(() => draggedIndex = null),
    );
  }
}
