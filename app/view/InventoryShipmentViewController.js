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
                store: '{shipFromLocation}'
            },
            txtShipFromAddress: '{current.strShipFromAddress}',
            cboShipToAddress: {
                value: '{current.intShipToLocationId}',
                store: '{shipToLocation}'
            },
            txtShipToAddress: '{current.strShipToAddress}',
            txtDeliveryInstructions: '{current.strDeliveryInstruction}',
            txtComments: '{current.strComment}',
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
            store = Ext.create('Inventory.store.Shipment', { pageSize: 1 });

        var grdInventoryShipment = win.down('#grdInventoryShipment');

        win.context = Ext.create('iRely.mvvm.Engine', {
            window : win,
            store  : store,
            createRecord : me.createRecord,
            binding: me.config.binding,
            attachment: Ext.create('iRely.mvvm.attachment.Manager', {
                type: 'Inventory.Shipment',
                window: win
            }),
            details: [
                {
                    key: 'tblICInventoryShipmentItems',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: grdInventoryShipment,
                        deleteButton : grdInventoryShipment.down('#btnRemoveItem')
                    })
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
//        if (app.DefaultLocation > 0)
//            record.set('intLocationId', app.DefaultLocation);
        record.set('dtmShipDate', today);
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

    init: function(application) {
        this.control({
            "#cboShipFromAddress": {
                select: this.onShipLocationSelect
            },
            "#cboShipToAddress": {
                select: this.onShipLocationSelect
            }
        })
    }

});
