import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter();
  await Hive.openBox('myFavBox');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
              seedColor: Color.fromARGB(255, 190, 131, 235)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];
  var box = Hive.box('myFavBox');

  void loadFavorites() {
    //favorites = stringListToWordPairs(
    //(box.get('FavoritesList')?.cast<List<List<String>>>() ?? []));
    List<List<String>> stringList =
        box.get('FavoritesList').cast<List<String>>();
    favorites = stringListToWordPairs(stringList);
    print(stringList);
    print('BOBs ur uncle');
    print(favorites);
  }

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    box.put('FavoritesList', wordPairsToStringList(favorites));
    // print('MAMA MIA');
    // print(favorites);
    // print(wordPairsToStringList(favorites));
    // print(stringListToWordPairs(wordPairsToStringList(favorites)));
    notifyListeners();
  }

  void removeFavorite(pair) {
    favorites.remove(pair);
    box.put('FavoritesList', wordPairsToStringList(favorites));
    notifyListeners();
  }

  List<List<String>> wordPairsToStringList(List<WordPair> wordPairList) {
    List<List<String>> returnList = [];
    for (WordPair wordPair in wordPairList) {
      returnList.add([wordPair.first, wordPair.second]);
    }
    return returnList;
  }

  List<WordPair> stringListToWordPairs(List<List<String>> stringListList) {
    List<WordPair> returnList = [];
    for (List<String> stringList in stringListList) {
      returnList.add(WordPair(stringList[0], stringList[1]));
    }
    return returnList;
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  // @override
  // void initState() {
  //   super.initState();
  //   final appState = Provider.of<MyAppState>(context, listen: false);
  //   appState.loadFavorites();
  //   print("Hellooo");
  // }

  // final box = Hive.box('myFavBox');
  // @override
  // void initState() {
  //   super.initState();
  //   _refreshItems();
  // }

  // void _refreshItems() {
  //   final appState = Provider.of<MyAppState>(context, listen: false);
  //   setState(() {
  //     var fav = box.get('myFavBox').cast<WordPair>();
  //     print("OMGOMGOMG");
  //     print(fav);
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 500,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    appState.loadFavorites();
    var favorites = appState.favorites;

    if (favorites.isEmpty) {
      return Center(
        child: Text('No favorites yet'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have ${favorites.length} favorites'),
        ),
        for (var pair in favorites)
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: Icon(Icons.favorite),
              title: Text(pair.asLowerCase),
              onTap: () {
                appState.removeFavorite(pair);

                print('OnTap pressed');
                print(favorites);
              },
            ),
          ),
      ],
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  print('Next pressed');
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayLarge!.copyWith(
      color: theme.colorScheme.onPrimary,
      fontFamily: 'Times',
    );

    return Card(
      margin: EdgeInsets.only(left: 10, right: 10),
      elevation: 10,
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            pair.asLowerCase,
            style: style,
            semanticsLabel: "${pair.first} ${pair.second}",
          ),
        ),
      ),
    );
  }
}
