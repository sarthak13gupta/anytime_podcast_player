import 'package:anytime/l10n/L.dart';
import 'package:anytime/ui/widgets/search_slide_route.dart';
import 'package:flutter/material.dart';

import 'search.dart';

class SearchBar extends StatefulWidget {
  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: TextField(
        controller: _searchController,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(hintText: L.of(context).search_for_podcasts_hint, border: InputBorder.none),
        style: const TextStyle(color: Colors.grey, fontSize: 18.0),
        onSubmitted: (value) async {
          await Navigator.push(context, SlideRightRoute(widget: Search(searchTerm: value)));
          _searchController.clear();
        },
      ),
      trailing: IconButton(
          tooltip: L.of(context).clear_search_button_label,
          icon: Icon(_searchController.text.isEmpty ? Icons.search : Icons.clear),
          onPressed: _searchController.text.isEmpty
              ? () {}
              : () {
                  _searchController.clear();
                  FocusScope.of(context).requestFocus(FocusNode());
                }),
    );
  }
}
