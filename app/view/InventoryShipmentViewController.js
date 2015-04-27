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
            }
        }
    },

    setupContext : function(options) {
        "use strict";
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.Shipment', { pageSize: 1 });

        var grdInventoryShipment = win.down('#grdInventoryShipment');

        win.context = Ext.create('iRely.mvvm.Engine', {
            window: win,
            store: store,
            createRecord: me.createRecord,
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
                        deleteButton: grdInventoryShipment.down('#btnRemoveItem')
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
            current.set('intItemUOMId', records[0].get('intItemUOMId'));
            current.set('strUnitMeasure', records[0].get('strUnitMeasure'));
            current.set('dblQuantity', records[0].get('dblQtyOrdered'));
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
            }
        })
    }

});
