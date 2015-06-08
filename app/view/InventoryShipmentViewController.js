Ext.define('Inventory.view.InventoryShipmentViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.icinventoryshipment',

    config: {
        searchConfig: {
            title:  'Search Inventory Shipment',
            type: 'Inventory.InventoryShipment',
            api: {
                read: '../Inventory/api/InventoryShipment/Search'
            },
            columns: [
                {dataIndex: 'intInventoryShipmentId',text: "Shipment Id", flex: 1, defaultSort:true, dataType: 'numeric', key: true, hidden: true},
                {dataIndex: 'strShipmentNumber', text: 'Shipment Number', flex: 1,  dataType: 'string'},
                {dataIndex: 'dtmShipDate', text: 'Ship Date', flex: 1,  dataType: 'date', xtype: 'datecolumn'},
                {dataIndex: 'strOrderType',text: 'Order Type', flex: 1,  dataType: 'int'},
                {dataIndex: 'strCustomerId',text: 'Customer', flex: 1,  dataType: 'string'},
                {dataIndex: 'strCustomerName',text: 'Customer Name', flex: 1,  dataType: 'string'},
                {dataIndex: 'ysnPosted', text: 'Posted', flex: 1, dataType: 'boolean', xtype: 'checkcolumn'}
            ]
        },
        binding: {
            bind: {
                title: 'Inventory Shipment - {current.strShipmentNumber}'
            },
            btnSave: {
                disabled: '{current.ysnPosted}'
            },
            btnDelete: {
                disabled: '{current.ysnPosted}'
            },
            btnUndo: {
                disabled: '{current.ysnPosted}'
            },
            btnShip: {
                text: '{getShipButtonText}',
                iconCls: '{getShipButtonIcon}'
            },

            txtShipmentNo: '{current.strShipmentNumber}',
            dtmShipDate: {
                value: '{current.dtmShipDate}',
                readOnly: '{current.ysnPosted}'
            },
            cboOrderType: {
                value: '{current.intOrderType}',
                store: '{orderTypes}',
                readOnly: '{current.ysnPosted}'
            },
            cboSourceType: {
                value: '{current.strReceiptType}',
                store: '{receiptTypes}',
                readOnly: '{current.ysnPosted}'
            },
            txtReferenceNumber: {
                value: '{current.strReferenceNumber}',
                readOnly: '{current.ysnPosted}'
            },
            dtmRequestedArrival: {
                value: '{current.dtmRequestedArrivalDate}',
                readOnly: '{current.ysnPosted}'
            },
            cboFreightTerms: {
                value: '{current.intFreightTermId}',
                store: '{freightTerm}',
                readOnly: '{current.ysnPosted}'
            },
            cboCustomer: {
                value: '{current.intEntityCustomerId}',
                store: '{customer}',
                readOnly: '{current.ysnPosted}'
            },
            txtCustomerName: '{current.strCustomerName}',
            cboShipFromAddress: {
                value: '{current.intShipFromLocationId}',
                store: '{shipFromLocation}',
                readOnly: '{current.ysnPosted}'
            },
            txtShipFromAddress: '{current.strShipFromAddress}',
            cboShipToAddress: {
                value: '{current.intShipToLocationId}',
                store: '{shipToLocation}',
                readOnly: '{current.ysnPosted}',
                defaultFilters: [{
                    column: 'intEntityId',
                    value: '{current.intEntityCustomerId}'
                }]
            },
            txtShipToAddress: '{current.strShipToAddress}',
            txtDeliveryInstructions: {
                value: '{current.strDeliveryInstruction}',
                readOnly: '{current.ysnPosted}'
            },
            txtComments: {
                value: '{current.strComment}',
                readOnly: '{current.ysnPosted}'
            },
            chkDirectShipment: {
                value: '{current.ysnDirectShipment}',
                readOnly: '{current.ysnPosted}'
            },
            txtBOLNo: {
                value: '{current.strBOLNumber}',
                readOnly: '{current.ysnPosted}'
            },
            cboShipVia: {
                value: '{current.intShipViaId}',
                store: '{shipVia}',
                readOnly: '{current.ysnPosted}'
            },
            txtVesselVehicle: {
                value: '{current.strVessel}',
                readOnly: '{current.ysnPosted}'
            },
            txtProNumber: {
                value: '{current.strProNumber}',
                readOnly: '{current.ysnPosted}'
            },
            txtDriverID: {
                value: '{current.strDriverId}',
                readOnly: '{current.ysnPosted}'
            },
            txtSealNumber: {
                value: '{current.strSealNumber}',
                readOnly: '{current.ysnPosted}'
            },
            txtAppointmentTime: {
                value: '{current.dtmAppointmentTime}',
                readOnly: '{current.ysnPosted}'
            },
            txtDepartureTime: {
                value: '{current.dtmDepartureTime}',
                readOnly: '{current.ysnPosted}'
            },
            txtArrivalTime: {
                value: '{current.dtmArrivalTime}',
                readOnly: '{current.ysnPosted}'
            },
            dtmDelivered: {
                value: '{current.dtmDeliveredDate}',
                readOnly: '{current.ysnPosted}'
            },
            dtmFreeTime: {
                value: '{current.dtmFreeTime}',
                readOnly: '{current.ysnPosted}'
            },
            txtReceivedBy: '{current.strReceivedBy}',

            grdInventoryShipment: {
                readOnly: '{current.ysnPosted}',
                colOrderNumber: {
                    dataIndex: 'strSourceId',
                    editor: {
                        store: '{soDetails}',
                        defaultFilters: [{
                            column: 'intEntityCustomerId',
                            value: '{current.intEntityCustomerId}',
                            conjunction: 'and'
                        }]
                    }
                },
                colItemNumber: {
                    dataIndex: 'strItemNo',
                    editor: {
                        store: '{items}'
                    }
                },
                colDescription: 'strItemDescription',
                colSubLocation: {
                    dataIndex: 'strSubLocationName',
                    editor: {
                        store: '{subLocation}',
                        defaultFilters: [{
                            column: 'intCompanyLocationId',
                            value: '{current.intShipFromLocationId}',
                            conjunction: 'and'
                        }]
                    }
                },
                colOrderQty: 'dblQtyOrdered',
                colOrderUOM: 'strOrderUOM',
                colQuantity: 'dblQuantity',
                colUOM: {
                    dataIndex: 'strUnitMeasure',
                    editor: {
                        store: '{itemUOM}',
                        defaultFilters: [{
                            column: 'intItemId',
                            value: '{grdInventoryShipment.selection.intItemId}'
                        }]
                    }
                },
                colWeightUOM: {
                    dataIndex: 'strWeightUOM',
                    editor: {
                        store: '{weightUOM}',
                        defaultFilters: [{
                            column: 'intItemId',
                            value: '{grdInventoryShipment.selection.intItemId}'
                        }]
                    }
                },
                colUnitPrice: 'dblUnitPrice',
//                colTaxCode: '',
//                colTaxAmount: '',
//                colDockDoor: {
//                    dataIndex: 'strDockDoor',
//                    editor: {
//                        store: '{itemPackType}'
//                    }
//                },
                colNotes: 'strNotes'
            },

            grdLotTracking: {
                readOnly: '{current.ysnPosted}',
                colLotID: {
                    dataIndex: 'strLotId',
                    editor: {
                        store: '{lot}',
                        defaultFilters: [{
                            column: 'intItemId',
                            value: '{currentShipmentItem.intItemId}',
                            conjunction: 'and'
                        },{
                            column: 'intSubLocationId',
                            value: '{currentShipmentItem.intSubLocationId}',
                            conjunction: 'and'
                        }]
                    }
                },
                colAvailableQty: 'dblAvailableQty',
                colShipQty: 'dblQuantityShipped',
                colLotUOM: {
                    dataIndex: 'strUnitMeasure'
                },
                colLotWeightUOM: {
                    dataIndex: 'strWeightUOM'
                },
                colGrossWeight: 'dblGrossWeight',
                colTareWeight: 'dblTareWeight',
                colNetWeight: 'dblNetWeight',
                colWarehouseCargoNumber: 'strWarehouseCargoNumber'
            }
        }
    },

    setupContext : function(options) {
        "use strict";
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.Shipment', { pageSize: 1 });

        var grdInventoryShipment = win.down('#grdInventoryShipment'),
            grdLotTracking = win.down('#grdLotTracking');

        win.context = Ext.create('iRely.Engine', {
            window: win,
            store: store,
            include: 'ShipFromLocation, ' +
                'tblARCustomer, ' +
                'ShipToLocation, ' +
                'tblICInventoryShipmentItems.vyuICGetInventoryShipmentItem',
            createRecord: me.createRecord,
            binding: me.config.binding,
            attachment: Ext.create('iRely.attachment.Manager', {
                type: 'Inventory.Shipment',
                window: win
            }),
            details: [
                {
                    key: 'tblICInventoryShipmentItems',
                    component: Ext.create('iRely.grid.Manager', {
                        grid: grdInventoryShipment,
                        deleteButton: grdInventoryShipment.down('#btnRemoveItem')
                    }),
                    details: [
                        {
                            key: 'tblICInventoryShipmentItemLots',
                            component: Ext.create('iRely.grid.Manager', {
                                grid: grdLotTracking,
                                deleteButton: grdLotTracking.down('#btnRemoveLot'),
                                createRecord: me.onLotCreateRecord
                            })
                        }
                    ]
                }
            ]
        });

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
                        column: 'intInventoryShipmentId',
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
        var record = Ext.create('Inventory.model.Shipment');
        if (app.DefaultLocation > 0)
            record.set('intShipFromLocationId', app.DefaultLocation);
        record.set('dtmShipDate', today);
        record.set('intOrderType', 2);
        action(record);
    },

    onLotCreateRecord: function(config, action) {
        var win = config.grid.up('window');
        var currentShipmentItem = win.viewModel.data.currentShipmentItem;
        var record = Ext.create('Inventory.model.ShipmentItemLot');
        record.set('strWeightUOM', currentShipmentItem.get('strWeightUOM'));
        record.set('dblQuantityShipped', config.dummy.get('dblQuantityShipped'));
        action(record);
    },

    onShipLocationSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var current = win.viewModel.data.current;

        if (current){
            if (combo.itemId === 'cboShipFromAddress'){
                current.set('strShipFromAddress', records[0].get('strAddress'));
            }
            else if (combo.itemId === 'cboShipToAddress'){
                current.set('strShipToAddress', records[0].get('strAddress'));
            }
        }
    },

    onCustomerSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var current = win.viewModel.data.current;

        if (current){
            current.set('intEntityCustomerId', records[0].get('intEntityCustomerId'));
            current.set('strCustomerName', records[0].get('strName'));
        }
    },

    onOrderNumberSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var grdLotTracking = win.down('#grdLotTracking');
        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepItem');
        var current = plugin.getActiveRecord();

        if (!current) return;

        if (combo.itemId === 'cboOrderNumber')
        {
            current.set('intSourceId', records[0].get('intSalesOrderId'));
            current.set('intLineNo', records[0].get('intSalesOrderDetailId'));
            current.set('intItemId', records[0].get('intItemId'));
            current.set('strItemNo', records[0].get('strItemNo'));
            current.set('strItemDescription', records[0].get('strItemDescription'));
            current.set('strLotTracking', records[0].get('strLotTracking'));
            current.set('intItemUOMId', records[0].get('intItemUOMId'));
            current.set('strUnitMeasure', records[0].get('strUnitMeasure'));
            current.set('dblQuantity', records[0].get('dblQtyOrdered'));
            current.set('strOrderUOM', records[0].get('strUnitMeasure'));
            current.set('dblQtyOrdered', records[0].get('dblQtyOrdered'));
            current.set('dblUnitPrice', records[0].get('dblPrice'));

            switch(records[0].get('strLotTracking')) {
                case 'Yes - Serial Number':
                case 'Yes - Manual':
                    grdLotTracking.setHidden(false);
                    break;
                default:
                    grdLotTracking.setHidden(true);
                    break;
            }
        }
        else if (combo.itemId === 'cboSubLocation') {
            current.set('intSubLocationId', records[0].get('intCompanyLocationSubLocationId'));
        }
        else if (combo.itemId === 'cboUOM') {
            current.set('intItemUOMId', records[0].get('intItemUOMId'));
        }
        else if (combo.itemId === 'cboWeightUOM') {
            current.set('intWeightUOMId', records[0].get('intItemUOMId'));

            if (current.tblICInventoryShipmentItemLots()) {
                Ext.Array.each(current.tblICInventoryShipmentItemLots().data.items, function(lot) {
                    if (!lot.dummy) {
                        lot.set('strWeightUOM', records[0].get('strUnitMeasure'));
                    }
                });
            }
        }
    },

    onLotSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepLotTracking');
        var current = plugin.getActiveRecord();

        if (!current) return;

        if (combo.itemId === 'cboLot')
        {
            current.set('intLotId', records[0].get('intLotId'));
            current.set('dblAvailableQty', records[0].get('dblAvailableQty'));
            current.set('strUnitMeasure', records[0].get('strItemUOM'));
        }
    },

    onItemSelectionChange: function(selModel, selected, eOpts) {
        if (selModel) {
            var win = selModel.view.grid.up('window');
            var vm = win.viewModel;
            var grdLotTracking = win.down('#grdLotTracking');

            if (selected.length > 0) {
                var current = selected[0];
                if (current.dummy) {
                    vm.data.currentShipmentItem = null;
                }
                else if (current.get('strLotTracking') === 'Yes - Serial Number' || current.get('strLotTracking') === 'Yes - Manual'){
                    vm.data.currentShipmentItem = current;
                }
                else {
                    vm.data.currentShipmentItem = null;
                }
            }
            else {
                vm.data.currentShipmentItem = null;
            }
            if (vm.data.currentShipmentItem !== null){
                grdLotTracking.setHidden(false);
            }
            else {
                grdLotTracking.setHidden(true);
            }

        }
    },

    onCustomerClick: function(button, e, eOpts) {
        var win = button.up('window');
        var current = win.viewModel.data.current;

        if (current.get('intEntityCustomerId') !== null) {
            iRely.Functions.openScreen('EntityManagement.view.Entity', {
                filters: [
                    {
                        column: 'intEntityId',
                        value: current.get('intEntityCustomerId')
                    }
                ]
            });
        }
    },

    onShipClick: function(button, e, eOpts) {
        var me = this;
        var win = button.up('window');
        var context = win.context;

        var doPost = function() {
            var strShipmentNumber = win.viewModel.data.current.get('strShipmentNumber');
            var posted = win.viewModel.data.current.get('ysnPosted');

            var options = {
                postURL             : '../Inventory/api/InventoryShipment/Ship',
                strTransactionId    : strShipmentNumber,
                isPost              : !posted,
                isRecap             : false,
                callback            : me.onAfterShip,
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
        var context = win.context;

        var doRecap = function(recapButton, currentRecord, currency){

            // Call the buildRecapData to generate the recap data
            CashManagement.common.BusinessRules.buildRecapData({
                postURL: '../Inventory/api/InventoryShipment/Ship',
                strTransactionId: currentRecord.get('strShipmentNumber'),
                ysnPosted: currentRecord.get('ysnPosted'),
                scope: me,
                success: function(){
                    // If data is generated, show the recap screen.
                    CashManagement.common.BusinessRules.showRecap({
                        strTransactionId: currentRecord.get('strShipmentNumber'),
                        ysnPosted: currentRecord.get('ysnPosted'),
                        dtmDate: currentRecord.get('dtmShipDate'),
                        strCurrencyId: null,
                        dblExchangeRate: 1,
                        scope: me,
                        postCallback: function(){
                            me.onShipClick(recapButton);
                        },
                        unpostCallback: function(){
                            me.onShipClick(recapButton);
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
            doRecap(button, win.viewModel.data.current, null);
            return;
        }

        // Save has data changes first before doing the post.
        context.data.saveRecord({
            successFn: function() {
                doRecap(button, win.viewModel.data.current, null);
            }
        });
    },

    onAfterShip: function(success, message) {
        if (success === true) {
            var me = this;
            var win = me.view;
            win.context.data.load();
        }
        else {
            iRely.Functions.showCustomDialog(iRely.Functions.dialogType.ERROR, iRely.Functions.dialogButtonType.OK, message);
        }
    },

    onInvoiceClick: function(button, e, eOpts) {

    },

    init: function(application) {
        this.control({
            "#cboShipFromAddress": {
                select: this.onShipLocationSelect
            },
            "#cboShipToAddress": {
                select: this.onShipLocationSelect
            },
            "#cboCustomer": {
                select: this.onCustomerSelect
            },
            "#cboOrderNumber": {
                select: this.onOrderNumberSelect
            },
            "#cboSubLocation": {
                select: this.onOrderNumberSelect
            },
            "#cboUOM": {
                select: this.onOrderNumberSelect
            },
            "#cboWeightUOM": {
                select: this.onOrderNumberSelect
            },
            "#grdInventoryShipment": {
                selectionchange: this.onItemSelectionChange
            },
            "#cboLot": {
                select: this.onLotSelect
            },
            "#btnCustomer": {
                click: this.onCustomerClick
            },
            "#btnShip": {
                click: this.onShipClick
            },
            "#btnRecap": {
                click: this.onRecapClick
            },
            "#btnInvoice": {
                click: this.onInvoiceClick
            }
        })
    }

});
