import 'package:flutter/material.dart' show immutable, ScrollController;

/// Typedef for the pagination function that returns a Future of [PaginationReturn]
typedef PaginationFunction = Future<PaginationReturn?> Function();

/// A class representing the return value of the pagination function
@immutable
final class PaginationReturn {
  final bool shouldStopController;
  final bool increment;

  const PaginationReturn({
    this.shouldStopController = false,
    this.increment = false,
  });
}

/// A controller for handling pagination with a ScrollController
class PaginationScrollController {
  /// Number of items per page
  final int perPage;

  /// Initial index to start pagination
  final int initialStartIndex;

  /// Initial current page number
  final int initialCurrentPage;

  /// Scroll controller to detect scroll events
  late ScrollController scrollController;

  /// Flag to indicate if a load action is in progress
  bool isLoading = false;

  /// Flag to indicate if loading should be stopped
  bool stopLoading = false;

  /// Current page number
  int currentPage;

  /// Start index for the current page
  late int startIndex;

  /// End index for the current page
  late int endIndex;

  /// Boundary offset for triggering pagination
  final double boundaryOffset;

  /// Function to load more items
  final PaginationFunction loadAction;

  PaginationScrollController({
    required this.loadAction,
    this.initialStartIndex = 0,
    this.initialCurrentPage = 1,
    this.boundaryOffset = 0.75,
    this.perPage = 10,
    PaginationFunction? initAction,
  }) : currentPage = initialCurrentPage {
    if (initAction != null) {
      _initialize(initAction);
    }

    scrollController = ScrollController()..addListener(scrollListener);
    _updateIndices();
  }

  Future<void> _initialize(PaginationFunction initAction) async {
    isLoading = true;
    final paginationReturn = await initAction();
    isLoading = false;

    if (paginationReturn == null) return;

    if (paginationReturn.increment) {
      incrementPage();
    }
    if (paginationReturn.shouldStopController) {
      stopLoading = true;
    }
  }

  /// Listener for the scroll controller to detect when to load more items
  Future<void> scrollListener() async {
    if (stopLoading || isLoading) return;

    final position = scrollController.position.maxScrollExtent * boundaryOffset;
    if (scrollController.offset < position) return;

    isLoading = true;
    final paginationReturn = await loadAction();
    isLoading = false;

    if (paginationReturn == null) return;

    if (paginationReturn.increment) {
      incrementPage();
    }
    if (paginationReturn.shouldStopController) {
      stopLoading = true;
    }
  }

  /// Getter to check if the current page is the first page
  bool get inFirstPage => currentPage == initialCurrentPage;

  /// Increment the current page and update indices
  void incrementPage() {
    currentPage++;
    _updateIndices();
  }

  /// Update the start and end indices based on the current page
  void _updateIndices() {
    startIndex =
        initialStartIndex + (currentPage - initialCurrentPage) * perPage;
    endIndex = startIndex + perPage - 1;
  }

  /// Reset the pagination to the initial state
  void reset() {
    currentPage = initialCurrentPage;
    _updateIndices();
  }

  /// Dispose the scroll controller and remove the listener
  void dispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
  }
}
