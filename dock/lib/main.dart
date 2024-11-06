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

  Map<int, Offset> iconPositions = {}; // Track floating icon positions
  List<int> dockSlots = [0, 1, 2, 3, 4]; // Track icons in dock by index
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
              width: dockSlots.length * 70.0,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(dockSlots.length, (slotIndex) {
                    return _buildDockSlot(slotIndex);
                  }),
                ),
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
          // Remove icon from floating and add it to dock in this slot
          if (!dockSlots.contains(fromIndex)) {
            dockSlots.add(fromIndex);
            dockSlots.sort(); // Ensure dock slots remain ordered
          }
          iconPositions.remove(fromIndex);
        });
      },
      builder: (context, acceptedData, rejectedData) {
        return Container(
          width: 70,
          height: 70,
          alignment: Alignment.center,
          child: iconIndex != null && dockSlots.contains(iconIndex)
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
            // Remove from dock and place in floating positions
            dockSlots.remove(index);
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
    // Check if the icon is near enough to the dock to snap back
    final dockCenterY = MediaQuery.of(context).size.height - 120; // Adjust based on dock height
    bool isNearDock = (offset.dy > dockCenterY - 50 && offset.dy < dockCenterY + 50);

    if (isNearDock) {
      if (!dockSlots.contains(index)) {
        dockSlots.add(index); // Add back to dock
        dockSlots.sort(); // Keep dock in original order
      }
      iconPositions.remove(index); // Remove from floating position
    } else {
      iconPositions[index] = offset; // Keep icon in floating space
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
