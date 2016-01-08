Ext.define('Inventory.view.InventoryShipmentViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.icinventoryshipment',

    config: {
        searchConfig: {
            title: 'Search Inventory Shipment',
            type: 'Inventory.InventoryShipment',
            api: {
                read: '../Inventory/api/InventoryShipment/Search'
            },
            columns: [
                {dataIndex: 'intInventoryShipmentId', text: "Shipment Id", flex: 1, defaultSort: true, dataType: 'numeric', key: true, hidden: true},
                {dataIndex: 'strShipmentNumber', text: 'Shipment Number', flex: 1, dataType: 'string', drillDownText: 'View Receipt', drillDownClick: 'onViewShipmentNo'},
                {dataIndex: 'dtmShipDate', text: 'Ship Date', flex: 1, dataType: 'date', xtype: 'datecolumn'},
                {dataIndex: 'strOrderType', text: 'Order Type', flex: 1, dataType: 'int'},
                {dataIndex: 'strSourceType', text: 'Source Type', flex: 1, dataType: 'int'},
                {dataIndex: 'strCustomerNumber', text: 'Customer', flex: 1, dataType: 'string', drillDownText: 'View Receipt', drillDownClick: 'onViewCustomerNo'},
                {dataIndex: 'strCustomerName', text: 'Customer Name', flex: 1, dataType: 'string', drillDownText: 'View Receipt', drillDownClick: 'onViewCustomerName'},
                {dataIndex: 'ysnPosted', text: 'Posted', flex: 1, dataType: 'boolean', xtype: 'checkcolumn'},

                {dataIndex: 'strReferenceNumber', text: 'Reference Number', flex: 1, dataType: 'string', hidden: true },
                {dataIndex: 'dtmRequestedArrivalDate', text: 'Requested Arrival Date', flex: 1, dataType: 'date', xtype: 'datecolumn', hidden: true },
                {dataIndex: 'strShipFromLocation', text: 'ShipFrom', flex: 1, dataType: 'string', hidden: true },
                {dataIndex: 'strShipToLocation', text: 'Ship To', flex: 1, dataType: 'string', hidden: true },
                {dataIndex: 'strFreightTerm', text: 'Freight Term', flex: 1, dataType: 'string', hidden: true },
                {dataIndex: 'strFobPoint', text: 'FOB Point', flex: 1, dataType: 'string', hidden: true },
                {dataIndex: 'strBOLNumber', text: 'BOL Number', flex: 1, dataType: 'string', hidden: true },
                {dataIndex: 'strShipVia', text: 'Ship Via', flex: 1, dataType: 'string', hidden: true },
                {dataIndex: 'strVessel', text: 'Vessel', flex: 1, dataType: 'string', hidden: true },
                {dataIndex: 'strProNumber', text: 'PRO Number', flex: 1, dataType: 'string', hidden: true },
                {dataIndex: 'strDriverId', text: 'Driver Id', flex: 1, dataType: 'string', hidden: true },
                {dataIndex: 'strSealNumber', text: 'Seal Number', flex: 1, dataType: 'string', hidden: true },
                {dataIndex: 'strDeliveryInstruction', text: 'Delivery Instruction', flex: 1, dataType: 'string', hidden: true },
                {dataIndex: 'dtmAppointmentTime', text: 'Appointment Time', flex: 1, dataType: 'date', xtype: 'datecolumn', hidden: true },
                {dataIndex: 'dtmDepartureTime', text: 'Departure Time', flex: 1, dataType: 'date', xtype: 'datecolumn', hidden: true },
                {dataIndex: 'dtmArrivalTime', text: 'Arrival Time', flex: 1, dataType: 'date', xtype: 'datecolumn', hidden: true },
                {dataIndex: 'dtmDeliveredDate', text: 'Delivered Date', flex: 1, dataType: 'date', xtype: 'datecolumn', hidden: true },
                {dataIndex: 'dtmFreeTime', text: 'Free Time', flex: 1, dataType: 'date', xtype: 'datecolumn', hidden: true },
                {dataIndex: 'strReceivedBy', text: 'Received By', flex: 1, dataType: 'string', hidden: true },
                {dataIndex: 'strComment', text: 'Comment', flex: 1, dataType: 'string', hidden: true }
            ],
            searchConfig: [
                {
                    title: 'Details',
                    api: {
                        read: '../Inventory/api/InventoryShipment/SearchShipmentItems'
                    },
                    columns: [
                        {dataIndex: 'intInventoryShipmentId', text: "Shipment Id", flex: 1, defaultSort: true, dataType: 'numeric', key: true, hidden: true},
                        {dataIndex: 'strShipmentNumber', text: 'Shipment Number', flex: 1, dataType: 'string', drillDownText: 'View Receipt', drillDownClick: 'onViewShipmentNo'},
                        {dataIndex: 'dtmShipDate', text: 'Ship Date', flex: 1, dataType: 'date', xtype: 'datecolumn'},
                        {dataIndex: 'strOrderType', text: 'Order Type', flex: 1, dataType: 'int'},
                        {dataIndex: 'strSourceType', text: 'Source Type', flex: 1, dataType: 'int'},
                        {dataIndex: 'strCustomerNumber', text: 'Customer', flex: 1, dataType: 'string', drillDownText: 'View Receipt', drillDownClick: 'onViewCustomerNo', hidden: true },
                        {dataIndex: 'strCustomerName', text: 'Customer Name', flex: 1, dataType: 'string', drillDownText: 'View Receipt', drillDownClick: 'onViewCustomerName', hidden: true },
                        {dataIndex: 'ysnPosted', text: 'Posted', flex: 1, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },

                        {dataIndex: 'strItemNo', text: 'Item No', flex: 1, dataType: 'string', drillDownText: 'View Item', drillDownClick: 'onViewItemNo'},
                        {dataIndex: 'strItemDescription', text: 'Description', flex: 1, dataType: 'string', drillDownText: 'View Item', drillDownClick: 'onViewItemNo'},
                        {dataIndex: 'strOrderNumber', text: 'Order Number', flex: 1, dataType: 'string'},
                        {dataIndex: 'strSourceNumber', text: 'Source Number', flex: 1, dataType: 'string'},
                        {dataIndex: 'strUnitMeasure', text: 'Ship UOM', flex: 1, dataType: 'string'},

                        { xtype: 'numbercolumn', dataIndex: 'dblQtyToShip', text: 'Quantity', flex: 1, dataType: 'float'},
                        { xtype: 'numbercolumn', dataIndex: 'dblPrice', text: 'Unit Price', flex: 1, dataType: 'float'},
                        { xtype: 'numbercolumn', dataIndex: 'dblLineTotal', text: 'Line Total', flex: 1, dataType: 'float'}
                    ]
                },
                {
                    title: 'Lots',
                    api: {
                        read: '../Inventory/api/InventoryShipment/SearchShipmentItemLots'
                    },
                    columns: [
                        {dataIndex: 'intInventoryShipmentId', text: "Shipment Id", flex: 1, defaultSort: true, dataType: 'numeric', key: true, hidden: true},
                        {dataIndex: 'strShipmentNumber', text: 'Shipment Number', flex: 1, dataType: 'string', drillDownText: 'View Receipt', drillDownClick: 'onViewShipmentNo'},
                        {dataIndex: 'dtmShipDate', text: 'Ship Date', flex: 1, dataType: 'date', xtype: 'datecolumn'},
                        {dataIndex: 'strOrderType', text: 'Order Type', flex: 1, dataType: 'int'},
                        {dataIndex: 'strSourceType', text: 'Source Type', flex: 1, dataType: 'int'},
                        {dataIndex: 'strCustomerNumber', text: 'Customer', flex: 1, dataType: 'string', drillDownText: 'View Receipt', drillDownClick: 'onViewCustomerNo', hidden: true },
                        {dataIndex: 'strCustomerName', text: 'Customer Name', flex: 1, dataType: 'string', drillDownText: 'View Receipt', drillDownClick: 'onViewCustomerName', hidden: true },
                        {dataIndex: 'ysnPosted', text: 'Posted', flex: 1, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },

                        {dataIndex: 'strItemNo', text: 'Item No', flex: 1, dataType: 'string', drillDownText: 'View Item', drillDownClick: 'onViewItemNo'},
                        {dataIndex: 'strItemDescription', text: 'Description', flex: 1, dataType: 'string', drillDownText: 'View Item', drillDownClick: 'onViewItemNo'},
                        {dataIndex: 'strOrderNumber', text: 'Order Number', flex: 1, dataType: 'string', hidden: true },
                        {dataIndex: 'strSourceNumber', text: 'Source Number', flex: 1, dataType: 'string', hidden: true },
                        {dataIndex: 'strUnitMeasure', text: 'Ship UOM', flex: 1, dataType: 'string', hidden: true },

                        {dataIndex: 'strLotNumber', text: 'Lot Number', flex: 1, dataType: 'string'},
                        {dataIndex: 'strSubLocationName', text: 'Sub Location', flex: 1, dataType: 'string'},
                        {dataIndex: 'strStorageLocationName', text: 'Storage Location', flex: 1, dataType: 'string'},
                        {dataIndex: 'strLotUOM', text: 'Lot UOM', flex: 1, dataType: 'string'},
                        { xtype: 'numbercolumn', dataIndex: 'dblLotQty', text: 'Lot Qty', flex: 1, dataType: 'float'},
                        { xtype: 'numbercolumn', dataIndex: 'dblGrossWeight', text: 'Gross Wgt', flex: 1, dataType: 'float'},
                        { xtype: 'numbercolumn', dataIndex: 'dblTareWeight', text: 'Tare Wgt', flex: 1, dataType: 'float'},
                        { xtype: 'numbercolumn', dataIndex: 'dblNetWeight', text: 'Net Wgt', flex: 1, dataType: 'float'}
                    ]
                }
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
                readOnly: '{checkReadOnlyWithLineItem}'
            },
            cboSourceType: {
                value: '{current.intSourceType}',
                store: '{sourceTypes}',
                readOnly: '{checkReadOnlyWithLineItem}',
                defaultFilters: '{filterSourceByType}'
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
                hidden: '{readOnlyOnPickLots}'
            },
            btnPickLots: {
                hidden: '{!readOnlyOnPickLots}'
            },
            btnRemoveItem: {
                hidden: '{readOnlyOnPickLots}'
            },
            btnQuality: {
                hidden: '{current.ysnPosted}'
            },
            grdInventoryShipment: {
                readOnly: '{readOnlyOnPickLots}',
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

            btnRemoveLot: {
                hidden: '{readOnlyOnPickLots}'
            },
            grdLotTracking: {
                readOnly: '{readOnlyOnPickLots}',
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
                colAvailableQty: {
                    hidden: '{readOnlyOnPickLots}',
                    dataIndex: 'dblAvailableQty'
                },
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
                colLotStorageLocation: 'strStorageLocation',
                colWarehouseCargoNumber: 'strWarehouseCargoNumber'
            },

            btnInsertCharge: {
                hidden: '{current.ysnPosted}'
            },
            btnRemoveCharge: {
                hidden: '{current.ysnPosted}'
            },
            grdCharges: {
                readOnly: '{current.ysnPosted}',
                colContract: {
                    hidden: '{hideContractColumn}',
                    dataIndex: 'strContractNumber',
                    editor: {
                        origValueField: 'intContractHeaderId',
                        origUpdateField: 'intContractId',
                        store: '{contract}',
                        defaultFilters: [{
                            column: 'strContractType',
                            value: 'Purchase',
                            conjunction: 'and'
                        },{
                            column: 'intEntityId',
                            value: '{current.intEntityVendorId}',
                            conjunction: 'and'
                        }]
                    }
                },
                colOtherCharge: {
                    dataIndex: 'strItemNo',
                    editor: {
                        store: '{otherCharges}'
                    }
                },
                colOnCostType: 'strOnCostType',
                colCostMethod: {
                    dataIndex: 'strCostMethod',
                    editor: {
                        readOnly: '{readOnlyCostMethod}',
                        store: '{costMethod}'
                    }
                },
                colRate: 'dblRate',
                colCostUOM: {
                    dataIndex: 'strCostUOM',
                    editor: {
                        readOnly: '{readOnlyCostUOM}',
                        store: '{costUOM}',
                        origValueField: 'intItemUOMId',
                        origUpdateField: 'intCostUOMId',
                        defaultFilters: [
                            {
                                column: 'intItemId',
                                value: '{grdCharges.selection.intChargeId}',
                                conjunction: 'and'
                            }
                        ]
                    }
                },
                colChargeAmount: 'dblAmount',
                colAccrue: {
                    dataIndex: 'ysnAccrue'
                },
                colCostVendor: {
                    dataIndex: 'strVendorId',
                    editor: {
                        readOnly: '{readOnlyAccrue}',
                        origValueField: 'intEntityVendorId',
                        origUpdateField: 'intEntityVendorId',
                        store: '{vendor}'
                    }
                },
                colPrice: 'ysnPrice'
            }
        }
    },

    setupContext : function(options) {
        "use strict";
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.Shipment', { pageSize: 1 });

        var grdInventoryShipment = win.down('#grdInventoryShipment'),
            grdLotTracking = win.down('#grdLotTracking'),
            grdCharges = win.down('#grdCharges');

        win.context = Ext.create('iRely.Engine', {
            window: win,
            store: store,
            enableComment: true,
            enableAudit: true,
            include: 'vyuICGetInventoryShipment, ' +
                'tblICInventoryShipmentCharges.vyuICGetInventoryShipmentCharge, ' +
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
                },
                {
                    key: 'tblICInventoryShipmentCharges',
                    component: Ext.create('iRely.grid.Manager', {
                        grid: grdCharges,
                        deleteButton: grdCharges.down('#btnRemoveCharge')
                    })
                }
            ]
        });

        win.context.data.on({
            currentrecordchanged: me.currentRecordChanged,
            scope: win
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

    currentRecordChanged: function(current) {
        current.tblICInventoryShipmentItems().on({
            add: this.controller.triggerAddRemoveLineItem,
            remove: this.controller.triggerAddRemoveLineItem,
            scope: this
        });
    },

    triggerAddRemoveLineItem: function(config, record, e) {
        this.viewModel.set('triggerAddRemoveLineItem', !this.viewModel.get('triggerAddRemoveLineItem'));
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
                    current.set('dblUnitPrice', records[0].get('dblCashPrice'));
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

            current.set('intSubLocationId', records[0].get('intSubLocationId'));
            current.set('strSubLocationName', records[0].get('strSubLocationName'));
            current.set('intStorageLocationId', records[0].get('intStorageLocationId'));
            current.set('strStorageLocationName', records[0].get('strStorageLocationName'));
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
                        iRely.Functions.showCustomDialog('question', 'yesno', 'Invoice successfully processed. Do you want to view this Invoice?', buttonAction);
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

    onViewShipmentNo: function (value, record) {
        i21.ModuleMgr.Inventory.showScreen(value, 'ShipmentNo');
    },

    onViewCustomerNo: function (value, record) {
        var strName = record.get('strCustomerName');
        i21.ModuleMgr.Inventory.showScreen(strName, 'CustomerName');
    },

    onViewCustomerName: function (value, record) {
        i21.ModuleMgr.Inventory.showScreen(value, 'CustomerName');
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
                        hidden: true
                    },
                    {
                        dataIndex: 'intSalesOrderDetailId',
                        dataType: 'numeric',
                        hidden: true
                    },
                    {
                        dataIndex: 'intCompanyLocationId',
                        dataType: 'string',
                        hidden: true
                    },
                    {
                        dataIndex: 'intItemId',
                        dataType: 'string',
                        hidden: true
                    },
                    {
                        dataIndex: 'intCommodityId',
                        dataType: 'string',
                        hidden: true
                    },
                    {
                        dataIndex: 'intItemUOMId',
                        dataType: 'string',
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
                        hidden: true
                    },
                    {
                        dataIndex: 'strStorageLocation',
                        dataType: 'string',
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
                        dataIndex: 'strContractNumber',
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
                displayField: 'strContractNumber',
                valueField: 'strContractNumber',
                store: win.viewModel.storeInfo.salesContract,
                defaultFilters: [{
                    column: 'strContractType',
                    value: 'Sale',
                    conjunction: 'and'
                },{
                    column: 'intEntityId',
                    value: win.viewModel.data.current.get('intEntityVendorId'),
                    conjunction: 'and'
                },{
                    column: 'ysnAllowedToShow',
                    value: true,
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

    onChargeSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var record = records[0];
        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepCharges');
        var current = plugin.getActiveRecord();
        var masterRecord = win.viewModel.data.current;

        if (combo.itemId === 'cboOtherCharge') {
            current.set('intChargeId', record.get('intItemId'));
            current.set('dblRate', record.get('dblAmount'));
            current.set('intCostUOMId', record.get('intCostUOMId'));
            current.set('strCostMethod', record.get('strCostMethod'));
            current.set('strCostUOM', record.get('strCostUOM'));
            current.set('strOnCostType', record.get('strOnCostType'));
            current.set('ysnPrice', record.get('ysnPrice'));
            if (!iRely.Functions.isEmpty(record.get('strOnCostType'))) {
                current.set('strCostMethod', 'Percentage');
            }
        }
    },

    onQualityClick: function(button, e, eOpts) {
        var grid = button.up('grid');

        var selected = grid.getSelectionModel().getSelection();

        if (selected) {
            if (selected.length > 0){
                var current = selected[0];
                if (!current.dummy)
                    iRely.Functions.openScreen('Grain.view.QualityTicketDiscount', { strSourceType: 'Inventory Shipment', intTicketFileId: current.get('intInventoryShipmentItemId') });
            }
            else {
                iRely.Functions.showErrorDialog('Please select an Item to view.');
            }
        }
        else {
            iRely.Functions.showErrorDialog('Please select an Item to view.');
        }
    },

    onWarehouseInstructionClick: function(button, e, eOpts) {
        var win = button.up('window');
        var vm = win.viewModel;
        var current = vm.data.current;
        var context = win.context;

        if (current.phantom === true)
            return;

        if (context.data.hasChanges()) {
            iRely.Functions.showErrorDialog('Please save changes before opening Warehouse Instructions screen');
            return;
        }

        var commodity = Ext.Array.findBy(current.tblICInventoryShipmentItems().data.items, function (row) {
            if (!iRely.Functions.isEmpty(row.get('intCommodityId'))) {
                return true;
            }
        });

        if (!commodity) {
            iRely.Functions.showErrorDialog('Atleast one(1) line item must be a Commodity Item.');
            return;
        }

        var subLocation = Ext.Array.findBy(current.tblICInventoryShipmentItems().data.items, function (row) {
            if (!iRely.Functions.isEmpty(row.get('intSubLocationId'))) {
                return true;
            }
        });

        if (!subLocation) {
            iRely.Functions.showErrorDialog('Atleast one(1) line item must have a Sub Location specified.');
            return;
        }

        if (iRely.Functions.isEmpty(current.data.intWarehouseInstructionHeaderId) === false)
        {
            iRely.Functions.openScreen('Logistics.view.WarehouseInstructions',
                {
                    action: 'edit',
                    filters : [{ column: 'intWarehouseInstructionHeaderId', value: current.data.intWarehouseInstructionHeaderId, conjunction: 'and'}]
                });
        }
        else {
            iRely.Functions.openScreen('Logistics.view.WarehouseInstructions',
                {
                    action: 'new',
                    intInventoryShipmentId: current.data.intInventoryShipmentId,
                    strReferenceNumber: current.data.strReferenceNumber,
                    intSourceType: 2,
                    intCommodityId: commodity.get('intCommodityId'),
                    intCompanyLocationId: current.data.intShipFromLocationId,
                    intCompanyLocationSubLocationId: subLocation.get('intSubLocationId')
                });
        }
    },

    onPrintBOLClick: function(button, e, eOpts) {
        var win = button.up('window');

        // Save has data changes first before doing the post.
        win.context.data.saveRecord({
            callbackFn: function() {
                var vm = win.viewModel;
                var current = vm.data.current;

                var filters = [{
                    Name: 'strShipmentNumber',
                    Type: 'string',
                    Condition: 'EQUAL TO',
                    From: current.get('strShipmentNumber'),
                    Operator: 'AND'
                }];
                
                iRely.Functions.openScreen('Reporting.view.ReportViewer', {
                    selectedReport: 'BillOfLading',
                    selectedGroup: 'Inventory',
                    selectedParameters: filters
                });
            }
        });
    },

    onPickLotsClick: function(button, e, eOpts) {
        var grid = button.up('grid');
        var shipmentWin = button.up('window');
        var vm = shipmentWin.getViewModel();
        var current = vm.data.current;

        iRely.Functions.openScreen('Inventory.view.PickLot', {
            viewConfig: {
                modal: true,
                listeners: {
                    close: function(win) {
                        if (win) {
                            if (win.AddPickLots) {
                                if (current) {
                                    Ext.Array.each(win.AddPickLots, function (pickLot) {
                                        if (pickLot.vyuLGDeliveryOpenPickLotDetails) {
                                            Ext.Array.each(pickLot.vyuLGDeliveryOpenPickLotDetails().data.items, function (lot) {
                                                var exists = Ext.Array.findBy(current.tblICInventoryShipmentItems().data.items, function (row) {
                                                    if (lot.get('intSContractHeaderId') === row.get('intOrderId') &&
                                                        lot.get('intPickLotHeaderId') === row.get('intSourceId')) {
                                                        return true;
                                                    }
                                                });
                                                if (!exists) {
                                                    var newItem = Ext.create('Inventory.model.ShipmentItem', {
                                                        intOrderId: lot.get('intSContractHeaderId'),
                                                        strOrderNumber: lot.get('strSContractNumber'),
                                                        intSourceId: lot.get('intPickLotHeaderId'),
                                                        strSourceNumber: lot.get('intReferenceNumber'),
                                                        intLineNo: lot.get('intPickLotDetailId'),
                                                        intItemId: lot.get('intItemId'),
                                                        strItemNo: lot.get('strItemNo'),
                                                        strItemDescription: lot.get('strItemDescription'),
                                                        strLotTracking: lot.get('strLotTracking'),
                                                        intCommodityId: lot.get('intCommodityId'),
                                                        intItemUOMId: lot.get('intItemUOMId'),
                                                        strUnitMeasure: lot.get('strSaleUnitMeasure'),
                                                        intWeightUOMId: lot.get('intWeightItemUOMId'),
                                                        strWeightUOM: lot.get('strWeightUnitMeasure'),
                                                        dblQuantity: 0,
                                                        strOrderUOM: lot.get('strSaleUnitMeasure'),
                                                        dblQtyOrdered: lot.get('dblSalesOrderedQty'),
                                                        dblUnitPrice: lot.get('dblCashPrice'),
                                                        intOwnershipType: lot.get('intOwnershipType'),
                                                        strOwnershipType: lot.get('strOwnershipType'),
                                                        intSubLocationId: lot.get('intSubLocationId'),
                                                        intStorageLocationId: lot.get('intStorageLocationId'),
                                                        strSubLocationName: lot.get('strSubLocationName'),
                                                        strStorageLocationName: lot.get('strStorageLocation')
                                                    });

                                                    var totalQty = 0;
                                                    Ext.Array.each(pickLot.vyuLGDeliveryOpenPickLotDetails().data.items, function (lotDetails) {
                                                        if (lotDetails.get('intSContractHeaderId') === lot.get('intSContractHeaderId') &&
                                                            lotDetails.get('intPickLotHeaderId') === lot.get('intPickLotHeaderId')) {
                                                            totalQty += lotDetails.get('dblLotPickedQty');
                                                            var newItemLot = Ext.create('Inventory.model.ShipmentItemLot', {
                                                                intLotId: lotDetails.get('intLotId'),
                                                                strLotId: lotDetails.get('strLotNumber'),
                                                                dblLotQty: lotDetails.get('dblLotPickedQty'),
                                                                dblAvailableQty: lotDetails.get('dblLotPickedQty'),
                                                                dblQuantityShipped: lotDetails.get('dblLotPickedQty'),
                                                                strUnitMeasure: lotDetails.get('strLotUnitMeasure'),
                                                                strWeightUOM: lotDetails.get('strWeightUnitMeasure'),
                                                                dblGrossWeight: lotDetails.get('dblGrossWt'),
                                                                dblTareWeight: lotDetails.get('dblTareWt'),
                                                                dblNetWeight: lotDetails.get('dblNetWt'),
                                                                strStorageLocation: lotDetails.get('strStorageLocation')
                                                            });
                                                            newItem.tblICInventoryShipmentItemLots().add(newItemLot);
                                                        }
                                                    });

                                                    newItem.set('dblQuantity', totalQty);

                                                    current.tblICInventoryShipmentItems().add(newItem);
                                                }
                                            });
                                        }

                                    });
                                }
                            }
                        }
                    }
                }
            },
            intCustomerId: current.get('intEntityCustomerId'),
            intShipFromId: current.get('intShipFromLocationId')
        });

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
            },
            "#cboOtherCharge": {
                select: this.onChargeSelect
            },
            "#btnQuality": {
                click: this.onQualityClick
            },
            "#btnPickLots": {
                click: this.onPickLotsClick
            },
            "#btnWarehouseInstruction": {
                click: this.onWarehouseInstructionClick
            },
            "#btnPrintBOL": {
                click: this.onPrintBOLClick
            }
        })
    }

});
