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
                {dataIndex: 'strBOLNumber', text: 'BOL Number', flex: 1,  dataType: 'string'},
                {dataIndex: 'dtmShipDate', text: 'Ship Date', flex: 1,  dataType: 'date', xtype: 'datecolumn'},
                {dataIndex: 'strOrderType',text: 'Order Type', flex: 1,  dataType: 'int'}
            ]
        },
        binding: {
            txtBOLNumber: '{current.strBOLNumber}',
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
                value: '{current.intCustomerId}',
                store: '{customer}'
            },
            txtCustomerName: '{current.strVendorName}',
            cboShipFromAddress: {
                value: '{current.intShipFromLocationId}',
                store: '{location}'
            },
//            txtShipFromAddress: '{current.strShipToAddress}',
//            cboShipToAddress: {
//                value: '{current.intCurrencyId}',
//                store: '{}'
//            },
            txtShipToAddress: '{current.strShipToAddress}',
//            txtDeliveryInstructions: '{current.strVendorRefNo}',
//            txtComments: '{current.strBillOfLading}',
            chkDirectShipment: '{current.ysnDirectShipment}',
            cboCarrier: {
                value: '{current.intCarrierId}',
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
                colReferenceNumber: 'strReferenceNumber',
                colItemNumber: {
                    dataIndex: 'strItemNo',
                    editor: {
                        store: '{items}'
                    }
                },
                colDescription: 'strItemDescription',
//                colSubLocation: '',
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
                colWeightUOM: {
                    dataIndex: 'strWeightUnitMeasure',
                    editor: {
                        store: '{weightUOM}',
                        defaultFilters: [{
                            column: 'intItemId',
                            value: '{grdInventoryReceipt.selection.intItemId}'
                        }]
                    }
                },
//                colGrossWeight: '',
                colTareWeight: 'dblTareWeight',
                colNetWeight: 'dbNetWeight',
                colUnitPrice: 'dblUnitPrice',
//                colDockDoor: {
//                    dataIndex: 'strDockDoor',
//                    editor: {
//                        store: '{itemPackType}'
//                    }
//                },
                colNotes: 'strNotes'
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
        if (app.DefaultLocation > 0)
            record.set('intLocationId', app.DefaultLocation);
        record.set('dtmReceiptDate', today);
        record.set('dtmReceiptDate', today);
        action(record);
    },

    onVendorSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var current = win.viewModel.data.current;

        if (current) current.set('strVendorName', records[0].get('strName'));
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
            current.set('intItemId', records[0].get('intItemId'));
            current.set('strItemDescription', records[0].get('strDescription'));
            current.set('strLotTracking', records[0].get('strLotTracking'));

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
            current.set('intUnitMeasureId', records[0].get('intUnitMeasureId'));
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
            }
        })
    }

});
