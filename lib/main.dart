import 'package:bt_c3/config.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BT_C3',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Salad'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ScrollController verticalScrollController = ScrollController();
  final ScrollController horizontalScrollController = ScrollController();
  bool isDarkMode = false;
  bool showGridLoadMore = false;
  int gridItemCount = Config.itemAmount;

  @override
  void initState() {
    super.initState();
    verticalScrollController.addListener(onVerticalScroll);
  }

  void onVerticalScroll() {
    if (verticalScrollController.offset >=
            verticalScrollController.position.maxScrollExtent &&
        !verticalScrollController.position.outOfRange) {
      setState(() {
        showGridLoadMore = !showGridLoadMore;
      });
      Future.delayed(
        const Duration(seconds: 1),
        () {
          setState(() {
            showGridLoadMore = !showGridLoadMore;
            gridItemCount += Config.itemIncrement;
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = isDarkMode ? Config.darkModeColor : Colors.white;
    Color secondColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: buildAppBar(
        primaryColor: primaryColor,
        secondColor: secondColor,
      ),
      body: Container(
        color: primaryColor,
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              flex: 1,
              child: buildListView(),
            ),
            buildSortBy(labelColor: secondColor),
            Expanded(
              flex: 4,
              child: buildGridView(),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget buildAppBar({
    required Color primaryColor,
    required Color secondColor,
  }) {
    return AppBar(
      backgroundColor: primaryColor,
      leading: Icon(
        Icons.arrow_back,
        color: secondColor,
      ),
      title: Text(
        widget.title,
        style: TextStyle(
          color: secondColor,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
      actions: [
        InkWell(
          onTap: () {
            setState(() {
              isDarkMode = !isDarkMode;
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Icon(
              Icons.search,
              color: secondColor,
            ),
          ),
        )
      ],
      elevation: 0,
    );
  }

  Widget buildListView() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 2,
      scrollDirection: Axis.horizontal,
      itemBuilder: (BuildContext context, int index) {
        return saladItem(
            title1: 'Salad',
            title2: 'Many recipes',
            image: "assets/images/salad_landscape.jpg");
      },
      separatorBuilder: (BuildContext context, int index) {
        return const SizedBox(width: 20);
      },
    );
  }

  Widget buildGridView() {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async {
            setState(() {
              gridItemCount = Config.itemAmount;
            });
          },
          child: GridView.builder(
            controller: verticalScrollController,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.7,
            ),
            itemBuilder: (context, index) {
              return saladItem(
                title1: "Salad $index",
                title2: "The one who made Salad $index",
                image: "assets/images/salad_portrait.webp",
                inGrid: true,
              );
            },
            itemCount: gridItemCount,
          ),
        ),
        if (showGridLoadMore)
          const Positioned(
            left: 0,
            right: 0,
            bottom: 10,
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.grey,
              ),
            ),
          ),
      ],
    );
  }

  Widget saladItem({
    required String title1,
    required String title2,
    required String image,
    bool inGrid = false,
  }) {
    int padding = inGrid ? 56 : 40;
    int widthRatio = inGrid ? 2 : 1;
    double heightRatio = inGrid ? 0.3 : 1 / 6;
    bool bookmarkStatus = false;

    return Stack(
      children: [
        Container(
          width: (MediaQuery.of(context).size.width - padding) / widthRatio,
          height: MediaQuery.of(context).size.height * heightRatio,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(image, fit: BoxFit.fitHeight),
          ),
        ),
        Container(
          width: (MediaQuery.of(context).size.width - padding) / widthRatio,
          height: MediaQuery.of(context).size.height * heightRatio,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.transparent,
                Colors.transparent,
                Colors.black,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white),
          ),
        ),
        Positioned(
          left: 12,
          right: 12,
          bottom: 12,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title1,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              inGrid
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipOval(
                          child: Container(
                            color: Colors.white,
                            height: 20,
                            width: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            title2,
                            style: const TextStyle(color: Colors.white),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      title2,
                      style: const TextStyle(color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
            ],
          ),
        ),
        if (inGrid)
          Positioned(
            top: 12,
            right: 12,
            child: StatefulBuilder(
              builder: (context, setState) => InkWell(
                onTap: () {
                  setState(() {
                    bookmarkStatus = !bookmarkStatus;
                  });
                },
                child: ClipOval(
                  child: Container(
                    width: 44,
                    height: 44,
                    color: Colors.redAccent,
                    child: Visibility(
                      replacement: const Icon(
                        Icons.bookmark_border,
                        color: Colors.white,
                      ),
                      visible: bookmarkStatus,
                      child: const Icon(
                        Icons.bookmark,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
      ],
    );
  }

  Widget buildSortBy({required Color labelColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Sort by",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: labelColor,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                "Most Popular",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                  fontSize: 16,
                ),
              ),
              SizedBox(width: 12),
              Icon(
                Icons.swap_vert,
                color: Colors.redAccent,
                size: 24,
              ),
            ],
          )
        ],
      ),
    );
  }
}
