Ext.define('Inventory.view.InventoryShipmentViewController', {
    extend: 'Inventory.view.InventoryBaseViewController',
    alias: 'controller.icinventoryshipment',
    requires: [
        'CashManagement.common.Text',
        'CashManagement.common.BusinessRules'
    ],

    config: {
        searchConfig: {
            title: 'Search Inventory Shipment',
            type: 'Inventory.InventoryShipment',
            api: {
                read: '../Inventory/api/InventoryShipment/Search'
            },
            columns: [
                {dataIndex: 'intInventoryShipmentId', text: "Shipment Id", flex: 1, defaultSort: true, sortOrder: 'DESC', dataType: 'numeric', key: true, hidden: true},
                {dataIndex: 'strShipmentNumber', text: 'Shipment Number', flex: 1, dataType: 'string', drillDownText: 'View Receipt', drillDownClick: 'onViewShipmentNo'},
                {dataIndex: 'dtmShipDate', text: 'Ship Date', flex: 1, dataType: 'date', xtype: 'datecolumn'},
                {dataIndex: 'strOrderType', text: 'Order Type', flex: 1, dataType: 'int'},
                {dataIndex: 'strSourceType', text: 'Source Type', flex: 1, dataType: 'int'},
                {dataIndex: 'strCustomerNumber', text: 'Customer', flex: 1, dataType: 'string', drillDownText: 'View Receipt', drillDownClick: 'onViewCustomerNo'},
                {dataIndex: 'strCustomerName', text: 'Customer Name', flex: 1, dataType: 'string', drillDownText: 'View Receipt', drillDownClick: 'onViewCustomerName'},
                {dataIndex: 'strCurrency', text: 'Currency', width: 80, dataType: 'string'},
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
                {dataIndex: 'strFreeTime', text: 'Free Time', flex: 1, dataType: 'string', hidden: true },
                {dataIndex: 'strReceivedBy', text: 'Received By', flex: 1, dataType: 'string', hidden: true },
                {dataIndex: 'strComment', text: 'Comment', flex: 1, dataType: 'string', hidden: true }
            ],
            buttons: [
                {
                    text: 'Items',
                    itemId: 'btnItem',
                    clickHandler: 'onItemClick',
                    width: 80
                },
                {
                    text: 'Categories',
                    itemId: 'btnCategory',
                    clickHandler: 'onCategoryClick',
                    width: 100
                },
                {
                    text: 'Commodities',
                    itemId: 'btnCommodity',
                    clickHandler: 'onCommodityClick',
                    width: 100
                },
                {
                    text: 'Locations',
                    itemId: 'btnLocation',
                    clickHandler: 'onLocationClick',
                    width: 100
                },
                {
                    text: 'Storage Locations',
                    itemId: 'btnStorageLocation',
                    clickHandler: 'onStorageLocationClick',
                    width: 110
                },
                {
                    text: 'Customer',
                    itemId: 'btnCustomer',
                    clickHandler: 'onViewCustomerClick',
                    width: 80
                }
            ],
            searchConfig: [
                {
                    title: 'Details',
                    api: {
                        read: '../Inventory/api/InventoryShipment/SearchShipmentItems'
                    },
                    columns: [
                        {dataIndex: 'intInventoryShipmentId', text: "Shipment Id", flex: 1, defaultSort: true, sortOrder: 'DESC', dataType: 'numeric', key: true, hidden: true},
                        {dataIndex: 'strShipmentNumber', text: 'Shipment Number', flex: 1, dataType: 'string', drillDownText: 'View Shipment', drillDownClick: 'onViewShipmentNo'},
                        {dataIndex: 'dtmShipDate', text: 'Ship Date', flex: 1, dataType: 'date', xtype: 'datecolumn'},
                        {dataIndex: 'strOrderType', text: 'Order Type', flex: 1, dataType: 'int'},
                        {dataIndex: 'strSourceType', text: 'Source Type', flex: 1, dataType: 'int'},
                        {dataIndex: 'strCustomerNumber', text: 'Customer', flex: 1, dataType: 'string', drillDownText: 'View Customer', drillDownClick: 'onViewCustomerNo', hidden: true },
                        {dataIndex: 'strCustomerName', text: 'Customer Name', flex: 1, dataType: 'string', drillDownText: 'View Customer', drillDownClick: 'onViewCustomerName', hidden: true },
                        {dataIndex: 'strCurrency', text: 'Currency', width: 80, dataType: 'string'},
                        {dataIndex: 'ysnPosted', text: 'Posted', flex: 1, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },

                        {dataIndex: 'strItemNo', text: 'Item No', flex: 1, dataType: 'string', drillDownText: 'View Item', drillDownClick: 'onViewItemNo'},
                        {dataIndex: 'strItemDescription', text: 'Description', flex: 1, dataType: 'string'},

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
                        {dataIndex: 'intInventoryShipmentId', text: "Shipment Id", flex: 1, defaultSort: true, sortOrder: 'DESC', dataType: 'numeric', key: true, hidden: true},
                        {dataIndex: 'strShipmentNumber', text: 'Shipment Number', flex: 1, dataType: 'string', drillDownText: 'View Receipt', drillDownClick: 'onViewShipmentNo'},
                        {dataIndex: 'dtmShipDate', text: 'Ship Date', flex: 1, dataType: 'date', xtype: 'datecolumn'},
                        {dataIndex: 'strOrderType', text: 'Order Type', flex: 1, dataType: 'int'},
                        {dataIndex: 'strSourceType', text: 'Source Type', flex: 1, dataType: 'int'},
                        {dataIndex: 'strCustomerNumber', text: 'Customer', flex: 1, dataType: 'string', drillDownText: 'View Receipt', drillDownClick: 'onViewCustomerNo', hidden: true },
                        {dataIndex: 'strCustomerName', text: 'Customer Name', flex: 1, dataType: 'string', drillDownText: 'View Receipt', drillDownClick: 'onViewCustomerName', hidden: true },
                        {dataIndex: 'strCurrency', text: 'Currency', width: 80, dataType: 'string'},
                        {dataIndex: 'ysnPosted', text: 'Posted', flex: 1, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },

                        {dataIndex: 'strItemNo', text: 'Item No', flex: 1, dataType: 'string', drillDownText: 'View Item', drillDownClick: 'onViewItemNo'},
                        {dataIndex: 'strItemDescription', text: 'Description', flex: 1, dataType: 'string'},
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
                },
                {
                    title: 'Invoices',
                    api: {
                        read: '../Inventory/api/InventoryShipment/ShipmentInvoice'
                    },
                    columns: [
                        { dataIndex: 'intInventoryShipmentId', text: "Shipment Id", flex: 1, dataType: 'numeric', key: true, hidden: true},
                        { dataIndex: 'intInventoryShipmentItemId', text: "Shipment Id", flex: 1, defaultSort: true, sortOrder: 'DESC', dataType: 'numeric', hidden: true},
                        { dataIndex: 'intInventoryShipmentChargeId', text: "Shipment Id", flex: 1, defaultSort: true, sortOrder: 'DESC', dataType: 'numeric', hidden: true},
                        { dataIndex: 'strAllVouchers', text: 'Invoice Nos.', width: 100, dataType: 'string', drillDownText: 'View Invoice', drillDownClick: 'onViewInvoice' },
                        { dataIndex: 'strShipmentNumber', text: 'Shipment No.', width: 100, defaultSort: true, sortOrder: 'DESC', dataType: 'string'},
                        { dataIndex: 'dtmShipDate', text: 'Ship Date', width: 100, dataType: 'date', xtype: 'datecolumn'},
                        { dataIndex: 'strCustomer', text: 'Customer', width: 300, dataType: 'string' },
                        { dataIndex: 'strLocationName', text: 'Ship From', width: 200, dataType: 'string' },
                        { dataIndex: 'strDestination', text: 'Ship To', width: 200, dataType: 'string' },
                        { dataIndex: 'strBOLNumber', text: 'Bill of Lading', width: 100, dataType: 'string' },
                        { dataIndex: 'strOrderType', text: 'Order Type', width: 120, dataType: 'string' },
                        { dataIndex: 'strItemNo', text: 'Item No.', width: 100, dataType: 'string' },
                        { xtype: 'numbercolumn', dataIndex: 'dblUnitCost', text: 'Cost', width: 100, dataType: 'float', xtype: 'numbercolumn'},
                        { xtype: 'numbercolumn', dataIndex: 'dblShipmentQty', text: 'Shipped Qty', width: 120, dataType: 'float', xtype: 'numbercolumn', emptyCellText: '0.00', aggregate: 'sum', aggregateFormat: '#,###.00'},
                        { xtype: 'numbercolumn', dataIndex: 'dblInTransitQty', text: 'In-Transit Qty', width: 120, dataType: 'float', xtype: 'numbercolumn', emptyCellText: '0.00', aggregate: 'sum', aggregateFormat: '#,###.00'},
                        { xtype: 'numbercolumn', dataIndex: 'dblInvoiceQty', text: 'Invoiced Qty', width: 120, dataType: 'float', xtype: 'numbercolumn', emptyCellText: '0.00', aggregate: 'sum', aggregateFormat: '#,###.00'},
                        { xtype: 'numbercolumn', dataIndex: 'dblShipmentLineTotal', text: 'Shipment Line Total', width: 120, dataType: 'float', xtype: 'numbercolumn', emptyCellText: '0.00', aggregate: 'sum', aggregateFormat: '#,###.00'},                        
                        { xtype: 'numbercolumn', dataIndex: 'dblInvoiceLineTotal', text: 'Invoice Line Total', width: 120, dataType: 'float', xtype: 'numbercolumn', emptyCellText: '0.00', aggregate: 'sum', aggregateFormat: '#,###.00'},
                        { xtype: 'numbercolumn', dataIndex: 'dblOpenQty', text: 'Uncleared Qty', width: 150, dataType: 'float', xtype: 'numbercolumn', emptyCellText: '0.00', aggregate: 'sum', aggregateFormat: '#,###.00'},
                        { xtype: 'numbercolumn', dataIndex: 'dblInTransitTotal', text: 'Uncleared Items Total', width: 150, dataType: 'float', xtype: 'numbercolumn', emptyCellText: '0.00', aggregate: 'sum', aggregateFormat: '#,###.00'},
                        { dataIndex: 'dtmLastInvoiceDate', text: 'Last Invoice Date', width: 120, dataType: 'date', xtype: 'datecolumn' },
                        { dataIndex: 'strFilterString', text: 'Voucher Nos.', flex: 1, dataType: 'string', required: true, hidden: true }               
                        
                    ],
                    buttons: [
                        {
                            text: 'Refresh Invoices',
                            itemId: 'btnRefreshInvoices',
                            clickHandler: 'onRefreshInvoicesClick',
                            width: 400
                        }                        
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
            btnPost: {
                hidden: '{hidePostButton}'
            },
            btnUnpost: {
                hidden: '{hideUnpostButton}'
            },
            // btnPostPreview: {
            //     hidden: '{hidePostButton}'
            // },
            // btnUnpostPreview: {
            //     hidden: '{hideUnpostButton}'    
            // },
            btnInvoice: {
                hidden: '{!current.ysnPosted}'
            },
            btnAddOrders: {
                hidden: '{checkHiddenAddOrders}'
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
            cboCurrency: {
                value: '{current.intCurrencyId}',                
                readOnly: '{current.ysnPosted}',
                store: '{currency}',
                defaultFilters: [
                    {
                        column: 'ysnSubCurrency',
                        value: false
                    }
                ]
            },            
            cboCustomer: {
                value: '{current.intEntityCustomerId}',
                store: '{customer}',
                readOnly: '{current.ysnPosted}',
                fieldLabel: '{setCustomerFieldLabel}',
                defaultFilters: [{
                    column: 'ysnActive',
                    value: true
                }]
            },
            cboShipFromAddress: {
                value: '{current.intShipFromLocationId}',
                store: '{shipFromLocation}',
                readOnly: '{current.ysnPosted}'
            },
            txtShipFromAddress: '{strShipFromAddress}',
            cboShipToAddress: {
                value: '{current.intShipToLocationId}',
                store: '{shipToLocation}',
                readOnly: '{current.ysnPosted}',
                defaultFilters: [{
                    column: 'intEntityId',
                    value: '{current.intEntityCustomerId}'
                }],
                hidden: '{hideShipToLocation}',
                fieldLabel: '{setShipToFieldLabel}'
            },
            cboShipToCompanyAddress: {
                value: '{current.intShipToCompanyLocationId}',
                store: '{shipToCompanyLocation}',
                readOnly: '{current.ysnPosted}',
                defaultFilters: [{
                    column: 'intCompanyLocationId',
                    value: '{current.intShipFromLocationId}',
                    conjunction: 'and',
                    condition: 'noteq'
                }],
                hidden: '{hideShipToCompanyLocation}',
                fieldLabel: '{setShipToFieldLabel}'
            },
            txtShipToAddress: '{strShipToAddress}',
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
            strFreeTime: {
                value: '{current.strFreeTime}',
                readOnly: '{current.ysnPosted}'
            },
            txtReceivedBy: '{current.strReceivedBy}',

            btnInsertItem: {
                hidden: '{readOnlyOnPickLots}'
            },
            btnPickLots: {
                hidden: true
            },
            btnRemoveItem: {
                hidden: '{readOnlyOnPickLots}'
            },
            btnCalculateCharges: {
                hidden: '{current.ysnPosted}'
            },
            grdInventoryShipment: {
                readOnly: '{readOnlyOnPickLots}',
                colOrderNumber: {
                    hidden: '{checkHideOrderNo}',
                    dataIndex: 'strOrderNumber'
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
                        },{
                            column: 'excludePhasedOutZeroStockItem',
                            value: true,
                            conjunction: 'and'
                        }]
                    }
                },
                colDescription: 'strItemDescription',
                colCustomerStorage: {
                    dataIndex: 'strStorageTypeDescription',
                    editor: {
                        readOnly: '{disableFieldInShipmentGrid}',
                        store: '{customerStorage}',
                        defaultFilters: [
                            {
                                column: 'intEntityId',
                                value: '{current.intEntityCustomerId}',
                                conjunction: 'and'
                            },
                            {
                                column: 'intItemId',
                                value: '{grdInventoryShipment.selection.intItemId}',
                                conjunction: 'and'
                            }
                        ]
                    }
                },
                colSubLocation: {
                    dataIndex: 'strSubLocationName',
                    editor: {
                        readOnly: '{disableFieldInShipmentGrid}',
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
                        readOnly: '{disableFieldInShipmentGrid}',
                        store: '{storageLocation}',
                        origValueField: 'intStorageLocationId',
                        origUpdateField: 'intStorageLocationId',
                        defaultFilters: [
                            {
                                column: 'intLocationId',
                                value: '{current.intShipFromLocationId}',
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
                // Grade from Commodity Attributes is now obsolete and will be removed
                // colGrade: {
                //     dataIndex: 'strGrade',
                //     editor: {
                //         readOnly: '{hasItemCommodity}',
                //         store: '{grade}',
                //         origValueField: 'intCommodityAttributeId',
                //         origUpdateField: 'intGradeId',
                //         defaultFilters: [
                //             {
                //                 column: 'intCommodityId',
                //                 value: '{grdInventoryShipment.selection.intCommodityId}',
                //                 conjunction: 'and'
                //             }
                //         ]
                //     }
                // },
                colDestGrades: {
                    dataIndex: 'strDestinationGrades',
                    editor: {
                        readOnly: '{readOnlyWeightsGrades}',
                        store: '{weightsGrades}',
                        origValueField: 'intWeightGradeId',
                        origUpdateField: 'intDestinationGradeId',
                        defaultFilters: [
                            {
                                column: 'ysnActive',
                                value: true,
                                conjunction: 'and'
                            },
                            {
                                column: 'ysnGrade',
                                value: true,
                                conjunction: 'and'
                            },
                            {
                                column: 'intOriginDest',
                                value: 2,
                                conjunction: 'and'
                            }
                        ]
                    }
                },
                colDestWeights: {
                    dataIndex: 'strDestinationWeights',
                    editor: {
                        readOnly: '{readOnlyWeightsGrades}',
                        store: '{weightsGrades}',
                        origValueField: 'intWeightGradeId',
                        origUpdateField: 'intDestinationWeightId',
                        defaultFilters: [
                            {
                                column: 'ysnActive',
                                value: true,
                                conjunction: 'and'
                            },
                            {
                                column: 'ysnWeight',
                                value: true,
                                conjunction: 'and'
                            },
                            {
                                column: 'intOriginDest',
                                value: 2,
                                conjunction: 'and'
                            }
                        ]
                    }
                },
                colDiscountSchedule: 'strDiscountSchedule',
                colOwnershipType: {
                    hidden: '{checkHideOwnershipType}',
                    dataIndex: 'strOwnershipType',
                    editor: {
                        readOnly: '{disableFieldInShipmentGrid}',
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
                colQuantity: {
                    dataIndex: 'dblQuantity',
                    editor: {
                        readOnly: '{disableFieldInShipmentGrid}'
                    }
                },
                colUOM: {
                    dataIndex: 'strUnitMeasure',
                    editor: {
                        readOnly: '{disableFieldInShipmentGrid}',
                        store: '{itemUOM}',
                        defaultFilters: [
                            {
                                column: 'intItemId',
                                value: '{grdInventoryShipment.selection.intItemId}',
                                conjunction: 'and'
                            },
                            {
                                column: 'intLocationId',
                                value: '{current.intShipFromLocationId}',
                                conjunction: 'and'
                            }
                        ]
                    }
                },
                colWeightUOM: {
                    dataIndex: 'strWeightUOM',
                    editor: {
                        readOnly: '{disableFieldInShipmentGrid}',
                        origValueField: 'intItemUOMId',
                        origUpdateField: 'intWeightUOMId',
                        store: '{weightUOM}',
                        defaultFilters: [{
                            column: 'intItemId',
                            value: '{grdInventoryShipment.selection.intItemId}'
                        }]
                    }
                },
                colUnitCost: 'dblUnitCost',
                colUnitPrice: {
                    dataIndex: 'dblUnitPrice',
                    //hidden: '{hideFunctionalCurrencyColumn}',
                    editor: {
                        readOnly: '{disableFieldInShipmentGrid}'
                    }
                },
                // colForeignUnitPrice: {
                //     dataIndex: 'dblForeignUnitPrice',
                //     hidden: '{hideForeignColumn}',
                //     editor: {
                //         readOnly: '{disableFieldInShipmentGrid}'
                //     }
                // },                
                colLineTotal: {
                    dataIndex: 'dblLineTotal'
                    //hidden: '{hideFunctionalCurrencyColumn}',
                },
                // colForeignLineTotal: {
                //     dataIndex:  'dblForeignLineTotal',
                //     hidden: '{hideForeignColumn}'
                // },
                colNotes: 'strNotes',
                colForexRateType: {
                    dataIndex: 'strForexRateType',
                    editor: {
                        origValueField: 'intCurrencyExchangeRateTypeId',
                        origUpdateField: 'intForexRateTypeId',
                        store: '{forexRateType}'
                    }
                },
                colForexRate: {
                    dataIndex: 'dblForexRate' 
                }                  
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
                        },
                        {
                            column: 'intLotStatusId',
                            value: 1,
                            condition: 'eq',
                            conjunction: 'and'
                        },
                        // Grade in Commodity Attributes is now obsolete and will be removed.
                        // {
                        //     column: 'intGradeId',
                        //     value: '{grdInventoryShipment.selection.intGradeId}',
                        //     conjunction: 'and'
                        // },
                        {
                            column: 'dblQty',
                            value: 0,
                            conjunction: 'and',
                            condition: 'gt'
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
                            value: 'Sale',
                            conjunction: 'and'
                        },{
                            column: 'intEntityId',
                            value: '{current.intEntityCustomerId}',
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
                colChargeCurrency: {
                    dataIndex: 'strCurrency',
                    editor: {
                        store: '{chargeCurrency}',
                        origValueField: 'intCurrencyID',
                        origUpdateField: 'intCurrencyId',
                        defaultFilters: [
                            {
                                column: 'ysnSubCurrency',
                                value: false,
                                conjunction: 'and'
                            }
                        ]
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
                colAllocatePriceBy: {
                    dataIndex: 'strAllocatePriceBy',
                    editor: {
                        readOnly: '{checkInventoryPrice}',
                        store: '{allocateBy}'
                    }
                },
                colAccrue: {
                    dataIndex: 'ysnAccrue',
                    disabled: '{current.ysnPosted}',
                },
                colCostVendor: {
                    dataIndex: 'strVendorName',
                    editor: {
                        readOnly: '{readOnlyAccrue}',
                        origValueField: 'intEntityVendorId',
                        origUpdateField: 'intEntityVendorId',
                        store: '{vendor}'
                    }
                },
                colPrice: 'ysnPrice',
                colChargeForexRateType: {
                    dataIndex: 'strForexRateType',
                    editor: {
                        origValueField: 'intCurrencyExchangeRateTypeId',
                        origUpdateField: 'intForexRateTypeId',
                        store: '{chargeForexRateType}'
                    }
                },
                colChargeForexRate: {
                    dataIndex: 'dblForexRate' 
                }
            },
            pgePostPreview: {
                title: '{pgePreviewTitle}'
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
            enableActivity: true,
            createTransaction: Ext.bind(me.createTransaction, me),
            enableAudit: true,
            onSaveClick: me.saveAndPokeGrid(win, grdInventoryShipment),
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
                        deleteButton: grdCharges.down('#btnRemoveCharge'),
                        createRecord: me.onChargeCreateRecord
                    })
                }
            ]
        });

        var cepItem = grdInventoryShipment.getPlugin('cepItem');
        if (cepItem) {
            cepItem.on({
                edit: me.onItemValidateEdit,
                scope: me
            });
        }        

        win.context.data.on({
            currentrecordchanged: me.currentRecordChanged,
            scope: win
        });
        
        var colShipQty = grdLotTracking.columns[2];
        var txtShipQty = colShipQty.getEditor();
        if (txtShipQty) {
            txtShipQty.on('change', me.onCalculateGrossWeight);
        }
        return win.context;
    },

    onCalculateGrossWeight: function(obj, newValue, oldValue, eOpts) {
        var win = obj.up('window');
        var grid = win.down('#grdLotTracking');
        var plugin = grid.getPlugin('cepLotTracking');
        var current = plugin.getActiveRecord();

        if (!current) return;
        
        var record = grid.selection;
        var availQty = record.get('dblAvailableQty');
        var shipQty = newValue;
        var lotDefaultQty = shipQty > availQty ? availQty : shipQty;
        var wgtPerQty = record.get('dblWeightPerQty');
        grossWgt = Ext.isNumeric(wgtPerQty) && Ext.isNumeric(lotDefaultQty) ? wgtPerQty * lotDefaultQty : 0;
        current.set('dblGrossWeight', grossWgt);
    },

    createTransaction: function(config, action) {
        var me = this,
            current = me.getViewModel().get('current');

        action({
            strTransactionNo: current.get('strShipmentNumber'), //Unique field
            intEntityId: current.get('intEntityId'), //Entity Associated
            dtmDate: current.get('dtmDate') // Date
        })
    },

    
    orgValueShipFrom: '',

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

            // Default control focus 
            var task = new Ext.util.DelayedTask(function(){
                var cboOrderType = win.down('#cboOrderType');
                if (cboOrderType) cboOrderType.focus();
            });
            task.delay(500);
            
        }
    },

    createRecord: function(config, action) {
        var me = this;
        var today = new Date();
        var record = Ext.create('Inventory.model.Shipment');
        var defaultShipmentType = i21.ModuleMgr.Inventory.getCompanyPreference('intShipmentOrderType');
        var defaultSourceType = i21.ModuleMgr.Inventory.getCompanyPreference('intShipmentSourceType');
        var defaultLocation = iRely.Configuration.Application.CurrentLocation; 
        
        if (defaultLocation){
            record.set('intShipFromLocationId', defaultLocation);
            Ext.create('i21.store.CompanyLocationBuffered', {
                storeId: 'icShipFrom',
                autoLoad: {
                    filters: [
                        {
                            dataIndex: 'intCompanyLocationId',
                            value: defaultLocation,
                            condition: 'eq'
                        }
                    ],
                    params: {
                        columns: 'intCompanyLocationId:strLocationName:strAddress:strCity:strStateProvince:strZipPostalCode:strCountry:'
                    },
                    callback: function(records, operation, success){
                        var companyLocation; 
                        if (records && records.length > 0) {
                            companyLocation = records[0];
                        }

                        if(success && companyLocation){
                            record.set('strShipFromStreet', companyLocation.get('strAddress'));
                            record.set('strShipFromCity', companyLocation.get('strCity'));
                            record.set('strShipFromState', companyLocation.get('strStateProvince'));
                            record.set('strShipFromZipPostalCode', companyLocation.get('strZipPostalCode'));
                            record.set('strShipFromCountry', companyLocation.get('strCountry'));    
                        }
                    }
                }
            });
        }
            
        record.set('dtmShipDate', today);

        if(defaultShipmentType !== null) {
            record.set('intOrderType', defaultShipmentType);
        }
            else {
                record.set('intOrderType', 2);
            }
        
        if(defaultSourceType !== null) {
            record.set('intSourceType', defaultSourceType);
        }
            else {
                record.set('intSourceType', 0);
            }
        
        action(record);
    },

    onLotCreateRecord: function(config, action) {
        var record = Ext.create('Inventory.model.ShipmentItemLot');
        record.set('dblQuantityShipped', config.dummy.get('dblQuantityShipped'));
        action(record);
    },

    getCustomerCurrency: function(customerId, action) {
        action = (typeof action === "function") ? action : function(){};

        if(customerId) {
            ic.utils.ajax({
                timeout: 120000,
                url: '../Inventory/api/InventoryShipment/GetCustomerCurrency',
                method: 'GET',
                params: {
                    customerId: customerId
                }
            })
                .subscribe(
                    function(response) {
                        var json = Ext.decode(response.responseText);
                        action(true, json);
                    },
                    function(response) {
                        action(false, response);
                    }
                );
        }
    },

    onChargeCreateRecord: function (config, action) {
        var win = config.grid.up('window');
        var record = Ext.create('Inventory.model.ShipmentCharge');
        record.set('strAllocatePriceBy', 'Unit');

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
        var grdInventoryShipment = win.down('#grdInventoryShipment');
        var grdInventoryShipmentCount = 0;
        var grdLotTracking = win.down('#grdLotTracking');
        
        if (current.tblICInventoryShipmentItems()) {
                Ext.Array.each(current.tblICInventoryShipmentItems().data.items, function(row) {
                    if (!row.dummy) {
                        grdInventoryShipmentCount++;
                    }
                });
            }
        
        if (current){
            if (combo.itemId === 'cboShipFromAddress'){
                    if(Inventory.view.InventoryShipmentViewController.orgValueShipFrom !== current.get('intShipFromLocationId')) {
                        var buttonAction = function(button) {
                            if (button === 'yes') {  
                                //Remove all items in Shipment Grid                   
                                var shipmentItems = current['tblICInventoryShipmentItems'](),
                                    shipmentItemRecords = shipmentItems ? shipmentItems.getRange() : [];

                                 var i = shipmentItemRecords.length - 1;

                                  for (; i >= 0; i--) {
                                      if (!shipmentItemRecords[i].dummy)
                                           shipmentItems.removeAt(i);
                                  }

                                  current.set('strShipFromStreet', records[0].get('strAddress'));
                                  current.set('strShipFromCity', records[0].get('strCity'));
                                  current.set('strShipFromState', records[0].get('strStateProvince'));
                                  current.set('strShipFromZipPostalCode', records[0].get('strZipPostalCode'));
                                  current.set('strShipFromCountry', records[0].get('strCountry'));
                            }
                            else {
                               current.set('intShipFromLocationId', Inventory.view.InventoryShipmentViewController.orgValueShipFrom);
                            }
                        };
                        
                        if(grdInventoryShipmentCount > 0) {
                                iRely.Functions.showCustomDialog('question', 'yesno', 'Changing Ship From location will clear all Items. Do you want to continue?', buttonAction);
                            }
                        else {                            
                            current.set('strShipFromStreet', records[0].get('strAddress'));
                            current.set('strShipFromCity', records[0].get('strCity'));
                            current.set('strShipFromState', records[0].get('strStateProvince'));
                            current.set('strShipFromZipPostalCode', records[0].get('strZipPostalCode'));
                            current.set('strShipFromCountry', records[0].get('strCountry'));                            
                        }
                            
                    }
                 
            }
            else if (combo.itemId === 'cboShipToAddress'){
                current.set('strShipToStreet', records[0].get('strAddress'));
                current.set('strShipToCity', records[0].get('strCity'));
                current.set('strShipToState', records[0].get('strState'));
                current.set('strShipToZipPostalCode', records[0].get('strZipCode'));
                current.set('strShipToCountry', records[0].get('strCountry'));
            }
            else if (combo.itemId === 'cboShipToCompanyAddress'){
                current.set('strShipToStreet', records[0].get('strAddress'));
                current.set('strShipToCity', records[0].get('strCity'));
                current.set('strShipToState', records[0].get('strStateProvince'));
                current.set('strShipToZipPostalCode', records[0].get('strZipPostalCode'));
                current.set('strShipToCountry', records[0].get('strCountry'));
            }
        }
    },

    onCustomerSelect: function(combo, records, eOpts) {
        var me = this; 

        if (records.length <= 0)
            return;

        var record = records[0];
        var win = combo.up('window');
        var current = win.viewModel.data.current;
        var cboShipToAddress = win.down('#cboShipToAddress');

        if (current && record){            
            current.set('intEntityCustomerId', record.get('intEntityCustomerId'));
            current.set('strCustomerName', record.get('strName'));

            //current.set('intShipToLocationId'), record.get('intShipToId');   
            current.set('strShipToStreet', record.get('strShipToAddress'));
            current.set('strShipToCity', record.get('strShipToCity'));
            current.set('strShipToState', record.get('strShipToState'));
            current.set('strShipToZipPostalCode', record.get('strShipToZipCode'));
            current.set('strShipToCountry', record.get('strShipToCountry'));

            if (cboShipToAddress) cboShipToAddress.setValue(record.get('intShipToId'));
        }

        var isHidden = true;
        switch (current.get('intOrderType')) {
            case 1:
                switch (current.get('intSourceType')) {
                    case 0:
                    case 2:
                        if (iRely.Functions.isEmpty(current.get('intEntityCustomerId'))) {
                            isHidden = true;
                        }
                        else {
                            isHidden = false;
                        }
                        break;
                    case 3:
                        isHidden = false;
                        break;
                    default:
                        isHidden = true;
                        break;

                }
                break;
            case 2:
                if (iRely.Functions.isEmpty(current.get('intEntityCustomerId'))) {
                    isHidden = true;
                }
                else {
                    isHidden = false;
                }
                break;
            default :
                me.getCustomerCurrency(current.get('intEntityCustomerId'), function(success, json) {
                    if(success) {
                        if(json.length > 0) {
                            current.set('intCurrencyId', !iRely.Functions.isEmpty(json[0].intCurrencyId) ? json[0].intCurrencyId : json[0].intDefaultCurrencyId);
                            current.set('strCurrency', !iRely.Functions.isEmpty(json[0].intCurrencyId) ? json[0].strCurrency : json[0].strDefaultCurrency);
                        } else {
                            var defaultCurrencyId = i21.ModuleMgr.SystemManager.getCompanyPreference('intDefaultCurrencyId');
                            current.set('intCurrencyId', defaultCurrencyId);
                        }
                    }
                });
                isHidden = true;
                break;
        }
        
        if (isHidden === false) {
            var btnAddOrders = win.down('#btnAddOrders');
            this.onAddOrderClick(btnAddOrders);
        }
    },

    onOrderNumberSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var pnlLotTracking = win.down('#pnlLotTracking');
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

                    if (!!records[0].get('strLotTracking') && records[0].get('strLotTracking') === 'No'){
                        pnlLotTracking.setHidden(true);
                    }
                    else {
                        pnlLotTracking.setHidden(false);
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

                    if (!!records[0].get('strLotTracking') && records[0].get('strLotTracking') === 'No'){
                        pnlLotTracking.setHidden(true);
                    }
                    else {
                        pnlLotTracking.setHidden(false);
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

    getItemSalesPrice: function(cfg, successFn, failureFn){
        // Sanitize parameters; 
        cfg = cfg ? cfg : {}; 
        successFn = successFn && (successFn instanceof Function) ? successFn : function(){ /*empty function*/ };
        failureFn = failureFn && (failureFn instanceof Function) ? failureFn : function(){ /*empty function*/ };

        ic.utils.ajax({
            url: '../accountsreceivable/api/common/getitemprice',
            params: {
                intItemId: cfg.ItemId,
                intCustomerId: cfg.CustomerId,
                intCurrencyId: cfg.CurrencyId,
                intLocationId: cfg.LocationId,
                intItemUOMId: cfg.ItemUOMId,
                dtmTransactionDate: cfg.TransactionDate,
                dblQuantity: cfg.Quantity,
                intContractHeaderId: null,
                intContractDetailId: null,
                strContractNumber: null,
                ysnCustomerPricingOnly: false,
                ysnItemPricingOnly: false,
                intContractSeq: null,
                dblOriginalQuantity: null,
                intShipToLocationId: cfg.ShipToLocationId,
                strInvoiceType: null, 
                intTermId: null
            },
            method: 'post'
        })
        .subscribe(
            function(response){
                successFn(response);                
            },
            function(response) {
                failureFn(response);
            }
        );
    },

    onItemNoSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var me = this;
        var win = combo.up('window');
        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepItem');
        var current = plugin.getActiveRecord();
        var pnlLotTracking = win.down('#pnlLotTracking');
        
        if (combo.itemId === 'cboItemNo') {

            // Get the default Forex Rate Type from the Company Preference. 
            var intRateType = i21.ModuleMgr.SystemManager.getCompanyPreference('intInventoryRateTypeId');

            // Get the functional currency:
            var functionalCurrencyId = i21.ModuleMgr.SystemManager.getCompanyPreference('intDefaultCurrencyId');           

            // Get the important header data: 
            var currentHeader = win.viewModel.data.current;
            var transactionCurrencyId = currentHeader.get('intCurrencyId');
            var customerId = currentHeader.get('intEntityCustomerId');            
            var shipFromLocationId = currentHeader.get('intShipFromLocationId');
            var shipToLocationId = currentHeader.get('intShipToLocationId');            
            var dtmShipDate = currentHeader.get('dtmShipDate');

            // Get the sales price
            var dblUnitPrice = records[0].get('dblIssueSalePrice');
            dblUnitPrice = Ext.isNumeric(dblUnitPrice) ? dblUnitPrice : 0;            

            // function variable to process the default forex rate. 
            var processForexRateOnSuccess = function(successResponse, isItemRetailPrice){
                if (successResponse && successResponse.length > 0 ){
                    var dblForexRate = successResponse[0].dblRate;
                    var strRateType = successResponse[0].strRateType;             

                    dblForexRate = Ext.isNumeric(dblForexRate) ? dblForexRate : 0;                       

                    // Convert the sales price to the transaction currency.
                    // and round it to six decimal places.  
                    if (transactionCurrencyId != functionalCurrencyId && isItemRetailPrice){
                        dblUnitPrice = dblForexRate != 0 ?  dblUnitPrice / dblForexRate : 0;
                        dblUnitPrice = i21.ModuleMgr.Inventory.roundDecimalFormat(dblUnitPrice, 6);
                    }
                    
                    current.set('intForexRateTypeId', intRateType);
                    current.set('strForexRateType', strRateType);
                    current.set('dblForexRate', dblForexRate);
                    current.set('dblUnitPrice', dblUnitPrice);                                 
                }
            }            

            var processCustomerPriceOnSuccess = function(successResponse){
                var jsonData = Ext.decode(successResponse.responseText);
                var isItemRetailPrice = true;                

                // If there is a customer cost, replace dblUnitPrice with the customer sales price. 
                var itemPricing = jsonData ? jsonData.itemPricing : null;
                if (itemPricing) {
                    dblUnitPrice = itemPricing.dblPrice; 
                    current.set('dblUnitPrice', dblUnitPrice);

                    if (itemPricing.strPricing !== 'Inventory - Standard Pricing'){
                        isItemRetailPrice = false;
                    }                    
                }

                // If transaction currency is a foreign currency, get the default forex rate type, forex rate, and convert the last cost to the transaction currency. 
                if (transactionCurrencyId != functionalCurrencyId && intRateType){
                    // Do ajax call to retrieve the forex rate. 
                    iRely.Functions.getForexRate(
                        transactionCurrencyId,
                        intRateType,
                        dtmShipDate,
                        function(successResponse){
                            processForexRateOnSuccess(successResponse, isItemRetailPrice);
                        },
                        function(failureResponse){
                            var jsonData = Ext.decode(failureResponse.responseText);
                            //iRely.Functions.showErrorDialog(jsonData.message.statusText);                    
                            iRely.Functions.showErrorDialog('Something went wrong while getting the forex data.');
                        }
                    );                      
                }

            };

            var processCustomerPriceOnFailure = function(failureResponse){
                var jsonData = Ext.decode(failureResponse.responseText);
                iRely.Functions.showErrorDialog('Something went wrong while getting the item price from the customer pricing hierarchy.');
            };            

            // Get the customer cost from the hierarchy.  
            var customerPriceCfg = {
                ItemId: records[0].get('intItemId'),
                CustomerId: customerId,
                CurrencyId: transactionCurrencyId,
                LocationId: shipFromLocationId,
                TransactionDate: dtmShipDate,
                Quantity: 0, // Default ship qty. 
                ShipToLocationId: shipToLocationId,
                ItemUOMId: records[0].get('intIssueUOMId')
            }

            me.getItemSalesPrice(customerPriceCfg, processCustomerPriceOnSuccess, processCustomerPriceOnFailure);

            current.set('intItemId', records[0].get('intItemId'));
            current.set('strItemDescription', records[0].get('strDescription'));
            current.set('strLotTracking', records[0].get('strLotTracking'));
            current.set('intCommodityId', records[0].get('intCommodityId'));
            current.set('intItemUOMId', records[0].get('intIssueUOMId'));
            current.set('strUnitMeasure', records[0].get('strIssueUOM'));
            current.set('dblUnitPrice', dblUnitPrice);            
            current.set('dblItemUOMConvFactor', records[0].get('dblIssueUOMConvFactor'));
            current.set('strUnitType', records[0].get('strIssueUOMType'));
            current.set('intOwnershipType', 1);
            current.set('strOwnershipType', 'Own');

            current.set('intSubLocationId', records[0].get('intSubLocationId'));
            current.set('strSubLocationName', records[0].get('strSubLocationName'));
            current.set('intStorageLocationId', records[0].get('intStorageLocationId'));
            current.set('strStorageLocationName', records[0].get('strStorageLocationName'));
            
            if (!!records[0].get('strLotTracking') && records[0].get('strLotTracking') === 'No'){
                pnlLotTracking.setHidden(true);
            }
            else {
                pnlLotTracking.setHidden(false);
            }                    
                    
        }
        else if (combo.itemId === 'cboUOM') {
            var dblUnitQty = records[0].get('dblUnitQty');
            var dblLastCost = records[0].get('dblLastCost');
            var dblSalesPrice = records[0].get('dblSalePrice');
            var dblSalesPriceForeign = records[0].get('dblSalePrice');
            var intItemUOMId = records[0].get('intItemUnitMeasureId');
            var dblForexRate = current.get('dblForexRate');

            // Convert the sales price from functional currency to the transaction currency. 
            dblSalesPriceForeign = dblForexRate != 0 ? dblSalesPrice / dblForexRate : dblLastCost;
            dblSalesPriceForeign = i21.ModuleMgr.Inventory.roundDecimalFormat(dblSalesPriceForeign, 6);            

            current.set('dblItemUOMConv', dblUnitQty);
            current.set('dblUnitCost', dblLastCost);
            current.set('dblUnitPrice', dblSalesPrice);
            current.set('intItemUOMId', intItemUOMId);
        }
        else if (combo.itemId === 'cboSubLocation') {
            if (current.get('intSubLocationId') !== records[0].get('intSubLocationId')) {
                current.set('intSubLocationId', records[0].get('intCompanyLocationSubLocationId'));
                current.set('intStorageLocationId', null);
                current.set('strStorageLocationName', null);
                
                 //Remove all lots in Lot Grid                   
                 var shipmentLotItems = current['tblICInventoryShipmentItemLots'](),
                     shipmentLotRecords = shipmentLotItems ? shipmentLotItems.getRange() : [];

                      var i = shipmentLotRecords.length - 1;

                      for (; i >= 0; i--) {
                        if (!shipmentLotRecords[i].dummy)
                            shipmentLotItems.removeAt(i);
                      }
            }
        }

        else if (combo.itemId === 'cboStorageLocation') {
            if (current.get('intSubLocationId') !== records[0].get('intSubLocationId')) {
                current.set('intSubLocationId', records[0].get('intSubLocationId'));
                current.set('intStorageLocationId', records[0].get('intStorageLocationId'));
                current.set('strSubLocationName', records[0].get('strSubLocationName'));
                
                 //Remove all lots in Lot Grid                   
                 var shipmentLotItems = current['tblICInventoryShipmentItemLots'](),
                     shipmentLotRecords = shipmentLotItems ? shipmentLotItems.getRange() : [];

                      var i = shipmentLotRecords.length - 1;

                      for (; i >= 0; i--) {
                        if (!shipmentLotRecords[i].dummy)
                            shipmentLotItems.removeAt(i);
                      }
            }
        }

        else if (combo.itemId === 'cboCustomerStorage') {
            current.set('intStorageScheduleTypeId', records[0].get('intStorageTypeId'));
        }

        else if (combo.itemId === 'cboForexRateType') {
            var oldForexRate = current.get('dblForexRate');

            current.set('intForexRateTypeId', records[0].get('intCurrencyExchangeRateTypeId'));
            current.set('strForexRateType', records[0].get('strCurrencyExchangeRateType'));
            current.set('dblForexRate', null);

            iRely.Functions.getForexRate(
                win.viewModel.data.current.get('intCurrencyId'),
                current.get('intForexRateTypeId'),
                win.viewModel.data.current.get('dtmShipDate'),
                function(successResponse){
                    if (successResponse && successResponse.length > 0){
                        var dblRate = successResponse[0].dblRate;

                        // Convert the unit price to the functional currency. 
                        var dblUnitPrice = current.get('dblUnitPrice');
                        dblUnitPrice = Ext.isNumeric(dblUnitPrice) ? dblUnitPrice : 0;
                        dblUnitPrice = Ext.isNumeric(oldForexRate) && oldForexRate != 0 ? dblUnitPrice * oldForexRate : dblUnitPrice;

                        // And then convert it to the newly selected currency. 
                        dblRate = Ext.isNumeric(dblRate) ? dblRate : 0;
                        dblUnitPrice = Ext.isNumeric(dblUnitPrice) ? dblUnitPrice : 0;

                        current.set('dblForexRate', dblRate);                        
                        current.set('dblUnitPrice', dblRate != 0 ? dblUnitPrice / dblRate : dblUnitPrice);
                    }
                },
                function(failureResponse){
                    var jsonData = Ext.decode(failureResponse.responseText);
                    iRely.Functions.showErrorDialog(jsonData.message.statusText);                    
                }
            );                       
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
            current.set('intWeightUOMId', records[0].get('intWeightUOMId'));
            current.set('strWeightUOM', records[0].get('strWeightUOM'));
            current.set('dblWeightPerQty', records[0].get('dblWeightPerQty'));

            var shipmentItem = win.viewModel.data.currentShipmentItem;
            if (shipmentItem) {
                // Assign a default ship qty for the lot.
                var shipQty = shipmentItem.get('dblQuantity');
                var availQty = current.get('dblAvailableQty');
                var lotDefaultQty = shipQty > availQty ? availQty : shipQty;

                current.set('dblQuantityShipped', lotDefaultQty);
                
                // Calculate the Gross Wgt based on the default lot qty.
                var wgtPerQty = records[0].get('dblWeightPerQty');
                var grossWgt;
                //
                grossWgt = Ext.isNumeric(wgtPerQty) && Ext.isNumeric(lotDefaultQty) ? wgtPerQty * lotDefaultQty : 0;
                current.set('dblGrossWeight', grossWgt);
            }
            
                var grdInventoryShipment = win.down('#grdInventoryShipment');

                var selected = grdInventoryShipment.getSelectionModel().getSelection();

                if (selected) {
                    if (selected.length > 0){
                        var currentShipment = selected[0];
                        if (!currentShipment.dummy)
                            currentShipment.set('strSubLocationName', records[0].get('strSubLocationName'));
                            currentShipment.set('strStorageLocationName', current.get('strStorageLocation'));
                    }
                }

        }
    },

    onItemSelectionChange: function(selModel, selected, eOpts) {
        if (selModel) {
            if (!selModel.view)
                return;
            var win = selModel.view.grid.up('window');
            var vm = win.viewModel;
            var pnlLotTracking = win.down('#pnlLotTracking');

            if (selected.length > 0) {
                var current = selected[0];
                if (current.dummy) {
                    vm.data.currentShipmentItem = null;
                }
                else if (!!current.get('strLotTracking') && current.get('strLotTracking') === 'No'){                    
                    vm.data.currentShipmentItem = null;
                }
                else {
                    vm.data.currentShipmentItem = current;
                }
            }
            else {
                vm.data.currentShipmentItem = null;
            }
            if (vm.data.currentShipmentItem !== null){
                pnlLotTracking.setHidden(false);
            }
            else {
                pnlLotTracking.setHidden(true);
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

                    // Hide the post/unpost button if: 
                    var showButton;
                    switch (currentRecord.get('intSourceType')) {
                        case 1: // Scale  
                            showButton = false; 
                            break; 
                        default:  
                            showButton = true;
                            break;   
                    }                    

                    // If data is generated, show the recap screen.
                    CashManagement.common.BusinessRules.showRecap({
                        strTransactionId: currentRecord.get('strShipmentNumber'),
                        ysnPosted: currentRecord.get('ysnPosted'),
                        dtmDate: currentRecord.get('dtmShipDate'),
                        strCurrencyId: null,
                        dblExchangeRate: 1,
                        scope: me,
                        showPostButton: showButton,
                        showUnpostButton: showButton,
                        postCallback: function(){
                            me.onPostClick(recapButton);
                        },
                        unpostCallback: function(){
                            me.onPostClick(recapButton);
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
            if(current.get('intOrderType') === 3) { //'Transfer Order'
                iRely.Functions.showErrorDialog('Invalid order type. An invoice is not applicable on transfer orders.');
                return;
            }

            ic.utils.ajax({
                timeout: 120000,
                url: '../Inventory/api/InventoryShipment/ProcessInvoice',
                params: {
                    id: current.get('intInventoryShipmentId')
                },
                method: 'post'
            })
            .subscribe(
                function(successResponse){
                    var jsonData = Ext.decode(successResponse.responseText);
                    var message = jsonData.message; 
                    if (message && message.InvoiceId){
                        var buttonAction = function(button) {
                            if (button === 'yes') {
                                iRely.Functions.openScreen('AccountsReceivable.view.Invoice', {
                                    filters: [
                                        {
                                            column: 'intInvoiceId',
                                            value: message.InvoiceId
                                        }
                                    ],
                                    action: 'view'
                                });
                                win.close();
                            }
                        };
                        iRely.Functions.showCustomDialog('question', 'yesno', 'Invoice successfully processed. Do you want to view this Invoice?', buttonAction);
                    }
                },
                function(failureResponse) {
                    var jsonData = Ext.decode(failureResponse.responseText);
                    var message = jsonData.message; 
                    iRely.Functions.showErrorDialog(message.statusText);
                }
            );
        }
    },

    processShipmentToInvoice: function (shipmentId, callback) {
        ic.utils.ajax({
            url: '../Inventory/api/InventoryShipment/ProcessInvoice',
            params:{
                id: shipmentId
            },
            method: 'post'  
        })
        .subscribe(
            function(successResponse) {
                var jsonData = Ext.decode(successResponse.responseText);
                callback(jsonData);
            }
            ,function(failureResponse) {
                var jsonData = Ext.decode(failureResponse.responseText);
                var message = jsonData.message; 
                iRely.Functions.showErrorDialog(message.statusText);
            }
        );          
    },

    onViewShipmentNo: function (value, record) {
        i21.ModuleMgr.Inventory.showScreen(value, 'ShipmentNo');
    },
    
    // onViewInvoice: function (value, record) {
    //     var strName = record.get('strInvoiceNumber');
    //     i21.ModuleMgr.Inventory.showScreen(strName, 'Invoice');
    // },

    onViewInvoice: function (value, record) {
        var me = this;

        if (value === 'New Invoice') {
            if(record.get('strOrderType') === 'Transfer Order') {
                iRely.Functions.showErrorDialog('Invalid order type. An invoice is not applicable on transfer orders.');
                return;
            }

            me.processShipmentToInvoice(record.get('intInventoryShipmentId'), function(data) {
                iRely.Functions.openScreen('AccountsReceivable.view.Invoice', {
                    filters: [
                        {
                            column: 'intInvoiceId',
                            value: data.message.InvoiceId
                        }
                    ],
                    action: 'view',
                    listeners: {
                        close: function(e) {
                            dashboard.$initParent.grid.controller.reload();  
                        }
                    }
                });        
            });            
            
        }
        else {
            var invoices = record.get('strFilterString');
            iRely.Functions.openScreen('AccountsReceivable.view.Invoice', {
                filters: [
                    {
                        column: 'intInvoiceId',
                        value: invoices
                    }
                ],
                action: 'view'
            });        
        }
    },

    onViewCustomerNo: function (value, record) {
        var strName = record.get('strCustomerName');
        i21.ModuleMgr.Inventory.showScreen(strName, 'CustomerName');
    },

    onViewCustomerName: function (value, record) {
        i21.ModuleMgr.Inventory.showScreen(value, 'CustomerName');
    },

    onViewItemNo: function(value, record) {
        var itemNo = record.get('strItemNo');
        i21.ModuleMgr.Inventory.showScreen(itemNo, 'ItemNo');
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
                        dataIndex: 'strLocationName',
                        dataType: 'string',
                        text: 'Location Name',
                        width: 150
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
                        dataIndex: 'strLocationName',
                        dataType: 'string',
                        text: 'Location Name',
                        width: 150
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
                                //return controller.salesOrderDropdown(win);
                                return false;
                            case 'colSourceNumber' :
                                return false;
                        }
                    }
                    else {
                        switch (columnId) {
                            case 'colOrderNumber' :
                                return false;
                            case 'colSourceNumber' :
                                return false;
                        };
                    }
                    break;
                case 1:
                    if (iRely.Functions.isEmpty(record.get('strOrderNumber')))
                    {
                        switch (columnId) {
                            case 'colOrderNumber' :
                                //return controller.salesContractDropdown(win);
                                return false;
                            case 'colSourceNumber' :
                                switch (current.get('intSourceType')) {
                                    case 2:
                                        return false;
                                    default:
                                        return false;
                                }
                        }
                    }
                    else {
                        switch (columnId) {
                            case 'colOrderNumber' :
                                return false;
                            case 'colSourceNumber' :
                                switch (current.get('intSourceType')) {
                                    case 2:
                                        return false;
                                    default:
                                        return false;
                                }
                        };
                    }
                    break;
                case 3:
                    if (iRely.Functions.isEmpty(record.get('strOrderNumber')))
                    {
                        switch (columnId) {
                            case 'colOrderNumber' :
                                //return controller.transferOrderDropdown(win);
                                return false;
                            case 'colSourceNumber' :
                                return false;
                        }
                    }
                    else {
                        switch (columnId) {
                            case 'colOrderNumber' :
                                return false;
                            case 'colSourceNumber' :
                                return false;
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
        var cboCurrency = win.down('#cboCurrency');
        
        if (combo.itemId === 'cboOtherCharge') {
            // Get the default Forex Rate Type from the Company Preference. 
            var intRateType = i21.ModuleMgr.SystemManager.getCompanyPreference('intInventoryRateTypeId');

            // Get the functional currency:
            var functionalCurrencyId = i21.ModuleMgr.SystemManager.getCompanyPreference('intDefaultCurrencyId');
            var strFunctionalCurrency = i21.ModuleMgr.SystemManager.getCompanyPreference('strDefaultCurrency');

            // Get the transaction currency
            var chargeCurrencyId = cboCurrency.getValue();

            current.set('intChargeId', record.get('intItemId'));
            current.set('intCostUOMId', record.get('intCostUOMId'));
            current.set('strCostMethod', record.get('strCostMethod'));
            current.set('strCostUOM', record.get('strCostUOM'));
            current.set('strOnCostType', record.get('strOnCostType'));
            current.set('ysnPrice', record.get('ysnPrice'));
            current.set('ysnAccrue', record.get('ysnAccrue'));
            current.set('intCurrencyId', chargeCurrencyId);
            current.set('strCurrency', cboCurrency.getRawValue());

            if (!iRely.Functions.isEmpty(record.get('strOnCostType'))) {
                current.set('strCostMethod', 'Percentage');
            }

            var dblAmount = record.get('dblAmount');
            dblAmount = Ext.isNumeric(dblAmount) ? dblAmount : 0;

            if(record.get('strCostMethod') === 'Amount') {
                current.set('dblAmount', dblAmount);
            }
            else {
                current.set('dblRate', dblAmount);
            }

            // function variable to process the default forex rate. 
            var processForexRateOnSuccess = function(successResponse){
                if (successResponse && successResponse.length > 0 ){
                    var dblForexRate = successResponse[0].dblRate;
                    var strRateType = successResponse[0].strRateType;             

                    dblForexRate = Ext.isNumeric(dblForexRate) ? dblForexRate : 0;                       

                    // Convert the last cost to the transaction currency.
                    // and round it to six decimal places.  
                    if (chargeCurrencyId != functionalCurrencyId){
                        dblAmount = dblForexRate != 0 ?  dblAmount / dblForexRate : 0;
                        dblAmount = i21.ModuleMgr.Inventory.roundDecimalFormat(dblAmount, 6);

                        if(record.get('strCostMethod') === 'Amount') {                           
                            current.set('dblAmount', dblAmount);
                        }
                        else {
                            current.set('dblRate', dblAmount);
                        }                           
                    }                 
                    
                    current.set('intForexRateTypeId', intRateType);
                    current.set('strForexRateType', strRateType);
                    current.set('dblForexRate', dblForexRate);
                }
            }

            // If transaction currency is a foreign currency, get the default forex rate type, forex rate, and convert the last cost to the transaction currency. 
            if (chargeCurrencyId != functionalCurrencyId && intRateType){
                iRely.Functions.getForexRate(
                    chargeCurrencyId,
                    intRateType,
                    masterRecord.get('dtmShipDate'),
                    function(successResponse){
                        processForexRateOnSuccess(successResponse);
                    },
                    function(failureResponse){
                        var jsonData = Ext.decode(failureResponse.responseText);
                        //iRely.Functions.showErrorDialog(jsonData.message.statusText);                    
                        iRely.Functions.showErrorDialog('Something went wrong while getting the forex data.');
                    }
                );                      
            }
        }

        if (combo.itemId === 'cboChargeCurrency') { 
            current.set('intCurrencyId', record.get('intCurrencyID'));
            current.set('strCurrency', record.get('strCurrency'));
        }

        if (combo.itemId === 'cboChargeForexRateType') {
            current.set('intForexRateTypeId', records[0].get('intCurrencyExchangeRateTypeId'));
            current.set('strForexRateType', records[0].get('strCurrencyExchangeRateType'));
            current.set('dblForexRate', null);

            iRely.Functions.getForexRate(
                win.viewModel.data.current.get('intCurrencyId'),
                current.get('intForexRateTypeId'),
                win.viewModel.data.current.get('dtmShipDate'),
                function(successResponse){
                    if (successResponse && successResponse.length > 0){
                        current.set('dblForexRate', successResponse[0].dblRate);
                    }
                },
                function(failureResponse){
                    var jsonData = Ext.decode(failureResponse.responseText);
                    //iRely.Functions.showErrorDialog(jsonData.message.statusText);      
                    iRely.Functions.showErrorDialog('Something went wrong while getting the forex data.');                                  
                }
            );                
        }           
    },

    onQualityClick: function(button, e, eOpts) {
        var grid = button.up('grid');
        var selected = grid.getSelectionModel().getSelection();
        
        var win = button.up('window');
        var vm = win.viewModel;
        var currentShipmentItem = vm.data.current;

        if (selected) {
            if (selected.length > 0){
                var current = selected[0];
                if (!current.dummy)
                    if(currentShipmentItem.get('ysnPosted') === true)
                        {
                            iRely.Functions.openScreen('Grain.view.QualityTicketDiscount', 
                                { 
                                    strSourceType: 'Inventory Shipment', 
                                    intTicketFileId: current.get('intInventoryShipmentItemId'),
                                    viewConfig:{
                                        modal: true, 
                                        listeners:
                                        {
                                            show: function(win) {
                                                Ext.defer(function(){
                                                    win.context.screenMgr.securityMgr.screen.setViewOnlyAccess();
                                                }, 100);
                                            }
                                        }
                                    }
                                }
                            );
                            
                        }
                    else
                        {
                            iRely.Functions.openScreen('Grain.view.QualityTicketDiscount', { strSourceType: 'Inventory Shipment', intTicketFileId: current.get('intInventoryShipmentItemId') });
                        }
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
                },
                    {
                        Name: 'strOrderType',
                        Type: 'string',
                        Condition: 'EQUAL TO',
                        From: current.get('strOrderType'),
                        Operator: 'AND'
                    }];

                iRely.Functions.openScreen('Reporting.view.ReportViewer', {
                    selectedReport: 'BillOfLadingReport',
                    selectedGroup: 'Inventory',
                    selectedParameters: filters,
                    viewConfig: { maximized: true }
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

    onItemClick: function () {
        iRely.Functions.openScreen('Inventory.view.Item', { action: 'new', viewConfig: { modal: true }});
    },

    onCategoryClick: function () {
        iRely.Functions.openScreen('Inventory.view.Category', { action: 'new', viewConfig: { modal: true }});
    },

    onCommodityClick: function () {
        iRely.Functions.openScreen('Inventory.view.Commodity', { action: 'new', viewConfig: { modal: true }});
    },

    onLocationClick: function () {
        iRely.Functions.openScreen('i21.view.CompanyLocation', { action: 'new', viewConfig: { modal: true }});
    },

    onStorageLocationClick: function () {
        iRely.Functions.openScreen('Inventory.view.StorageUnit', { action: 'new', viewConfig: { modal: true }});
    },

    onViewCustomerClick: function () {
        iRely.Functions.openScreen('EntityManagement.view.Entity:searchEntityCustomer',{ action: 'view' });
    },

    onAddOrderClick: function(button) {
        var win = button.up('window');
        if (button.text === 'Add Orders') {
            this.showAddOrders(win);
        }
        else {
            this.onPickLotsClick(button);
        }
    },

    showAddOrders: function(win) {
        var currentRecord = win.viewModel.data.current;
        var cboOrderType = win.down('#cboOrderType');
        var cboSourceType = win.down('#cboSourceType');

        var CustomerId = currentRecord.get('intEntityCustomerId').toString();
        var OrderType = cboOrderType.getRawValue().toString();
        var SourceType = cboSourceType.getRawValue().toString();
        var ContractStore = win.viewModel.storeInfo.salesContractList;
        var me = this;
        var showAddScreen = function () {
            var search = i21.ModuleMgr.Search;
            search.scope = me;
            search.url = '../Inventory/api/InventoryShipment/GetAddOrders?CustomerId=' + CustomerId + '&OrderType=' + OrderType + '&SourceType=' + SourceType;
            search.columns = [
                { dataIndex: 'intKey', text: 'Key', flex: 1, dataType: 'numeric', defaultSort: true, sortOrder: 'DESC', key: true, hidden: true },
                { dataIndex: 'strOrderNumber', text: 'Order Number', width: 100, dataType: 'string' },
                { dataIndex: 'strSourceNumber', text: 'Source Number', width: 100, dataType: 'string' },
                { dataIndex: 'strShipFromLocation', text: 'Ship From Location', width: 100, dataType: 'string' },
                { dataIndex: 'strCustomerNumber', text: 'Customer Number', width: 100, dataType: 'string' },
                { dataIndex: 'strCustomerName', text: 'Customer Name', width: 100, dataType: 'string' },

                { dataIndex: 'intLocationId', text: 'Location Id', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'intItemId', text: 'Item Id', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strItemNo', text: 'Item No', width: 100, dataType: 'string' },
                { dataIndex: 'strItemDescription', text: 'Item Description', width: 100, dataType: 'string' },
                { dataIndex: 'strLotTracking', text: 'Lot Tracking', width: 100, dataType: 'string' },
                { dataIndex: 'intCommodityId', text: 'Commodity Id', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'intSubLocationId', text: 'SubLocation Id', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strSubLocationName', text: 'SubLocation Name', width: 100, dataType: 'string' },
                { dataIndex: 'intStorageLocationId', text: 'Storage Location Id', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strStorageLocationName', text: 'Storage Location Name', width: 100, dataType: 'string' },
                { dataIndex: 'intOrderUOMId', text: 'Order UOM Id', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strOrderUOM', text: 'Order UOM', width: 100, dataType: 'string' },
                { xtype: 'numbercolumn', dataIndex: 'dblOrderUOMConvFactor', text: 'Order UOM Conversion Factor', width: 100, dataType: 'float', hidden: true },
                { dataIndex: 'intItemUOMId', text: 'Item UOM Id', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strItemUOM', text: 'Item UOM', width: 100, dataType: 'string' },
                { xtype: 'numbercolumn', dataIndex: 'dblItemUOMConv', text: 'Item UOM Conversion Factor', width: 100, dataType: 'float', hidden: true },
                { dataIndex: 'intWeightUOMId', text: 'Weight UOM Id', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strWeightUOM', text: 'Weight UOM', width: 100, dataType: 'string' },
                { xtype: 'numbercolumn', dataIndex: 'dblWeightItemUOMConv', text: 'Weight Item UOM Conversion Factor', width: 100, dataType: 'float', hidden: true },
                { xtype: 'numbercolumn', dataIndex: 'dblQtyOrdered', text: 'Qty Ordered', width: 100, dataType: 'float' },
                { xtype: 'numbercolumn', dataIndex: 'dblQtyAllocated', text: 'Qty Allocated', width: 100, dataType: 'float' },
                { xtype: 'numbercolumn', dataIndex: 'dblQtyShipped', text: 'Qty Shipped', width: 100, dataType: 'float' },
                { xtype: 'numbercolumn', dataIndex: 'dblUnitPrice', text: 'Unit Price', width: 100, dataType: 'float' },
                { xtype: 'numbercolumn', dataIndex: 'dblDiscount', text: 'Discount', width: 100, dataType: 'float' },
                { xtype: 'numbercolumn', dataIndex: 'dblTotal', text: 'Total', width: 100, dataType: 'float' },
                { xtype: 'numbercolumn', dataIndex: 'dblQtyToShip', text: 'Qty To Ship', width: 100, dataType: 'float' },
                { xtype: 'numbercolumn', dataIndex: 'dblPrice', text: 'Price', width: 100, dataType: 'float' },
                { xtype: 'numbercolumn', dataIndex: 'dblLineTotal', text: 'Line Total', width: 100, dataType: 'float' },
                { dataIndex: 'intGradeId', text: 'Grade Id', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strGrade', text: 'Grade', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'intDestinationGradeId', text: 'Destination Grade Id', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strDestinationGrades', text: 'Destination Grades', width: 100, dataType: 'string' },
                { dataIndex: 'intDestinationWeightId', text: 'Destination Weight Id', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strDestinationWeights', text: 'Destination Weights', width: 100, dataType: 'string' },

                { dataIndex: 'intForexRateTypeId', text: 'Forex Rate Type Id', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strForexRateType', text: 'Forex Rate Type', width: 100, dataType: 'string', hidden: true },
                { xtype: 'numbercolumn', dataIndex: 'dblForexRate', text: 'Forex Rate', width: 100, dataType: 'float', hidden: true },               

                {dataIndex: 'intLineNo', text: 'intLineNo', width: 100, dataType: 'numeric', hidden: true },
                {dataIndex: 'intOrderId', text: 'intOrderId', width: 100, dataType: 'numeric', hidden: true },
                {dataIndex: 'intSourceId', text: 'intSourceId', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'intCurrencyId', text: 'Currency Id', hidden: true, dataType: 'numeric' },
                { dataIndex: 'intFreightTermId', text: 'Freight Term Id', hidden: true, dataType: 'numeric' },
                { dataIndex: 'intShipToLocationId', text: 'Ship To Location Id', hidden: true, dataType: 'numeric' }
            ];
            search.title = "Add Orders";
            search.showNew = false;
            search.on({
                scope: me,
                openselectedclick: function (button, e, result) {
                    var win = this.getView();
                    var currentVM = this.getViewModel().data.current;
                    var pickLotList = win.viewModel.storeInfo.pickedLotList;

                    Ext.each(result, function (order) {
                        if (SourceType === 'Pick Lot') {
                            pickLotList.load({
                                filters: [
                                    {
                                        column: 'intPickLotHeaderId',
                                        value: order.get('intSourceId'),
                                        conjunction: 'and'
                                    },
                                    {
                                        column: 'intSContractHeaderId',
                                        value: order.get('intOrderId'),
                                        conjunction: 'and'
                                    }
                                ],
                                callback: function (result) {
                                    Ext.each(result, function (pickLot) {
                                        if (pickLot.vyuLGDeliveryOpenPickLotDetails) {
                                            Ext.Array.each(pickLot.vyuLGDeliveryOpenPickLotDetails().data.items, function (lot) {
                                                var exists = Ext.Array.findBy(currentVM.tblICInventoryShipmentItems().data.items, function (row) {
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
                                                       // intLineNo: lot.get('intSContractDetailId'),
                                                        intLineNo: order.get('intLineNo'),
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
                                                        //dblQtyOrdered: lot.get('dblSalesOrderedQty'),
                                                        dblQtyOrdered: lot.get('dblDetailQuantity'),
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

                                                            if (currentVM.get('intShipFromLocationId') != lot.get('intLocationId') ){
                                                                newItemLot.set('strStorageLocation', null);
                                                            }

                                                            newItem.tblICInventoryShipmentItemLots().add(newItemLot);
                                                        }
                                                    });
                                                    newItem.set('dblQuantity', totalQty);

                                                    // Check if the shipment location matches the location of the order.
                                                    // If not, clear the sub and storage location.
                                                    if (currentVM.get('intShipFromLocationId') != lot.get('intLocationId') ){
                                                        newItem.set('intSubLocationId', null);
                                                        newItem.set('intStorageLocationId', null);
                                                        newItem.set('strSubLocationName', null);
                                                        newItem.set('strStorageLocationName', null);
                                                    }

                                                    currentVM.tblICInventoryShipmentItems().add(newItem);
                                                }
                                            });
                                        }
                                    });
                                }
                            });
                        }
                        else {
                            if(!iRely.Functions.isEmpty(order.get('intCurrencyId'))) 
                                currentVM.set('intCurrencyId', order.get('intCurrencyId'));
                            if(!iRely.Functions.isEmpty(order.get('intFreightTermId'))) 
                                currentVM.set('intFreightTermId', order.get('intFreightTermId'));
                            if(!iRely.Functions.isEmpty(order.get('intShipToLocationId'))) 
                                currentVM.set('intShipToLocationId', order.get('intShipToLocationId'));

                            var newRecord = {
                                intInventoryShipmentId: currentVM.get('intInventoryShipmentId'),
                                intOrderId: order.get('intOrderId'),
                                intSourceId: order.get('intSourceId'),
                                intLineNo: order.get('intLineNo'),
                                intItemId: order.get('intItemId'),
                                intSubLocationId: order.get('intSubLocationId'),
                                intStorageLocationId: order.get('intStorageLocationId'),
                                dblQuantity: order.get('dblQtyToShip'),
                                intItemUOMId: order.get('intItemUOMId'),
                                intWeightUOMId: order.get('intWeightUOMId'),
                                dblUnitPrice: order.get('dblUnitPrice'),
                                strItemNo: order.get('strItemNo'),
                                strUnitMeasure: order.get('strItemUOM'),
                                strWeightUOM: order.get('strWeightUOM'),
                                strSubLocationName: order.get('strSubLocationName'),
                                strStorageLocationName: order.get('strStorageLocationName'),
                                strOrderNumber: order.get('strOrderNumber'),
                                strSourceNumber: order.get('strSourceNumber'),
                                strItemDescription: order.get('strItemDescription'),
                                strGrade: order.get('strGrade'),
                                dblQtyOrdered: order.get('dblQtyOrdered'),
                                strOrderUOM: order.get('strOrderUOM'),
                                dblLineTotal: order.get('dblLineTotal'),
                                dblQtyAllocated: order.get('dblQtyAllocated'),
                                dblOrderUnitPrice: order.get('dblPrice'),
                                dblOrderDiscount: order.get('dblDiscount'),
                                dblOrderTotal: order.get('dblTotal'),
                                strLotTracking: order.get('strLotTracking'),
                                dblItemUOMConv: order.get('dblItemUOMConv'),
                                dblWeightItemUOMConv: order.get('dblWeightItemUOMConv'),
                                intDestinationGradeId: order.get('intDestinationGradeId'),
                                strDestinationGrades: order.get('strDestinationGrades'),
                                intDestinationWeightId: order.get('intDestinationWeightId'),
                                strDestinationWeights: order.get('strDestinationWeights'),
                                strOwnershipType: 'Own',
                                intOwnershipType: 1,
                                intCommodityId: order.get('intCommodityId'),
                                intForexRateTypeId: order.get('intForexRateTypeId'),
                                strForexRateType: order.get('strForexRateType'),
                                dblForexRate: order.get('dblForexRate')                                
                            };

                            // Check if the shipment location matches the location of the order.
                            // If not, clear the sub and storage location.
                            if (currentVM.get('intShipFromLocationId') != order.get('intLocationId') ){
                                newRecord.intSubLocationId = null;
                                newRecord.intStorageLocationId = null;
                                newRecord.strSubLocationName = null;
                                newRecord.strStorageLocationName = null;
                            }
                            currentVM.tblICInventoryShipmentItems().add(newRecord);
                        }

                        if (OrderType === 'Sales Contract') {
                            ContractStore.load({
                                filters: [
                                    {
                                        column: 'intContractDetailId',
                                        value: order.get('intLineNo'),
                                        conjunction: 'and'
                                    },
                                    {
                                        column: 'intContractHeaderId',
                                        value: order.get('intOrderId'),
                                        conjunction: 'and'
                                    }
                                ],
                                callback: function (result) {
                                    if (result) {
                                        Ext.each(result, function (contract) {
                                            var contractCosts = contract.get('tblCTContractCosts');
                                            if (contractCosts) {
                                                Ext.each(contractCosts, function (otherCharge) {
                                                    var shipmentCharges = currentVM.tblICInventoryShipmentCharges().data.items;
                                                    var exists = Ext.Array.findBy(shipmentCharges, function (row) {
                                                        if ((row.get('intContractId') === order.get('intOrderId')
                                                            && row.get('intChargeId') === otherCharge.intItemId)) {
                                                            return true;
                                                        }
                                                    });

                                                    if (!exists) {
                                                        var newCost = Ext.create('Inventory.model.ShipmentCharge', {
                                                            intInventoryReceiptId: currentVM.get('intInventoryShipmentId'),
                                                            intContractId: order.get('intOrderId'),
                                                            intChargeId: otherCharge.intItemId,
                                                            ysnInventoryCost: false,
                                                            strCostMethod: otherCharge.strCostMethod,
                                                            dblRate: otherCharge.dblRate,
                                                            intCostUOMId: otherCharge.intItemUOMId,
                                                            intEntityVendorId: otherCharge.intVendorId,
                                                            dblAmount: 0,
                                                            strAllocatePriceBy: 'Unit',
                                                            ysnAccrue: otherCharge.ysnAccrue,
                                                            ysnPrice: otherCharge.ysnPrice,
                                                            strItemNo: otherCharge.strItemNo,
                                                            intCurrencyId: otherCharge.intCurrencyId,
                                                            strCurrency: otherCharge.strCurrency,
                                                            strCostUOM: otherCharge.strUOM,
                                                            strVendorId: otherCharge.strVendorName,
                                                            strContractNumber: order.get('strOrderNumber')
                                                        });
                                                        currentVM.tblICInventoryShipmentCharges().add(newCost);
                                                    }
                                                });
                                            }
                                        });
                                    }
                                }
                            });

                        }
                    });
                    search.close();
                    win.context.data.saveRecord();
                },
                openallclick: function () {
                    search.close();
                }
            });
            search.show();
        }
        
         var task = new Ext.util.DelayedTask(function () {
            showAddScreen();          
        });
        task.delay(10);
    },

    onOrderTypeSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var current = win.viewModel.data.current;

        if (current){
            current.set('intShipToCompanyLocationId', null);
            current.set('intShipToLocationId', null);
            current.set('strShipToAddress', null);

            //Change Source Type to "None" for "Direct" or "Sales Order" Order Type
            if(current.get('intOrderType') == 4 || current.get('intOrderType') == 2) {
                current.set('intSourceType', 0);
                current.set('strSourceType', 'None');
            }
        }
    },

    onPrintClick: function(button, e, eOpts) {
        var win = button.up('window');
        var vm = win.viewModel;
        var current = vm.data.current;

        var filters = [{
            Name: 'strShipmentNo',
            Type: 'string',
            Condition: 'EQUAL TO',
            From: current.get('strShipmentNumber'),
            Operator: 'AND'
        }];

        // Save has data changes first before doing the post.
        win.context.data.saveRecord({
            callbackFn: function() {
                iRely.Functions.openScreen('Reporting.view.ReportViewer', {
                    selectedReport: 'InventoryShipment',
                    selectedGroup: 'Inventory',
                    selectedParameters: filters,
                    viewConfig: { maximized: true }
                });
            }
        });
    },
    
    onShipFromAddressBeforeSelect: function(combo, record, index, eOpts) {
        var win = combo.up('window');
        var current = win.viewModel.data.current;
        
        Inventory.view.InventoryShipmentViewController.orgValueShipFrom = current.get('intShipFromLocationId');
    },
    
    onCalculateChargeClick: function (button, e, eOpts) {
        var win = button.up('window');
        var context = win.context;
        var current = win.viewModel.data.current;

        var doPost = function () {
            if (current) {
                ic.utils.ajax({
                    timeout: 120000,
                    url: '../Inventory/api/InventoryShipment/CalculateCharges',
                    params: {
                        id: current.get('intInventoryShipmentId')
                    },
                method: 'POST'})
                .subscribe(
                    function (response) {
                        var jsonData = Ext.decode(response.responseText);
                        if (!jsonData.success) {
                            iRely.Functions.showErrorDialog(jsonData.message.statusText);
                        }
                        else {
                            context.configuration.paging.store.load();
                        }
                    },
                    function (response) {
                        var jsonData = Ext.decode(response.responseText);
                        iRely.Functions.showErrorDialog(jsonData.ExceptionMessage);
                    }
                );
            }
        };

        // If there is no data change, do the post.
        if (!context.data.hasChanges()){
            doPost();
            return;
        }

        // Save has data changes first before doing the post.
        context.data.saveRecord({
            successFn: function () {
                doPost();
            }
        });
    },
    
    onAccrueCheckChange: function (obj, rowIndex, checked, eOpts) {
        if (obj.dataIndex === 'ysnAccrue') {
            var grid = obj.up('grid');
            var win = obj.up('window');
            var current = grid.view.getRecord(rowIndex);

            if (checked === false) {
                current.set('intEntityVendorId', null);
                current.set('strVendorName', null);
            }
        }
    },

    onItemBeforeQuery: function(obj) {
        if(obj.combo) {
            if(obj.combo.itemId === 'cboItemNo') {
                var win = obj.combo.up('window');
                obj.combo.defaultFilters = [
                    {
                        column: 'strType',
                        value: 'Inventory|^|Raw Material|^|Finished Good|^|Bundle|^|Kit',
                        conjunction: 'and',
                        condition: 'eq'
                    },
                    {
                        column: 'intLocationId',
                        value: win.viewModel.data.current.get('intShipFromLocationId'),
                        conjunction: 'and'
                    },
                    {
                        column: 'excludePhasedOutZeroStockItem',
                        value: true,
                        conjunction: 'and'
                    }
                ];
            }
        }
    },

    onItemHeaderClick: function (menu, column) {
        // var grid = column.initOwnerCt.grid; 
        var grid = column.$initParent.grid;

        if (grid.itemId === 'grdInventoryShipment') {
            i21.ModuleMgr.Inventory.showScreenFromHeaderDrilldown('Inventory.view.Item', grid, 'intItemId');
        }
        else {
            i21.ModuleMgr.Inventory.showScreenFromHeaderDrilldown('Inventory.view.Item', grid, 'intChargeId');
        }
    },    

    onVendorHeaderClick: function (menu, column) {
        // var grid = column.initOwnerCt.grid;
        var grid = column.$initParent.grid;

        if (grid.itemId === 'grdCharges') {
            var selectedObj = grid.getSelectionModel().getSelection();
            var vendorId = '';

            if (selectedObj.length == 0) {
                iRely.Functions.openScreen('EntityManagement.view.Entity:searchEntityVendor', { action: 'new', viewConfig: { modal: true } });
            }

            else {
                for (var x = 0; x < selectedObj.length; x++) {
                    vendorId += selectedObj[x].data.intEntityVendorId + '|^|';
                }

                iRely.Functions.openScreen('EntityManagement.view.Entity:searchEntityVendor', {
                    filters: [{
                        column: 'intEntityId',
                        value: vendorId
                    }]
                });
            }
        }

        i21.ModuleMgr.Inventory.showScreenFromHeaderDrilldown('EntityManagement.view.Entity:searchEntityVendor', grid, 'intEntityVendorId');
        if (grid.itemId === 'grdCharges') {
            var selectedObj = grid.getSelectionModel().getSelection();
            var vendorId = '';

            if (selectedObj.length == 0) {
                iRely.Functions.openScreen('EntityManagement.view.Entity:searchEntityVendor', { action: 'new', viewConfig: { modal: true } });
            }

            else {
                for (var x = 0; x < selectedObj.length; x++) {
                    vendorId += selectedObj[x].data.intEntityVendorId + '|^|';
                }

                iRely.Functions.openScreen('EntityManagement.view.Entity:searchEntityVendor', {
                    filters: [{
                        column: 'intEntityId',
                        value: vendorId
                    }]
                });
            }
        }
    },   

    onSpecialKeyTab: function(component, e, eOpts) {
        var win = component.up('window');
        if(win) {
            if (e.getKey() === Ext.event.Event.TAB) {
                var gridObj = win.down('#grdInventoryShipment'),
                    sel = gridObj.getStore().getAt(0);
                    
                if (sel && gridObj) {
                    gridObj.setSelection(sel);
                    var cepItem = gridObj.getPlugin('cepItem');
                    if (cepItem){
                        var task = new Ext.util.DelayedTask(function () {
                            cepItem.startEditByPosition({row: 0, column: 1});
                        });
                        task.delay(10);
                    }
                }
            }
        }
    },      

    onCurrencyDrilldown: function (combo) {
        iRely.Functions.openScreen('i21.view.Currency', { viewConfig: { modal: true } });
    },   

    onPnlRecapBeforeShow: function(component, eOpts){
        // var me = this;
        // var win = component.up('window');

        // me.doPostPreview(win);
    }, 

    onPostClick: function(button, e, eOpts) {
        var me = this;
        var win = button.up('window');
        var context = win.context;
        var currentRecord = win.viewModel.data.current;
        var tabInventoryShipment = win.down('#tabInventoryShipment');
        var activeTab = tabInventoryShipment.getActiveTab();

        var doPost = function (){
            var current = currentRecord; 
            ic.utils.ajax({
                url: '../Inventory/api/InventoryShipment/Ship',
                params:{
                    strTransactionId: current.get('strShipmentNumber'),
                    isPost: current.get('ysnPosted') ? false : true,
                    isRecap: false
                },
                method: 'post'
            })
            .subscribe(
                function(successResponse) {
                    me.onAfterShip(true);

                    // Check what is the active tab. If it is the Post Preview tab, load the recap data. 
                    if (activeTab.itemId == 'pgePostPreview'){
                        var cfg = {
                            isAfterPostCall: true,
                            ysnPosted: current.get('ysnPosted') ? true : false
                        };
                        me.doPostPreview(win, cfg);
                    }                     
                }
                ,function(failureResponse) {
                    var jsonData = Ext.decode(failureResponse.responseText);
                    me.onAfterShip(false, jsonData.message.statusText);
                }
            )
        };    

        // If there is no data change, calculate the charge and do the recap. 
        if (!context.data.hasChanges()) {
            doPost();
        }

        // Save has data changes first before anything else. 
        context.data.saveRecord({
            successFn: function () {
                doPost();             
            }
        });
    },    

    onItemValidateEdit: function (editor, context, eOpts) {
        var win = editor.grid.up('window');
        var me = win.controller;
        var vw = win.viewModel;
        var currentItem = context ? context.record : null; 
        var currentHeader = win.viewModel.data.current;        
        var field = context ? context.field : null;

        var transactionCurrencyId = currentHeader.get('intCurrencyId');
        var functionalCurrencyId = i21.ModuleMgr.SystemManager.getCompanyPreference('intDefaultCurrencyId');           
        
        // If editing the qty, check if there is a new sales price appropriate with the shipped qty. 
        if (currentItem) {
            if (field === 'dblQuantity') {
                var dblQuantity = context.value;
                var dblUnitPrice = currentItem.get('dblUnitPrice');
                var dblForexRate = currentItem.get('dblForexRate');

                // Get the transaction and functional currency. 
                var transactionCurrencyId = currentHeader.get('intCurrencyId');
                var functionalCurrencyId = i21.ModuleMgr.SystemManager.getCompanyPreference('intDefaultCurrencyId');           

                dblQuantity = Ext.isNumeric(dblQuantity) ? dblQuantity : 0;
                dblUnitPrice = Ext.isNumeric(dblUnitPrice) ? dblUnitPrice : 0;
                dblForexRate = Ext.isNumeric(dblForexRate) ? dblForexRate : 0;

                var processCustomerPriceOnSuccess = function(successResponse){
                    var jsonData = Ext.decode(successResponse.responseText);
                    var isItemRetailPrice = true;                

                    // If there is a customer cost, replace dblUnitPrice with the customer sales price. 
                    var itemPricing = jsonData ? jsonData.itemPricing : null;
                    if (itemPricing) {
                        dblUnitPrice = itemPricing.dblPrice; 
                        if (itemPricing.strPricing !== 'Inventory - Standard Pricing'){
                            isItemRetailPrice = false;
                        }                    
                    }

                    // Convert the sales price to the transaction currency.
                    // and round it to six decimal places.  
                    if (transactionCurrencyId != functionalCurrencyId && isItemRetailPrice){
                        dblUnitPrice = dblForexRate != 0 ?  dblUnitPrice / dblForexRate : 0;
                        dblUnitPrice = i21.ModuleMgr.Inventory.roundDecimalFormat(dblUnitPrice, 6);
                    }                    

                    // Set the new sales price. 
                    currentItem.set('dblUnitPrice', dblUnitPrice);
                };

                var processCustomerPriceOnFailure = function(failureResponse){
                    var jsonData = Ext.decode(failureResponse.responseText);
                    iRely.Functions.showErrorDialog('Something went wrong while getting the item price from the customer pricing hierarchy.');
                };            

                // Get the customer cost from the hierarchy.  
                var customerPriceCfg = {
                    ItemId: currentItem.get('intItemId'),
                    CustomerId: currentHeader.get('intEntityCustomerId'),
                    CurrencyId: currentHeader.get('intCurrencyId'),
                    LocationId: currentHeader.get('intShipFromLocationId'),
                    TransactionDate: currentHeader.get('dtmShipDate'),
                    Quantity: dblQuantity,
                    ShipToLocationId: currentHeader.get('intShipToLocationId'), 
                    ItemUOMId: currentItem.get('intItemUOMId')
                }
                
                // Call the pricing hierarchy if the order type is not a Sales Contract. 
                //var orderType_SalesContract = 1;

                // Call the pricing hierarchy if the line item does not have an Order Id. Meaning, it is not linked to any other transactions like SO or Contracts. 
                var intOrderId = currentItem.get('intOrderId');
                if (!(intOrderId && Ext.isNumeric(intOrderId) && intOrderId > 0))
                {
                    // Do an ajax call to retrieve the latest sales price from the pricing hierarchy. 
                    me.getItemSalesPrice(customerPriceCfg, processCustomerPriceOnSuccess, processCustomerPriceOnFailure);
                }
            }
        }       
    },

    onItemForexRateTypeChange: function (control, newForexRateType, oldValue, eOpts) {
        var me = this;
        var grid = control.up('grid');
        var plugin = grid.getPlugin('cepItem');
        var current = plugin.getActiveRecord();
        if (current && !(newForexRateType)) {
            current.set('dblForexRate', null);
        }
    },    

    onChargeForexRateTypeChange: function (control, newForexRateType, oldValue, eOpts) {
        var me = this;
        var grid = control.up('grid');
        var plugin = grid.getPlugin('cepCharges');
        var current = plugin.getActiveRecord();
        if (current && !(newForexRateType)) {
            current.set('dblForexRate', null);
        }
    },      

    // onShipFromAddressChange: function (combo, newValue, oldValue, eOpts) {
    //     var win = combo.up('window');
	// 	var txtShipFromAddress = win.down('#txtShipFromAddress');

    //       ic.utils.ajax({
    //             url: '../i21/api/companylocation/search'
    //         })
    //         .flatMap(function(res) {
    //             var json = JSON.parse(res.responseText);
    //             return json.data;
    //         })
    //         .filter(function(data) {
    //             return data.intCompanyLocationId === newValue;
    //         })
    //         .subscribe(
    //             function(successResponse) {
    //                 txtShipFromAddress.setValue(successResponse.strAddress)                 
    //             }
    //             ,function(failureResponse) {
    //                 var jsonData = Ext.decode(failureResponse.responseText);
    //                 iRely.Functions.showErrorDialog(jsonData.message.statusText);                    
    //             }
    //         )
    // },

    onCustomerDrilldown: function (combo) {
        var win = combo.up('window');
        var current = win.viewModel.data.current;

        if (iRely.Functions.isEmpty(combo.getValue())) {
            iRely.Functions.openScreen('EntityManagement.view.Entity:searchEntityCustomer', { action: 'new', viewConfig: { modal: true } });
        }
        else {
            iRely.Functions.openScreen('EntityManagement.view.Entity:searchEntityCustomer', {
                filters: [
                    {
                        column: 'intEntityId',
                        value: current.get('intEntityCustomerId')
                    }
                ]
            });
        }
    },

    onGumUOMSelect: function(plugin, records) {
        if (records.length <= 0)
            return;

        var me = this;
        var win = me.getView().screenMgr.window;
        var grid = win.down('grid');
        var current = plugin.getActiveRecord();

        var dblUnitQty = records[0].get('dblUnitQty');
        var dblLastCost = records[0].get('dblLastCost');
        var dblSalesPrice = records[0].get('dblSalePrice');
        var dblSalesPriceForeign = records[0].get('dblSalePrice');
        var intItemUOMId = records[0].get('intItemUnitMeasureId');
        var dblForexRate = current.get('dblForexRate');

        // Convert the sales price from functional currency to the transaction currency. 
        dblSalesPriceForeign = dblForexRate !== 0 ? dblSalesPrice / dblForexRate : dblLastCost;
        dblSalesPriceForeign = i21.ModuleMgr.Inventory.roundDecimalFormat(dblSalesPriceForeign, 6);            

        current.set('dblItemUOMConv', dblUnitQty);
        current.set('dblUnitCost', dblLastCost);
        current.set('dblUnitPrice', dblSalesPrice);
        current.set('intItemUOMId', intItemUOMId);
    },

    doPostPreview: function(win, cfg){
        var me = this;

        if (!win) {return;}
        cfg = cfg ? cfg : {};

        var isAfterPostCall = cfg.isAfterPostCall;
        var ysnPosted = cfg.ysnPosted;
        var context = win.context;

        var doRecap = function (currentRecord){
            ic.utils.ajax({
                url: '../Inventory/api/InventoryShipment/Ship',
                params:{
                    strTransactionId: currentRecord.get('strShipmentNumber'),
                    isPost: isAfterPostCall ? ysnPosted : currentRecord.get('ysnPosted') ? false : true,
                    isRecap: true
                },
                method: 'post'
            })
            .subscribe(
                function(successResponse) {
                    var postResult = Ext.decode(successResponse.responseText);
                    var batchId = postResult.data.strBatchId;
                    if (batchId) {
                        me.bindRecapGrid(batchId);
                    }                    
                }
                ,function(failureResponse) {
                    // Show Post Preview failed.
                    var jsonData = Ext.decode(failureResponse.responseText);
                    iRely.Functions.showErrorDialog(jsonData.message.statusText);                    
                }
            )
        };    

        // If there is no data change, calculate the charge and do the recap. 
        if (!context.data.hasChanges()) {
            doRecap(win.viewModel.data.current);
        }

        // Save has data changes first before anything else. 
        context.data.saveRecord({
            successFn: function () {
                doRecap(win.viewModel.data.current);             
            }
        });        
    },    

    onShipmentTabChange: function(tabPanel, newCard, oldCard, eOpts){
        var me = this;
        var win = tabPanel.up('window');
        var context = win.context;
        var current = win.viewModel.data.current;        
        switch (newCard.itemId) {
            case 'pgePostPreview': 
                me.doPostPreview(win);
        }
    },

    onRefreshInvoicesClick: function (control) {
        ic.utils.ajax({
            url: '../Inventory/api/InventoryShipment/UpdateShipmentInvoice',
            method: 'post'  
        })
        .subscribe(
            function(successResponse) {
                var jsonData = Ext.decode(successResponse.responseText);
                var panel = control.up('panel');
                var grdSearch = panel ? panel.query('#grdSearch') : null;

                if (grdSearch && grdSearch.length > 0){
                    grdSearch.forEach(function (grid) {
                        if (grid && grid.url == '../Inventory/api/InventoryShipment/ShipmentInvoice'){
                            var store = grid ? grid.getStore() : null;
                            if (store){
                                store.reload({
                                    callback: function(){
                                        grid.getView().refresh();
                                    }
                                });                    
                            }
                        }
                    }); 
                }                
            }
            , function(failureResponse) {
                var jsonData = Ext.decode(failureResponse.responseText);
                iRely.Functions.showErrorDialog(jsonData.message.statusText);
            }
        );        
    },    

    init: function(application) {
        this.control({
            "#cboShipFromAddress": {
                select: this.onShipLocationSelect,
                beforeselect: this.onShipFromAddressBeforeSelect
                //change: this.onShipFromAddressChange
            },
            "#cboShipToAddress": {
                select: this.onShipLocationSelect
            },
            "#cboCustomer": {
                select: this.onCustomerSelect,
                drilldown: this.onCustomerDrilldown
            },
            "#cboOrderNumber": {
                select: this.onOrderNumberSelect
            },
            "#cboItemNo": {
                select: this.onItemNoSelect,
                beforequery: this.onItemBeforeQuery
            },
            "#cboUOM": {
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
            "#btnPost": {
                click: this.onPostClick
            },
            "#btnUnpost": {
                click: this.onPostClick
            },
            "#btnPostPreview": {
                click: this.onRecapClick
            },
            "#btnUnpostPreview": {
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
            },
            "#btnAddOrders": {
                click: this.onAddOrderClick
            },
            "#cboChargeCurrency": {
                select: this.onChargeSelect
            },
            "#cboShipToCompanyAddress": {
                select: this.onShipLocationSelect
            },
            "#cboOrderType": {
                select: this.onOrderTypeSelect
            },
            "#btnPrint": {
                click: this.onPrintClick
            },
            "#cboSubLocation": {
                select: this.onItemNoSelect
            },
            "#cboStorageLocation": {
                select: this.onItemNoSelect
            },
            "#cboCustomerStorage": {
                select: this.onItemNoSelect
            },
            "#btnCalculateCharges": {
                click: this.onCalculateChargeClick
            },
            "#colAccrue": {
                beforecheckchange: this.onAccrueCheckChange
            },
            "#txtComments": {
                specialKey: this.onSpecialKeyTab
            },
            "#cboForexRateType": {
                select: this.onItemNoSelect,
                change: this.onItemForexRateTypeChange
            },
            "#cboChargeForexRateType": {
                select: this.onChargeSelect,
                change: this.onChargeForexRateTypeChange
            },
            "#cboCurrency": {
                drilldown: this.onCurrencyDrilldown
                //select: this.onCurrencySelect
            },
            "#gumQuantity": {
                onUOMSelect: this.onGumUOMSelect
            },
            "#tabInventoryShipment": {
                tabChange: this.onShipmentTabChange
            }            
        })
    }

});
