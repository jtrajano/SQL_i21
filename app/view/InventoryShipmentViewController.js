Ext.define('Inventory.view.InventoryShipmentViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.icinventoryshipment',

    config: {
        searchConfig: {
            title:  'Search Inventory Shipment',
            type: 'Inventory.InventoryShipment',
            api: {
                read: '../Inventory/api/Shipment/SearchShipments'
            },
            columns: [
                {dataIndex: 'intInventoryShipmentId',text: "Shipment Id", flex: 1, defaultSort:true, dataType: 'numeric', key: true, hidden: true},
                {dataIndex: 'strShipmentNumber', text: 'Shipment Number', flex: 1,  dataType: 'string'},
                {dataIndex: 'dtmShipDate', text: 'Ship Date', flex: 1,  dataType: 'date', xtype: 'datecolumn'},
                {dataIndex: 'strOrderType',text: 'Order Type', flex: 1,  dataType: 'int'},
                {dataIndex: 'strBOLNumber', text: 'BOL Number', flex: 1,  dataType: 'string'}
            ]
        },
        binding: {
            bind: {
                title: 'Inventory Shipment - {current.strBOLNumber}'
            },
            txtShipmentNo: '{current.strShipmentNumber}',
            dtmShipDate: '{current.dtmShipDate}',
            cboOrderType: {
                value: '{current.intOrderType}',
                store: '{orderTypes}'
            },
            txtReferenceNumber: '{current.strReferenceNumber}',
            dtmRequestedArrival: '{current.dtmRequestedArrivalDate}',
            cboFreightTerms: {
                value: '{current.intFreightTermId}',
                store: '{freightTerm}'
            },
            cboCustomer: {
                value: '{current.intEntityCustomerId}',
                store: '{customer}'
            },
            txtCustomerName: '{current.strCustomerName}',
            cboShipFromAddress: {
                value: '{current.intShipFromLocationId}',
                store: '{shipFromLocation}'
            },
            txtShipFromAddress: '{current.strShipFromAddress}',
            cboShipToAddress: {
                value: '{current.intShipToLocationId}',
                store: '{shipToLocation}',
                defaultFilters: [{
                    column: 'intEntityId',
                    value: '{current.intEntityCustomerId}'
                }]
            },
            txtShipToAddress: '{current.strShipToAddress}',
            txtDeliveryInstructions: '{current.strDeliveryInstruction}',
            txtComments: '{current.strComment}',
            chkDirectShipment: '{current.ysnDirectShipment}',
            txtBOLNo: '{current.strBOLNumber}',
            cboShipVia: {
                value: '{current.intShipViaId}',
                store: '{shipVia}'
            },
            txtVesselVehicle: '{current.strVessel}',
            txtProNumber: '{current.strProNumber}',
            txtDriverID: '{current.strDriverId}',
            txtSealNumber: '{current.strSealNumber}',
            txtAppointmentTime: '{current.dtmAppointmentTime}',
            txtDepartureTime: '{current.dtmDepartureTime}',
            txtArrivalTime: '{current.dtmArrivalTime}',
            dtmDelivered: '{current.dtmDeliveredDate}',
            dtmFreeTime: '{current.dtmFreeTime}',
            txtReceivedBy: '{current.strReceivedBy}',

            grdInventoryShipment: {
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
                        store: '{subLocation}'
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
//                colDifference: '',
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
                colLotID: {
                    dataIndex: 'strLotId',
                    editor: {
                        store: '{lot}',
                        defaultFilters: [{
                            column: 'intItemId',
                            value: '{currentShipmentItem.intItemId}',
                            conjunction: 'and'
                        }]
                    }
                },
                colAvailableQty: 'dblLotQty',
                colShipQty: 'dblQuantityShipped',
                colLotUOM: {
                    dataIndex: 'strUnitMeasure',
                    editor: {
                        store: '{lotUOM}',
                        defaultFilters: [{
                            column: 'intItemId',
                            value: '{currentShipmentItem.intItemId}',
                            conjunction: 'and'
                        }]
                    }
                },
                colLotWeightUOM: {
                    dataIndex: 'strWeightUOM',
                    editor: {
                        store: '{lotWeightUOM}',
                        defaultFilters: [{
                            column: 'intItemId',
                            value: '{currentShipmentItem.intItemId}',
                            conjunction: 'and'
                        }]
                    }
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
                                deleteButton: grdLotTracking.down('#btnRemoveLot')
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
            current.set('dblOrderQty', records[0].get('dblQtyOrdered'));
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
            current.set('dblLotQty', records[0].get('dblQty'));
        }
        else if (combo.itemId === 'cboLotUOM')
        {
            current.set('intItemUOMId', records[0].get('intItemUOMId'));
        }
        else if (combo.itemId === 'cboLotWeightUOM')
        {
            current.set('intWeightUOMId', records[0].get('intItemUOMId'));
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
            "#grdInventoryShipment": {
                selectionchange: this.onItemSelectionChange
            },
            "#cboLot": {
                select: this.onLotSelect
            },
            "#cboLotUOM": {
                select: this.onLotSelect
            },
            "#cboLotWeightUOM": {
                select: this.onLotSelect
            },
            "#btnCustomer": {
                click: this.onCustomerClick
            }

        })
    }

});
