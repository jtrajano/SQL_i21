Ext.define('Inventory.view.InventoryReceiptViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.icinventoryreceipt',

    config: {
        searchConfig: {
            title:  'Search Inventory Receipt',
            type: 'Inventory.InventoryReceipt',
            api: {
                read: '../Inventory/api/Receipt/SearchReceipts'
            },
            columns: [
                {dataIndex: 'intInventoryReceiptId',text: "Receipt Id", flex: 1, defaultSort:true, dataType: 'numeric', key: true, hidden: true},
                {dataIndex: 'strReceiptNumber', text: 'Receipt No', flex: 1,  dataType: 'string'},
                {dataIndex: 'dtmReceiptDate', text: 'Receipt Date', flex: 1,  dataType: 'date', xtype: 'datecolumn'},
                {dataIndex: 'strReceiptType',text: 'Receipt Type', flex: 1,  dataType: 'string'},
                {dataIndex: 'ysnPosted',text: 'Posted', flex: 1,  dataType: 'boolean', xtype: 'checkcolumn'}
            ]
        },
        binding: {
            bind: {
                title: 'Inventory Receipt - {current.strReceiptNumber}'
            },
            cboReceiptType: {
                value: '{current.strReceiptType}',
                store: '{receiptTypes}',
                readOnly: '{checkReadOnlyWithSource}'
            },
            cboVendor: {
                value: '{current.intVendorId}',
                store: '{vendor}',
                readOnly: '{checkReadOnlyWithSource}',
                hidden: '{checkHiddenInTransferReceipt}'
            },
            txtVendorName: {
                value: '{current.strVendorName}',
                hidden: '{checkHiddenInTransferReceipt}'
            },
            cboTransferor: {
                value: '{current.intTransferorId}',
                store: '{transferor}',
                hidden: '{checkHiddenIfNotTransferReceipt}'
            },
            cboSource: {
                value: '{current.intSourceId}',
                store: '{poSource}',
//                defaultFilters: [{
//                    column: 'intOrderStatusId',
//                    value: 1,
//                    conjunction: 'and'
//                },{
//                    column: 'intVendorId',
//                    value: '{current.intVendorId}',
//                    conjunction: 'and'
//                }],
                readOnly: '{checkReadOnlyWithSource}'
            },
            cboLocation: {
                value: '{current.intLocationId}',
                store: '{location}',
                readOnly: '{current.ysnPosted}'
            },
            dtmReceiptDate: {
                value: '{current.dtmReceiptDate}',
                readOnly: '{current.ysnPosted}'
            },
            cboCurrency: {
                value: '{current.intCurrencyId}',
                store: '{currency}',
                readOnly: '{current.ysnPosted}'
            },
            txtReceiptNumber: {
                value: '{current.strReceiptNumber}'
            },
            txtBlanketReleaseNumber: {
                value: '{current.intBlanketRelease}',
                readOnly: '{current.ysnPosted}'
            },
            txtVendorRefNumber: {
                value: '{current.strVendorRefNo}',
                readOnly: '{current.ysnPosted}'
            },
            txtBillOfLadingNumber: {
                value: '{current.strBillOfLading}',
                readOnly: '{current.ysnPosted}'
            },
            cboShipVia: {
                value: '{current.intShipViaId}',
                store: '{shipvia}',
                readOnly: '{current.ysnPosted}'
            },
            cboShipFrom: {
                value: '{current.intShipFromId}',
                store: '{shipFrom}',
                defaultFilters: [{
                    column: 'intEntityId',
                    value: '{current.intVendorEntityId}'
                }],
                readOnly: '{current.ysnPosted}'
            },
            cboReceiver: {
                value: '{current.intReceiverId}',
                store: '{users}',
                readOnly: '{current.ysnPosted}'
            },
            txtVessel: {
                value: '{current.strVessel}',
                readOnly: '{current.ysnPosted}'
            },
            cboFreightTerms: {
                value: '{current.intFreightTermId}',
                store: '{freightTerm}',
                defaultFilters: [{
                    column: 'ysnActive',
                    value: 'true'
                }],
                readOnly: '{current.ysnPosted}'
            },
            txtFobPoint: {
                value: '{current.strFobPoint}',
                readOnly: '{current.ysnPosted}'
            },
            cboAllocateFreight: {
                value: '{current.strAllocateFreight}',
                store: '{allocateFreights}',
                readOnly: '{current.ysnPosted}'
            },
            txtShiftNumber: {
                value: '{current.intShiftNumber}',
                readOnly: '{current.ysnPosted}'
            },
            txtNotes: {
                value: '{current.strNotes}',
                readOnly: '{current.ysnPosted}'
            },



            grdInventoryReceipt: {
                colItemNo: {
                    dataIndex: 'strItemNo',
                    editor: {
                        store: '{items}',
                        defaultFilters: [{
                            column: 'intLocationId',
                            value: '{current.intLocationId}'
                        }]
                    }
                },
                colDescription: 'strItemDescription',
                colSubLocation: '',
                colLotTracking: 'strLotTracking',
                colQtyOrdered: 'dblOrderQty',
                colQtyToReceive: 'dblOpenReceive',
                colReceived: 'dblReceived',
                colUOM: {
                    dataIndex: 'strUnitMeasure',
                    editor: {
                        store: '{itemUOM}',
                        defaultFilters: [{
                            column: 'intItemId',
                            value: '{grdInventoryReceipt.selection.intItemId}',
                            conjunction: 'and'
                        },{
                            column: 'intLocationId',
                            value: '{current.intLocationId}',
                            conjunction: 'and'
                        }]
                    }
                },
                colUnitCost: 'dblUnitCost',
                colUnitRetail: 'dblUnitRetail',
//                colTax: 'dblUnitCost',
                colLineTotal: 'dblLineTotal',
                colGrossMargin: 'dblGrossMargin',
                colPackages: 'intNoPackages',
                colPackageType: {
                    dataIndex: 'strPackName',
                    editor: {
                        store: '{itemPackType}'
                    }
                }
//                colExpPackageWt: 'dblUnitCost'
            },

            grdLotTracking: {
                colParentLotId: 'strParentLotId',
                colLotId: 'strLotId',
                colLotContainerNo: 'strContainerNo',
                colLotQtyOrdered: 'dblQuantity',
                colLotUom: '',
                colLotUnits: 'intUnits',
                colLotUnitUom: 'intUnitUOMId',
                colLotUnitPerPallet: 'intUnitPallet',
                colLotGrossWeight: 'dblGrossWeight',
                colLotTareWeight: 'dblTareWeight',
                colLotNetWeight: '',
                colLotWeightPerUnit: '',
                colLotStatedGrossPerUnit: 'dblStatedGrossPerUnit',
                colLotStatedTarePerUnit: 'dblStatedTarePerUnit'
            },

            grdIncomingInspection: {
                colInspect: 'ysnSelected',
                colQualityPropertyName: 'strPropertyName'
            },

            // ---- Freight and Invoice Tab
            cboCalculationBasis: {
                value: '{current.strCalculationBasis}',
                store: '{calculationBasis}',
                readOnly: '{current.ysnPosted}'
            },
            txtUnitsWeightMiles: {
                value: '{current.dblUnitWeightMile}',
                readOnly: '{current.ysnPosted}'
            },
            txtFreightRate: {
                value: '{current.dblFreightRate}',
                readOnly: '{current.ysnPosted}'
            },
            txtFuelSurcharge: {
                value: '{current.dblFuelSurcharge}',
                readOnly: '{current.ysnPosted}'
            },
//            txtCalculatedFreight: '{getCalculatedFreight}',

//            txtCalculatedAmount: '{current.strMessage}',
            txtInvoiceAmount: {
                value: '{current.dblInvoiceAmount}',
                readOnly: '{current.ysnPosted}'
            },
//            txtDifference: '{current.strMessage}',
            chkPrepaid: {
                value: '{current.ysnPrepaid}',
                readOnly: '{current.ysnPosted}'
            },
            chkInvoicePaid: {
                value: '{current.ysnInvoicePaid}',
                readOnly: '{current.ysnPosted}'
            },
            txtCheckNo: {
                value: '{current.intCheckNo}',
                readOnly: '{checkHiddenInInvoicePaid}'
            },
            txtCheckDate: {
                value: '{current.dtmCheckDate}',
                readOnly: '{checkHiddenInInvoicePaid}'
            },
//            txtInvoiceMargin: '{current.strMessage}',

            // ---- EDI tab
            cboTrailerType: {
                value: '{current.intTrailerTypeId}',
                store: '{equipmentLength}',
                readOnly: '{current.ysnPosted}'
            },
            txtTrailerArrivalDate: {
                value: '{current.dtmTrailerArrivalDate}',
                readOnly: '{current.ysnPosted}'
            },
            txtTrailerArrivalTime: {
                value: '{current.dtmTrailerArrivalTime}',
                readOnly: '{current.ysnPosted}'
            },
            txtSealNo: {
                value: '{current.strSealNo}',
                readOnly: '{current.ysnPosted}'
            },
            cboSealStatus: {
                value: '{current.strSealStatus}',
                store: '{sealStatuses}',
                readOnly: '{current.ysnPosted}'
            },
            txtReceiveTime: {
                value: '{current.dtmReceiveTime}',
                readOnly: '{current.ysnPosted}'
            },
            txtActualTempReading: {
                value: '{current.dblActualTempReading}',
                readOnly: '{current.ysnPosted}'
            }

        }
    },

    setupContext : function(options){
        "use strict";
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.Receipt', { pageSize: 1 });

        var grdInventoryReceipt = win.down('#grdInventoryReceipt'),
            grdIncomingInspection = win.down('#grdIncomingInspection'),
            grdLotTracking = win.down('#grdLotTracking');

        win.context = Ext.create('iRely.mvvm.Engine', {
            window : win,
            store  : store,
            createRecord : me.createRecord,
            validateRecord: me.validateRecord,
            binding: me.config.binding,
            attachment: Ext.create('iRely.mvvm.attachment.Manager', {
                type: 'Inventory.Receipt',
                window: win
            }),
            details: [
                {
                    key: 'tblICInventoryReceiptItems',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: grdInventoryReceipt,
                        deleteButton : grdInventoryReceipt.down('#btnDeleteInventoryReceipt')
                    }),
                    details: [
                        {
                            key: 'tblICInventoryReceiptItemLots',
                            component: Ext.create('iRely.mvvm.grid.Manager', {
                                grid: grdLotTracking,
                                deleteButton : grdLotTracking.down('#btnDeleteInventoryReceipt')
                            })
                        }
                    ]
                },
                {
                    key: 'tblICInventoryReceiptInspections',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: grdIncomingInspection,
                        position: 'none'
                    })
                }
            ]
        });

        win.context.data.store.on('load', me.onStoreLoad);

        var cepItem = grdInventoryReceipt.getPlugin('cepItem');
        if (cepItem){
            cepItem.on({
                validateedit: me.onEditItem,
                scope: me
            });
        }

        var colTaxDetails = grdInventoryReceipt.columns[11];
        var btnViewTaxDetail = colTaxDetails.items[0];
        if (btnViewTaxDetail){
            btnViewTaxDetail.handler = function(grid, rowIndex, colIndex) {
                var current = grid.store.data.items[rowIndex];
                me.onViewTaxDetailsClick(current.get('intInventoryReceiptItemId'));
            }
        }

        var colReceived = grdInventoryReceipt.columns[6];
        var txtReceived = colReceived.getEditor();
        if (txtReceived){
            txtReceived.on('change', me.onCalculateTotalAmount);
        }
        var colUnitCost = grdInventoryReceipt.columns[10];
        var txtUnitCost = colUnitCost.getEditor();
        if (txtUnitCost){
            txtUnitCost.on('change', me.onCalculateTotalAmount);
        }

        return win.context;
    },

    show : function(config) {
        "use strict";

        var me = this,
            win = this.getView();

        if (config) {
            win.show();

            var context = me.setupContext( {window : win} );

            if (config.action === 'new') {
                context.data.addRecord();
            } else {
                if (config.id) {
                    config.filters = [{
                        column: 'intInventoryReceiptId',
                        value: config.id
                    }];
                }
                context.data.load({
                    filters: config.filters
                });
            }
        }
    },

    createRecord: function(config, action) {
        var today = new Date();
        var record = Ext.create('Inventory.model.Receipt');
        record.set('strReceiptType', 'Direct');
        if (app.DefaultLocation > 0)
            record.set('intLocationId', app.DefaultLocation);
        if (app.UserId > 0)
            record.set('intReceiverId', app.UserId);
        record.set('dtmReceiptDate', today);
        record.set('intBlanketRelease', 0);
        record.set('ysnPosted', false);
        action(record);
    },

    validateRecord: function(config, action) {
        this.validateRecord(config, function(result) {
            if (result) {
                var vm = config.window.viewModel;
                var current = vm.data.current;

                if (current) {
                    //Validate PO Date versus Receipt Date
                    if (current.get('strReceiptType') === 'Purchase Order') {
                        var cboSource = config.window.down('#cboSource');
                        var index = cboSource.store.findExact(cboSource.valueField, cboSource.getValue());
                        var sourcePO = cboSource.store.getAt(index);

                        if (sourcePO){
                            if (sourcePO.get('dtmDate')) {
                                if (current.get('dtmReceiptDate') < sourcePO.get('dtmDate')){
                                    iRely.Functions.showErrorDialog("The Purchase Order Date must not be later than the specified Receipt Date.");
                                    action(false);
                                }
                                else { action(true); }
                            }
                        }
                    }

                    //Validate Logged in User's default location against the selected Location for the receipt
                    if (current.get('strReceiptType') !== 'Direct') {

                        if (app.DefaultLocation > 0) {
                            if (app.DefaultLocation !== current.get('intLocationId')) {
                                var result = function(button) {
                                    if (button === 'yes') {
                                        action(true);
                                    }
                                    else {
                                        action(false);
                                    }
                                };

                                var msgBox = iRely.Functions;
                                msgBox.showCustomDialog(
                                    msgBox.dialogType.WARNING,
                                    msgBox.dialogButtonType.YESNO,
                                    "The Location is different from the default user location. Do you want to continue?",
                                    result
                                );
                            }
                            else { action(true) }
                        }
                        else { action(true) }
                    }
                    else { action(true) }
                }
                else { action(true) }
            }
        });
    },

    onStoreLoad: function(store, records, success, eOpts) {
        if (success === true){
            var win = Ext.WindowManager.getActive();
            var grdInventoryReceipt = win.down('#grdInventoryReceipt');
            var grdLotTracking = win.down('#grdLotTracking');
            var itemPlugin = grdInventoryReceipt.plugins[0];
            var lotPlugin = grdLotTracking.plugins[0];
            var btnReceive = win.down('#btnReceive');
            var btnSave = win.down('#btnSave');
            var btnDelete = win.down('#btnDelete');
            var btnUndo = win.down('#btnUndo');
            var btnDuplicate = win.down('#btnDuplicate');
            var btnNotes = win.down('#btnNotes');

            btnDuplicate.setHidden(true);
            btnNotes.setHidden(true);

            var current = records[0];
            if (current){
                if (current.get('ysnPosted') !== false){
                    itemPlugin.disable();
                    lotPlugin.disable();
                    btnReceive.setText('UnReceive');
                    btnSave.disable();
                    btnDelete.disable();
                    btnUndo.disable();
                }
                else {
                    itemPlugin.enable();
                    lotPlugin.enable();
                    btnReceive.setText('Receive');
                    btnSave.enable();
                    btnDelete.enable();
                    btnUndo.enable();
                }
            }
        }
    },

    onVendorSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var current = win.viewModel.data.current;

        if (current) {
            current.set('strVendorName', records[0].get('strName'));
            current.set('intVendorEntityId', records[0].get('intEntityId'));
            current.set('intCurrencyId', records[0].get('intCurrencyId'));

            current.set('intShipFromId', null);
            current.set('intShipViaId', null);
        }
    },

    onFreightTermSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var current = win.viewModel.data.current;

        if (current) current.set('strFobPoint', records[0].get('strFobPoint'));
    },

    onReceiptItemSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var grdLotTracking = win.down('#grdLotTracking');
        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepItem');
        var current = plugin.getActiveRecord();

        if (combo.column.itemId === 'colItemNo')
        {
            if (win.viewModel.data.current.get('strReceiptType') === 'Direct'){
                current.set('intUnitMeasureId', records[0].get('intReceiveUOMId'));
                current.set('strUnitMeasure', records[0].get('strReceiveUOM'));
            }

            current.set('tblICItemPricings', records[0].tblICItemPricings());
            current.set('intItemId', records[0].get('intItemId'));
            current.set('strItemDescription', records[0].get('strDescription'));
            current.set('strLotTracking', records[0].get('strLotTracking'));
            current.set('dblOpenReceive', 0);


            switch (records[0].get('strLotTracking')){
                case 'Yes - Serial Number':
                    grdLotTracking.plugins[0].enable();
                    var newLot = Ext.create('Inventory.model.ReceiptItemLot', {
                        intInventoryReceiptItemId: current.get('intInventoryReceiptItemId') || current.get('strClientId'),
                        strLotId: '',
                        strContainerNo: '',
                        dblQuantity: '',
                        intUnits: '',
                        intUnitUOMId: '',
                        intUnitPallet: '',
                        dblGrossWeight: '',
                        dblTareWeight: '',
                        intWeightUOMId: '',
                        dblStatedGrossPerUnit: '',
                        dblStatedTarePerUnit: ''
                    });
                    current.tblICInventoryReceiptItemLots().add(newLot);
                    break;

                case 'Yes - Manual':
                    grdLotTracking.plugins[0].enable();
                    break;

                default :
                    grdLotTracking.plugins[0].disable();
                    break;
            }
        }
        else if (combo.column.itemId === 'colUOM')
        {
            current.set('intUnitMeasureId', records[0].get('intItemUnitMeasureId'));
            current.set('dblUnitCost', records[0].get('dblLastCost'));
            current.set('dblUnitRetail', records[0].get('dblLastCost'));
        }
        else if (combo.column.itemId === 'colPackageType')
        {
            current.set('intPackTypeId', records[0].get('intPackTypeId'));
        }
    },

    onViewTaxDetailsClick: function (ReceiptItemId) {
        var win = window;
        var me = win.controller;
        var screenName = 'Inventory.view.InventoryReceiptTaxes';

        Ext.require([
            screenName,
                screenName + 'ViewModel',
                screenName + 'ViewController'
        ], function() {
            var screen = screenName.substring(screenName.indexOf('view.') + 5, screenName.length);
            var view = Ext.create(screenName, { controller: screen.toLowerCase(), viewModel: screen.toLowerCase() });
            var controller = view.getController();
            controller.show({ id: ReceiptItemId});
        });
    },

    onInventoryClick: function(button, e, eOpts) {
        var win = button.up('window');
        var grd = win.down('#grdInventoryReceipt');

        var selected = grd.getSelectionModel().getSelection();

        if (selected) {
            if (selected.length > 0){
                var current = selected[0];
                if (!current.phantom)
                    iRely.Functions.openScreen('Inventory.view.Item', current.get('intItemId'));
            }
        }
    },

    onReceiveClick: function(button, e, eOpts) {
        var me = this;
        var win = button.up('window');
        var context = win.context;

        var doPost = function() {
            var strReceiptNumber = win.viewModel.data.current.get('strReceiptNumber');
            var posted = win.viewModel.data.current.get('ysnPosted');

            var options = {
                postURL             : '../Inventory/api/Receipt/Receive',
                strTransactionId    : strReceiptNumber,
                isPost              : !posted,
                isRecap             : false,
                callback            : me.onAfterReceive,
                scope               : me
            };

            CashManagement.common.BusinessRules.callPostRequest(options);
        };

        // If there is no data change, do the post.
        if (!context.data.hasChanges()){
            doPost();
            return;
        }

        // Save has data changes first before doing the post.
        context.data.saveRecord({
            successFn: function() {
                doPost();
            }
        });
    },

    onRecapClick: function(button, e, eOpts) {
        var me = this;
        var win = button.up('window');
        var cboCurrency = win.down('#cboCurrency');
        var context = win.context;

        var doRecap = function(recapButton, currentRecord, currency){
            "use strict";
            var me = this;

            // Call the buildRecapData to generate the recap data
            CashManagement.common.BusinessRules.buildRecapData({
                postURL: '../Inventory/api/Receipt/Receive',
                strTransactionId: currentRecord.get('strReceiptNumber'),
                ysnPosted: currentRecord.get('ysnPosted'),
                scope: me,
                success: function(){
                    // If data is generated, show the recap screen.
                    CashManagement.common.BusinessRules.showRecap({
                        strTransactionId: currentRecord.get('strReceiptNumber'),
                        ysnPosted: currentRecord.get('ysnPosted'),
                        dtmDate: currentRecord.get('dtmReceiptDate'),
                        strCurrencyId: currency,
                        dblExchangeRate: 1,
                        scope: me,
                        postCallback: function(){
                            me.onReceiveClick(recapButton);
                        },
                        unpostCallback: function(){
                            me.onReceiveClick(recapButton);
                        }
                    });
                },
                failure: function(message){
                    // Show why recap failed.
                    var msgBox = iRely.Functions;
                    msgBox.showCustomDialog(
                        msgBox.dialogType.ERROR,
                        msgBox.dialogButtonType.OK,
                        message
                    );
                }
            });
        };

        // If there is no data change, do the post.
        if (!context.data.hasChanges()){
            doRecap(button, win.viewModel.data.current, cboCurrency.getRawValue());
            return;
        }

        // Save has data changes first before doing the post.
        context.data.saveRecord({
            successFn: function() {
                doRecap(button, win.viewModel.data.current, cboCurrency.getRawValue());
            }
        });
    },

    onAfterReceive: function(success, message) {
        if (success === true) {
            var me = this;
            var win = me.view;
            win.context.data.load();
        }
        else {
            iRely.Functions.showCustomDialog(iRely.Functions.dialogType.ERROR, iRely.Functions.dialogButtonType.OK, message);
        }
    },

    onCalculationBasisChange: function(obj, newValue, oldValue, eOpts) {
        var win = obj.up('window');
        var txtUnitsWeightMiles = win.down('#txtUnitsWeightMiles');
        switch (newValue) {
            case 'Per Ton':
                txtUnitsWeightMiles.setFieldLabel('Weight');
                break;
            case 'Per Miles':
                txtUnitsWeightMiles.setFieldLabel('Miles');
                break;
            default:
                txtUnitsWeightMiles.setFieldLabel('Unit');
                break;
        }
    },

    onFreightCalculationChange: function(obj, newValue, oldValue, eOpts) {
        var win = obj.up('window');
        var txtUnitsWeightMiles = win.down('#txtUnitsWeightMiles');
        var txtFreightRate = win.down('#txtFreightRate');
        var txtFuelSurcharge = win.down('#txtFuelSurcharge');
        var txtCalculatedFreight = win.down('#txtCalculatedFreight');

        var unitRate = (txtUnitsWeightMiles.getValue() * txtFreightRate.getValue());
        var unitRateSurcharge = (unitRate * txtFuelSurcharge.getValue());

        txtCalculatedFreight.setValue(unitRate + unitRateSurcharge);
    },

    onCalculateTotalAmount: function(obj, newValue, oldValue, eOpts) {
        var win = obj.up('window');
        var txtCalculatedAmount = win.down('#txtCalculatedAmount');
        var txtInvoiceAmount = win.down('#txtInvoiceAmount');
        var txtDifference = win.down('#txtDifference');
        var grid = win.down('#grdInventoryReceipt');
        var store = grid.store;

        if (store){
            var data = store.data;
            var calculatedTotal = 0
            Ext.Array.each(data.items, function(row) {
                var dblReceived = row.get('dblReceived');
                var dblUnitCost = row.get('dblUnitCost');
                if (obj.column.itemId === 'colReceived')
                    dblReceived = newValue;
                else if (obj.column.itemId === 'colUnitCost')
                    dblUnitCost = newValue;
                var rowTotal = dblReceived * dblUnitCost;
                calculatedTotal += rowTotal;
            })
            txtCalculatedAmount.setValue(calculatedTotal);
            var difference = calculatedTotal - (txtInvoiceAmount.getValue());
            txtDifference.setValue(difference);
        }
    },

    onEditItem: function (editor, context, eOpts) {
        if (context.field === 'dblOpenReceive' || context.field === 'dblUnitCost')
        {
            if (context.record) {
                var value = 0;
                var record = context.record;
                if (context.field === 'dblOpenReceive'){
                    value = context.value * (record.get('dblUnitCost'));
                }
                else if (context.field === 'dblUnitCost'){
                    value = context.value * (record.get('dblOpenReceive'));
                    record.set('dblUnitRetail', context.value);
                }
                record.set('dblLineTotal', value);
            }
        }
    },

    onShipFromBeforeQuery: function(obj) {
        if (obj.combo) {
            var store = obj.combo.store;
            if (store) {
                store.remoteFilter = true;
                store.remoteSort = true;
            }
        }
    },

    onShipFromSelect: function(combo, records) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var current = win.viewModel.data.current;

        if (current) current.set('intShipViaId', records[0].get('intShipViaId'));
    },

    init: function(application) {
        this.control({
            "#cboVendor": {
                select: this.onVendorSelect
            },
            "#cboFreightTerms": {
                select: this.onFreightTermSelect
            },
            "#cboItem": {
                select: this.onReceiptItemSelect
            },
            "#cboItemUOM": {
                select: this.onReceiptItemSelect
            },
            "#cboItemPackType": {
                select: this.onReceiptItemSelect
            },
            "#cboCalculationBasis": {
                change: this.onCalculationBasisChange
            },
            "#txtUnitsWeightMiles": {
                change: this.onFreightCalculationChange
            },
            "#txtFreightRate": {
                change: this.onFreightCalculationChange
            },
            "#txtFuelSurcharge": {
                change: this.onFreightCalculationChange
            },
            "#txtInvoiceAmount": {
                change: this.onCalculateTotalAmount
            },
            "#btnReceive": {
                click: this.onReceiveClick
            },
            "#btnRecap": {
                click: this.onRecapClick
            },
            "#btnInventory": {
                click: this.onInventoryClick
            },
            "#cboShipFrom": {
                beforequery: this.onShipFromBeforeQuery,
                select: this.onShipFromSelect
            },
            "#cboSource": {
                beforequery: this.onShipFromBeforeQuery
            }
        })
    }

});
