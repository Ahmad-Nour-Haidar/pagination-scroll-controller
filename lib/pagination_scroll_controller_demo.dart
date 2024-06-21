import 'dart:math';

import 'package:flutter/material.dart';
import 'pagination_controller.dart';

class PaginationScrollControllerDemo extends StatefulWidget {
  const PaginationScrollControllerDemo({super.key});

  @override
  State<PaginationScrollControllerDemo> createState() =>
      _PaginationScrollControllerDemoState();
}

class _PaginationScrollControllerDemoState
    extends State<PaginationScrollControllerDemo> {
  late PaginationScrollController _paginationScrollController;

  Future<bool> getDataApi() async {
    await Future.delayed(const Duration(seconds: 3));
    return Random().nextBool();
  }

  Future<PaginationReturn?> getData() async {
    final response = await getDataApi();
    if (response) {
      return const PaginationReturn(
        increment: true,
      );
    } else {
      return null;
    }
  }

  @override
  void initState() {
    _paginationScrollController = PaginationScrollController(
      loadAction: getData,
    );
    super.initState();
  }

  @override
  void dispose() {
    _paginationScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        controller: _paginationScrollController.scrollController,
        children: const [
          // your widgets
        ],
      ),
    );
  }
}
