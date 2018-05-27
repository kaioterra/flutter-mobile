// Copyright 2018 The Flutter Architecture Sample Authors. All rights reserved.
// Use of this source code is governed by the MIT license that can be found
// in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:invoiceninja/redux/product/product_actions.dart';
import 'package:invoiceninja/data/models/models.dart';
import 'package:invoiceninja/ui/product/product_details.dart';
import 'package:invoiceninja/redux/app/app_state.dart';

class ProductDetails extends StatelessWidget {
  final int id;

  ProductDetails({Key key, @required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      //ignoreChange: (state) => productSelector(state.product().list, id).isNotPresent,
      converter: (Store<AppState> store) {
        return _ViewModel.from(store, id);
      },
      builder: (context, vm) {
        return DetailsScreen(
          product: vm.product,
          onDelete: vm.onDelete,
          onSaveClicked: vm.onSaveClicked,
        );
      },
    );
  }
}

class _ViewModel {
  final ProductEntity product;
  final Function onDelete;
  final Function(ProductEntity) onSaveClicked;

  _ViewModel({
    @required this.product,
    @required this.onDelete,
    @required this.onSaveClicked,
  });

  factory _ViewModel.from(Store<AppState> store, int id) {
    //final product = productSelector(productsSelector(store.state), id).value;
    final product = store.state.productState().map[id];

    return _ViewModel(
      product: product,
      onDelete: () => false, //store.dispatch(DeleteProductAction(product.id)),
      onSaveClicked: (ProductEntity product) {
        store.dispatch(UpdateProductAction(product));
      },
    );
  }
}