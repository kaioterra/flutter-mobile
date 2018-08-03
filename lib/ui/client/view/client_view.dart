import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:invoiceninja_flutter/data/models/models.dart';
import 'package:invoiceninja_flutter/redux/app/app_state.dart';
import 'package:invoiceninja_flutter/redux/invoice/invoice_actions.dart';
import 'package:invoiceninja_flutter/ui/app/actions_menu_button.dart';
import 'package:invoiceninja_flutter/ui/app/buttons/edit_icon_button.dart';
import 'package:invoiceninja_flutter/ui/client/view/client_view_activity.dart';
import 'package:invoiceninja_flutter/ui/client/view/client_view_details.dart';
import 'package:invoiceninja_flutter/ui/client/view/client_view_vm.dart';
import 'package:invoiceninja_flutter/ui/client/view/client_view_overview.dart';
import 'package:invoiceninja_flutter/utils/localization.dart';

class ClientView extends StatefulWidget {
  final ClientViewVM viewModel;

  const ClientView({
    Key key,
    @required this.viewModel,
  }) : super(key: key);

  @override
  _ClientViewState createState() => _ClientViewState();
}

class _ClientViewState extends State<ClientView>
    with SingleTickerProviderStateMixin {
  TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(vsync: this, length: 3);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    final store = StoreProvider.of<AppState>(context);
    final viewModel = widget.viewModel;
    final client = viewModel.client;

    return WillPopScope(
      onWillPop: () async {
        viewModel.onBackPressed();
        return true;
      },
      child: Scaffold(
        backgroundColor: Theme
            .of(context)
            .backgroundColor,
        appBar: _CustomAppBar(
          viewModel: viewModel,
          controller: _controller,
        ),
        body: CustomTabBarView(
          viewModel: viewModel,
          controller: _controller,
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Theme
              .of(context)
              .primaryColorDark,
          onPressed: () {
            showDialog<SimpleDialog>(
              context: context,
              builder: (BuildContext context) =>
                  SimpleDialog(children: <Widget>[
                    ListTile(
                      dense: true,
                      leading: Icon(Icons.add_circle_outline),
                      title: Text(localization.invoice),
                      onTap: () {
                        Navigator.of(context).pop();
                        store.dispatch(EditInvoice(
                            invoice: InvoiceEntity()
                                .rebuild((b) => b.clientId = client.id),
                            context: context));
                      },
                    ),
                    ListTile(
                      dense: true,
                      leading: Icon(Icons.add_circle_outline),
                      title: Text(localization.quote),
                      onTap: () {},
                    ),
                    ListTile(
                      dense: true,
                      leading: Icon(Icons.add_circle_outline),
                      title: Text(localization.payment),
                      onTap: () {},
                    ),
                    ListTile(
                      dense: true,
                      leading: Icon(Icons.add_circle_outline),
                      title: Text(localization.expense),
                      onTap: () {},
                    ),
                    ListTile(
                      dense: true,
                      leading: Icon(Icons.add_circle_outline),
                      title: Text(localization.task),
                      onTap: () {},
                    ),
                  ]),
            );
          },
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          tooltip: localization.create,
        ),
      ),
    );
  }
}

class CustomTabBarView extends StatefulWidget {
  const CustomTabBarView({
    @required this.viewModel,
    @required this.controller,
  });

  final ClientViewVM viewModel;
  final TabController controller;

  @override
  _CustomTabBarViewState createState() => _CustomTabBarViewState();
}

class _CustomTabBarViewState extends State<CustomTabBarView> {

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTabChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTabChange);
    super.dispose();
  }

  void _onTabChange() {
    final viewModel = widget.viewModel;

    if (widget.controller.index == 2 && viewModel.client.activities.isEmpty &&
        !viewModel.isLoading) {
      viewModel.onRefreshed(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;

    return TabBarView(
      controller: widget.controller,
      children: <Widget>[
        RefreshIndicator(
          onRefresh: () => viewModel.onRefreshed(context),
          child: ClientOverview(viewModel: viewModel),
        ),
        RefreshIndicator(
          onRefresh: () => viewModel.onRefreshed(context),
          child: ClientViewDetails(client: viewModel.client),
        ),
        RefreshIndicator(
          onRefresh: () => viewModel.onRefreshed(context),
          child: ClientViewActivity(client: viewModel.client),
        ),
      ],
    );
  }
}

class _CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _CustomAppBar({
    @required this.viewModel,
    @required this.controller,
  });

  final ClientViewVM viewModel;
  final TabController controller;

  @override
  final Size preferredSize = const Size(double.infinity, 100.0);

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalization.of(context);
    final client = viewModel.client;

    return AppBar(
      title:
      Text(client.displayName ?? ''), // Text(localizations.clientDetails),
      bottom: TabBar(
        controller: controller,
        //isScrollable: true,
        tabs: [
          Tab(
            text: localization.overview,
          ),
          Tab(
            text: localization.details,
          ),
          Tab(
            text: localization.activity,
          ),
        ],
      ),
      actions: client.isNew
          ? []
          : [
        EditIconButton(
          isVisible: !client.isDeleted,
          onPressed: () => viewModel.onEditPressed(context),
        ),
        ActionMenuButton(
          isSaving: viewModel.isSaving,
          entity: client,
          onSelected: viewModel.onActionSelected,
        )
      ],
    );
  }
}
