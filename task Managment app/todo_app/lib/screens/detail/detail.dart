
import 'package:flutter/material.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/screens/detail/Widgets/date_picker.dart';
import 'package:todo_app/screens/detail/Widgets/task_timeline.dart';
import 'package:todo_app/screens/detail/Widgets/task_title.dart';



class DetailPage extends StatelessWidget {
  final Task task;

  const DetailPage(this.task, {super.key});

  @override
  Widget build(BuildContext context) {
    final detailedList = task.desc;
    return Scaffold(
      backgroundColor: Colors.black,
      body: CustomScrollView(
        slivers: <Widget>[
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DatePicker(),
                  TaskTitle(),
                ],
              ),
            ),
          ),
          detailedList == null || detailedList.isEmpty
              ? SliverFillRemaining(
            child: Container(
              color: Colors.white,
              child: const Center(
                child: Text(
                  'No tasks yet',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          )
              : SliverList(
            delegate: SliverChildBuilderDelegate(
                  (_, index) => TaskTimeline(detailedList[index]),
              childCount: detailedList.length,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 90,
      backgroundColor: Colors.black,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back_ios),
        iconSize: 20,
        color: Colors.white,
      ),
      actions: const [
        Icon(
          Icons.more_vert,
          color: Colors.white,
          size: 30,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${task.title} tasks',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Your tasks',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}