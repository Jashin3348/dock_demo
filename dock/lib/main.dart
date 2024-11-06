import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: DockDemo(),
    );
  }
}

class DockDemo extends StatefulWidget {
  const DockDemo({super.key});

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

  Map<int, Offset> iconPositions = {};
  List<int?> dockSlots = List.generate(5, (index) => index); // Fixed slots in dock
  int? draggedIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[800],
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 100,
              width: dockSlots.where((slot) => slot != null).length * 70.0,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(dockSlots.length, (slotIndex) {
                  return _buildDockSlot(slotIndex);
                }),
              ),
            ),
          ),
          ...iconPositions.entries.map((entry) {
            return Positioned(
              left: entry.value.dx,
              top: entry.value.dy,
              child: _buildDraggableIcon(entry.key, inDock: false),
            );
          })
        ],
      ),
    );
  }

  Widget _buildDockSlot(int slotIndex) {
    final iconIndex = dockSlots[slotIndex];
    return DragTarget<int>(
      onAccept: (fromIndex) {
        setState(() {
          // Place the icon in the specific slot
          dockSlots[slotIndex] = fromIndex;
          iconPositions.remove(fromIndex);
        });
      },
      builder: (context, acceptedData, rejectedData) {
        return Container(
          width: 70,
          height: 70,
          alignment: Alignment.center,
          child: iconIndex != null
              ? _buildDraggableIcon(iconIndex, inDock: true)
              : const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildDraggableIcon(int index, {required bool inDock}) {
    return LongPressDraggable<int>(
      data: index,
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
      onDragEnd: (details) {
        setState(() {
          if (inDock) {
            // Remove from dock and add to floating positions
            dockSlots[dockSlots.indexOf(index)] = null;
            iconPositions[index] = details.offset;
          } else {
            // Check if icon should snap back to dock
            _snapToDockOrKeepPosition(index, details.offset);
          }
          draggedIndex = null;
        });
      },
      child: inDock && iconPositions.containsKey(index)
          ? const SizedBox.shrink()
          : _buildIcon(index),
    );
  }

  void _snapToDockOrKeepPosition(int index, Offset offset) {
    // Determine if the icon is near enough to the dock to snap back
    final dockCenterY = MediaQuery.of(context).size.height - 120; // Adjust based on dock height
    final dockCenterX = MediaQuery.of(context).size.width / 2;
    bool isNearDock = (offset.dy > dockCenterY - 50 && offset.dy < dockCenterY + 50);

    if (isNearDock) {
      // Find the first empty slot and snap the icon to it
      for (int i = 0; i < dockSlots.length; i++) {
        if (dockSlots[i] == null) {
          dockSlots[i] = index;
          iconPositions.remove(index); // Clear from free space positions
          return;
        }
      }
    } else {
      iconPositions[index] = offset; // Keep icon in free space if not near dock
    }
  }

  Widget _buildIcon(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Icon(
        icons[index],
        color: Colors.white,
        size: 50,
      ),
    );
  }
}
