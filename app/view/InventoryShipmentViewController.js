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
            btnInvoice: {
                hidden: '{!current.ysnPosted}'
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
                value: '{current.intSourceType}',
                store: '{sourceTypes}',
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

            btnInsertItem: {
                hidden: '{current.ysnPosted}'
            },
            btnRemoveItem: {
                hidden: '{current.ysnPosted}'
            },
            grdInventoryShipment: {
                readOnly: '{current.ysnPosted}',
                colOrderNumber: {
                    hidden: '{checkHideOrderNo}',
                    dataIndex: 'strOrderNumber',
                    editor: {
                        store: '{soDetails}',
                        defaultFilters: [{
                            column: 'intEntityCustomerId',
                            value: '{current.intEntityCustomerId}',
                            conjunction: 'and'
                        }]
                    }
                },
                colSourceNumber: {
                    hidden: '{checkHideSourceNo}',
                    dataIndex: 'strSourceNumber'
                },
                colItemNumber: {
                    dataIndex: 'strItemNo',
                    editor: {
                        readOnly: '{readOnlyItemDropdown}',
                        store: '{items}',
                        defaultFilters: [{
                            column: 'intLocationId',
                            value: '{current.intShipFromLocationId}',
                            conjunction: 'and'
                        }]
                    }
                },
                colDescription: 'strItemDescription',
                colSubLocation: {
                    dataIndex: 'strSubLocationName',
                    editor: {
                        store: '{subLocation}',
                        origValueField: 'intCompanyLocationSubLocationId',
                        origUpdateField: 'intSubLocationId',
                        defaultFilters: [{
                            column: 'intCompanyLocationId',
                            value: '{current.intShipFromLocationId}',
                            conjunction: 'and'
                        }]
                    }
                },
                colStorageLocation: {
                    dataIndex: 'strStorageLocationName',
                    editor: {
                        store: '{storageLocation}',
                        origValueField: 'intStorageLocationId',
                        origUpdateField: 'intStorageLocationId',
                        defaultFilters: [
                            {
                                column: 'intLocationId',
                                value: '{current.intLocationId}',
                                conjunction: 'and'
                            },
                            {
                                column: 'intSubLocationId',
                                value: '{grdInventoryShipment.selection.intSubLocationId}',
                                conjunction: 'and'
                            }
                        ]
                    }
                },
                colGrade: {
                    dataIndex: 'strGrade',
                    editor: {
                        readOnly: '{hasItemCommodity}',
                        store: '{grade}',
                        origValueField: 'intCommodityAttributeId',
                        origUpdateField: 'intGradeId',
                        defaultFilters: [
                            {
                                column: 'intCommodityId',
                                value: '{grdInventoryShipment.selection.intCommodityId}',
                                conjunction: 'and'
                            }
                        ]
                    }
                },
                colOwnershipType: {
                    hidden: '{checkHideOwnershipType}',
                    dataIndex: 'strOwnershipType',
                    editor: {
                        origValueField: 'intOwnershipType',
                        origUpdateField: 'intOwnershipType',
                        store: '{ownershipTypes}'
                    }
                },
                colOrderQty: {
                    hidden: '{checkHideOrderNo}',
                    dataIndex: 'dblQtyOrdered'
                },
                colOrderUOM: {
                    hidden: '{checkHideOrderNo}',
                    dataIndex: 'strOrderUOM'
                },
                colQuantity: 'dblQuantity',
                colUOM: {
                    dataIndex: 'strUnitMeasure',
                    editor: {
                        origValueField: 'intItemUOMId',
                        origUpdateField: 'intItemUOMId',
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
                        origValueField: 'intItemUOMId',
                        origUpdateField: 'intWeightUOMId',
                        store: '{weightUOM}',
                        defaultFilters: [{
                            column: 'intItemId',
                            value: '{grdInventoryShipment.selection.intItemId}'
                        }]
                    }
                },
                colUnitPrice: 'dblUnitPrice',
                colLineTotal: 'dblLineTotal',
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
                            value: '{grdInventoryShipment.selection.intItemId}',
                            conjunction: 'and'
                        },{
                            column: 'intSubLocationId',
                            value: '{grdInventoryShipment.selection.intSubLocationId}',
                            conjunction: 'and'
                        },{
                            column: 'intLocationId',
                            value: '{current.intShipFromLocationId}',
                            conjunction: 'and'
                        },{
                            column: 'intStorageLocationId',
                            value: '{grdInventoryShipment.selection.intStorageLocationId}',
                            conjunction: 'and'
                        },{
                            column: 'intOwnershipType',
                            value: '{grdInventoryShipment.selection.intOwnershipType}',
                            conjunction: 'and'
                        },{
                            column: 'intGradeId',
                            value: '{grdInventoryShipment.selection.intGradeId}',
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
                colStorageLocation: 'strStorageLocation',
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
            enableComment: true,
            include: 'ShipFromLocation, ' +
                'tblARCustomer, ' +
                'ShipToLocation, ' +
                'tblICInventoryShipmentItems.vyuICGetInventoryShipmentItem, ' +
                'tblICInventoryShipmentItems.tblICInventoryShipmentItemLots.tblICLot',
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
        record.set('intSourceType', 0);
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
            switch (win.viewModel.data.current.get('intOrderType')) {
                case 1:
                    current.set('intOrderId', records[0].get('intContractHeaderId'));
                    current.set('intLineNo', records[0].get('intContractDetailId'));
                    current.set('intItemId', records[0].get('intItemId'));
                    current.set('strItemNo', records[0].get('strItemNo'));
                    current.set('strItemDescription', records[0].get('strItemDescription'));
                    current.set('strLotTracking', records[0].get('strLotTracking'));
                    current.set('intCommodityId', records[0].get('intCommodityId'));
                    current.set('intItemUOMId', records[0].get('intItemUOMId'));
                    current.set('strUnitMeasure', records[0].get('strItemUOM'));
                    current.set('dblQuantity', records[0].get('dblBalance'));
                    current.set('strOrderUOM', records[0].get('strItemUOM'));
                    current.set('dblQtyOrdered', records[0].get('dblDetailQuantity'));
                    current.set('dblUnitPrice', records[0].get('dblCost'));
                    current.set('intOwnershipType', 1);
                    current.set('strOwnershipType', 'Own');

                    switch(records[0].get('strLotTracking')) {
                        case 'Yes - Serial Number':
                        case 'Yes - Manual':
                            grdLotTracking.setHidden(false);
                            break;
                        default:
                            grdLotTracking.setHidden(true);
                            break;
                    }
                    break;
                case 2:
                    current.set('intOrderId', records[0].get('intSalesOrderId'));
                    current.set('intLineNo', records[0].get('intSalesOrderDetailId'));
                    current.set('intItemId', records[0].get('intItemId'));
                    current.set('strItemNo', records[0].get('strItemNo'));
                    current.set('strItemDescription', records[0].get('strItemDescription'));
                    current.set('strLotTracking', records[0].get('strLotTracking'));
                    current.set('intCommodityId', records[0].get('intCommodityId'));
                    current.set('intItemUOMId', records[0].get('intItemUOMId'));
                    current.set('strUnitMeasure', records[0].get('strUnitMeasure'));
                    current.set('dblQuantity', records[0].get('dblQtyOrdered'));
                    current.set('strOrderUOM', records[0].get('strUnitMeasure'));
                    current.set('dblQtyOrdered', records[0].get('dblQtyOrdered'));
                    current.set('dblUnitPrice', records[0].get('dblPrice'));
                    current.set('intOwnershipType', 1);
                    current.set('strOwnershipType', 'Own');

                    switch(records[0].get('strLotTracking')) {
                        case 'Yes - Serial Number':
                        case 'Yes - Manual':
                            grdLotTracking.setHidden(false);
                            break;
                        default:
                            grdLotTracking.setHidden(true);
                            break;
                    }
                    break;
                case 3:

                    break;
            }
        }
        else if (combo.itemId === 'cboWeightUOM') {
            if (current.tblICInventoryShipmentItemLots()) {
                Ext.Array.each(current.tblICInventoryShipmentItemLots().data.items, function(lot) {
                    if (!lot.dummy) {
                        lot.set('strWeightUOM', records[0].get('strUnitMeasure'));
                    }
                });
            }
        }
    },

    onItemNoSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepItem');
        var current = plugin.getActiveRecord();

        if (combo.itemId === 'cboItemNo') {
            current.set('intItemId', records[0].get('intItemId'));
            current.set('strItemDescription', records[0].get('strDescription'));
            current.set('strLotTracking', records[0].get('strLotTracking'));
            current.set('intCommodityId', records[0].get('intCommodityId'));
            current.set('intItemUOMId', records[0].get('intIssueUOMId'));
            current.set('strUnitMeasure', records[0].get('strIssueUOM'));
            current.set('dblUnitPrice', records[0].get('dblLastCost'));
            current.set('dblItemUOMConvFactor', records[0].get('dblIssueUOMConvFactor'));
            current.set('strUnitType', records[0].get('strIssueUOMType'));
            current.set('intOwnershipType', 1);
            current.set('strOwnershipType', 'Own');
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
            current.set('strStorageLocation', records[0].get('strStorageLocation'));

            var shipmentItem = win.viewModel.data.currentShipmentItem;
            if (shipmentItem) {
                var shipQty = shipmentItem.get('dblQuantity');
                var availQty = current.get('dblAvailableQty');
                if (shipQty > availQty){
                    current.set('dblQuantityShipped', availQty);
                }
                else{
                    current.set('dblQuantityShipped', shipQty);
                }
            }

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
        var win = button.up('window');
        var current = win.viewModel.data.current;

        if (current) {
            Ext.Ajax.request({
                timeout: 120000,
                url: '../Inventory/api/InventoryShipment/ProcessInvoice?id=' + current.get('intInventoryShipmentId'),
                method: 'post',
                success: function(response){
                    var jsonData = Ext.decode(response.responseText);
                    if (jsonData.success) {
                        var buttonAction = function(button) {
                            if (button === 'yes') {
                                iRely.Functions.openScreen('AccountsReceivable.view.Invoice', {
                                    filters: [
                                        {
                                            column: 'intInvoiceId',
                                            value: jsonData.message.InvoiceId
                                        }
                                    ],
                                    action: 'view'
                                });
                                win.close();
                            }
                        };
                        iRely.Functions.showCustomDialog('question', 'yesno', 'Invoice succesfully processed. Do you want to view this Invoice?', buttonAction);
                    }
                    else {
                        iRely.Functions.showErrorDialog(jsonData.message.statusText);
                    }
                },
                failure: function(response) {
                    var jsonData = Ext.decode(response.responseText);
                    iRely.Functions.showErrorDialog(jsonData.ExceptionMessage);
                }
            });
        }
    },

    onViewItemClick: function(button, e, eOpts) {
        var win = button.up('window');
        var grd = win.down('#grdInventoryShipment');

        var selected = grd.getSelectionModel().getSelection();

        if (selected) {
            if (selected.length > 0){
                var current = selected[0];
                if (!current.dummy)
                    iRely.Functions.openScreen('Inventory.view.Item', current.get('intItemId'));
            }
            else {
                iRely.Functions.showErrorDialog('Please select an Item to view.');
            }
        }
        else {
            iRely.Functions.showErrorDialog('Please select an Item to view.');
        }
    },

    salesOrderDropdown: function(win) {
        return Ext.create('Ext.grid.CellEditor', {
            field: Ext.widget({
                xtype: 'gridcombobox',
                matchFieldWidth: false,
                columns: [
                    {
                        dataIndex: 'intSalesOrderId',
                        dataType: 'numeric',
                        text: 'Sales Order Id',
                        hidden: true
                    },
                    {
                        dataIndex: 'intSalesOrderDetailId',
                        dataType: 'numeric',
                        text: 'Sales Order Detail Id',
                        hidden: true
                    },
                    {
                        dataIndex: 'intCompanyLocationId',
                        dataType: 'string',
                        text: 'Location Id',
                        hidden: true
                    },
                    {
                        dataIndex: 'intItemId',
                        dataType: 'string',
                        text: 'Item Id',
                        hidden: true
                    },
                    {
                        dataIndex: 'intItemUOMId',
                        dataType: 'string',
                        text: 'Item UOM Id',
                        hidden: true
                    },
                    {
                        dataIndex: 'strSalesOrderNumber',
                        dataType: 'string',
                        text: 'Sales Order',
                        width: 100
                    },
                    {
                        dataIndex: 'strItemNo',
                        dataType: 'string',
                        text: 'Item No',
                        width: 100
                    },
                    {
                        dataIndex: 'strItemDescription',
                        dataType: 'string',
                        text: 'Description',
                        width: 120
                    },
                    {
                        dataIndex: 'strLotTracking',
                        dataType: 'string',
                        text: 'Lot Tracking',
                        width: 100
                    },
                    {
                        dataIndex: 'dblQtyOrdered',
                        dataType: 'float',
                        text: 'Order Qty',
                        width: 100
                    },
                    {
                        dataIndex: 'strUnitMeasure',
                        dataType: 'string',
                        text: 'Order UOM',
                        width: 100
                    },
                    {
                        dataIndex: 'dblPrice',
                        dataType: 'float',
                        text: 'Unit Price',
                        hidden: true
                    },
                    {
                        dataIndex: 'strStorageLocation',
                        dataType: 'string',
                        text: 'Storage Location',
                        hidden: true
                    }
                ],
                pickerWidth: 625,
                itemId: 'cboOrderNumber',
                displayField: 'strSalesOrderNumber',
                valueField: 'strSalesOrderNumber',
                itemId: 'cboOrderNumber',
                store: win.viewModel.storeInfo.soDetails,
                defaultFilters: [{
                    column: 'intEntityCustomerId',
                    value: win.viewModel.data.current.get('intEntityCustomerId'),
                    conjunction: 'and'
                }]
            })
        });
    },

    salesContractDropdown: function(win) {
        return Ext.create('Ext.grid.CellEditor', {
            field: Ext.widget({
                xtype: 'gridcombobox',
                matchFieldWidth: false,
                columns: [
                    {
                        dataIndex: 'intContractNumber',
                        dataType: 'string',
                        text: 'Contract Number',
                        flex: 1
                    },
                    {
                        dataIndex: 'strItemNo',
                        dataType: 'string',
                        text: 'Item No',
                        flex: 1
                    },
                    {
                        dataIndex: 'strItemDescription',
                        dataType: 'string',
                        text: 'Description',
                        flex: 1
                    },
                    {
                        dataIndex: 'dblDetailQuantity',
                        dataType: 'float',
                        text: 'Ordered Qty',
                        flex: 1
                    },
                    {
                        dataIndex: 'dblBalance',
                        dataType: 'float',
                        text: 'Balance Qty',
                        flex: 1
                    },
                    {
                        dataIndex: 'intContractDetailId',
                        dataType: 'numeric',
                        hidden: true
                    },
                    {
                        dataIndex: 'intContractHeaderId',
                        dataType: 'numeric',
                        hidden: true
                    },
                    {
                        dataIndex: 'intItemId',
                        dataType: 'numeric',
                        hidden: true
                    },
                    {
                        dataIndex: 'intItemUOMId',
                        dataType: 'numeric',
                        hidden: true
                    },
                    {
                        dataIndex: 'strItemUOM',
                        dataType: 'string',
                        hidden: true
                    },
                    {
                        dataIndex: 'strLotTracking',
                        dataType: 'string',
                        hidden: true
                    },
                    {
                        dataIndex: 'intStorageLocationId',
                        dataType: 'numeric',
                        hidden: true
                    },
                    {
                        dataIndex: 'intSubLocationId',
                        dataType: 'numeric',
                        text: 'Sub Location Id',
                        hidden: true
                    },
                    {
                        dataIndex: 'strSubLocationName',
                        dataType: 'string',
                        text: 'Sub Location Name',
                        hidden: true
                    },
                    {
                        dataIndex: 'strStorageLocationName',
                        dataType: 'string',
                        hidden: true
                    },
                    {
                        dataIndex: 'dblItemUOMCF',
                        dataType: 'float',
                        text: 'Unit Qty',
                        hidden: true
                    },
                    {
                        dataIndex: 'intStockUOM',
                        dataType: 'numeric',
                        text: 'Stock UOM Id',
                        hidden: true
                    },
                    {
                        dataIndex: 'strStockUOM',
                        dataType: 'string',
                        text: 'Stock UOM',
                        hidden: true
                    },
                    {
                        dataIndex: 'strStockUOMType',
                        dataType: 'string',
                        text: 'Stock UOM Type',
                        hidden: true
                    },
                    {
                        dataIndex: 'dblStockUOMCF',
                        dataType: 'float',
                        text: 'Stock UOM Conversion Factor',
                        hidden: true
                    }
                ],
                pickerWidth: 600,
                itemId: 'cboOrderNumber',
                displayField: 'intContractNumber',
                valueField: 'intContractNumber',
                store: win.viewModel.storeInfo.salesContract,
                defaultFilters: [{
                    column: 'strContractType',
                    value: 'Sale',
                    conjunction: 'and'
                },{
                    column: 'intEntityId',
                    value: win.viewModel.data.current.get('intEntityVendorId'),
                    conjunction: 'and'
                }]
            })
        });
    },

    transferOrderDropdown: function(win) {
        return Ext.create('Ext.grid.CellEditor', {
            field: Ext.widget({
                xtype: 'gridcombobox',
                matchFieldWidth: false,
                columns: [
                    {
                        dataIndex: 'strPurchaseOrderNumber',
                        dataType: 'string',
                        text: 'PO Number',
                        flex: 1
                    },
                    {
                        dataIndex: 'strItemNo',
                        dataType: 'string',
                        text: 'Item No',
                        flex: 1
                    },
                    {
                        dataIndex: 'strDescription',
                        dataType: 'string',
                        text: 'Description',
                        flex: 1
                    },
                    {
                        dataIndex: 'dblQtyOrdered',
                        dataType: 'float',
                        text: 'Ordered Qty',
                        flex: 1
                    },
                    {
                        dataIndex: 'dblQtyReceived',
                        dataType: 'float',
                        text: 'Received Qty',
                        flex: 1
                    },
                    {
                        dataIndex: 'dblCost',
                        dataType: 'float',
                        text: 'Cost',
                        hidden: true
                    },
                    {
                        dataIndex: 'dblTotal',
                        dataType: 'float',
                        text: 'Line Total',
                        hidden: true
                    },
                    {
                        dataIndex: 'intPurchaseDetailId',
                        dataType: 'numeric',
                        text: 'Purchase Detail Id',
                        hidden: true
                    },
                    {
                        dataIndex: 'intPurchaseId',
                        dataType: 'numeric',
                        text: 'Purchase Detail Id',
                        hidden: true
                    },
                    {
                        dataIndex: 'intItemId',
                        dataType: 'numeric',
                        text: 'Purchase Detail Id',
                        hidden: true
                    },
                    {
                        dataIndex: 'intUnitOfMeasureId',
                        dataType: 'numeric',
                        text: 'Purchase Detail Id',
                        hidden: true
                    },
                    {
                        dataIndex: 'strUOM',
                        dataType: 'string',
                        text: 'Unit of Measure',
                        hidden: true
                    },
                    {
                        dataIndex: 'strLotTracking',
                        dataType: 'string',
                        text: 'Lot Tracking',
                        hidden: true
                    },
                    {
                        dataIndex: 'intStorageLocationId',
                        dataType: 'numeric',
                        text: 'Storage Location Id',
                        hidden: true
                    },
                    {
                        dataIndex: 'intSubLocationId',
                        dataType: 'numeric',
                        text: 'Sub Location Id',
                        hidden: true
                    },
                    {
                        dataIndex: 'strSubLocationName',
                        dataType: 'string',
                        text: 'Sub Location Name',
                        hidden: true
                    },
                    {
                        dataIndex: 'strStorageName',
                        dataType: 'string',
                        text: 'Storage Location Name',
                        hidden: true
                    },
                    {
                        dataIndex: 'dblItemUOMCF',
                        dataType: 'float',
                        text: 'Unit Qty',
                        hidden: true
                    },
                    {
                        dataIndex: 'intStockUOM',
                        dataType: 'numeric',
                        text: 'Stock UOM Id',
                        hidden: true
                    },
                    {
                        dataIndex: 'strStockUOM',
                        dataType: 'string',
                        text: 'Stock UOM',
                        hidden: true
                    },
                    {
                        dataIndex: 'strStockUOMType',
                        dataType: 'string',
                        text: 'Stock UOM Type',
                        hidden: true
                    },
                    {
                        dataIndex: 'dblStockUOMCF',
                        dataType: 'float',
                        text: 'Stock UOM Conversion Factor',
                        hidden: true
                    }
                ],
                itemId: 'cboOrderNumber',
                displayField: 'strPurchaseOrderNumber',
                valueField: 'strPurchaseOrderNumber',
                store: win.viewModel.storeInfo.orderNumbers,
                defaultFilters: [{
                    column: 'ysnCompleted',
                    value: 'false',
                    conjunction: 'and'
                },{
                    column: 'intEntityVendorId',
                    value: win.viewModel.data.current.get('intEntityVendorId'),
                    conjunction: 'and'
                }]
            })
        });
    },

    itemDropdown: function(win) {
        return Ext.create('Ext.grid.CellEditor', {
            field: Ext.widget({
                xtype: 'gridcombobox',
                matchFieldWidth: false,
                columns: [
                    {
                        dataIndex: 'intItemId',
                        dataType: 'numeric',
                        text: 'Item Id',
                        hidden: true
                    },
                    {
                        dataIndex: 'strItemNo',
                        dataType: 'string',
                        text: 'Item Number',
                        flex: 1
                    },
                    {
                        dataIndex: 'strType',
                        dataType: 'string',
                        text: 'Item Type',
                        flex: 1
                    },
                    {
                        dataIndex: 'strDescription',
                        dataType: 'string',
                        text: 'Description',
                        flex: 1
                    },
                    {
                        dataIndex: 'strLotTracking',
                        dataType: 'string',
                        text: 'Lot Tracking',
                        hidden: true
                    }
                ],
                itemId: 'cboItemNo',
                displayField: 'strItemNo',
                valueField: 'strItemNo',
                store: win.viewModel.storeInfo.items
            })
        });
    },

    onItemGridColumnBeforeRender: function(column) {
        "use strict";

        var me = this,
            win = column.up('window'),
            controller = win.getController();

        // Show or hide the editor based on the selected Field type.
        column.getEditor = function(record){

            var vm = win.viewModel,
                current = vm.data.current;

            if (!current) return false;
            if (!column) return false;
            if (!record) return false;

            var orderType = current.get('intOrderType');
            var columnId = column.itemId;

            switch (orderType) {
                case 2:
                    if (iRely.Functions.isEmpty(record.get('strOrderNumber')))
                    {
                        switch (columnId) {
                            case 'colOrderNumber' :
                                return controller.salesOrderDropdown(win);
                                break;
                            case 'colSourceNumber' :
                                return false;
                                break;
                        }
                    }
                    else {
                        switch (columnId) {
                            case 'colOrderNumber' :
                                return false;
                                break;
                            case 'colSourceNumber' :
                                return false;
                                break;
                        };
                    }
                    break;
                case 1:
                    if (iRely.Functions.isEmpty(record.get('strOrderNumber')))
                    {
                        switch (columnId) {
                            case 'colOrderNumber' :
                                return controller.salesContractDropdown(win);
                                break;
                            case 'colSourceNumber' :
                                switch (current.get('intSourceType')) {
                                    case 2:
                                        return false;
                                        break;
                                    default:
                                        return false;
                                        break;
                                }
                                break;
                        }
                    }
                    else {
                        switch (columnId) {
                            case 'colOrderNumber' :
                                return false;
                                break;
                            case 'colSourceNumber' :
                                switch (current.get('intSourceType')) {
                                    case 2:
                                        return false;
                                        break;
                                    default:
                                        return false;
                                        break;
                                }
                                break;
                        };
                    }
                    break;
                case 3:
                    if (iRely.Functions.isEmpty(record.get('strOrderNumber')))
                    {
                        switch (columnId) {
                            case 'colOrderNumber' :
                                return controller.transferOrderDropdown(win);
                                break;
                            case 'colSourceNumber' :
                                return false;
                                break;
                        }
                    }
                    else {
                        switch (columnId) {
                            case 'colOrderNumber' :
                                return false;
                                break;
                            case 'colSourceNumber' :
                                return false;
                                break;
                        };
                    }
                    break;
            };
        };
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
            "#cboItemNo": {
                select: this.onItemNoSelect
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
            },
            "#btnViewItem": {
                click: this.onViewItemClick
            },
            "#colOrderNumber": {
                beforerender: this.onItemGridColumnBeforeRender
            },
            "#colSourceNumber": {
                beforerender: this.onItemGridColumnBeforeRender
            }
        })
    }

});
