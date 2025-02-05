import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../api/invoice_api.dart';
import '../../api/invoice_charge_api.dart';
import '../../model/invoice_charge_model.dart';
import '../components/dialog.dart';
import '../components/snack_bar.dart';
import 'add_invoice_charge_screen.dart';
import 'components/item_list.dart';

class InvoiceChargesScreen extends StatefulWidget {
  final List<InvoiceChargeModel> selectedChargesFromAddInvoiceScreen;
  final void Function(List<InvoiceChargeModel>) onSaveSelectedCharges;
  const InvoiceChargesScreen({
    Key? key,
    required this.selectedChargesFromAddInvoiceScreen,
    required this.onSaveSelectedCharges,
  }) : super(key: key);

  static const String id = "invoiceCharges";
  static void launchScreen({required BuildContext context, 
  required List<InvoiceChargeModel> selectedChargesFromAddInvoiceScreen, 
  required Function(List<InvoiceChargeModel>) onSaveSelectedCharges}) {

  }

  @override
  State<InvoiceChargesScreen> createState() => _InvoiceChargesScreenState();
}

class _InvoiceChargesScreenState extends State<InvoiceChargesScreen> {
  late InvoiceChargeProvider provider;

  @override
  void initState() {
    super.initState();
    provider = Provider.of<InvoiceChargeProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getSelectedCharges();
    });
  }

  getSelectedCharges() {
    provider.setSelectedChargesFromAddInvoiceScreen(
        widget.selectedChargesFromAddInvoiceScreen);
  }

  addChargesToAddInvoiceScreen() {
    widget.onSaveSelectedCharges(provider.selectedCharges.toList());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InvoiceChargeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('other charges'),
        actions: [_buildSaveButton()],
      ),
      body: ListView(
        padding: EdgeInsets.only(
          top: 10,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).size.height * 0.1,
        ),
        children: [
          // === add charge button
          Container(
            margin: const EdgeInsets.only(
              top: 10,
            ),
            child: InkWell(
              onTap: () {
                AddInvoiceChargeScreen.launchScreen(context: context, indexCharge: 0, isEditMode: false);
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 10,
                  bottom: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/add_charges.png",
                      width: 20,
                      height: 20,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text(
                      'add new charge',
                    )
                  ],
                ),
              ),
            ),
          ),
          // === add charge button

          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 20),
            child: const Divider(),
          ),

          Builder(builder: (context) {
            if (provider.selectedCharges.isNotEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'previous charges',
                  ),
                  ListView.builder(
                    itemCount: provider.selectedCharges.length,
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(top: 10),
                    itemBuilder: (ctx, index) {
                      return ItemListChargesInvoice(
                        model: provider.selectedCharges[index],
                        onTap: () {
                          provider.changeSelectedCharges(index: index);
                        },
                        onEdit: () {
                          AddInvoiceChargeScreen.launchScreen(context: context, indexCharge: index, isEditMode: true);
                        },
                        onDelete: () {
                          if (provider.selectedCharges[index].isSelected) {
                            showSnackBar(
                              context: context,
                              text: 'delete selected charge',
                              snackBarType: SnackBarType.error,
                            );
                          } else {
                            Future.delayed(
                              const Duration(seconds: 0),
                              () {
                                showCustomAlertDialog(
                                  title: 'delete',
                                  subTitle: 'are you sure want to delete charge?',
                                  context: context,
                                  leftButtonText:'yes',
                                  rightButtonText: 'cancel',
                                  onLeftButtonClicked: () {
                                    Navigator.of(context).pop();
                                    provider.deleteCharge(index);
                                    Provider.of<InvoicesProvider>(
                                      context,
                                      listen: false,
                                    ).changeFullSelectedChargesFromInvoiceChargesScreen(
                                      newList:
                                          provider.selectedCharges.toList(),
                                    );
                                    showSnackBar(
                                      context: context,
                                      text: 'Delete charge success',
                                      snackBarType: SnackBarType.success,
                                    );
                                  },
                                  onRightButtonClicked: () {
                                    Navigator.of(context).pop();
                                  },
                                );
                              },
                            );
                          }
                        },
                      );
                    },
                  ),
                ],
              );
            }
            return const Opacity(opacity: 0);
          })
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
      child: TextButton(
        onPressed: () {
          addChargesToAddInvoiceScreen();
        },
        child: const Text('save'),
      ),
    );
  }
}
