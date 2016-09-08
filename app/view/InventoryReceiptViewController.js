Ext.define('Inventory.view.InventoryReceiptViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.icinventoryreceipt',
    requires: [
        'CashManagement.common.Text',
        'CashManagement.common.BusinessRules'
    ],

    config: {
        helpURL: '/display/DOC/Inventory+Receipts',
        searchConfig: {
            title: 'Search Inventory Receipt',
            type: 'Inventory.InventoryReceipt',
            api: {
                read: '../Inventory/api/InventoryReceipt/Search'
            },
            columns: [
                {dataIndex: 'intInventoryReceiptId', text: "Receipt Id", flex: 1, defaultSort: true, sortOrder: 'DESC', dataType: 'numeric', key: true, hidden: true},
                {dataIndex: 'strReceiptNumber', text: 'Receipt No', flex: 1, dataType: 'string', drillDownText: 'View Receipt', drillDownClick: 'onViewReceiptNo'},
                {dataIndex: 'dtmReceiptDate', text: 'Receipt Date', flex: 1, dataType: 'date', xtype: 'datecolumn'},
                {dataIndex: 'strReceiptType', text: 'Order Type', flex: 1, dataType: 'string'},
                {dataIndex: 'strVendorName', text: 'Vendor Name', flex: 1, dataType: 'string', drillDownText: 'View Vendor', drillDownClick: 'onViewVendorName'},
                {dataIndex: 'strLocationName', text: 'Location Name', flex: 1, dataType: 'string', drillDownText: 'View Location', drillDownClick: 'onViewLocationName'},
                {dataIndex: 'strBillOfLading', text: 'Bill Of Lading No', flex: 1, dataType: 'string'},
                {dataIndex: 'ysnPosted', text: 'Posted', flex: 1, dataType: 'boolean', xtype: 'checkcolumn'},

                {dataIndex: 'strSourceType', text: 'Source Type', flex: 1, dataType: 'string', hidden: true },
                {dataIndex: 'strVendorId', text: 'Vendor Id', flex: 1, dataType: 'string', hidden: true },
                {dataIndex: 'strTransferor', text: 'Transferor', flex: 1, dataType: 'string', hidden: true },
                {dataIndex: 'strCurrency', text: 'Currency', flex: 1, dataType: 'string', hidden: true },
                {dataIndex: 'intBlanketRelease', text: 'Blanket Release', flex: 1, dataType: 'int', hidden: true },
                {dataIndex: 'strVendorRefNo', text: 'Vendor Reference No', flex: 1, dataType: 'string', hidden: true },
                {dataIndex: 'strShipVia', text: 'Ship Via', flex: 1, dataType: 'string', hidden: true },
                {dataIndex: 'strShipFrom', text: 'Ship From', flex: 1, dataType: 'string', hidden: true },
                {dataIndex: 'strReceiver', text: 'Receiver', flex: 1, dataType: 'string', hidden: true },
                {dataIndex: 'strVessel', text: 'Vessel', flex: 1, dataType: 'string', hidden: true },
                {dataIndex: 'strFreightTerm', text: 'Freight Term', flex: 1, dataType: 'string', hidden: true },
                {dataIndex: 'strFobPoint', text: 'Fob Point', flex: 1, dataType: 'string', hidden: true },
                {dataIndex: 'intShiftNumber', text: 'Shift Number', flex: 1, dataType: 'int', hidden: true },
                {dataIndex: 'dblInvoiceAmount', text: 'Invoice Amount', flex: 1, dataType: 'float', hidden: true },
                {dataIndex: 'ysnPrepaid', text: 'Prepaid', flex: 1, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                {dataIndex: 'ysnInvoicePaid', text: 'Invoice Paid', flex: 1, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                {dataIndex: 'intCheckNo', text: 'Check No', flex: 1, dataType: 'int', hidden: true },
                {dataIndex: 'dtmCheckDate', text: 'Check Date', flex: 1, dataType: 'date', xtype: 'datecolumn', hidden: true },
                {dataIndex: 'intTrailerTypeId', text: 'Trailer Type Id', flex: 1, dataType: 'int', hidden: true },
                {dataIndex: 'dtmTrailerArrivalDate', text: 'Trailer Arrival Date', flex: 1, dataType: 'date', xtype: 'datecolumn', hidden: true },
                {dataIndex: 'dtmTrailerArrivalTime', text: 'Trailer Arrival Time', flex: 1, dataType: 'date', xtype: 'datecolumn', hidden: true },
                {dataIndex: 'strSealNo', text: 'Seal No', flex: 1, dataType: 'string', hidden: true },
                {dataIndex: 'strSealStatus', text: 'Seal Status', flex: 1, dataType: 'string', hidden: true },
                {dataIndex: 'dtmReceiveTime', text: 'Receive Time', flex: 1, dataType: 'date', xtype: 'datecolumn', hidden: true },
                {dataIndex: 'dblActualTempReading', text: 'Actual Temp Reading', flex: 1, dataType: 'float', hidden: true },
                {dataIndex: 'strEntityName', text: 'Entity Name', flex: 1, dataType: 'string', hidden: true },
                {dataIndex: 'strActualCostId', text: 'Actual Cost Id', flex: 1, dataType: 'string', hidden: true }
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
                    text: 'Vendor',
                    itemId: 'btnVendor',
                    clickHandler: 'onBtnVendorClick',
                    width: 80
                }
            ],
            searchConfig: [
                {
                    title: 'Details',
                    api: {
                        read: '../Inventory/api/InventoryReceipt/SearchReceiptItems'
                    },
                    columns: [
                        {dataIndex: 'intInventoryReceiptId', text: "Receipt Id", flex: 1, defaultSort: true, sortOrder: 'DESC', dataType: 'numeric', key: true, hidden: true},
                        {dataIndex: 'strReceiptNumber', text: 'Receipt No', flex: 1, dataType: 'string', drillDownText: 'View Receipt', drillDownClick: 'onViewReceiptNo'},
                        {dataIndex: 'strReceiptType', text: 'Order Type', flex: 1, dataType: 'string'},
                        {dataIndex: 'strItemNo', text: 'Item No', flex: 1, dataType: 'string', drillDownText: 'View Item', drillDownClick: 'onViewItemNo'},
                        {dataIndex: 'strItemDescription', text: 'Description', flex: 1, dataType: 'string', drillDownText: 'View Item', drillDownClick: 'onViewItemNo'},
                        {dataIndex: 'strOrderNumber', text: 'Order Number', flex: 1, dataType: 'string'},
                        {dataIndex: 'strSourceNumber', text: 'Source Number', flex: 1, dataType: 'string'},
                        {dataIndex: 'strUnitMeasure', text: 'Receipt UOM', flex: 1, dataType: 'string'},

                        { xtype: 'numbercolumn', dataIndex: 'dblQtyToReceive', text: 'Qty to Receive', flex: 1, dataType: 'float'},
                        { xtype: 'numbercolumn', format: '0,000.000##', dataIndex: 'dblUnitCost', text: 'Cost', flex: 1, dataType: 'float'},
                        { xtype: 'numbercolumn', dataIndex: 'dblTax', text: 'Tax', flex: 1, dataType: 'float'},
                        { xtype: 'numbercolumn', dataIndex: 'dblLineTotal', text: 'Line Total', flex: 1, dataType: 'float'},

                        {dataIndex: 'strCostUOM', text: 'Cost UOM', flex: 1, dataType: 'string', hidden: true},
                        {dataIndex: 'dtmReceiptDate', text: 'Receipt Date', flex: 1, dataType: 'date', xtype: 'datecolumn', hidden: true},
                        {dataIndex: 'strVendorName', text: 'Vendor Name', flex: 1, dataType: 'string', drillDownText: 'View Vendor', drillDownClick: 'onViewVendorName', hidden: true},
                        {dataIndex: 'strLocationName', text: 'Location Name', flex: 1, dataType: 'string', drillDownText: 'View Location', drillDownClick: 'onViewLocationName', hidden: true},
                        {dataIndex: 'strBillOfLading', text: 'Bill Of Lading No', flex: 1, dataType: 'string', hidden: true},
                        {dataIndex: 'ysnPosted', text: 'Posted', flex: 1, dataType: 'boolean', xtype: 'checkcolumn', hidden: false},
                        {dataIndex: 'strVendorRefNo', text: 'Vendor Reference No.', flex: 1, dataType: 'string', hidden: false},
                        {dataIndex: 'strShipFrom', text: 'Ship From', flex: 1, dataType: 'string', hidden: false}
                    ]
                },
                {
                    title: 'Lots',
                    api: {
                        read: '../Inventory/api/InventoryReceipt/SearchReceiptItemLots'
                    },
                    columns: [
                        {dataIndex: 'intInventoryReceiptId', text: "Receipt Id", flex: 1, defaultSort: true, sortOrder: 'DESC', dataType: 'numeric', key: true, hidden: true},
                        {dataIndex: 'strReceiptNumber', text: 'Receipt No', flex: 1, dataType: 'string', drillDownText: 'View Receipt', drillDownClick: 'onViewReceiptNo'},
                        {dataIndex: 'strReceiptType', text: 'Order Type', flex: 1, dataType: 'string'},
                        {dataIndex: 'strItemNo', text: 'Item No', flex: 1, dataType: 'string', drillDownText: 'View Item', drillDownClick: 'onViewItemNo'},
                        {dataIndex: 'strItemDescription', text: 'Description', flex: 1, dataType: 'string', drillDownText: 'View Item', drillDownClick: 'onViewItemNo'},

                        {dataIndex: 'strLotNumber', text: 'Lot Number', flex: 1, dataType: 'string'},
                        {dataIndex: 'strSubLocationName', text: 'Sub Location', flex: 1, dataType: 'string'},
                        {dataIndex: 'strStorageLocationName', text: 'Storage Location', flex: 1, dataType: 'string'},
                        {dataIndex: 'strUnitMeasure', text: 'Lot UOM', flex: 1, dataType: 'string'},
                        { xtype: 'numbercolumn', dataIndex: 'dblQuantity', text: 'Lot Qty', flex: 1, dataType: 'float'},
                        { xtype: 'numbercolumn', dataIndex: 'dblGrossWeight', text: 'Gross Wgt', flex: 1, dataType: 'float'},
                        { xtype: 'numbercolumn', dataIndex: 'dblTareWeight', text: 'Tare Wgt', flex: 1, dataType: 'float'},
                        { xtype: 'numbercolumn', dataIndex: 'dblNetWeight', text: 'Net Wgt', flex: 1, dataType: 'float'},
                        {dataIndex: 'dtmExpiryDate', text: 'Expiry Date', flex: 1, dataType: 'date', xtype: 'datecolumn'},

                        {dataIndex: 'strOrderNumber', text: 'Order Number', flex: 1, dataType: 'string', hidden: true},
                        {dataIndex: 'strSourceNumber', text: 'Source Number', flex: 1, dataType: 'string', hidden: true},
                        {dataIndex: 'strItemUOM', text: 'Receipt UOM', flex: 1, dataType: 'string', hidden: true},
                        {dataIndex: 'dtmReceiptDate', text: 'Receipt Date', flex: 1, dataType: 'date', xtype: 'datecolumn', hidden: true},
                        {dataIndex: 'strLocationName', text: 'Location Name', flex: 1, dataType: 'string', drillDownText: 'View Location', drillDownClick: 'onViewLocationName', hidden: true},
                        {dataIndex: 'strBillOfLading', text: 'Bill Of Lading No', flex: 1, dataType: 'string', hidden: true},
                        {dataIndex: 'ysnPosted', text: 'Posted', flex: 1, dataType: 'boolean', xtype: 'checkcolumn', hidden: true}
                    ]
                },
                {
                    title: 'Vouchers',
                    api: {
                        read: '../Inventory/api/InventoryReceipt/GetReceiptVouchers'
                    },
                    columns: [
                        {dataIndex: 'intInventoryReceiptId', text: 'Inventory Receipt Id', flex: 1, dataType: 'numeric', key: true, hidden: true },
                        {dataIndex: 'intInventoryReceiptItemId', text: 'Inventory Receipt Item Id', flex: 1, dataType: 'numeric', hidden: true },
                        {dataIndex: 'strBillId', text: 'Voucher No', flex: 1, defaultSort: true, sortOrder: 'DESC', dataType: 'string', drillDownText: 'View Voucher', drillDownClick: 'onViewVoucher' },
                        {dataIndex: 'dtmBillDate', text: 'Voucher Date', flex: 1, dataType: 'date', xtype: 'datecolumn' },

                        {dataIndex: 'strVendor', text: 'Vendor', flex: 1, dataType: 'string' },
                        {dataIndex: 'strLocationName', text: 'Destination', flex: 1, dataType: 'string' },
                        {dataIndex: 'strReceiptNumber', text: 'Receipt No', flex: 1, dataType: 'string' },
                        {dataIndex: 'dtmReceiptDate', text: 'Receipt Date', flex: 1, dataType: 'date', xtype: 'datecolumn' },
                        {dataIndex: 'strBillOfLading', text: 'BOL', flex: 1, dataType: 'string' },
                        {dataIndex: 'strReceiptType', text: 'Order Type', flex: 1, dataType: 'string' },
                        {dataIndex: 'strOrderNumber', text: 'Order No', flex: 1, dataType: 'string' },
                        {dataIndex: 'strItemDescription', text: 'Product', flex: 1, dataType: 'string' },
                        {dataIndex: 'dblUnitCost', text: 'Unit Cost', flex: 1, dataType: 'float', xtype: 'numbercolumn' },
                        {dataIndex: 'dblQtyToReceive', text: 'Qty Received', flex: 1, dataType: 'float', xtype: 'numbercolumn' },
                        {dataIndex: 'dblLineTotal', text: 'Receipt Amount', flex: 1, dataType: 'float', xtype: 'numbercolumn', emptyCellText: '0.00', aggregate:'sum', aggregateFormat: '#,###.00' },
                        {dataIndex: 'dblQtyVouchered', text: 'Qty Vouchered', flex: 1, dataType: 'float', xtype: 'numbercolumn' },
                        {dataIndex: 'dblVoucherAmount', text: 'Voucher Amount', flex: 1, dataType: 'float', xtype: 'numbercolumn', emptyCellText: '0.00', aggregate:'sum', aggregateFormat: '#,###.00' },
                        {dataIndex: 'dblQtyToVoucher', text: 'Qty To Voucher', flex: 1, dataType: 'float', xtype: 'numbercolumn' },
                        {dataIndex: 'dblAmountToVoucher', text: 'Amount To Voucher', flex: 1, dataType: 'float', xtype: 'numbercolumn', emptyCellText: '0.00', aggregate:'sum', aggregateFormat: '#,###.00' }
                    ]
                }
            ]
        },
        binding: {
            bind: {
                title: 'Inventory Receipt - {current.strReceiptNumber}'
            },
            btnSave: {
                disabled: '{isReceiptReadonly}'
            },
            btnDelete: {
                disabled: '{isReceiptReadonly}'
            },
            btnUndo: {
                disabled: '{isReceiptReadonly}'
            },
            btnReceive: {
                disabled: '{current.ysnOrigin}',
                text: '{getReceiveButtonText}',
                hidden: '{checkTransportPosting}'
            },
            btnRecap: {
                disabled: '{current.ysnOrigin}'
            },
            btnVendor: {
                disabled: '{current.ysnOrigin}'
            },
            btnAddOrders: {
                hidden: '{checkHiddenAddOrders}',
                disabled: '{current.ysnOrigin}'
            },

            cboReceiptType: {
                value: '{current.strReceiptType}',
                store: '{receiptTypes}',
                readOnly: '{checkReadOnlyWithOrder}',
                disabled: '{current.ysnOrigin}'
            },
            cboSourceType: {
                value: '{current.intSourceType}',
                store: '{sourceTypes}',
                readOnly: '{disableSourceType}',
                defaultFilters: '{filterSourceByType}',
                disabled: '{current.ysnOrigin}'
            },
            cboVendor: {
                value: '{current.intEntityVendorId}',
                store: '{vendor}',
                readOnly: '{checkReadOnlyWithOrder}',
                hidden: '{checkHiddenInTransferOrder}',
                disabled: '{current.ysnOrigin}'
            },
            cboTransferor: {
                value: '{current.intTransferorId}',
                store: '{transferor}',
                hidden: '{checkHiddenIfNotTransferOrder}',
                readOnly: '{current.ysnOrigin}',
                disabled: '{current.ysnOrigin}'
            },
            cboLocation: {
                value: '{current.intLocationId}',
                store: '{location}',
                readOnly: '{checkReadOnlyWithOrder}',
                disabled: '{current.ysnOrigin}'
            },
            dtmReceiptDate: {
                value: '{current.dtmReceiptDate}',
                readOnly: '{isReceiptReadonly}'
            },
            cboCurrency: {
                value: '{current.intCurrencyId}',
                disabled: '{current.ysnOrigin}',
                store: '{currency}',
                readOnly: '{isReceiptReadonly}',
                defaultFilters: [
                    {
                        column: 'ysnSubCurrency',
                        value: false
                    }
                ]
            },
            txtReceiptNumber: {
                value: '{current.strReceiptNumber}'
            },
            txtBlanketReleaseNumber: {
                value: '{current.intBlanketRelease}',
                readOnly: '{isReceiptReadonly}'
            },
            txtVendorRefNumber: {
                value: '{current.strVendorRefNo}',
                readOnly: '{isReceiptReadonly}'
            },
            txtBillOfLadingNumber: {
                value: '{current.strBillOfLading}',
                readOnly: '{isReceiptReadonly}'
            },
            cboShipVia: {
                value: '{current.intShipViaId}',
                store: '{shipvia}',
                readOnly: '{isReceiptReadonly}'
            },
            cboShipFrom: {
                value: '{current.intShipFromId}',
                store: '{shipFrom}',
                defaultFilters: [
                    {
                        column: 'intEntityId',
                        value: '{current.intEntityVendorId}'
                    }
                ],
                readOnly: '{isReceiptReadonly}'
            },
            cboReceiver: {
                value: '{current.intReceiverId}',
                store: '{users}',
                readOnly: '{isReceiptReadonly}'
            },
            txtVessel: {
                value: '{current.strVessel}',
                readOnly: '{isReceiptReadonly}'
            },
            cboFreightTerms: {
                value: '{current.intFreightTermId}',
                store: '{freightTerm}',
                defaultFilters: [
                    {
                        column: 'ysnActive',
                        value: 'true'
                    }
                ],
                readOnly: '{isReceiptReadonly}'
            },
            txtFobPoint: {
                value: '{current.strFobPoint}',
                readOnly: '{isReceiptReadonly}'
            },
            cboTaxGroup: {
                value: '{current.intTaxGroupId}',
                store: '{taxGroup}',
                readOnly: '{isReceiptReadonly}',
                disabled: '{current.ysnOrigin}'
            },
            txtShiftNumber: {
                value: '{current.intShiftNumber}',
                readOnly: '{isReceiptReadonly}'
            },
            btnInsertInventoryReceipt: {
                hidden: '{isReceiptReadonly}'
            },
            btnRemoveInventoryReceipt: {
                hidden: '{isReceiptReadonly}'
            },
            btnInsertLot: {
                hidden: '{isReceiptReadonly}'
            },
            btnRemoveLot: {
                hidden: '{isReceiptReadonly}'
            },
            btnReplicateBalanceLots: {
                hidden: '{isReceiptReadonly}'
            },
            btnPrintLabel: {
                hidden: '{!current.ysnPosted}'
            },
            btnInsertCharge: {
                hidden: '{isReceiptReadonly}'
            },
            btnRemoveCharge: {
                hidden: '{isReceiptReadonly}'
            },
            btnCalculateCharges: {
                hidden: '{isReceiptReadonly}'
            },
            btnshowOtherCharges: {
                hidden: '{current.ysnPosted}'
            },
            btnBill: {
                hidden: '{!current.ysnPosted}',
                disabled: '{current.ysnOrigin}'
            },
            btnQuality: {
                hidden: '{current.ysnPosted}',
                disabled: '{current.ysnOrigin}'
            },
            lblWeightLossMsg: {
                text: '{getWeightLossText}'
            },
            lblWeightLossMsgValue: {
                text: '{getWeightLossValueText}',
                hidden: '{hidelblWeightLossMsgValue}'
            },
            grdInventoryReceipt: {
                readOnly: '{readOnlyReceiptItemGrid}',
                colOrderNumber: {
                    hidden: '{checkHideOrderNo}',
                    dataIndex: 'strOrderNumber'
                },
                colSourceNumber: {
                    hidden: '{checkHideSourceNo}',
                    dataIndex: 'strSourceNumber'
                },
                colItemNo: {
                    dataIndex: 'strItemNo',
                    editor: {
                        readOnly: '{readOnlyItemDropdown}',
                        defaultFilters: [
                            {
                                column: 'intLocationId',
                                value: '{current.intLocationId}',
                                conjunction: 'and'
                            },
                            {
                                column: 'ysnReceiveUOMAllowPurchase',
                                value: true,
                                conjunction: 'and'
                            },
                            {
                                column: 'strType',
                                condition: 'noteq',
                                value: 'Other Charge',
                                conjunction: 'and'
                            }
                        ],
                        store: '{items}'
                    }
                },
                colDescription: 'strItemDescription',
                colContainer: {
                    hidden: '{hideContainerColumn}',
                    dataIndex: 'strContainer'
                },
                colSubLocation: {
                    dataIndex: 'strSubLocationName',
                    editor: {
                        origValueField: 'intCompanyLocationSubLocationId',
                        origUpdateField: 'intSubLocationId',
                        store: '{subLocation}',
                        defaultFilters: [
                            {
                                column: 'intCompanyLocationId',
                                value: '{current.intLocationId}',
                                conjunction: 'and'
                            },
                            {
                                column: 'strClassification',
                                value: 'Inventory',
                                conjunction: 'and'
                            }
                        ]
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
                                value: '{grdInventoryReceipt.selection.intSubLocationId}',
                                conjunction: 'and'
                            }
                        ]
                    }
                },
                colGrade: {
                    dataIndex: 'strGrade',
                    editor: {
                        readOnly: '{hasItemCommodity}',
                        origValueField: 'intCommodityAttributeId',
                        origUpdateField: 'intGradeId',
                        store: '{grade}',
                        defaultFilters: [
                            {
                                column: 'intCommodityId',
                                value: '{grdInventoryReceipt.selection.intCommodityId}',
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
                        origValueField: 'intOwnershipType',
                        origUpdateField: 'intOwnershipType',
                        store: '{ownershipTypes}'
                    }
                },
                colLotTracking: 'strLotTracking',
                colLoadContract: {
                    hidden: '{checkShowContractOnly}',
                    dataIndex: 'ysnLoad'
                },
                colOrderUOM: {
                    hidden: '{checkHideOrderNo}',
                    dataIndex: 'strOrderUOM'
                },
                colQtyOrdered: {
                    hidden: '{checkHideOrderNo}',
                    dataIndex: 'dblOrderQty'
                },
                colAvailableQty: {
                    hidden: '{checkShowLoadContractOnly}',
                    dataIndex: 'dblAvailableQty'
                },
                colReceived: {
                    hidden: '{checkHideOrderNo}',
                    dataIndex: 'dblReceived'
                },
                colQtyToReceive: 'dblOpenReceive',
                colLoadToReceive: {
                    hidden: '{checkShowLoadContractOnly}',
                    dataIndex: 'intLoadReceive'
                },
                colItemSubCurrency: {
                    dataIndex: 'strSubCurrency'
                },
                colUOM: {
                    dataIndex: 'strUnitMeasure',
                    editor: {
                        store: '{itemUOM}',
                        defaultFilters: [
                            {
                                column: 'intItemId',
                                value: '{grdInventoryReceipt.selection.intItemId}',
                                conjunction: 'and'
                            },
                            {
                                column: 'intLocationId',
                                value: '{current.intLocationId}',
                                conjunction: 'and'
                            }
                        ]
                    }
                },
                colWeightUOM: {
                    dataIndex: 'strWeightUOM',
                    editor: {
                        origValueField: 'intItemUOMId',
                        origUpdateField: 'intWeightUOMId',
                        store: '{weightUOM}',
                        defaultFilters: [
                            {
                                column: 'intItemId',
                                value: '{grdInventoryReceipt.selection.intItemId}',
                                conjunction: 'and'
                            }
                        ]
                    }
                },
                colUnitCost: {
                    dataIndex: 'dblUnitCost',
                    editor: {
                        readOnly: '{readOnlyUnitCost}'
                    }
                },
                colCostUOM: {
                    dataIndex: 'strCostUOM',
                    editor: {
                        readOnly: '{readOnlyUnitCost}',
                        origValueField: 'intItemUnitMeasureId',
                        origUpdateField: 'intCostUOMId',
                        store: '{costUOM}',
                        defaultFilters: [
                            {
                                column: 'intItemId',
                                value: '{grdInventoryReceipt.selection.intItemId}',
                                conjunction: 'and'
                            },
                            {
                                column: 'intLocationId',
                                value: '{current.intLocationId}',
                                conjunction: 'and'
                            }
                        ]
                    }
                },
                colTax: {
                    dataIndex: 'dblTax'
                },
                colUnitRetail: 'dblUnitRetail',
                colGross: {
                    dataIndex: 'dblGross',
                    editor: {
                        readOnly: '{readOnlyNoGrossNetUOM}'
                    }
                },
                colNet: {
                    dataIndex: 'dblNet',
                    editor: {
                        readOnly: '{readOnlyNoGrossNetUOM}'
                    }
                },
                colLineTotal: 'dblLineTotal',
                colGrossMargin: 'dblGrossMargin'
            },

            /*pnlLotTracking: {
                hidden: '{hasItemSelection}'
            },*/
            grdLotTracking: {
                readOnly: '{isReceiptReadonly}',
                colLotId: {
                    dataIndex: 'strLotNumber',
                    editor: {
                        forceSelection: '{forceSelection}',
                        origValueField: 'intLotId',
                        origUpdateField: 'intLotId',
                        store: '{lots}',
                        defaultFilters: [
                            {
                                column: 'intItemId',
                                value: '{grdInventoryReceipt.selection.intItemId}',
                                conjunction: 'and'
                            },
                            {
                                column: 'intLocationId',
                                value: '{current.intLocationId}',
                                conjunction: 'and'
                            },
                            {
                                column: 'intSubLocationId',
                                value: '{grdInventoryReceipt.selection.intSubLocationId}',
                                conjunction: 'and'
                            },
                            {
                                column: 'intStorageLocationId',
                                value: '{grdInventoryReceipt.selection.intStorageLocationId}',
                                conjunction: 'and'
                            },
                            {
                                column: 'intOwnershipType',
                                value: '{grdInventoryReceipt.selection.intOwnershipType}',
                                conjunction: 'and'
                            },
                            {
                                column: 'strLotStatusType',
                                value: 'Active',
                                conjunction: 'and'
                            }
                        ]
                    }
                },
                colLotAlias: {
                    dataIndex: 'strLotAlias'

                },
                colLotUOM: {
                    dataIndex: 'strUnitMeasure',
                    editor: {
                        store: '{lotUOM}',
                        defaultFilters: [
                            {
                                column: 'intItemId',
                                value: '{grdInventoryReceipt.selection.intItemId}',
                                conjunction: 'and'
                            }
                        ]
                    }
                },
                colLotQuantity: 'dblQuantity',
                colLotGrossWeight: {
                    dataIndex: 'dblGrossWeight',
                    editor: {
                        readOnly: '{readOnlyNoGrossNetUOM}'
                    }
                },
                colLotTareWeight: {
                    dataIndex: 'dblTareWeight',
                    editor: {
                        readOnly: '{readOnlyNoGrossNetUOM}'
                    }
                },
                colLotNetWeight: {
                    dataIndex: 'dblNetWeight',
                    editor: {
                        readOnly: '{readOnlyNoGrossNetUOM}'
                    }
                },
                colLotExpiryDate: 'dtmExpiryDate',
                colLotStorageLocation: {
                    dataIndex: 'strStorageLocation',
                    editor: {
                        readOnly: '{hasStorageLocation}',
                        store: '{lotStorageLocation}',
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
                                value: '{grdInventoryReceipt.selection.intSubLocationId}',
                                conjunction: 'and'
                            }
                        ]
                    }
                },
                colLotUnitsPallet: 'intUnitPallet',
                colLotStatedGross: 'dblStatedGrossPerUnit',
                colLotStatedTare: 'dblStatedTarePerUnit',
                colLotStatedNet: 'dblStatedNetPerUnit',
                colLotWeightUOM: 'strWeightUOM',
                colLotPhyVsStated: 'dblPhyVsStated',
                colLotParentLotId: {
                    dataIndex: 'strParentLotNumber',
                    editor: {
                        store: '{parentLots}',
                        defaultFilters: [
                            {
                                column: 'intItemId',
                                value: '{grdInventoryReceipt.selection.intItemId}',
                                conjunction: 'and'
                            }
                        ]
                    }
                },
                colLotContainerNo: 'strContainerNo',
                colLotVendorLocation: {
                    dataIndex: 'strGarden'
                },
                colLotGrade: {
                    dataIndex: 'strGrade',
                    editor: {
                        readOnly: '{hasItemCommodity}',
                        origValueField: 'intCommodityAttributeId',
                        origUpdateField: 'intGradeId',
                        store: '{lotGrade}',
                        defaultFilters: [
                            {
                                column: 'intCommodityId',
                                value: '{grdInventoryReceipt.selection.intCommodityId}',
                                conjunction: 'and'
                            }
                        ]
                    }
                },
                colLotOrigin: {
                    dataIndex: 'strOrigin',
                    editor: {
                        origValueField: 'intCountryID',
                        origUpdateField: 'intOriginId',
                        store: '{origin}'
                    }
                },
                colLotSeasonCropYear: 'intSeasonCropYear',
                colLotVendorLotId: 'strVendorLotId',
                colLotManufacturedDate: 'dtmManufacturedDate',
                colLotRemarks: 'strRemarks',
                colLotCondition: {
                    dataIndex: 'strCondition',
                    editor: {
                        store: '{condition}'
                    }
                },
                colLotCertified: 'dtmCertified'
            },

            grdIncomingInspection: {
                colInspect: 'ysnSelected',
                colQualityPropertyName: 'strPropertyName'
            },

            // ---- Charge and Invoice Tab
            grdCharges: {
                readOnly: '{isReceiptReadonly}',
                colContract: {
                    hidden: '{hideContractColumn}',
                    dataIndex: 'strContractNumber',
                    editor: {
                        origValueField: 'intContractHeaderId',
                        origUpdateField: 'intContractId',
                        store: '{contract}',
                        defaultFilters: [
                            {
                                column: 'strContractType',
                                value: 'Purchase',
                                conjunction: 'and'
                            },
                            {
                                column: 'intEntityId',
                                value: '{current.intEntityVendorId}',
                                conjunction: 'and'
                            }
                        ]
                    }
                },
                colOtherCharge: {
                    dataIndex: 'strItemNo',
                    editor: {
                        store: '{otherCharges}'
                    }
                },
                colInventoryCost: {
                    disabled: '{current.ysnPosted}',
                    dataIndex: 'ysnInventoryCost'
                },
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
                        origUpdateField: 'intCurrencyId'
                    }
                },
                colRate: 'dblRate',
                colChargeUOM: {
                    dataIndex: 'strCostUOM',
                    editor: {
                        store: '{chargeUOM}',
                        origValueField: 'intItemUOMId',
                        origUpdateField: 'intCostUOMId',
                        defaultFilters: [
                            {
                                column: 'intItemId',
                                value: '{grdCharges.selection.intChargeId}',
                                conjunction: 'and'
                            },
                            {
                                column: 'intLocationId',
                                value: '{current.intLocationId}',
                                conjunction: 'and'
                            }
                        ]
                    }
                },
                colOnCostType: 'strOnCostType',
                colCostVendor: {
                    dataIndex: 'strVendorName',
                    editor: {
                        readOnly: '{readOnlyAccrue}',
                        origValueField: 'intEntityVendorId',
                        origUpdateField: 'intEntityVendorId',
                        store: '{vendor}'
                    }
                },
                 colChargeAmount: {
                    dataIndex: 'dblAmount',
                    editor:{
                        disabled:'{disableAmount}'
                    }
                },
                colAllocateCostBy: {
                    dataIndex: 'strAllocateCostBy',
                    editor: {
                        readOnly: '{checkInventoryCostAndPrice}',
                        store: '{allocateBy}'
                    }
                },
                colAccrue: {
                    disabled: '{current.ysnPosted}',
                    dataIndex: 'ysnAccrue'
                },
                colPrice: {
                    disabled: '{current.ysnPosted}',
                    dataIndex: 'ysnPrice'
                }
            },

//            txtCalculatedAmount: '{current.strMessage}',
            txtInvoiceAmount: {
                value: '{current.dblInvoiceAmount}',
                readOnly: '{isReceiptReadonly}'
            },
//            txtDifference: '{current.strMessage}',
            chkPrepaid: {
                value: '{current.ysnPrepaid}',
                readOnly: '{isReceiptReadonly}'
            },
            chkInvoicePaid: {
                value: '{current.ysnInvoicePaid}',
                readOnly: '{isReceiptReadonly}'
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
                readOnly: '{isReceiptReadonly}'
            },
            txtTrailerArrivalDate: {
                value: '{current.dtmTrailerArrivalDate}',
                readOnly: '{isReceiptReadonly}'
            },
            txtTrailerArrivalTime: {
                value: '{current.dtmTrailerArrivalTime}',
                readOnly: '{isReceiptReadonly}'
            },
            txtSealNo: {
                value: '{current.strSealNo}',
                readOnly: '{isReceiptReadonly}'
            },
            cboSealStatus: {
                value: '{current.strSealStatus}',
                store: '{sealStatuses}',
                readOnly: '{isReceiptReadonly}'
            },
            txtReceiveTime: {
                value: '{current.dtmReceiveTime}',
                readOnly: '{isReceiptReadonly}'
            },
            txtActualTempReading: {
                value: '{current.dblActualTempReading}',
                readOnly: '{isReceiptReadonly}'
            }

        }
    },

    setupContext: function (options) {
        "use strict";
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.Receipt', { pageSize: 1});

        var grdInventoryReceipt = win.down('#grdInventoryReceipt'),
            grdIncomingInspection = win.down('#grdIncomingInspection'),
            grdLotTracking = win.down('#grdLotTracking'),
            grdCharges = win.down('#grdCharges');

        grdInventoryReceipt.mon(grdInventoryReceipt, {
            afterlayout: me.onGridAfterLayout
        });

        // Update the summary fields whenever the receipt item data changed.
        me.getViewModel().bind('{current.tblICInventoryReceiptItems}', function(store) {
            store.on('update', function(){
                me.showSummaryTotals(win);
                me.showOtherCharges(win);
            });

            store.on('datachanged', function(){
                me.showSummaryTotals(win);
                me.showOtherCharges(win);
            });
        });

        // Update the summary fields whenever the other charges data changed.
        me.getViewModel().bind('{current.tblICInventoryReceiptCharges}', function(store) {
            store.on('update', function(){
                me.showSummaryTotals(win);
                me.showOtherCharges(win);
            });

            store.on('datachanged', function(){
                me.showSummaryTotals(win);
                me.showOtherCharges(win);
            });
        });

        //'vyuICGetInventoryReceipt,' +

        win.context = Ext.create('iRely.mvvm.Engine', {
            window: win,
            store: store,
            createRecord: me.createRecord,
            validateRecord: me.validateRecord,
            onPageChange: me.onPageChange,
            binding: me.config.binding,
            enableActivity: true,
            createTransaction: Ext.bind(me.createTransaction, me),
            enableAudit: true,
            include: 'tblICInventoryReceiptInspections,' +
            'vyuICInventoryReceiptLookUp,' +
            'tblICInventoryReceiptItems.vyuICInventoryReceiptItemLookUp,' +
            /*'tblICInventoryReceiptItems.tblICInventoryReceiptItemLots.vyuICGetInventoryReceiptItemLot, ' +*/
            'tblICInventoryReceiptItems.tblICInventoryReceiptItemTaxes,' +
            'tblICInventoryReceiptCharges.vyuICGetInventoryReceiptCharge',
            attachment: Ext.create('iRely.mvvm.attachment.Manager', {
                type: 'Inventory.Receipt',
                window: win
            }),
            details: [
                {
                    key: 'tblICInventoryReceiptItems',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: grdInventoryReceipt,
                        deleteButton: grdInventoryReceipt.down('#btnRemoveInventoryReceipt')
                    }),
                    details: [
                        {
                            key: 'tblICInventoryReceiptItemLots',
                            component: Ext.create('iRely.mvvm.grid.Manager', {
                                grid: grdLotTracking,
                                deleteButton: grdLotTracking.down('#btnRemoveLot'),
                                createRecord: me.onLotCreateRecord
                            })
                        },
                        {
                            key: 'tblICInventoryReceiptItemTaxes'
                        }
                    ]
                },
                {
                    key: 'tblICInventoryReceiptCharges',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: grdCharges,
                        deleteButton: grdCharges.down('#btnRemoveCharge'),
                        createRecord: me.onChargeCreateRecord
                    })
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

        var cepItemLots = grdLotTracking.getPlugin('cepItemLots');
        if (cepItemLots) {
            cepItemLots.on({
               // validateedit: me.onEditLots,
                edit: me.onEditLots,
                scope: me
            });
        }

        var cepItem = grdInventoryReceipt.getPlugin('cepItem');
        if (cepItem) {
            cepItem.on({

                edit: me.onItemValidateEdit,
                //edit: me.onItemEdit,
                scope: me
            });
        }

        var cepCharges = grdCharges.getPlugin('cepCharges');
        if (cepCharges) {
            cepCharges.on({
                validateedit: me.onChargeValidateEdit,
                //edit: me.onChargeEdit,
                scope: me
            });
        }

        var colReceived = grdInventoryReceipt.columns[5];
        var txtReceived = colReceived.getEditor();
        if (txtReceived) {
            txtReceived.on('change', me.onCalculateTotalAmount);
        }
        var colUnitCost = grdInventoryReceipt.columns[7];
        var txtUnitCost = colUnitCost.getEditor();
        if (txtUnitCost) {
            txtUnitCost.on('change', me.onCalculateTotalAmount);
        }
        return win.context;
    },

    createTransaction: function(config, action) {
        var me = this,
            current = me.getViewModel().get('current');

        action({
            strTransactionNo: current.get('strReceiptNumber'), //Unique field
            intEntityId: current.get('intEntityId'), //Entity Associated
            dtmDate: current.get('dtmDate') // Date
        })
    },

    orgValueLocation: '',

    onGridAfterLayout: function(grid) {
        "use strict";

        //TODO: Remove this when we upgrade to Ext 6 - workaround for the flying combo
        var editor = grid.editingPlugin && grid.editingPlugin.activeEditor;
        if (editor && editor.field instanceof Ext.form.field.Text) {
            var plugin  = editor.editingPlugin,
                record  = plugin.activeRecord,
                column  = plugin.activeColumn,
                view    = grid.view,
                row     = view.getRow(record);

            if (row && record && column && editor.getXY().toString() !== '0,0') {
                var cell = plugin.getCell(record, column);
                if (cell && (editor.getXY() !== cell.getXY())) {
                    editor.realign();
                }
            }
        }
    },

    setupAdditionalBinding: function(win){
        var column, editor;

        column = win.down('#colLotParentLotId');
        if (column) {
            editor = column.getEditor();
        }
        if (editor) {
            editor.forceSelection = false;
        }
    },

    show: function (config) {
        "use strict";

        var me = this,
            win = this.getView();

        if (config) {
            win.show();

            var context = me.setupContext({window: win});

            if (config.action === 'new') {
                context.data.addRecord();
            } else {
                if (config.id) {
                    config.filters = [
                        {
                            column: 'intInventoryReceiptId',
                            value: config.id
                        }
                    ];
                }
                context.data.load({
                    filters: config.filters
                });
            }

            me.setupAdditionalBinding(win);
        }
    },
    onPageChange: function(pagingStatusBar, record, eOpts) {
        var win = pagingStatusBar.up('window');
        var grd = win.down('#grdLotTracking');
        grd.getStore().removeAll();

        var me = win.controller;
        var current = win.viewModel.data.current;
        if (current){
            var ReceiptItems = current.tblICInventoryReceiptItems();

            me.validateWeightLoss(win, ReceiptItems.data.items);
            me.showSummaryTotals(win);
            me.showOtherCharges(win);
        }
    },
    createRecord: function (config, action) {
        var win = config.window;
        win.down("#lblWeightLossMsgValue").setText("");
        win.down("#lblWeightLossMsg").setText("Wgt or Vol Gain/Loss: ");
        var today = new Date();
        var record = Ext.create('Inventory.model.Receipt');
        var defaultReceiptType = i21.ModuleMgr.Inventory.getCompanyPreference('strReceiptType');
        var defaultSourceType = i21.ModuleMgr.Inventory.getCompanyPreference('intReceiptSourceType');
        
        if(defaultReceiptType !== null) {
            record.set('strReceiptType', defaultReceiptType);
        }
            else {
                record.set('strReceiptType', 'Purchase Order');
            }
        
        if(defaultSourceType !== null) {
            record.set('intSourceType', defaultSourceType);
        }
            else {
                record.set('intSourceType', 0);
            }
        
        if (app.DefaultLocation > 0)
            record.set('intLocationId', app.DefaultLocation);
        if (iRely.config.Security.EntityId > 0)
            record.set('intReceiverId', iRely.config.Security.EntityId);
        record.set('dtmReceiptDate', today);
        record.set('intBlanketRelease', 0);
        record.set('ysnPosted', false);
        action(record);
    },

    onLotCreateRecord: function (config, action) {
        var win = config.grid.up('window');
        var current = win.viewModel.data.current;
        var currentReceiptItem = win.viewModel.data.currentReceiptItem;
        var record = Ext.create('Inventory.model.ReceiptItemLot');
        var me = win.controller;

        record.set('strUnitMeasure', currentReceiptItem.get('strUnitMeasure'));
        record.set('intItemUnitMeasureId', currentReceiptItem.get('intUnitMeasureId'));
        record.set('dblLotUOMConvFactor', currentReceiptItem.get('dblItemUOMConvFactor'));
        record.set('strWeightUOM', currentReceiptItem.get('strWeightUOM'));
        record.set('intStorageLocationId', currentReceiptItem.get('intStorageLocationId'));
        record.set('strStorageLocation', currentReceiptItem.get('strStorageLocationName'));
        record.set('dblGrossWeight', 0.00);
        record.set('dblTareWeight', 0.00);
        record.set('dblNetWeight', 0.00);
        record.set('dblQuantity', config.dummy.get('dblQuantity'));

        //Expiry Date Calculation
        var receiptDate = current.get('dtmReceiptDate');
        var lifetime = currentReceiptItem.get('intLifeTime');
        var lifetimeType = currentReceiptItem.get('strLifeTimeType');
        var expiryDate = i21.ModuleMgr.Inventory.computeDateAdd(receiptDate, lifetime, lifetimeType);
        record.set('dtmExpiryDate', expiryDate);

        var qty = config.dummy.get('dblQuantity');
        var lotCF = currentReceiptItem.get('dblItemUOMConvFactor');
        var itemUOMCF = currentReceiptItem.get('dblItemUOMConvFactor');
        var weightCF = currentReceiptItem.get('dblWeightUOMConvFactor');

        if (iRely.Functions.isEmpty(qty)) qty = 0.00;
        if (iRely.Functions.isEmpty(lotCF)) lotCF = 0.00;
        if (iRely.Functions.isEmpty(itemUOMCF)) itemUOMCF = 0.00;
        if (iRely.Functions.isEmpty(weightCF)) weightCF = 0.00;

        if (!iRely.Functions.isEmpty(currentReceiptItem.get('strContainer'))) {
            record.set('strContainerNo', currentReceiptItem.get('strContainer'));
        }

        // If there is a Gross/Net UOM, pre-calculate the lot gross and net
        if (!iRely.Functions.isEmpty(currentReceiptItem.get('intWeightUOMId'))){
            // Get the current gross.
            var grossQty = record.get('dblGrossWeight');
            grossQty = Ext.isNumeric(grossQty) ? grossQty : 0.00;

            // If current gross is zero, do the pre-calculation.
            if (grossQty == 0){

                if (lotCF === weightCF) {
                    grossQty = qty;
                }
                else if (weightCF !== 0){
                    //grossQty = (lotCF * qty) / weightCF;
                    grossQty = me.convertQtyBetweenUOM(lotCF, weightCF, qty);
                }

            }
            record.set('dblGrossWeight', grossQty);

            // Calculate the net qty
            var tare = record.get('dblTareWeight');
            tare = Ext.isNumeric(tare) ? tare : 0.00;
            grossQty = Ext.isNumeric(grossQty) ? grossQty : 0.00;
            record.set('dblNetWeight', grossQty - tare);
        }

        action(record);
    },

    onChargeCreateRecord: function (config, action) {
        var win = config.grid.up('window');
        //var current = win.viewModel.data.current;
        //var currentCharge = win.viewModel.data.currentReceiptCharge;
        var record = Ext.create('Inventory.model.ReceiptCharge');
        record.set('strAllocateCostBy', 'Unit');

        action(record);
    },

    validateRecord: function (config, action) {
        this.validateRecord(config, function (result) {
            if (result) {
                var controller = config.window.controller;
                var vm = config.window.viewModel;
                var current = vm.data.current;

                if (current) {
                    //Validate Unit Cost in not zero
                    if (current.get('strReceiptType') !== 'Purchase Contract') {
                        var receiptItems = current.tblICInventoryReceiptItems().data.items;
                        var exists = Ext.Array.findBy(receiptItems, function (item) {
                            if (item.get('dblUnitCost') === 0 && item.dummy !== true) {
                                return true;
                            }
                        });

                        var result = function (button) {
                            if (button === 'yes') {
                                if (controller.validateDate(current)) {
                                    action(true);
                                }
                                else {
                                    action(false);
                                }
                            }
                        };

                        if (exists) {
                            var msgBox = iRely.Functions;
                            msgBox.showCustomDialog(
                                msgBox.dialogType.WARNING,
                                msgBox.dialogButtonType.YESNO,
                                exists.get('strItemNo') + " has zero cost. Do you want to continue?",
                                result
                            );
                        }
                        else {
                            action(true);
                        }
                    }
                    else {
                        if (controller.validateDate(current)) {
                            action(true);
                        }
                        else {
                            action(false);
                        }
                    }
                }
                else {
                    action(true)
                }
            }
        });
    },

    validateDate: function (current) {
        //Validate PO Date versus Receipt Date
        if (current.get('strReceiptType') === 'Purchase Order') {
            var receiptItems = current.tblICInventoryReceiptItems().data.items;
            Ext.Array.each(receiptItems, function (item) {
                if (item.dtmDate !== null) {
                    if (current.get('dtmReceiptDate') < item.get('dtmOrderDate')) {
                        iRely.Functions.showErrorDialog('The Purchase Order Date of ' + item.get('strOrderNumber') + ' must not be later than the Receipt Date');
                        return false;
                    }
                }
            });
        }
        return true;
    },

    onCurrencySelect: function (combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var current = win.viewModel.data.current;

        if (current) {
            var subCurrencyCents = records[0].get('intSubCurrencyCent');
            subCurrencyCents = subCurrencyCents && Ext.isNumeric(subCurrencyCents) && subCurrencyCents > 0 ? subCurrencyCents : 1;
            current.set('intSubCurrencyCents', subCurrencyCents);
        }
    },


    onVendorSelect: function (combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var current = win.viewModel.data.current;

        if (current) {
            current.set('strVendorName', records[0].get('strName'));
            current.set('intVendorEntityId', records[0].get('intEntityVendorId'));
            current.set('intCurrencyId', records[0].get('intCurrencyId'));

            var subCurrencyCents =  records[0].get('intSubCurrencyCent');
            subCurrencyCents = subCurrencyCents && Ext.isNumeric(subCurrencyCents) && subCurrencyCents > 0 ? subCurrencyCents : 1;
            current.set('intSubCurrencyCents', subCurrencyCents);

            current.set('intShipFromId', null);
            current.set('intShipViaId', null);

            current.set('intShipFromId', records[0].get('intDefaultLocationId'));

            var vendorLocation = records[0].getDefaultLocation();
            if (vendorLocation) {
                current.set('intShipViaId', vendorLocation.get('intShipViaId'));
                current.set('intTaxGroupId', vendorLocation.get('intTaxGroupId'));
            }
        }

        var isHidden = true;
        switch (current.get('strReceiptType')) {
            case 'Purchase Contract':
                switch (current.get('intSourceType')) {
                    case 0:
                    case 2:
                        if (iRely.Functions.isEmpty(current.get('intEntityVendorId'))) {
                            isHidden = true;
                        }
                        else {
                            isHidden = false;
                        }
                        break;
                    default:
                        isHidden = true;
                        break;
                }
                break;
            case 'Purchase Order':
                if (iRely.Functions.isEmpty(current.get('intEntityVendorId'))) {
                    isHidden = true;
                }
                else {
                    isHidden = false;
                }
                break;
            case 'Transfer Order':
                if (iRely.Functions.isEmpty(current.get('intTransferorId'))) {
                    isHidden = true;
                }
                else {
                    isHidden = false;
                }
                break;
            default :
                isHidden = true;
                break;
        }
        if (isHidden === false) {
            this.showAddOrders(win);
        }
    },

    onLocationSelect: function (combo, records, eOpts) {
        var win = combo.up('window');
        var current = win.viewModel.data.current;
        var me = this;
        var grdInventoryReceiptCount = 0;
        
        if (current) {
            if (current.tblICInventoryReceiptItems()) {
                Ext.Array.each(current.tblICInventoryReceiptItems().data.items, function(row) {
                    if (!row.dummy) {
                        grdInventoryReceiptCount++;
                    }
                });
            }
            
            if(Inventory.view.InventoryReceiptViewController.orgValueLocation !== current.get('intLocationId')) {
                        var buttonAction = function(button) {
                            if (button === 'yes') {  
                                //Remove all Sub and Storage Locations Receipt Grid                   
                                var receiptItems = current['tblICInventoryReceiptItems'](),
                                    receiptItemRecords = receiptItems ? receiptItems.getRange() : [];

                                 var i = receiptItemRecords.length - 1;

                                  for (; i >= 0; i--) {
                                      if (!receiptItemRecords[i].dummy) {
                                          receiptItemRecords[i].set('intStorageLocationId', null);
                                          receiptItemRecords[i].set('strStorageLocationName', null);
                                          receiptItemRecords[i].set('intSubLocationId', null);
                                          receiptItemRecords[i].set('strSubLocationName', null);
                                      }

                                    //Remove all Storage Locations in Lot Grid
                                    var currentReceiptItem = receiptItemRecords[i];
                                    var receiptItemLots = currentReceiptItem['tblICInventoryReceiptItemLots'](),
                                        receiptItemLotRecords = receiptItemLots ? receiptItemLots.getRange() : [];

                                        var li = receiptItemLotRecords.length - 1;

                                      for (; li >= 0; li--) {
                                          if (!receiptItemLotRecords[li].dummy)
                                          receiptItemLotRecords[li].set('intStorageLocationId', null);
                                          receiptItemLotRecords[li].set('strStorageLocation', null);
                                      }
                                  }
                                 current.set('strLocationName', records[0].get('strLocationName'));
                                
                                current.set('intTaxGroupId', records[0].get('intTaxGroupId'));
                                if (current.tblICInventoryReceiptItems()) {
                                    Ext.Array.each(current.tblICInventoryReceiptItems().data.items, function (item) {
                                        current.currentReceiptItem = item;
                                        me.calculateItemTaxes();
                                    });
                                }
                            }
                            else {
                               current.set('intLocationId', Inventory.view.InventoryReceiptViewController.orgValueLocation);
                            }
                        };
                        
                        if(grdInventoryReceiptCount > 0) {
                                iRely.Functions.showCustomDialog('question', 'yesno', 'Changing Location will clear ALL Sub Locations and Storage Locations. Do you want to continue?', buttonAction);
                            }
                        else {
                            current.set('strLocationName', records[0].get('strLocationName'));
                        }
            }
                
        }
    },

    onTransferorSelect: function (combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var current = win.viewModel.data.current;
        var isHidden = true;
        switch (current.get('strReceiptType')) {
            case 'Transfer Order':
                if (iRely.Functions.isEmpty(current.get('intTransferorId'))) {
                    isHidden = true;
                }
                else {
                    isHidden = false;
                }
                break;
            default :
                isHidden = true;
                break;
        }
        if (isHidden === false) {
            this.showAddOrders(win);
        }
    },

    onFreightTermSelect: function (combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var current = win.viewModel.data.current;

        if (current) current.set('strFobPoint', records[0].get('strFobPoint'));

        // Calculate the taxes
        this.calculateItemTaxes();
    },

    onReceiptItemSelect: function (combo, records, eOpts) {
        var me = this;

        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var grid = combo.up('grid');
        var cboCurrency = win.down('#cboCurrency');

        var plugin = grid.getPlugin('cepItem');
        var current = plugin.getActiveRecord();

        if (combo.itemId === 'cboItem') {
            current.set('intItemId', records[0].get('intItemId'));
            current.set('strItemDescription', records[0].get('strDescription'));
            current.set('strLotTracking', records[0].get('strLotTracking'));
            current.set('intUnitMeasureId', records[0].get('intReceiveUOMId'));
            current.set('strUnitMeasure', records[0].get('strReceiveUOM'));
            current.set('intCostUOMId', records[0].get('intReceiveUOMId'));
            current.set('strCostUOM', records[0].get('strReceiveUOM'));
            current.set('dblUnitCost', records[0].get('dblLastCost'));
            current.set('dblUnitRetail', records[0].get('dblLastCost'));
            current.set('dblItemUOMConvFactor', records[0].get('dblReceiveUOMConvFactor'));
            current.set('dblCostUOMConvFactor', records[0].get('dblReceiveUOMConvFactor'));
            current.set('strUnitType', records[0].get('strReceiveUOMType'));
            current.set('intCommodityId', records[0].get('intCommodityId'));
            current.set('intOwnershipType', 1);
            current.set('strOwnershipType', 'Own');
            current.set('intLifeTime', records[0].get('intLifeTime'));
            current.set('strLifeTimeType', records[0].get('strLifeTimeType'));
            current.set('intSubLocationId', records[0].get('intSubLocationId'));
            current.set('strSubLocationName', records[0].get('strSubLocationName'));
            current.set('intStorageLocationId', records[0].get('intStorageLocationId'));
            current.set('strStorageLocationName', records[0].get('strStorageLocationName'));
            current.set('strSubCurrency', cboCurrency.getDisplayValue());

            var intUOM = null;
            var strUOM = '';
            var strWeightUOM = '';
            var dblLotUOMConvFactor = 0;

            if (records[0].get('strReceiveUOMType') === 'Weight') {
                intUOM = records[0].get('intReceiveUOMId');
                strUOM = records[0].get('strReceiveUOM');
                strWeightUOM = records[0].get('strReceiveUOM');
                dblLotUOMConvFactor = records[0].get('dblReceiveUOMConvFactor');
                current.set('intWeightUOMId', intUOM);
                current.set('strWeightUOM', strUOM);
                current.set('dblWeightUOMConvFactor', records[0].get('dblReceiveUOMConvFactor'));
            }
            else if (records[0].get('strStockUOMType') === 'Weight') {
                intUOM = records[0].get('intStockUOMId');
                strUOM = records[0].get('strStockUOM');
                strWeightUOM = records[0].get('strStockUOM');
                dblLotUOMConvFactor = 1;
                current.set('intWeightUOMId', intUOM);
                current.set('strWeightUOM', strUOM);
                current.set('dblWeightUOMConvFactor', 1);
            }
            else {
                intUOM = records[0].get('intReceiveUOMId');
                strUOM = records[0].get('strReceiveUOM');
                strWeightUOM = '';
                dblLotUOMConvFactor = 0;
                current.set('dblWeightUOMConvFactor', 0);
            }

            if (records[0].get('strLotTracking') === 'No') {
                current.set('intWeightUOMId', null);
                current.set('strWeightUOM', null);
            }

            var receiptDate = win.viewModel.data.current.get('dtmReceiptDate');
            var lifetime = current.get('intLifeTime');
            var lifetimeType = current.get('strLifeTimeType');
            var expiryDate = i21.ModuleMgr.Inventory.computeDateAdd(receiptDate, lifetime, lifetimeType);

          /*  switch (records[0].get('strLotTracking')) {
                case 'Yes - Serial Number':
                case 'Yes - Manual':
                    var newLot = Ext.create('Inventory.model.ReceiptItemLot', {
                        intInventoryReceiptItemId: current.get('intInventoryReceiptItemId') || current.get('strClientId'),
                        strLotId: '',
                        strContainerNo: '',
                        intItemUnitMeasureId: intUOM,
                        strUnitMeasure: strUOM,
                        strWeightUOM: strWeightUOM,
                        dblLotUOMConvFactor: dblLotUOMConvFactor,
                        dblQuantity: '',
                        intUnitPallet: '',
                        dblGrossWeight: '',
                        dblTareWeight: '',
                        dblStatedGrossPerUnit: '',
                        dblStatedTarePerUnit: '',
                        intStorageLocationId: current.get('intStorageLocationId'),
                        strStorageLocation: current.get('strStorageLocationName'),
                        dtmExpiryDate: expiryDate
                    });
                    //current.tblICInventoryReceiptItemLots().store.load();
                    current.tblICInventoryReceiptItemLots().add(newLot);
                    break;
            }*/
        }
        else if (combo.itemId === 'cboItemUOM') {
            current.set('intUnitMeasureId', records[0].get('intItemUnitMeasureId'));
            current.set('dblItemUOMConvFactor', records[0].get('dblUnitQty'));
            current.set('strUnitType', records[0].get('strUnitType'));
            
            if(current.get('dblWeightUOMConvFactor') === 0)
                {
                   current.set('dblWeightUOMConvFactor', records[0].get('dblUnitQty')); 
                }

            var origCF = current.get('dblOrderUOMConvFactor');
            var newCF = current.get('dblItemUOMConvFactor');
            var received = current.get('dblReceived');
            var ordered = current.get('dblOrderQty');
            var qtyToReceive = ordered - received;
            if (origCF > 0 && newCF > 0) {
                //qtyToReceive = (qtyToReceive * origCF) / newCF;
                qtyToReceive = me.convertQtyBetweenUOM(origCF, newCF, qtyToReceive);
                current.set('dblOpenReceive', qtyToReceive);
            }

            //current.tblICInventoryReceiptItemLots().store.load();

            if (current.tblICInventoryReceiptItemLots()) {
                Ext.Array.each(current.tblICInventoryReceiptItemLots().data.items, function (lot) {
                    if (!lot.dummy) {
                        //Set Default Value for Lot Wgt UOM 
                        if(lot.get('strWeightUOM') === null || lot.get('strWeightUOM') === '')
                            {
                                lot.set('strWeightUOM', records[0].get('strUnitMeasure'));
                                lot.set('dblLotUOMConvFactor', records[0].get('dblUnitQty'));
                            }
                    }
                });
            }

            if (iRely.Functions.isEmpty(current.get('intCostUOMId'))) {
                current.set('intCostUOMId', records[0].get('intItemUnitMeasureId'));
                current.set('dblCostUOMConvFactor', records[0].get('dblUnitQty'));
                current.set('strCostUOM', records[0].get('strUnitMeasure'));

                var dblCost = records[0].get('dblLastCost');
                if (win.viewModel.data.current.get('strReceiptType') === 'Purchase Contract') {
                    dblCost = current.get('dblUnitCost');
                    if (current.get('strOrderUOM') !== records[0].get('strUnitMeasure')) {
                        var orderUOMCF = current.get('dblOrderUOMConvFactor');
                        var receiptUOMCF = records[0].get('dblUnitQty');
                        if (orderUOMCF !== receiptUOMCF) {
                            var currentCost = current.get('dblUnitCost');
                            var perUnitCost = currentCost / orderUOMCF;
                            dblCost = perUnitCost * receiptUOMCF;
                        }
                    }
                }
                current.set('dblUnitCost', dblCost);
                current.set('dblUnitRetail', dblCost);
            }
            
            //Set Default Value for Gross/Net UOM if Receipt Unit Type is Weight or Volume and Gross/Net UOM has no current value
            if ((records[0].get('strUnitType') === 'Weight' || records[0].get('strUnitType') === 'Volume') && 
                (current.get('strWeightUOM') === null || current.get('strWeightUOM') === ''))
                {
                    current.set('strWeightUOM', records[0].get('strUnitMeasure'));
                    current.set('intWeightUOMId', records[0].get('intItemUnitMeasureId'));
                }
        }
        else if (combo.itemId === 'cboWeightUOM') {
            current.set('dblWeightUOMConvFactor', records[0].get('dblUnitQty'));
            //current.tblICInventoryReceiptItemLots().store.load();
            if (current.tblICInventoryReceiptItemLots()) {
                Ext.Array.each(current.tblICInventoryReceiptItemLots().data.items, function (lot) {
                    if (!lot.dummy) {
                        lot.set('strWeightUOM', records[0].get('strUnitMeasure'));
                    }
                });
            }
        }
        else if (combo.itemId === 'cboCostUOM') {
            current.set('dblCostUOMConvFactor', records[0].get('dblUnitQty'));
            current.set('dblUnitCost', records[0].get('dblLastCost'));
        }
        else if (combo.itemId === 'cboStorageLocation') {
            if (current.get('intSubLocationId') !== records[0].get('intSubLocationId')) {
                current.set('intSubLocationId', records[0].get('intSubLocationId'));
                current.set('strSubLocationName', records[0].get('strSubLocationName'));
            }
            //current.tblICInventoryReceiptItemLots().store.load();
            var lots = current.tblICInventoryReceiptItemLots();

            if (lots) {
                Ext.Array.each(lots.data.items, function (lot) {
                    if (!lot.dummy) {
                        lot.set('intStorageLocationId', records[0].get('intStorageLocationId'));
                        lot.set('strStorageLocation', records[0].get('strName'));
                    }
                });
            }
        }

        this.calculateGrossNet(current, 1);
        win.viewModel.data.currentReceiptItem = current;
        this.calculateItemTaxes();
        
        //Calculate Line Total
        var currentReceiptItem = win.viewModel.data.currentReceiptItem;
        var currentReceipt  = win.viewModel.data.current;
        currentReceiptItem.set('dblLineTotal', this.calculateLineTotal(currentReceipt, currentReceiptItem));

        var pnlLotTracking = win.down("#pnlLotTracking");

        if (current.get('strLotTracking') === 'Yes - Serial Number' || current.get('strLotTracking') === 'Yes - Manual') {
            pnlLotTracking.setVisible(true);
        } else {
            pnlLotTracking.setVisible(false);
        }
    },

    calculateItemTaxes: function (reset) {
        var me = this;
        var win = me.getView();
        var masterRecord = win.viewModel.data.current;
        var detailRecord = win.viewModel.data.currentReceiptItem;

        if (!masterRecord) return;
        if (!detailRecord) return;
        if (iRely.Functions.isEmpty(detailRecord.get('intItemId'))) return;

        if (reset !== false) reset = true;

        if (detailRecord) {
            var current = {
                ItemId: detailRecord.get('intItemId'),
                TransactionDate: masterRecord.get('dtmReceiptDate'),
                LocationId: masterRecord.get('intLocationId'),
                TransactionType: 'Purchase',
                TaxGroupId: masterRecord.get('intTaxGroupId'),
                EntityId: masterRecord.get('intEntityVendorId'),
                BillShipToLocationId: masterRecord.get('intShipFromId'),
                FreightTermId: masterRecord.get('intFreightTermId')
            };

            if (reset)
                iRely.Functions.getItemTaxes(current, me.computeItemTax, me);
            else {
                var receiptItemTaxes = detailRecord.tblICInventoryReceiptItemTaxes();
                if (receiptItemTaxes) {
                    if (receiptItemTaxes.data.items.length > 0) {
                        var ItemTaxes = new Array();
                        Ext.Array.each(receiptItemTaxes.data.items, function (itemDetailTax) {
                            var taxes = {
                                intTaxGroupMasterId: itemDetailTax.get('intTaxGroupMasterId'),
                                intTaxGroupId: itemDetailTax.get('intTaxGroupId'),
                                intTaxCodeId: itemDetailTax.get('intTaxCodeId'),
                                intTaxClassId: itemDetailTax.get('intTaxClassId'),
                                strTaxCode: itemDetailTax.get('strTaxCode'),
                                strTaxableByOtherTaxes: itemDetailTax.get('strTaxableByOtherTaxes'),
                                strCalculationMethod: itemDetailTax.get('strCalculationMethod'),
                                dblRate: itemDetailTax.get('dblRate'),
                                dblTax: itemDetailTax.get('dblTax'),
                                dblAdjustedTax: itemDetailTax.get('dblAdjustedTax'),
                                intTaxAccountId: itemDetailTax.get('intTaxAccountId'),
                                ysnTaxAdjusted: itemDetailTax.get('ysnTaxAdjusted'),
                                ysnSeparateOnInvoice: itemDetailTax.get('ysnSeparateOnInvoice'),
                                ysnCheckoffTax: itemDetailTax.get('ysnCheckoffTax')
                            };
                            ItemTaxes.push(taxes);
                        });

                        me.computeItemTax(ItemTaxes, me, reset);
                    }
                    else {
                        iRely.Functions.getItemTaxes(current, me.computeItemTax, me);
                    }
                }
            }
        }
    },

    computeItemTax: function (itemTaxes, me, reset) {
        var win = me.getView();
        var currentReceipt  = win.viewModel.data.current;
        var currentReceiptItem = win.viewModel.data.currentReceiptItem;

        if (!currentReceiptItem) {
            return;
        }

        var totalItemTax = 0.00,
            qtyOrdered = currentReceiptItem.get('dblOpenReceive'),
            unitCost = currentReceiptItem.get('dblUnitCost');

        if (reset !== false) reset = true;

        // Adjust the item price by the sub currency
        {
            var isSubCurrency = currentReceiptItem.get('ysnSubCurrency');
            var costCentsFactor = currentReceipt.get('intSubCurrencyCents');

            // sanitize the value for the sub currency.
            costCentsFactor = Ext.isNumeric(costCentsFactor) && costCentsFactor != 0 ? costCentsFactor : 1;

            // check if there is a need to compute for the sub currency.
            if (!isSubCurrency) {
                costCentsFactor = 1;
            }

            unitCost = unitCost / costCentsFactor;
        }

        currentReceiptItem.tblICInventoryReceiptItemTaxes().removeAll();

        Ext.Array.each(itemTaxes, function (itemDetailTax) {
            var taxableAmount,
                taxAmount;
               

            taxableAmount = me.getTaxableAmount(qtyOrdered, unitCost, itemDetailTax, itemTaxes);
            if (itemDetailTax.strCalculationMethod === 'Percentage') {
                taxAmount = (taxableAmount * (itemDetailTax.dblRate / 100));
            } else {
                taxAmount = qtyOrdered * itemDetailTax.dblRate;
            }

            if (itemDetailTax.ysnCheckoffTax){
                taxAmount = taxAmount * -1;
            }

            taxAmount = i21.ModuleMgr.Inventory.roundDecimalFormat(taxAmount, 2);

            if (itemDetailTax.dblTax === itemDetailTax.dblAdjustedTax && !itemDetailTax.ysnTaxAdjusted) {
                if (itemDetailTax.ysnTaxExempt)
                    taxAmount = 0.00;
                itemDetailTax.dblTax = taxAmount;
                itemDetailTax.dblAdjustedTax = taxAmount;
            }
            else {
                itemDetailTax.dblTax = taxAmount;
                itemDetailTax.dblAdjustedTax = itemDetailTax.dblAdjustedTax;
                itemDetailTax.ysnTaxAdjusted = true;
            }
            totalItemTax = totalItemTax + itemDetailTax.dblAdjustedTax;

            var newItemTax = Ext.create('Inventory.model.ReceiptItemTax', {
                intTaxGroupMasterId: itemDetailTax.intTaxGroupMasterId,
                intTaxGroupId: itemDetailTax.intTaxGroupId,
                intTaxCodeId: itemDetailTax.intTaxCodeId,
                intTaxClassId: itemDetailTax.intTaxClassId,
                strTaxCode: itemDetailTax.strTaxCode,
                strTaxableByOtherTaxes: itemDetailTax.strTaxableByOtherTaxes,
                strCalculationMethod: itemDetailTax.strCalculationMethod,
                dblRate: itemDetailTax.dblRate,
                dblTax: itemDetailTax.dblTax,
                dblAdjustedTax: itemDetailTax.dblAdjustedTax,
                intTaxAccountId: itemDetailTax.intTaxAccountId,
                ysnTaxAdjusted: itemDetailTax.ysnTaxAdjusted,
                ysnSeparateOnInvoice: itemDetailTax.ysnSeparateOnInvoice,
                ysnCheckoffTax: itemDetailTax.ysnCheckoffTax
            });
            currentReceiptItem.tblICInventoryReceiptItemTaxes().add(newItemTax);
        });

        currentReceiptItem.set('dblTax', totalItemTax);
        currentReceiptItem.set('dblLineTotal', me.calculateLineTotal(currentReceipt, currentReceiptItem));
    },

    calculateLineTotal: function (currentReceipt, currentReceiptItem){
        if (!currentReceipt || !currentReceiptItem)
            return;

        var qty = currentReceiptItem.get('dblOpenReceive');
        var qtyCF = currentReceiptItem.get('dblItemUOMConvFactor');
        var unitCost = currentReceiptItem.get('dblUnitCost');
        var costCF = currentReceiptItem.get('dblCostUOMConvFactor');
        var costCentsFactor = currentReceipt.get('intSubCurrencyCents');
        var tax = currentReceiptItem.get('dblTax');
        var isSubCurrency = currentReceiptItem.get('ysnSubCurrency');
        var lineTotal = 0;

        // sanitize the value for the sub currency.
        costCentsFactor = Ext.isNumeric(costCentsFactor) && costCentsFactor != 0 ? costCentsFactor : 1;

        // check if there is a need to compute for the sub currency.
        if (!isSubCurrency) {
            costCentsFactor = 1;
        }


        // Compute the line total with respect to the Item UOM
        if (iRely.Functions.isEmpty(currentReceiptItem.get('intWeightUOMId'))) {
            // Sanitize the cost conversion factor.
            costCF = Ext.isNumeric(costCF) && costCF != 0 ? costCF : qtyCF;
            costCF = Ext.isNumeric(costCF) && costCF != 0 ? costCF : 1;

            // Formula is:
            // {Sub Cost} = {Unit Cost} / {Sub Currency Cents Factor}
            // {New Cost} = {Sub Cost} x {Item UOM Conv Factor} / {Cost UOM Conv Factor}
            // {Line Total} = ( {Qty in Item UOM} x {New Cost} )
            lineTotal = (qty * (unitCost / costCentsFactor) * (qtyCF / costCF));
        }

        // Compute the line total with respect to the Gross UOM..
        else {
            var netWgt = currentReceiptItem.get('dblNet');
            var netWgtCF = currentReceiptItem.get('dblWeightUOMConvFactor');

            // Sanitize the cost conversion factor.
            costCF = Ext.isNumeric(costCF) && costCF != 0 ? costCF : netWgtCF;
            costCF = Ext.isNumeric(costCF) && costCF != 0 ? costCF : 1;

            // Formula is:
            // {Sub Cost} = {Unit Cost} / {Sub Currency Cents Factor}
            // {New Cost} = {Sub Cost} x {Gross/Net UOM Conv Factor} / {Cost UOM Conv Factor}
            // {Line Total} = ( {Net Qty in Gross/Net UOM} x {New Cost} )
            lineTotal = (netWgt * (unitCost / costCentsFactor) * (netWgtCF / costCF));
        }

        return i21.ModuleMgr.Inventory.roundDecimalFormat(lineTotal, 2)
    },

    showSummaryTotals: function (win) {
        var current = win.viewModel.data.current;
        var lblSubTotal = win.down('#lblSubTotal');
        var lblTax = win.down('#lblTax');
        var lblGrossWgt = win.down('#lblGrossWgt');
        var lblNetWgt = win.down('#lblNetWgt');
        var lblTotal = win.down('#lblTotal');

        var totalAmount = 0;
        var totalTax = 0;
        var totalGross = 0;
        var totalNet = 0;
        if (current) {
            var items = current.tblICInventoryReceiptItems();
            if (items) {
                Ext.Array.each(items.data.items, function (item) {
                    if (!item.dummy) {
                        totalAmount += item.get('dblLineTotal');
                        totalTax += item.get('dblTax');
                        totalGross += item.get('dblGross');
                        totalNet += item.get('dblNet');
                    }
                });
            }
        }
        var totalCharges = this.calculateOtherCharges(win);
        var grandTotal = totalAmount + totalCharges + totalTax;

        lblSubTotal.setText('SubTotal: ' + Ext.util.Format.number(totalAmount, '0,000.00'));
        lblTax.setText('Tax: ' + Ext.util.Format.number(totalTax, '0,000.00'));
        lblGrossWgt.setText('Gross: ' + Ext.util.Format.number(totalGross, '0,000.00'));
        lblNetWgt.setText('Net: ' + Ext.util.Format.number(totalNet, '0,000.00'));
        lblTotal.setText('Total: ' + Ext.util.Format.number(grandTotal, '0,000.00'));
    },

    getTaxableAmount: function (quantity, price, currentItemTax, itemTaxes) {

        var taxableAmount = quantity * price;

        Ext.Array.each(itemTaxes, function (itemDetailTax) {
            if (itemDetailTax.strTaxableByOtherTaxes && itemDetailTax.strTaxableByOtherTaxes !== String.empty) {
                if (itemDetailTax.strTaxableByOtherTaxes.split(",").indexOf(currentItemTax.intTaxClassId.toString()) > -1) {
                    if (itemDetailTax.ysnTaxAdjusted) {
                        taxableAmount = (quantity * price) + (itemDetailTax.dblAdjustedTax);
                    } else {
                        if (itemDetailTax.strCalculationMethod === 'Percentage') {
                            taxableAmount = (quantity * price) + ((quantity * price) * (itemDetailTax.dblRate / 100));
                        } else {
                            taxableAmount = (quantity * price) + (itemDetailTax.dblRate * quantity);
                        }
                    }
                }
            }
        });

        return taxableAmount;
    },

    calculateOtherCharges: function(win){
        var current = win.viewModel.data.current;
        var totalCharges = 0;
        var lblCharges = win.down('#lblCharges');
        
        if (current) {
            var charges = current.tblICInventoryReceiptCharges();
            if (charges) {
                Ext.Array.each(charges.data.items, function (charge) {
                    if (!charge.dummy) {
                        var amount = charge.get('dblAmount');
                                                
                        if (charge.get('ysnPrice') === true) {
                            totalCharges -= amount;
                        }
                        else {
                            totalCharges += amount;
                        }

                    }
                });
            }
        }
        lblCharges.setText('Charges: ' + Ext.util.Format.number(totalCharges, '0,000.00'));
        return totalCharges;
    },

    showOtherCharges: function (win) {
        var me = this;
        var lblCharges = win.down('#lblCharges');
        var totalCharges = me.calculateOtherCharges(win);

        if (lblCharges) {
            lblCharges.setText('Charges: ' + Ext.util.Format.number(totalCharges, '0,000.00'));
        }

    },
/*
    convertLotUOMToGross: function(lotCF, weightCF, lotQty){
        var result = 0;
        if (lotCF === weightCF) {
            result = lotQty;
        }
        else if (weightCF !== 0){
            result = (lotCF * lotQty) / weightCF;
        }

        return result;
    },*/

    convertQtyBetweenUOM: function(sourceUOMConversionFactor, targetUOMConversionFactor, qty){
        var result = 0;

        if (sourceUOMConversionFactor === targetUOMConversionFactor) {
            result = qty;
        }
        else if (targetUOMConversionFactor !== 0){
            result = (sourceUOMConversionFactor * qty) / targetUOMConversionFactor;
        }

        return result;
    },

    calculateGrossNet: function (record, calculateItemGrossNet) {
        if (!record) return;

        var totalGross = 0
            ,totalNet = 0
            ,lotGross = 0
            ,lotTare = 0
            ,ysnCalculatedInLot = 0
            ,me = this;

        //Calculate based on Lot
        if (record.tblICInventoryReceiptItemLots()) {
            Ext.Array.each(record.tblICInventoryReceiptItemLots().data.items, function (lot) {
                if (!lot.dummy) {
                    // If Gross/Net UOM is blank, do not calculate the lot Gross and Net.
                    if (!iRely.Functions.isEmpty(record.get('intWeightUOMId'))) {
                        if(lot.get('dblQuantity') !== 0 )
                            {
                                //Calculate First Gross and Net for Lots
                                    var lotQty = lot.get('dblQuantity');
                                    var lotCF = lot.get('dblLotUOMConvFactor');
                                    var itemUOMCF = record.get('dblItemUOMConvFactor');
                                    var weightCF = record.get('dblWeightUOMConvFactor');

                                    if (iRely.Functions.isEmpty(lotQty)) lotQty = 0.00;
                                    if (iRely.Functions.isEmpty(lotCF)) lotCF = 0.00;
                                    if (iRely.Functions.isEmpty(itemUOMCF)) itemUOMCF = 0.00;
                                    if (iRely.Functions.isEmpty(weightCF)) weightCF = 0.00;

                                    // If there is no Gross/Net UOM, do not calculate the lot gross and net.
                                    if (record.get('intWeightUOMId') !== null) {
                                        var grossQty;
                                        //Convert Lot UOM to Gross
                                                if (lotCF === weightCF) {
                                                        grossQty = lotQty;
                                                }
                                                else if (weightCF !== 0){
                                                        //grossQty = (lotCF * lotQty) / weightCF;
                                                        grossQty = me.convertQtyBetweenUOM(lotCF, weightCF, lotQty);
                                                }
                                        
                                        lot.set('dblGrossWeight', grossQty);
                                        var tare = lot.get('dblTareWeight');
                                        var netTotal = grossQty - tare;
                                        lot.set('dblNetWeight', netTotal);
                                    }

                                    //Set Default Value for Lot UOM
                                    if(lot.get('strUnitMeasure') === null || lot.get('strUnitMeasure') === '') {
                                            lot.set('strUnitMeasure', record.get('strUnitMeasure'));
                                            lot.set('intItemUnitMeasureId', record.get('intItemUnitMeasureId'));
                                        } 
                                
                                 // Get the Gross Qty
                                lotGross = lot.get('dblGrossWeight');
                                lotGross = Ext.isNumeric(lotGross) ? lotGross : 0.00;

                                // Get the Tare Qty
                                lotTare = lot.get('dblTareWeight');
                                lotTare = Ext.isNumeric(lotTare) ? lotTare : 0.00;

                                // Calculate the total Gross and total Net
                                totalGross += lotGross;
                                totalNet += (lotGross - lotTare);
                                ysnCalculatedInLot = 1;
                            }
                    }
                }
            });
        }
        
        if(ysnCalculatedInLot === 1) {
            if (record.get('dblGross') === 0 && record.get('dblNet') === 0) {
                record.set('dblGross', totalGross);
                record.set('dblNet', totalNet);
            }
            else {
                //Gross Net is not calculated based on Lot
                ysnCalculatedInLot = 0;
            }
        }
            
        
        //Use this to calculate item's Gross/Net based on item grid
        if(ysnCalculatedInLot === 0 && calculateItemGrossNet === 1)
            {
                 var receiptItemQty = record.get('dblOpenReceive');
                 var receiptUOMCF = record.get('dblItemUOMConvFactor');
                 var weightUOMCF = record.get('dblWeightUOMConvFactor');

                 if (iRely.Functions.isEmpty(receiptItemQty)) receiptItemQty = 0.00;
                 if (iRely.Functions.isEmpty(receiptUOMCF)) receiptUOMCF = 0.00;
                 if (iRely.Functions.isEmpty(weightUOMCF)) weightUOMCF = 0.00;

                 // If there is not Gross/Net UOM, do not calculate the lot gross and net.
                 if (record.get('intWeightUOMId') === null || record.get('intWeightUOMId') === '') {
                    totalGross = 0;
                 }
                else {
                    //totalGross = (receiptItemQty * receiptUOMCF) / weightUOMCF; // TODO: fix this part
                    totalGross = me.convertQtyBetweenUOM(receiptUOMCF, weightUOMCF, receiptItemQty);
                 }    
                totalNet = totalGross;
                
                record.set('dblGross', totalGross);
                record.set('dblNet', totalNet);
            }
    },

    onViewReceiptNo: function (value, record) {
        i21.ModuleMgr.Inventory.showScreen(value, 'ReceiptNo');
    },

    onViewVoucher: function (value, record) {
        if (value === 'New Voucher') {
            iRely.Functions.openScreen('AccountsPayable.view.Voucher', {
                action: 'new',
                showAddReceipt: false
            });
        }
        else {
            iRely.Functions.openScreen('AccountsPayable.view.Voucher', {
                filters: [
                    {
                        column: 'strBillId',
                        value: value
                    }
                ],
                action: 'view',
                showAddReceipt: false
            });
        }
    },

    onViewVendorName: function (value, record) {
        i21.ModuleMgr.Inventory.showScreen(value, 'VendorName');
    },

    onViewLocationName: function (value, record) {
        i21.ModuleMgr.Inventory.showScreen(value, 'LocationName');
    },

    onViewItemNo: function (value, record) {
        var itemId = record.get('intItemId');
        i21.ModuleMgr.Inventory.showScreen(itemId, 'ItemId');
    },

    onItemHeaderClick: function(menu, column) {
       // var grid = column.initOwnerCt.grid; 
         var grid = column.$initParent.grid;

        if (grid.itemId === 'grdInventoryReceipt') {
            i21.ModuleMgr.Inventory.showScreenFromHeaderDrilldown('Inventory.view.Item', grid, 'intItemId');
        }
        else {
            i21.ModuleMgr.Inventory.showScreenFromHeaderDrilldown('Inventory.view.Item', grid, 'intChargeId');
        }
    },

    onVendorHeaderClick: function (menu, column) {
       // var grid = column.initOwnerCt.grid;
        var grid = column.$initParent.grid;
        
        if (grid.itemId === 'grdCharges') 
            {
                var selectedObj = grid.getSelectionModel().getSelection();
                var vendorId = '';

                if(selectedObj.length == 0)
                    {
                        iRely.Functions.openScreen('EntityManagement.view.Entity:searchEntityVendor', { action: 'new',  viewConfig: { modal: true }}); 
                    }
                
                else
                    {
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
        if (grid.itemId === 'grdCharges') 
            {
                var selectedObj = grid.getSelectionModel().getSelection();
                var vendorId = '';

                if(selectedObj.length == 0)
                    {
                        iRely.Functions.openScreen('EntityManagement.view.Entity:searchEntityVendor', { action: 'new',  viewConfig: { modal: true }}); 
                    }
                
                else
                    {
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

    onViewTaxDetailsClick: function (ReceiptItemId) {
        var win = this.getView();
        var screenName = 'Inventory.view.InventoryReceiptTaxes';
        var grd = win.down('#grdInventoryReceipt');
        var vm = win.getViewModel();

        if (vm.data.current.phantom === true) {
            win.context.data.saveRecord({ callbackFn: function (batch, eOpts, success) {
                iRely.Functions.openScreen(screenName, {
                    id: grd.getSelection()[0].data.intInventoryReceiptItemId
                });
                return;
            } });
        }
        else if (win.context.data.hasChanges() !== true) {
            iRely.Functions.openScreen(screenName, {
                id: ReceiptItemId
            });
        }
        else {
            win.context.data.validator.validateRecord({ window: win }, function (valid) {
                if (valid) {
                    win.context.data.saveRecord({ callbackFn: function (batch, eOpts, success) {
                        iRely.Functions.openScreen(screenName, {
                            id: grd.getSelection()[0].data.intInventoryReceiptItemId
                        });
                        return;
                    } });
                }
            });
        }
    },

    onInventoryClick: function (button, e, eOpts) {
        var win = button.up('window');
        var grd = win.down('#grdInventoryReceipt');

        var selected = grd.getSelectionModel().getSelection();

        if (selected) {
            if (selected.length > 0) {
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

    onOtherChargeClick: function (button, e, eOpts) {
        var win = button.up('window');
        var grd = win.down('#grdCharges');

        var selected = grd.getSelectionModel().getSelection();

        if (selected) {
            if (selected.length > 0) {
                var current = selected[0];
                if (!current.dummy)
                    iRely.Functions.openScreen('Inventory.view.Item', current.get('intChargeId'));
            }
            else {
                iRely.Functions.showErrorDialog('Please select an Other Charge to view.');
            }
        }
        else {
            iRely.Functions.showErrorDialog('Please select an Other Charge to view.');
        }
    },

    onQualityClick: function (button, e, eOpts) {
        var win = button.up('window');
        var grd = win.down('#grdInventoryReceipt');
        var selected = grd.getSelectionModel().getSelection();
        
        var win = button.up('window');
        var vm = win.viewModel;
        var currentReceiptItem = vm.data.current;

        if (selected) {
            if (selected.length > 0) {
                var current = selected[0];
                if (!current.dummy)
                    if(currentReceiptItem.get('ysnPosted') === true)
                        {
                            iRely.Functions.openScreen('Grain.view.QualityTicketDiscount', 
                                { 
                                    strSourceType: 'Inventory Receipt', 
                                    intTicketFileId: current.get('intInventoryReceiptItemId'),
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
                            iRely.Functions.openScreen('Grain.view.QualityTicketDiscount', { strSourceType: 'Inventory Receipt', intTicketFileId: current.get('intInventoryReceiptItemId') });
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

    onTaxDetailsClick: function (button, e, eOpts) {
        var win = button.up('window');
        var grd = win.down('#grdInventoryReceipt');

        var selected = grd.getSelectionModel().getSelection();

        if (selected) {
            if (selected.length > 0) {
                var current = selected[0];
                if (!current.dummy)
                    this.onViewTaxDetailsClick(current.get('intInventoryReceiptItemId'));
            }
            else {
                iRely.Functions.showErrorDialog('Please select an Item to view.');
            }
        }
        else {
            iRely.Functions.showErrorDialog('Please select an Item to view.');
        }
    },

    onInsertChargeClick: function (button, e, eOpts) {
        var grd = button.up('grid');
        if (grd) {
            grd.startAdd();
        }
    },

    onShowOtherChargesClick: function (button, e, eOpts) {
        var win = button.up('window');
        var context = win.context;
        var current = win.viewModel.data.current;

        var doPost = function () {
            if (current) {
                Ext.Ajax.request({
                    timeout: 120000,
                    url: '../Inventory/api/InventoryReceipt/showOtherCharges?id=' + current.get('intInventoryReceiptId'),
                    method: 'post',
                    success: function (response) {
                        var jsonData = Ext.decode(response.responseText);
                        if (!jsonData.success) {
                            iRely.Functions.showErrorDialog(jsonData.message.statusText);
                        }
                        else {
                            context.configuration.paging.store.load();
                        }
                    },
                    failure: function (response) {
                        var jsonData = Ext.decode(response.responseText);
                        iRely.Functions.showErrorDialog(jsonData.ExceptionMessage);
                    }
                });
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

    onBillClick: function (button, e, eOpts) {
        var win = button.up('window');
        var current = win.viewModel.data.current;

        if (current) {
            Ext.Ajax.request({
                timeout: 120000,
                url: '../Inventory/api/InventoryReceipt/ProcessBill?id=' + current.get('intInventoryReceiptId'),
                method: 'post',
                success: function (response) {
                    var jsonData = Ext.decode(response.responseText);
                    if (jsonData.success) {
                        var buttonAction = function (button) {
                            if (button === 'yes') {
                                iRely.Functions.openScreen('AccountsPayable.view.Voucher', {
                                    filters: [
                                        {
                                            column: 'intBillId',
                                            value: jsonData.message.BillId
                                        }
                                    ],
                                    action: 'view',
                                    showAddReceipt: false
                                });
                                win.close();
                            }
                        };
                        iRely.Functions.showCustomDialog('question', 'yesno', 'Voucher successfully processed. Do you want to view this voucher?', buttonAction);
                    }
                    else {
                        iRely.Functions.showErrorDialog(jsonData.message.statusText);
                    }
                },
                failure: function (response) {
                    var jsonData = Ext.decode(response.responseText);
                    iRely.Functions.showErrorDialog(jsonData.ExceptionMessage);
                }
            });
        }
    },

    onVendorClick: function (button, e, eOpts) {
        var win = button.up('window');
        var current = win.viewModel.data.current;

        if (current.get('intEntityVendorId') !== null) {
            iRely.Functions.openScreen('EntityManagement.view.Entity:searchEntityVendor', {
                filters: [
                    {
                        column: 'intEntityId',
                        value: current.get('intEntityVendorId')
                    }
                ]
            });
        }
        
        else
            {
                iRely.Functions.openScreen('EntityManagement.view.Entity:searchEntityVendor', { action: 'new',  viewConfig: { modal: true }}); 
            }
    },

    onReceiveClick: function (button, e, eOpts) {
        var me = this;
        var win = button.up('window');
        var context = win.context;
        var current = win.viewModel.data.current;
        var btnReceive = win.down('#btnReceive');

        var postReceipt = function() {
            var doPost = function () {
                        var strReceiptNumber = current.get('strReceiptNumber');
                        var posted = current.get('ysnPosted');

                        var options = {
                            postURL: '../Inventory/api/InventoryReceipt/Receive',
                            strTransactionId: strReceiptNumber,
                            isPost: !posted,
                            isRecap: false,
                            callback: me.onAfterReceive,
                            scope: me
                        };

                        CashManagement.common.BusinessRules.callPostRequest(options);
                    };

                    var isValid = true;
                    if (current) {
                        if (current.tblICInventoryReceiptItems()) {
                            if (current.tblICInventoryReceiptItems().data.items) {

                            }
                        }
                    }
                    // If there is no data change, do the post.
                    if (!context.data.hasChanges()) {
                        doPost();
                        return;
                    }

                    // Save has data changes first before doing the post.
                    context.data.saveRecord({
                        successFn: function () {
                            doPost();
                        }
                    });
        }
        
        if (current) {
					
            var buttonAction = function(button) {
                if (button === 'yes') {  
				    postReceipt();
                }
            }

            var ReceivedGrossDiscrepancyItems = '';
            
            if (current.tblICInventoryReceiptItems()) {
                Ext.Array.each(current.tblICInventoryReceiptItems().data.items, function(row) {
                    if (!row.dummy) {
                        //If there is Gross, check if the value is equivalent to Received Quantity
                        if(row.get('intWeightUOMId') !== null) {
                            var receiptItemQty = row.get('dblOpenReceive');
                            var receiptUOMCF = row.get('dblItemUOMConvFactor');
                            var weightUOMCF = row.get('dblWeightUOMConvFactor');

                            if (iRely.Functions.isEmpty(receiptItemQty)) receiptItemQty = 0.00;
                            if (iRely.Functions.isEmpty(receiptUOMCF)) receiptUOMCF = 0.00;
                            if (iRely.Functions.isEmpty(weightUOMCF)) weightUOMCF = 0.00;

                            //var totalGross = (receiptItemQty * receiptUOMCF) / weightUOMCF;
                            var totalGross = me.convertQtyBetweenUOM(receiptUOMCF, weightUOMCF, receiptItemQty);

                            if(row.get('dblGross') !== totalGross) {                                
                                ReceivedGrossDiscrepancyItems = ReceivedGrossDiscrepancyItems + row.get('strItemNo') + '<br/>'
                            }
                        }
                        
                    }
                });
            }

            if(ReceivedGrossDiscrepancyItems !== '' && btnReceive.text === 'Post') {
                iRely.Functions.showCustomDialog('question', 'yesno', 'Received and Gross quantities are not equal for the following item/s: <br/> <br/>' + ReceivedGrossDiscrepancyItems + '<br/>. Do you want to continue?', buttonAction);
            }
            else {
                postReceipt();
            }
        }   
    },

    onRecapClick: function (button, e, eOpts) {
        var me = this;
        var win = button.up('window');
        var cboCurrency = win.down('#cboCurrency');
        var context = win.context;

        var doRecap = function (recapButton, currentRecord, currency) {

            // Call the buildRecapData to generate the recap data
            CashManagement.common.BusinessRules.buildRecapData({
                postURL: '../Inventory/api/InventoryReceipt/Receive',
                strTransactionId: currentRecord.get('strReceiptNumber'),
                ysnPosted: currentRecord.get('ysnPosted'),
                scope: me,
                success: function () {
                    // If data is generated, show the recap screen.
                    var showPostButton = true;
                    if (currentRecord.get('intSourceType') === 3) {
                        showPostButton = false;
                    }

                    CashManagement.common.BusinessRules.showRecap({
                        strTransactionId: currentRecord.get('strReceiptNumber'),
                        ysnPosted: currentRecord.get('ysnPosted'),
                        dtmDate: currentRecord.get('dtmReceiptDate'),
                        strCurrencyId: currency,
                        dblExchangeRate: 1,
                        scope: me,
                        showPostButton: showPostButton,
                        showUnpostButton: showPostButton,
                        postCallback: function () {
                            me.onReceiveClick(recapButton);
                        },
                        unpostCallback: function () {
                            me.onReceiveClick(recapButton);
                        }
                    });
                },
                failure: function (message) {
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
        if (!context.data.hasChanges()) {
            doRecap(button, win.viewModel.data.current, cboCurrency.getRawValue());
            return;
        }

        // Save has data changes first before doing the post.
        context.data.saveRecord({
            successFn: function () {
                doRecap(button, win.viewModel.data.current, cboCurrency.getRawValue());
            }
        });
    },

    onAfterReceive: function (success, message) {
        if (success === true) {
            var me = this;
            var win = me.view;
            var paging = win.down('ipagingstatusbar');
            var grd = win.down('#grdInventoryReceipt');

            grd.getSelectionModel().deselectAll();
            paging.doRefresh();
        }
        else {
            iRely.Functions.showCustomDialog(iRely.Functions.dialogType.ERROR, iRely.Functions.dialogButtonType.OK, message);
        }
    },

    onCalculationBasisChange: function (obj, newValue, oldValue, eOpts) {
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

    onFreightCalculationChange: function (obj, newValue, oldValue, eOpts) {
        var win = obj.up('window');
        var txtUnitsWeightMiles = win.down('#txtUnitsWeightMiles');
        var txtFreightRate = win.down('#txtFreightRate');
        var txtFuelSurcharge = win.down('#txtFuelSurcharge');
        var txtCalculatedFreight = win.down('#txtCalculatedFreight');

        var unitRate = (txtUnitsWeightMiles.getValue() * txtFreightRate.getValue());
        var unitRateSurcharge = (unitRate * (txtFuelSurcharge.getValue() / 100));

        txtCalculatedFreight.setValue(unitRate + unitRateSurcharge);
    },

    onCalculateTotalAmount: function (obj, newValue, oldValue, eOpts) {
        var win = obj.up('window');
        var txtCalculatedAmount = win.down('#txtCalculatedAmount');
        var txtInvoiceAmount = win.down('#txtInvoiceAmount');
        var txtDifference = win.down('#txtDifference');
        var grid = win.down('#grdInventoryReceipt');
        var store = grid.store;

        if (store) {
            var data = store.data;
            var calculatedTotal = 0;
            Ext.Array.each(data.items, function (row) {
                if (!row.dummy) {
                    var dblReceived = row.get('dblReceived');
                    var dblUnitCost = row.get('dblUnitCost');
                    if (obj.column) {
                        if (obj.column.itemId === 'colReceived')
                            dblReceived = newValue;
                        else if (obj.column.itemId === 'colUnitCost')
                            dblUnitCost = newValue;
                        var rowTotal = dblReceived * dblUnitCost;
                        calculatedTotal += rowTotal;
                    }
                }
            });
            txtCalculatedAmount.setValue(calculatedTotal);
            var difference = calculatedTotal - (txtInvoiceAmount.getValue());
            txtDifference.setValue(difference);
        }
    },

    //calculateActualQty: function(current) {
    //    var receiptUOMCF = current.get('dblItemUOMConvFactor');
    //    var receiptQty = current.get('dblOpenReceive');
    //    var costUOMCF = current.get('dblCostUOMConvFactor');
    //    var cost = current.get('dblUnitCost');
    //    var weightUOMCF = current.get('dblWeightUOMConvFactor');
    //    var net = current.get('dblNet');
    //    var actualQty = 0;
    //
    //    if (iRely.Functions.isEmpty(current.get('intWeightUOMId'))) {
    //        actualQty = receiptQty;
    //    }
    //    else {
    //        if (weightUOMCF !== costUOMCF) {
    //            //actualQty = (receiptUOMCF * receiptQty) / weightUOMCF; -- Computation for auto calculate
    //            if (costUOMCF > weightUOMCF) {
    //                actualQty = net * weightUOMCF;
    //            }
    //            else {
    //                actualQty = net / costUOMCF;
    //            }
    //        }
    //        else {
    //            actualQty = net;
    //        }
    //    }
    //
    //    return actualQty;
    //},

    //calculateActualCost: function(current) {
    //    var receiptUOMCF = current.get('dblItemUOMConvFactor');
    //    var receiptQty = current.get('dblOpenReceive');
    //    var costUOMCF = current.get('dblCostUOMConvFactor');
    //    var cost = current.get('dblUnitCost');
    //    var weightUOMCF = current.get('dblWeightUOMConvFactor');
    //    var gross = current.get('dblGross');
    //    var net = current.get('dblNet');
    //    var actualCost = 0;
    //
    //    //no conversion computations yet since we take the cost straightforward
    //    if (iRely.Functions.isEmpty(current.get('intCostUOMId'))) {
    //        actualCost = cost;
    //    }
    //    else {
    //        if (costUOMCF !== receiptUOMCF) {
    //            actualCost = cost;
    //        }
    //        else {
    //            actualCost = cost;
    //        }
    //    }
    //
    //    return actualCost;
    //},

    //calculateActualCost: function(current, subCurrencyCents) {
    //    var receiptUOMCF = current.get('dblItemUOMConvFactor');
    //    var receiptQty = current.get('dblOpenReceive');
    //    var costUOMCF = current.get('dblCostUOMConvFactor');
    //    var cost = current.get('dblUnitCost');
    //    var weightUOMCF = current.get('dblWeightUOMConvFactor');
    //    var gross = current.get('dblGross');
    //    var net = current.get('dblNet');
    //    var actualCost = 0;
    //
    //    //no conversion computations yet since we take the cost straightforward
    //    if (iRely.Functions.isEmpty(current.get('intCostUOMId'))) {
    //        actualCost = cost;
    //    }
    //    else {
    //        if (costUOMCF !== receiptUOMCF) {
    //            actualCost = cost / subCurrencyCents;
    //        }
    //        else {
    //            actualCost = cost / subCurrencyCents;
    //        }
    //    }
    //
    //    return actualCost;
    //},

    //calculateSubCurrency: function(viewModel){
    //    if (!viewModel || !viewModel.data.currentReceiptItem)
    //        return 1;
    //
    //    var subCurrencyCents = viewModel.data.current.get('intSubCurrencyCents');
    //    var isComputeSubCurrency = viewModel.data.currentReceiptItem.get('ysnSubCurrency');
    //
    //    // sanitize the value for the sub currency.
    //    subCurrencyCents = Ext.isNumeric(subCurrencyCents) && subCurrencyCents != 0 ? subCurrencyCents : 1;
    //
    //    // check if there is a need to compute for the sub currency.
    //    if (!isComputeSubCurrency) {
    //        subCurrencyCents = 1;
    //    }
    //
    //    return subCurrencyCents;
    //},

    onItemValidateEdit: function (editor, context, eOpts) {
        var win = editor.grid.up('window');
        var me = win.controller;
        var vw = win.viewModel;
        var currentReceipt = vw.data.current;

        // If editing the open receive and unit cost, update the following too:
        // 1. Unit Retail
        // 2. Gross Margin. Set to zero.
        if (context.field === 'dblUnitCost') {
            if (context.record) {
                context.record.set('dblUnitRetail', context.value);
                context.record.set('dblGrossMargin', 0);
            } 
        }
        
        if (context.field === 'dblOpenReceive') {
            if (context.record) { 
                // Calculate the gross weight.
                me.calculateGrossNet(context.record, 1);
            }
        }
        
        // If editing the unit retail, update the gross margin too.
        else if (context.field === 'dblUnitRetail') {
            if (context.record) {
                var salesPrice = context.value;
                var grossMargin = ((salesPrice - context.record.get('dblUnitCost')) / (salesPrice)) * 100;
                context.record.set('dblGrossMargin', grossMargin);
            }
        }
        
        else if (context.field === 'strWeightUOM')
            {
                // Calculate the gross weight.
                me.calculateGrossNet(context.record, 1);
            }

        // Accept the data input.
        context.record.set(context.field, context.value);

        // Validate the gross and net variance.
        vw.data.currentReceiptItem = context.record;
        if (context.field === 'dblGross' || context.field === 'dblNet') {
            me.validateWeightLoss(win) 
        }

        // Calculate the taxes and line totals.
        
            // Calculate the taxes
            me.calculateItemTaxes();

            // Calculate the line total
            context.record.set('dblLineTotal', me.calculateLineTotal(currentReceipt, context.record));
        

        //// Update the summary totals
        //me.showSummaryTotals(win);
        //me.showOtherCharges(win);
    },

    onEditLots: function (editor, context, eOpts) {
        var me = this;
        var win = editor.grid.up('window');
        var receiptItem = win.viewModel.data.currentReceiptItem;
        var totalGross = iRely.Functions.isEmpty(receiptItem.get('dblGross')) ? 0 : receiptItem.get('dblGross');
        var totalNet = iRely.Functions.isEmpty(receiptItem.get('dblNet')) ? 0 : receiptItem.get('dblNet');

        if (context.field === 'dblGrossWeight' || context.field === 'dblTareWeight') {
            var gross = context.record.get('dblGrossWeight');
            var tare = context.record.get('dblTareWeight');
            var net = context.record.get('dblNetWeight');

            if (context.field === 'dblGrossWeight') {
                totalGross -= (tare + net);
                gross = context.value;
            }
            else if (context.field === 'dblTareWeight') {
                tare = context.value;
            }
            context.record.set('dblNetWeight', gross - tare);
        }

        // Call this function to auto-calculate the Gross and Net at the item grid.
        if (receiptItem.get('dblGross') === 0 && receiptItem.get('dblNet') === 0) {
            me.calculateGrossNet(receiptItem, 1);
        }

        //Calculate Line Total
        var currentReceipt  = win.viewModel.data.current;
        receiptItem.set('dblLineTotal', me.calculateLineTotal(currentReceipt, receiptItem));
        
        if(context.field === 'dblQuantity') {
            me.calculateGrossNet(receiptItem, 0);
        }
    },

    onChargeValidateEdit: function (editor, context, eOpts) {
        var win = editor.grid.up('window');
        var me = win.controller;
        if (context.field === 'dblAmount') {
            var amount = i21.ModuleMgr.Inventory.roundDecimalFormat(context.value, 2);
            context.record.set('dblAmount', amount);           
            //me.showOtherCharges(win);
            //return false;
        }
    },

    //onItemEdit: function (editor, context, eOpts) {
    //    var win = editor.grid.up('window');
    //    var me = win.controller;
    //
    //    // Update the summary totals
    //    me.showSummaryTotals(win);
    //    me.showOtherCharges(win);
    //},

    //onChargeEdit: function (editor, context, eOpts) {
    //    var win = editor.grid.up('window');
    //    var me = win.controller;
    //
    //    // Update the summary totals
    //    me.showSummaryTotals(win);
    //    me.showOtherCharges(win);
    //},

    onShipFromBeforeQuery: function (obj) {
        if (obj.combo) {
            var store = obj.combo.store;
            var win = obj.combo.up('window');
            if (store) {
                store.remoteFilter = true;
                store.remoteSort = true;
            }

            if (obj.combo.itemId === 'cboOrderNumber') {
                var proxy = obj.combo.store.proxy;
                proxy.setExtraParams({search: true, include: 'item'});
            }
            else if (obj.combo.itemId === 'cboVendor') {
                var proxy = obj.combo.store.proxy;
                proxy.setExtraParams({include: 'tblEntityLocations'});
            }
            else if (obj.combo.itemId === 'cboLotUOM') {
                obj.combo.defaultFilters = [
                    {
                        column: 'intItemId',
                        value: win.viewModel.data.currentReceiptItem.get('intItemId')
                    }
                ];
            }
            else if (obj.combo.itemId === 'cboWeightUOM') {
                obj.combo.defaultFilters = [
                    {
                        column: 'intItemId',
                        value: win.viewModel.data.currentReceiptItem.get('intItemId'),
                        conjunction: 'and'
                    }
                ];
            }
        }
    },

    onShipFromSelect: function (combo, records) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var current = win.viewModel.data.current;

        if (current) {
            current.set('intShipViaId', records[0].get('intShipViaId'));
            current.set('intTaxGroupId', records[0].get('intTaxGroupId'));
        }
    },

    onOrderNumberSelect: function (combo, records) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepItem');
        var current = plugin.getActiveRecord();
        var receipt = win.viewModel.data.current;
        var po = records[0];

        switch (win.viewModel.data.current.get('strReceiptType')) {
            case 'Purchase Order':
                current.set('intLineNo', po.get('intPurchaseDetailId'));
                current.set('intOrderId', po.get('intPurchaseId'));
                current.set('dblOrderQty', po.get('dblQtyOrdered'));
                current.set('dblReceived', po.get('dblQtyReceived'));
                current.set('dblOpenReceive', po.get('dblQtyOrdered') - po.get('dblQtyReceived'));
                current.set('strItemDescription', po.get('strDescription'));
                current.set('intItemId', po.get('intItemId'));
                current.set('strItemNo', po.get('strItemNo'));
                current.set('intUnitMeasureId', po.get('intUnitOfMeasureId'));
                current.set('strUnitMeasure', po.get('strUOM'));
                current.set('strOrderUOM', po.get('strUOM'));
                current.set('intCostUOMId', po.get('intUnitOfMeasureId'));
                current.set('strCostUOM', po.get('strUOM'));
                current.set('dblUnitCost', po.get('dblCost'));
                current.set('dblCostUOMConvFactor', po.get('dblItemUOMCF'));
               // current.set('dblLineTotal', po.get('dblTotal') + po.get('dblTax'));
                current.set('dblLineTotal', po.get('dblTotal'));
                current.set('dblTax', po.get('dblTax'));
                current.set('strLotTracking', po.get('strLotTracking'));
                current.set('intCommodityId', po.get('intCommodityId'));
                current.set('intOwnershipType', 1);
                current.set('strOwnershipType', 'Own');
                current.set('intSubLocationId', po.get('intSubLocationId'));
                current.set('intStorageLocationId', po.get('intStorageLocationId'));
                current.set('strSubLocationName', po.get('strSubLocationName'));
                current.set('strStorageLocationName', po.get('strStorageName'));
                current.set('dblItemUOMConvFactor', po.get('dblItemUOMCF'));
                current.set('dblOrderUOMConvFactor', po.get('dblItemUOMCF'));
                current.set('strUnitType', po.get('strStockUOMType'));
                current.set('intLifeTime', po.get('intLifeTime'));
                current.set('strLifeTimeType', po.get('strLifeTimeType'));
                break;

            case 'Purchase Contract':
                current.set('intLineNo', po.get('intContractDetailId'));
                current.set('intOrderId', po.get('intContractHeaderId'));

                var costTypes = po.get('tblCTContractCosts');
                if (costTypes) {
                    if (costTypes.length > 0) {
                        costTypes.forEach(function (otherCharge) {
                            var charges = receipt.tblICInventoryReceiptCharges().data.items;
                            var exists = Ext.Array.findBy(charges, function (row) {
                                if ((row.get('intContractId') === po.get('intContractHeaderId')
                                    && row.get('intChargeId') === cost.intItemId)) {
                                    return true;
                                }
                            });

                            if (!exists) {
                                var newOtherCharge = Ext.create('Inventory.model.ReceiptCharge', {
                                    intInventoryReceiptId: receipt.get('intInventoryReceiptId'),
                                    intContractId: po.get('intContractHeaderId'),
                                    intContractDetailId: otherCharge.intContractDetailId,
                                    intChargeId: otherCharge.intItemId,
                                    ysnInventoryCost: false,
                                    strCostMethod: otherCharge.strCostMethod,
                                    dblRate: otherCharge.dblRate,
                                    intCostUOMId: otherCharge.intItemUOMId,
                                    intEntityVendorId: otherCharge.intVendorId,
                                    dblAmount: 0,
                                    strAllocateCostBy: 'Unit',
                                    ysnAccrue: otherCharge.ysnAccrue,
                                    ysnPrice: otherCharge.ysnPrice,
                                    strItemNo: otherCharge.strItemNo,
                                    intCurrencyId: otherCharge.intCurrencyId,
                                    strCurrency: otherCharge.strCurrency,
                                    ysnSubCurrency: otherCharge.ysnSubCurrency,
                                    strCostUOM: otherCharge.strUOM,
                                    strVendorName: otherCharge.strVendorName,
                                    strContractNumber: po.get('strContractNumber')
                                });
                                receipt.tblICInventoryReceiptCharges().add(newOtherCharge);
                            }
                        });
                    }
                }

                if (win.viewModel.data.current) {
                    if (win.viewModel.data.current.get('intSourceType') === 0) {
                        current.set('dblOrderQty', po.get('dblDetailQuantity'));
                        current.set('ysnLoad', po.get('ysnLoad'));
                        if (po.get('ysnLoad') === true) {
                            current.set('dblReceived', po.get('intLoadReceived'));
                            current.set('dblOpenReceive', po.get('dblQuantityPerLoad'));
                            current.set('dblAvailableQty', po.get('dblAvailableQty'));
                        }
                        else {
                            current.set('dblReceived', po.get('dblDetailQuantity') - po.get('dblBalance'));
                            current.set('dblOpenReceive', po.get('dblBalance'));
                        }

                        current.set('strItemDescription', po.get('strItemDescription'));
                        current.set('intItemId', po.get('intItemId'));
                        current.set('strItemNo', po.get('strItemNo'));
                        current.set('intUnitMeasureId', po.get('intItemUOMId'));
                        current.set('intCostUOMId', po.get('intPriceItemUOMId'));
                        current.set('strUnitMeasure', po.get('strItemUOM'));
                        current.set('strOrderUOM', po.get('strItemUOM'));
                        current.set('strCostUOM', po.get('strPriceUOM'));

                        if (po.get('strPricingType') === 'Index') {
                            CTFunctions.getIndexPrice(receipt.get('intEntityVendorId'),
                                receipt.get('intShipFromId'),
                                po.get('intRackPriceSupplyPointId'),
                                po.get('intSupplyPointId'),
                                po.get('strIndexType'),
                                receipt.get('dtmReceiptDate'),
                                po.get('dblAdjustment'),
                                po.get('intItemId'),
                                function (response) {
                                    contractPrice = response.data;
                                    current.set('dblUnitCost', contractPrice);
                                });
                        } else {
                            current.set('intCostUOMId', po.get('intPriceItemUOMId'));
                            current.set('strCostUOM', po.get('strPriceUOM'));
                            current.set('dblUnitCost', po.get('dblCashPrice'));
                        }

                        current.set('dblLineTotal', po.get('dblTotal'));
                        current.set('strLotTracking', po.get('strLotTracking'));
                        current.set('intCommodityId', po.get('intCommodityId'));
                        current.set('intOwnershipType', 1);
                        current.set('strOwnershipType', 'Own');
                        current.set('intStorageLocationId', po.get('intStorageLocationId'));
                        current.set('strStorageLocationName', po.get('strStorageLocationName'));
                        current.set('intSubLocationId', po.get('intCompanyLocationSubLocationId'));
                        current.set('strSubLocationName', po.get('strSubLocationName'));
                        current.set('dblItemUOMConvFactor', po.get('dblItemUOMCF'));
                        current.set('dblOrderUOMConvFactor', po.get('dblItemUOMCF'));
                        current.set('dblCostUOMConvFactor', po.get('dblItemUOMCF'));
                        current.set('strUnitType', po.get('strStockUOMType'));
                        current.set('intLifeTime', po.get('intLifeTime'));
                        current.set('strLifeTimeType', po.get('strLifeTimeType'));
                    }
                }
                break;
        }

        if (po.get('strStockUOMType') === 'Weight' && po.get('strLotTracking') !== 'No') {
            current.set('intWeightUOMId', po.get('intStockUOM'));
            current.set('strWeightUOM', po.get('strStockUOM'));
            current.set('dblWeightUOMConvFactor', po.get('dblStockUOMCF'));
        }

        win.viewModel.data.currentReceiptItem = current;
    },

    onSourceNumberSelect: function (combo, records) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepItem');
        var current = plugin.getActiveRecord();
        var masterRecord = win.viewModel.data.current;
        var po = records[0];

        switch (win.viewModel.data.current.get('intSourceType')) {
            case 2:
                current.set('intSourceId', po.get('intShipmentContractQtyId'));
                current.set('dblOrderQty', po.get('dblQuantity'));
                current.set('dblReceived', po.get('dblReceivedQty'));
                current.set('dblOpenReceive', po.get('dblQuantity') - po.get('dblReceivedQty'));
                current.set('strItemDescription', po.get('strItemDescription'));
                current.set('intItemId', po.get('intItemId'));
                current.set('strItemNo', po.get('strItemNo'));
                current.set('intUnitMeasureId', po.get('intItemUOMId'));
                current.set('strUnitMeasure', po.get('strUnitMeasure'));
                current.set('strOrderUOM', po.get('strUnitMeasure'));
                current.set('strCostUOM', po.get('strCostUOM'));
                current.set('intCostUOMId', po.get('intCostUOMId'));
                current.set('dblUnitCost', po.get('dblCost'));
                current.set('dblLineTotal', po.get('dblTotal'));
                current.set('strLotTracking', po.get('strLotTracking'));
                current.set('intCommodityId', po.get('intCommodityId'));
                current.set('intOwnershipType', 1);
                current.set('strOwnershipType', 'Own');
                current.set('intSubLocationId', po.get('intSubLocationId'));
                current.set('strSubLocationName', po.get('strSubLocationName'));
                current.set('dblItemUOMConvFactor', po.get('dblItemUOMCF'));
                current.set('dblOrderUOMConvFactor', po.get('dblItemUOMCF'));
                current.set('dblCostUOMConvFactor', po.get('dblCostUOMCF'));
                current.set('strUnitType', po.get('strStockUOMType'));
                current.set('strContainer', po.get('strContainerNumber'));
                current.set('intContainerId', po.get('intShipmentBLContainerId'));
                current.set('intLifeTime', po.get('intLifeTime'));
                current.set('strLifeTimeType', po.get('strLifeTimeType'));

                if (iRely.Functions.isEmpty(current.get('intOrderId'))) {
                    current.set('intLineNo', po.get('intContractDetailId'));
                    current.set('intOrderId', po.get('intContractHeaderId'));
                    current.set('strOrderNumber', po.get('strContractNumber'));
                }
                break;

            case 1:
                break;
        }
        win.viewModel.data.currentReceiptItem = current;
    },

    onSourceNumberBeforeSelect: function (combo, record, index, eOpts) {
        if (!record)
            return false;

        var win = combo.up('window');
        var masterRecord = win.viewModel.data.current;
        var po = record;

        //Validate recurring instances of Inbound Shipment Container Line Items
        if (masterRecord.get('strReceiptType') === 'Purchase Contract' && masterRecord.get('intSourceType') === 2) {
            var receiptItems = masterRecord.tblICInventoryReceiptItems().data.items;
            var exists = Ext.Array.findBy(receiptItems, function (row) {
                if ((row.get('intSourceId') === po.get('intShipmentContractQtyId')
                    && row.get('intContainerId') === po.get('intShipmentBLContainerId'))) {
                    return true;
                }
            });
            if (exists) {
                iRely.Functions.showErrorDialog('This information is already selected. Please select a different container.');
                return false;
            }

        }
    },

    purchaseOrderDropdown: function (win) {
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
                        dataIndex: 'strLocationName',
                        dataType: 'string',
                        text: 'Location Name',
                        flex: 1.5
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
                        hidden: true
                    },
                    {
                        dataIndex: 'dblTotal',
                        dataType: 'float',
                        hidden: true
                    },
                    {
                        dataIndex: 'dblTax',
                        dataType: 'float',
                        hidden: true
                    },
                    {
                        dataIndex: 'intPurchaseDetailId',
                        dataType: 'numeric',
                        hidden: true
                    },
                    {
                        dataIndex: 'intPurchaseId',
                        dataType: 'numeric',
                        hidden: true
                    },
                    {
                        dataIndex: 'intCommodityId',
                        dataType: 'numeric',
                        hidden: true
                    },
                    {
                        dataIndex: 'intItemId',
                        dataType: 'numeric',
                        hidden: true
                    },
                    {
                        dataIndex: 'intLocationId',
                        dataType: 'numeric',
                        hidden: true
                    },
                    {
                        dataIndex: 'intUnitOfMeasureId',
                        dataType: 'numeric',
                        hidden: true
                    },
                    {
                        dataIndex: 'strUOM',
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
                        hidden: true
                    },
                    {
                        dataIndex: 'strSubLocationName',
                        dataType: 'string',
                        hidden: true
                    },
                    {
                        dataIndex: 'strStorageName',
                        dataType: 'string',
                        hidden: true
                    },
                    {
                        dataIndex: 'dblItemUOMCF',
                        dataType: 'float',
                        hidden: true
                    },
                    {
                        dataIndex: 'intStockUOM',
                        dataType: 'numeric',
                        hidden: true
                    },
                    {
                        dataIndex: 'strStockUOM',
                        dataType: 'string',
                        hidden: true
                    },
                    {
                        dataIndex: 'strStockUOMType',
                        dataType: 'string',
                        hidden: true
                    },
                    {
                        dataIndex: 'dblStockUOMCF',
                        dataType: 'float',
                        hidden: true
                    },
                    {
                        dataIndex: 'intLifeTime',
                        dataType: 'numeric',
                        hidden: true
                    },
                    {
                        dataIndex: 'strLifeTimeType',
                        dataType: 'string',
                        hidden: true
                    }
                ],
                itemId: 'cboOrderNumber',
                displayField: 'strPurchaseOrderNumber',
                valueField: 'strPurchaseOrderNumber',
                store: win.viewModel.storeInfo.orderNumbers,
                defaultFilters: [
                    {
                        column: 'ysnCompleted',
                        value: 'false',
                        conjunction: 'and'
                    },
                    {
                        column: 'intEntityVendorId',
                        value: win.viewModel.data.current.get('intEntityVendorId'),
                        conjunction: 'and'
                    }
                ]
            })
        });
    },

    purchaseContractDropdown: function (win) {
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
                        flex: 1.5
                    },
                    {
                        dataIndex: 'intContractSeq',
                        dataType: 'string',
                        text: 'Sequence',
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
                        dataIndex: 'dblCashPrice',
                        dataType: 'float',
                        text: 'Cash Price',
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
                        dataIndex: 'dblAvailableQty',
                        dataType: 'float',
                        text: 'Available Qty',
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
                        dataIndex: 'intStorageLocationId',
                        dataType: 'numeric',
                        hidden: true
                    },
                    {
                        dataIndex: 'strStorageLocationName',
                        dataType: 'string',
                        hidden: true
                    },
                    {
                        dataIndex: 'strContractComments',
                        dataType: 'string',
                        text: 'Contract Comments',
                        width: 150
                    }
                ],
                itemId: 'cboOrderNumber',
                displayField: 'strContractNumber',
                valueField: 'strContractNumber',
                store: win.viewModel.storeInfo.purchaseContract,
                pickerWidth: 800,
                defaultFilters: [
                    {
                        column: 'strContractType',
                        value: 'Purchase',
                        conjunction: 'and'
                    },
                    {
                        column: 'intEntityId',
                        value: win.viewModel.data.current.get('intEntityVendorId'),
                        conjunction: 'and'
                    },
                    {
                        column: 'ysnAllowedToShow',
                        value: true,
                        conjunction: 'and'
                    }
                ]
            })
        });
    },

    transferOrderDropdown: function (win) {
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
                defaultFilters: [
                    {
                        column: 'ysnCompleted',
                        value: 'false',
                        conjunction: 'and'
                    },
                    {
                        column: 'intEntityVendorId',
                        value: win.viewModel.data.current.get('intEntityVendorId'),
                        conjunction: 'and'
                    }
                ]
            })
        });
    },

    inboundShipmentDropdown: function (win, record) {
        return Ext.create('Ext.grid.CellEditor', {
            field: Ext.widget({
                xtype: 'gridcombobox',
                matchFieldWidth: false,
                columns: [
                    {
                        dataIndex: 'intTrackingNumber',
                        dataType: 'string',
                        text: 'Tracking No',
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
                        dataIndex: 'dblQuantity',
                        dataType: 'float',
                        text: 'Ordered Qty',
                        flex: 1
                    },
                    {
                        dataIndex: 'dblReceivedQty',
                        dataType: 'float',
                        text: 'Received Qty',
                        flex: 1
                    },
                    {
                        dataIndex: 'dblCost',
                        dataType: 'float',
                        hidden: true
                    },
                    {
                        dataIndex: 'intShipmentContractQtyId',
                        dataType: 'numeric',
                        hidden: true
                    },
                    {
                        dataIndex: 'intShipmentId',
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
                        dataIndex: 'strUnitMeasure',
                        dataType: 'string',
                        hidden: true
                    },
                    {
                        dataIndex: 'strLotTracking',
                        dataType: 'string',
                        hidden: true
                    },
                    {
                        dataIndex: 'intSubLocationId',
                        dataType: 'numeric',
                        hidden: true
                    },
                    {
                        dataIndex: 'strSubLocationName',
                        dataType: 'string',
                        hidden: true
                    },
                    {
                        dataIndex: 'dblItemUOMCF',
                        dataType: 'float',
                        hidden: true
                    },
                    {
                        dataIndex: 'intStockUOM',
                        dataType: 'numeric',
                        hidden: true
                    },
                    {
                        dataIndex: 'strStockUOM',
                        dataType: 'string',
                        hidden: true
                    },
                    {
                        dataIndex: 'strStockUOMType',
                        dataType: 'string',
                        hidden: true
                    },
                    {
                        dataIndex: 'dblStockUOMCF',
                        dataType: 'float',
                        hidden: true
                    }
                ],
                itemId: 'cboSourceNumber',
                displayField: 'intTrackingNumber',
                valueField: 'intTrackingNumber',
                store: win.viewModel.storeInfo.inboundShipment,
                defaultFilters: [
                    {
                        column: 'dblBalanceToReceived',
                        value: '0',
                        conjunction: 'and',
                        condition: 'gt'
                    },
                    {
                        column: 'intContractDetailId',
                        value: record.get('intLineNo'),
                        conjunction: 'and'
                    }
                ]
            })
        });
    },

    onItemGridColumnBeforeRender: function (column) {
        "use strict";

        var me = this,
            win = column.up('window'),
            controller = win.getController();

        // Show or hide the editor based on the selected Field type.
        column.getEditor = function (record) {

            var vm = win.viewModel,
                current = vm.data.current;

            if (!current) return false;
            if (!column) return false;
            if (!record) return false;

            var receiptType = current.get('strReceiptType');
            var columnId = column.itemId;

            switch (receiptType) {
                case 'Purchase Order' :
                    if (iRely.Functions.isEmpty(record.get('strOrderNumber'))) {
                        switch (columnId) {
                            case 'colOrderNumber' :
                                //return controller.purchaseOrderDropdown(win);
                                return false;
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
                        }
                        ;
                    }
                    break;
                case 'Purchase Contract' :
                    switch (columnId) {
                        case 'colOrderNumber' :
                            if (iRely.Functions.isEmpty(record.get('strOrderNumber')))
                                //return controller.purchaseContractDropdown(win);
                                return false;
                            else
                                return false;
                            break;
                        case 'colSourceNumber' :
                            switch (current.get('intSourceType')) {
                                case 2:
                                    if (iRely.Functions.isEmpty(record.get('strSourceNumber')))
                                        return controller.inboundShipmentDropdown(win, record);
                                    else
                                        return false;
                                    break;
                                default:
                                    return false;
                                    break;
                            }
                            break;
                    }
                    break;
                case 'Transfer Order' :
                    if (iRely.Functions.isEmpty(record.get('strOrderNumber'))) {
                        switch (columnId) {
                            case 'colOrderNumber' :
                                //return controller.transferOrderDropdown(win);
                                return false;
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
                        }
                        ;
                    }
                    break;
            }
            ;
        };
    },

    onLotGridColumnBeforeRender: function (column) {
        "use strict";
        if (!column) return false;
        var me = this,
            win = column.up('window');

        // Show or hide the editor based on the selected Field type.
        column.getEditor = function (record) {

            var vm = win.viewModel,
                currentReceiptItem = vm.data.currentReceiptItem;

            if (!record) return false;

            var UOMType = currentReceiptItem.get('strUnitType');
            var columnId = column.itemId;

            var cboLotUOM = Ext.widget({
                xtype: 'gridcombobox',
                matchFieldWidth: false,
                columns: [
                    {
                        dataIndex: 'intItemUOMId',
                        dataType: 'numeric',
                        text: 'Unit Of Measure Id',
                        hidden: true
                    },
                    {
                        dataIndex: 'strUnitMeasure',
                        dataType: 'string',
                        text: 'Unit Measure',
                        flex: 1
                    },
                    {
                        dataIndex: 'strUnitType',
                        dataType: 'string',
                        text: 'Unit Type',
                        flex: 1
                    },
                    {
                        xtype: 'checkcolumn',
                        dataIndex: 'ysnStockUnit',
                        dataType: 'boolean',
                        text: 'Stock Unit',
                        flex: 1
                    },
                    {
                        dataIndex: 'dblUnitQty',
                        dataType: 'float',
                        text: 'Unit Qty',
                        hidden: true
                    }
                ],
                itemId: 'cboLotUOM',
                displayField: 'strUnitMeasure',
                valueField: 'strUnitMeasure',
                store: win.viewModel.storeInfo.lotUOM,
                defaultFilters: [
                    {
                        column: 'intItemId',
                        value: currentReceiptItem.get('intItemId'),
                        conjunction: 'and'
                    }
                ]
            });

            if (cboLotUOM) {
                cboLotUOM.on({
                    select: me.onLotSelect,
                    scope: me
                });
            }

            switch (UOMType) {
                case 'Weight':
                    switch (columnId) {
                        case 'colLotUOM' :
                            return Ext.create('Ext.grid.CellEditor', {
                                field: cboLotUOM
                            });
                            break;
                    }
                    break;
                default:
                    switch (columnId) {
                        case 'colLotUOM' :
                            return false;
                            break;
                    }
                    break;
            }
        };
    },

    onSpecialKeyTab: function (component, e, eOpts) {
        var win = component.up('window');
        if (win) {
            if (e.getKey() === Ext.event.Event.TAB) {
                var gridObj = win.query('#grdInventoryReceipt')[0],
                    sel = gridObj.getStore().getAt(0);

                if (sel && gridObj) {
                    gridObj.setSelection(sel);

                    var column = 1;
                    if (win.viewModel.data.current.get('strReceiptType') === 'Direct') {
                        column = 2
                    }

                    var task = new Ext.util.DelayedTask(function () {
                        gridObj.plugins[0].startEditByPosition({
                            row: 0,
                            column: column
                        });
                    });

                    task.delay(10);
                }
            }
        }
    },

    onItemSelectionChange: function (selModel, selected, eOpts) {
        if (selModel) {
            if (selModel.view == null || selModel.view == 'undefined') {
                if (selModel.views == 'undefined' || selModel.views == null || selModel.views.length == 0)
                    return;
                var w = selModel.views[0].up('window');
                var plt = w.down("#pnlLotTracking");
                w.down("#lblWeightLossMsgValue").setText("");
                w.down("#lblWeightLossMsg").setText("Wgt or Vol Gain/Loss: ");
                plt.setVisible(false);
                return;
            }
            var win = selModel.view.grid.up('window');
            var vm = win.viewModel;
            var pnlLotTracking = win.down("#pnlLotTracking");

            if (selected.length > 0) {
                var current = selected[0];

                if (current.dummy) {
                    vm.data.currentReceiptItem = null;
                    pnlLotTracking.setVisible(false);
                }
                else if (current.get('strLotTracking') === 'Yes - Serial Number' || current.get('strLotTracking') === 'Yes - Manual') {
                    vm.data.currentReceiptItem = current;
                    pnlLotTracking.setVisible(true);
                }
                else {
                    pnlLotTracking.setVisible(false);
                    vm.data.currentReceiptItem = null;
                }
            }
            else {
                vm.data.currentReceiptItem = null;
                pnlLotTracking.setVisible(false);
            }
        }
    },

    onLotSelect: function (combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var me = win.controller;
        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepItemLots');
        var current = plugin.getActiveRecord();

        if (combo.itemId === 'cboLot') {
            current.set('strItemUOM', records[0].get('strItemUOM'));
            current.set('intItemUnitMeasureId', records[0].get('intItemUOMId'));
            current.set('dblLotUOMConvFactor', records[0].get('dblUnitQty'));

            current.set('strWeightUOM', records[0].get('strWeightUOM'));
            current.set('dtmExpiryDate', records[0].get('dtmExpiryDate'));
        }
        else if (combo.itemId === 'cboLotUOM') {
            current.set('intItemUnitMeasureId', records[0].get('intItemUOMId'));
            current.set('dblLotUOMConvFactor', records[0].get('dblUnitQty'));
            current.set('strUnitType', records[0].get('strUnitType'));

			//Calculate the Line Gross Net Qty. 
            me.calculateGrossNet(win.viewModel.data.currentReceiptItem, 0);		
            
            //Calculate Line Total
            var currentReceiptItem = win.viewModel.data.currentReceiptItem;
            var currentReceipt  = win.viewModel.data.current;
            currentReceiptItem.set('dblLineTotal', me.calculateLineTotal(currentReceipt, currentReceiptItem));
        }
    },

    onWeightUOMChange: function (combo, newValue, oldValue, eOpts) {
        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepItem');
        var current = plugin.getActiveRecord();
        if (current && (newValue === null || newValue === '')) {
            current.set('intWeightUOMId', null);
            current.set('dblWeightUOMConvFactor', null);
            current.set('dblGross', 0);
            current.set('dblNet', 0);
            if (current.tblICInventoryReceiptItemLots()) {
                Ext.Array.each(current.tblICInventoryReceiptItemLots().data.items, function (lot) {
                    if (!lot.dummy) {
                        lot.set('strWeightUOM', null);
                        lot.set('dblGrossWeight', 0);
                        lot.set('dblTareWeight', 0);
                        lot.set('dblNetWeight', 0);
                    }
                });
            }
        }
    },

    onChargeSelect: function (combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var record = records[0];
        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepCharges');
        var current = plugin.getActiveRecord();
        var masterRecord = win.viewModel.data.current;
        var cboVendor = win.down('#cboVendor');

        if (combo.itemId === 'cboOtherCharge') {
            current.set('intChargeId', record.get('intItemId'));
            current.set('ysnInventoryCost', record.get('ysnInventoryCost'));
            current.set('ysnAccrue', record.get('ysnAccrue'));

            if (record.get('ysnAccrue') === true) {
                current.set('intEntityVendorId', masterRecord.get('intEntityVendorId'));
                current.set('strVendorName', cboVendor.getRawValue());
            }
            else {
                current.set('intEntityVendorId', null);
                current.set('strVendorName', null);
            }

            current.set('dblRate', record.get('dblAmount'));
            current.set('intCostUOMId', record.get('intCostUOMId'));
            current.set('strCostMethod', record.get('strCostMethod'));
            current.set('strCostUOM', record.get('strCostUOM'));
            current.set('strOnCostType', record.get('strOnCostType'));
            if (!iRely.Functions.isEmpty(record.get('strOnCostType'))) {
                current.set('strCostMethod', 'Percentage');
            }
        }

        if (combo.itemId === 'cboChargeCurrency') {
            current.set('intCurrencyId', record.get('intCurrencyID'));
            current.set('strCurrency', record.get('strCurrency'));
            current.set('intCent', record.get('intCent'));
            current.set('ysnSubCurrency', record.get('ysnSubCurrency'));
        }
    },

    onAccrueCheckChange: function (obj, rowIndex, checked, eOpts) {
        if (obj.dataIndex === 'ysnAccrue') {
            var grid = obj.up('grid');
            var win = obj.up('window');
            var current = grid.view.getRecord(rowIndex);
            var masterRecord = win.viewModel.data.current;
            var cboVendor = win.down('#cboVendor');

            if (checked === true) {
                if (iRely.Functions.isEmpty(current.get('strVendorName'))) {
                    current.set('intEntityVendorId', masterRecord.get('intEntityVendorId'));
                    current.set('strVendorName', cboVendor.getRawValue());
                }
            }
            else {
                current.set('intEntityVendorId', null);
                current.set('strVendorName', null);
            }
        }
    },

    onPrintLabelClick: function (button, e, eOpts) {
        var win = button.up('window'),
            gridObj = button.up('grid'),
            selectedObj = gridObj.getSelectionModel().getSelection(),
            me = this;

        if (selectedObj.length <= 0) {
            i21.functions.showErrorDialog('Please select a lot.');
            return;
        }

        var strLotNo = '';
        for (var x = 0; x < selectedObj.length; x++) {
            strLotNo += selectedObj[x].data.strLotNumber + '^';
        }
        iRely.Functions.openScreen('Reporting.view.ReportViewer', {
            selectedReport: 'LotLabel',
            selectedGroup: 'Manufacturing',
            selectedParameters: [
                {
                    Name: 'strLotNo',
                    Type: 'string',
                    Condition:'EQUAL TO',
                    From: strLotNo,
                    To: '',
                    Operator: ''
                }],
            directPrint: true
        });
    },

    onAddOrderClick: function(button, e, eOpts) {
        var win = button.up('window');
        this.showAddOrders(win);
    },

    showAddOrders: function(win) {
        var me = this;
        var currentRecord = win.viewModel.data.current;
        var VendorId = null;
        var ReceiptType = currentRecord.get('strReceiptType');
        var SourceType = currentRecord.get('intSourceType').toString();
        var CurrencyId = currentRecord.get('intCurrencyId') === null ? 0 : currentRecord.get('intCurrencyId').toString();
        var ContractStore = win.viewModel.storeInfo.purchaseContractList;
        if (ReceiptType === 'Transfer Order') {
            VendorId = currentRecord.get('intTransferorId').toString();
        }
        else {
            VendorId = currentRecord.get('intEntityVendorId').toString();
        }

        var showAddScreen = function() {
            var search = i21.ModuleMgr.Search;
            search.scope = me;
            search.url = '../Inventory/api/InventoryReceipt/GetAddOrders?VendorId=' + VendorId + '&ReceiptType=' + ReceiptType + '&SourceType=' + SourceType + '&CurrencyId=' + CurrencyId;
            search.columns = [
                {dataIndex: 'intKey', text: "Key", flex: 1, defaultSort: true, sortOrder: 'DESC', dataType: 'numeric', key: true, hidden: true},
                {dataIndex: 'strOrderNumber', text: 'Order Number', width: 100, dataType: 'string', drillDownText: 'View Receipt', drillDownClick: 'onViewReceiptNo'},
                {dataIndex: 'strOrderUOM', text: 'Order UOM', width: 100, dataType: 'string'},
                { xtype: 'numbercolumn', dataIndex: 'dblOrderUOMConvFactor', text: 'Order UOM Conversion Factor', width: 100, dataType: 'float', hidden: true},
                { xtype: 'numbercolumn', dataIndex: 'dblOrdered', text: 'Ordered Qty', width: 100, dataType: 'float'},
                { xtype: 'numbercolumn', dataIndex: 'dblReceived', text: 'Received Qty', width: 100, dataType: 'float'},
                {dataIndex: 'strSourceNumber', text: 'Source Number', width: 100, dataType: 'string'},
                {dataIndex: 'strItemNo', text: 'Item No', width: 100, dataType: 'string'},
                {dataIndex: 'strItemDescription', text: 'Item Description', width: 100, dataType: 'string'},
                { xtype: 'numbercolumn', dataIndex: 'dblQtyToReceive', text: 'Qty to Receive', width: 100, dataType: 'float'},
                { xtype: 'numbercolumn', dataIndex: 'intLoadToReceive', text: 'Load to Receive', width: 100, dataType: 'numeric'},
                { xtype: 'numbercolumn', dataIndex: 'dblUnitCost', text: 'Cost', width: 100, dataType: 'float'},
                { xtype: 'numbercolumn', dataIndex: 'dblTax', text: 'Tax', width: 100, dataType: 'float'},
                { xtype: 'numbercolumn', dataIndex: 'dblLineTotal', text: 'Line Total', width: 100, dataType: 'float'},

                {dataIndex: 'strLotTracking', text: 'Lot Tracking', width: 100, dataType: 'string', hidden: true},
                {dataIndex: 'strContainer', text: 'Container', width: 100, dataType: 'string'},
                {dataIndex: 'strSubLocationName', text: 'SubLocation', width: 100, dataType: 'string'},
                {dataIndex: 'strStorageLocationName', text: 'Storage Location', width: 100, dataType: 'string'},

                {dataIndex: 'strUnitMeasure', text: 'Item UOM', width: 100, dataType: 'string'},
                {dataIndex: 'strUnitType', text: 'Item UOM Type', width: 100, dataType: 'string', hidden: true},
                { xtype: 'numbercolumn', dataIndex: 'dblItemUOMConvFactor', text: 'Item UOM Conversion Factor', width: 100, dataType: 'float', hidden: true},
                {dataIndex: 'strWeightUOM', text: 'Weight UOM', width: 100, dataType: 'string'},
                { xtype: 'numbercolumn', dataIndex: 'dblWeightUOMConvFactor', text: 'Weight UOM Conversion Factor', width: 100, dataType: 'float', hidden: true},
                {dataIndex: 'strCostUOM', text: 'Cost UOM', width: 100, dataType: 'string'},
                { xtype: 'numbercolumn', dataIndex: 'dblCostUOMConvFactor', text: 'Cost UOM Conversion Factor', width: 100, dataType: 'float', hidden: true},
                {dataIndex: 'intLifeTime', text: 'Lifetime', width: 100, dataType: 'string', hidden: true},
                {dataIndex: 'strLifeTimeType', text: 'Lifetime Type', width: 100, dataType: 'string', hidden: true},
                {dataIndex: 'ysnLoad', text: 'Load Contract', width: 100, dataType: 'boolean', xtype: 'checkcolumn' },
                { xtype: 'numbercolumn', dataIndex: 'dblAvailableQty', text: 'Available Qty', width: 100, dataType: 'float'},
                {dataIndex: 'strBOL', text: 'BOL', width: 100, dataType: 'string', hidden: true},
                {dataIndex: 'intLocationId', text: 'Location Id', width: 100, dataType: 'numeric', hidden: true},
                {dataIndex: 'intEntityVendorId', text: 'Vendor Id', width: 100, dataType: 'numeric', hidden: true},
                {dataIndex: 'strVendorId', text: 'Vendor', width: 100, dataType: 'string', hidden: true},
                {dataIndex: 'strVendorName', text: 'Vendor Name', width: 100, dataType: 'string', hidden: true},
                {dataIndex: 'strReceiptType', text: 'Transaction Type', width: 100, dataType: 'string', hidden: true},
                {dataIndex: 'intLineNo', text: 'Line No', width: 100, dataType: 'numeric', hidden: true},
                {dataIndex: 'intOrderId', text: 'Order Id', width: 100, dataType: 'numeric', hidden: true},
                {dataIndex: 'intSourceType', text: 'Source Type', width: 100, dataType: 'numeric', hidden: true},
                {dataIndex: 'intSourceId', text: 'Source Id', width: 100, dataType: 'string', hidden: true},
                {dataIndex: 'intItemId', text: 'Item Id', width: 100, dataType: 'string', hidden: true},
                {dataIndex: 'intCommodityId', text: 'Commodity Id', width: 100, dataType: 'string', hidden: true},
                {dataIndex: 'intContainerId', text: 'Container Id', width: 100, dataType: 'numeric', hidden: true},
                {dataIndex: 'intSubLocationId', text: 'SubLocation Id', width: 100, dataType: 'numeric', hidden: true},
                {dataIndex: 'intStorageLocationId', text: 'Storage Location Id', width: 100, dataType: 'numeric', hidden: true},
                {dataIndex: 'intOrderUOMId', text: 'Order UOM Id', width: 100, dataType: 'string', hidden: true},
                {dataIndex: 'intItemUOMId', text: 'Item UOM Id', width: 100, dataType: 'string', hidden: true},
                {dataIndex: 'intWeightUOMId', text: 'Weight UOM Id', width: 100, dataType: 'string', hidden: true},
                {dataIndex: 'intCostUOMId', text: 'Cost UOM Id', width: 100, dataType: 'numeric', hidden: true},
                {dataIndex: 'ysnSubCurrency', text: 'Cost Currency', width: 100, dataType: 'boolean', hidden: true},
                {dataIndex: 'strSubCurrency', text: 'Cost Currency', width: 100, dataType: 'string', hidden: true},
                { xtype: 'numbercolumn', dataIndex: 'dblFranchise', text: 'Franchise', width: 100, dataType: 'float', hidden: true},
                { xtype: 'numbercolumn', dataIndex: 'dblContainerWeightPerQty', text: 'Container Weight Per Qty', width: 100, dataType: 'float', hidden: true},

                { xtype: 'numbercolumn', dataIndex: 'dblGross', text: 'Gross', width: 100, dataType: 'float'},
                { xtype: 'numbercolumn', dataIndex: 'dblNet', text: 'Net', width: 100, dataType: 'float'}

            ];
            search.title = "Add Orders";
            search.showNew = false;
            search.on({
                scope: me,
                openselectedclick: function (button, e, result) {
                    var win = me.getView();
                    var currentVM = me.getViewModel().data.current;

                    Ext.each(result, function (order) {
                        var newRecord = {
                            intInventoryReceiptId: currentVM.get('intInventoryReceiptId'),
                            intLineNo: order.get('intLineNo'),
                            intOrderId: order.get('intOrderId'),
                            strOrderNumber: order.get('strOrderNumber'),
                            dtmDate: order.get('dtmDate'),
                            dblOrderQty: order.get('dblOrdered'),
                            dblReceived: order.get('dblReceived'),
                            intSourceId: order.get('intSourceId'),
                            strSourceNumber: order.get('strSourceNumber'),
                            intItemId: order.get('intItemId'),
                            strItemNo: order.get('strItemNo'),
                            strItemDescription: order.get('strItemDescription'),
                            dblOpenReceive: order.get('dblQtyToReceive'),
                            intLoadReceive: order.get('intLoadToReceive'),
                            dblUnitCost: order.get('dblUnitCost'),
                            dblUnitRetail: order.get('dblUnitCost'),
                            dblTax: order.get('dblTax'),
                            dblLineTotal: order.get('dblLineTotal'),
                            strLotTracking: order.get('strLotTracking'),
                            intCommodityId: order.get('intCommodityId'),
                            intContainerId: order.get('intContainerId'),
                            strContainer: order.get('strContainer'),
                            intSubLocationId: order.get('intSubLocationId'),
                            strSubLocationName: order.get('strSubLocationName'),
                            intStorageLocationId: order.get('intStorageLocationId'),
                            strStorageLocationName: order.get('strStorageLocationName'),
                            strOrderUOM: order.get('strOrderUOM'),
                            dblOrderUOMConvFactor: order.get('dblOrderUOMConvFactor'),
                            intUnitMeasureId: order.get('intItemUOMId'),
                            strUnitMeasure: order.get('strUnitMeasure'),
                            strUnitType: order.get('strUnitType'),
                            strWeightUOM: order.get('strWeightUOM'),
                            intWeightUOMId: order.get('intWeightUOMId'),
                            dblItemUOMConvFactor: order.get('dblItemUOMConvFactor'),
                            dblWeightUOMConvFactor: order.get('dblWeightUOMConvFactor'),
                            intCostUOMId: order.get('intCostUOMId'),
                            strCostUOM: order.get('strCostUOM'),
                            dblCostUOMConvFactor: order.get('dblCostUOMConvFactor'),
                            dblGrossMargin: order.get('dblGrossMargin'),
                            intGradeId: order.get('intGradeId'),
                            strGrade: order.get('strGrade'),
                            intLifeTime: order.get('intLifeTime'),
                            strLifeTimeType: order.get('strLifeTimeType'),
                            ysnLoad: order.get('ysnLoad'),
                            dblAvailableQty: order.get('dblAvailableQty'),
                            intOwnershipType: 1,
                            strOwnershipType: 'Own',
                            dblFranchise: order.get('dblFranchise'),
                            dblContainerWeightPerQty: order.get('dblContainerWeightPerQty'),
                            ysnSubCurrency: order.get('ysnSubCurrency'),
                            strSubCurrency: order.get('strSubCurrency'),
                            dblGross: order.get('dblGross'),
                            dblNet: order.get('dblNet')
                        };
                        currentVM.set('strBillOfLading', order.get('strBOL'));

                        // Add the item record.
                        var newReceiptItems = currentVM.tblICInventoryReceiptItems().add(newRecord);

                        // Calculate the line total
                        var newReceiptItem = newReceiptItems.length > 0 ? newReceiptItems[0] : null;
                        newReceiptItem.set('dblLineTotal', me.calculateLineTotal(currentVM, newReceiptItem));

                        // Calculate the taxes
                        win.viewModel.data.currentReceiptItem = newReceiptItem;
                        me.calculateItemTaxes();

                        if (ReceiptType === 'Purchase Contract') {
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
                                                    var receiptCharges = currentVM.tblICInventoryReceiptCharges().data.items;
                                                    var exists = Ext.Array.findBy(receiptCharges, function (row) {
                                                        if ((row.get('intContractId') === order.get('intOrderId')
                                                            && row.get('intChargeId') === otherCharge.intItemId)) {
                                                            return true;
                                                        }
                                                    });

                                                    if (!exists) {
                                                        var newReceiptCharge = Ext.create('Inventory.model.ReceiptCharge', {
                                                            intInventoryReceiptId: currentVM.get('intInventoryReceiptId'),
                                                            intContractId: order.get('intOrderId'),
                                                            intContractDetailId: otherCharge.intContractDetailId,
                                                            intChargeId: otherCharge.intItemId,
                                                            ysnInventoryCost: false,
                                                            strCostMethod: otherCharge.strCostMethod,
                                                            dblRate: otherCharge.strCostMethod == "Amount" ? 0 : otherCharge.dblRate,
                                                            intCostUOMId: otherCharge.intItemUOMId,
                                                            intEntityVendorId: otherCharge.intVendorId,
                                                            dblAmount: otherCharge.strCostMethod == "Amount" ? otherCharge.dblRate : 0,
                                                            strAllocateCostBy: 'Unit',
                                                            ysnAccrue: otherCharge.ysnAccrue,
                                                            ysnPrice: otherCharge.ysnPrice,
                                                            strItemNo: otherCharge.strItemNo,
                                                            intCurrencyId: otherCharge.intCurrencyId,
                                                            strCurrency: otherCharge.strCurrency,
                                                            ysnSubCurrency: otherCharge.ysnSubCurrency,
                                                            strCostUOM: otherCharge.strUOM,
                                                            strVendorName: otherCharge.strVendorName,
                                                            strContractNumber: order.get('strOrderNumber')

                                                        });
                                                        currentVM.tblICInventoryReceiptCharges().add(newReceiptCharge);
                                                    }
                                                });
                                            }
                                        });
                                    }
                                }
                            });
                        }
                        
                        if (order.get('strLotTracking') !== 'No' && newReceiptItem.get('intWeightUOMId') === null) {
                                //Set default value for Gross/Net UOM
                                newReceiptItem.set('intWeightUOMId', order.get('intItemUOMId'));
                                newReceiptItem.set('strWeightUOM', order.get('strUnitMeasure'));
                                newReceiptItem.set('dblGross', order.get('dblQtyToReceive'));
                                newReceiptItem.set('dblNet', order.get('dblQtyToReceive'));
                                newReceiptItem.set('dblWeightUOMConvFactor', order.get('dblItemUOMConvFactor'));
                            
                               //Calculate Line Total
                                var currentReceipt  = win.viewModel.data.current;
                                newReceiptItem.set('dblLineTotal', me.calculateLineTotal(currentReceipt, newReceiptItem));
                            }
                        
                        if (order.get('intWeightUOMId') !== null) {
                             if (order.get('dblGross') === 0 && order.get('dblNet') !== 0) {
                                 newReceiptItem.set('dblGross', order.get('dblNet'));
                             }  
                            
                             else if (order.get('dblGross') !== 0 && order.get('dblNet') === 0) {
                                 newReceiptItem.set('dblNet', order.get('dblGross'));
                             }  
                            
                             else if (order.get('dblGross') === 0 && order.get('dblNet') === 0) {
                                var currentReceiptItem = win.viewModel.data.currentReceiptItem;
                                me.calculateGrossNet(currentReceiptItem, 1);
                             }
                        }
                    });
                    search.close();
                    //win.context.data.saveRecord();
                },
                openallclick: function () {
                    search.close();
                }
            });
            search.show();
        };
        showAddScreen();
    },

    onReplicateBalanceLotClick: function(button) {
        var me = this;
        var win = button.up('window');
        var grdLotTracking = win.down('grdLotTracking');
        var currentReceiptItem = win.viewModel.data.currentReceiptItem;
        var lineItemQty = currentReceiptItem.get('dblOpenReceive');
        var lineItemCF = currentReceiptItem.get('dblItemUOMConvFactor');

        // Validate the lot qty.
        if (lineItemQty <= 0) {
            iRely.Functions.showErrorDialog('Cannot replicate zero Qty to Receive.');
            return;
        }

        if (currentReceiptItem) {
            var grdLotTracking = win.down('#grdLotTracking');
            var selectedLot = grdLotTracking.getSelectionModel().getSelection();

            if (selectedLot.length <= 0){
                iRely.Functions.showErrorDialog('Please select a lot to replicate.');
                return;
            }

            // Get the first lot record (if there are multiple selected)
            var currentLot = selectedLot[0];

            // Get the lot qty.
            var lotQty = currentLot.get('dblQuantity');

            // Validate the lot qty.
            if (lotQty <= 0) {
                iRely.Functions.showErrorDialog('Cannot replicate zero Lot Quantity.');
                return;
            }

            // Initialize the other variables.
            var lastGrossWgt = currentLot.get('dblGrossWeight'),
                lotGrossWgt = currentLot.get('dblGrossWeight');

            var lastTareWgt = currentLot.get('dblTareWeight'),
                lotTareWgt = currentLot.get('dblTareWeight');

            var lastNetWgt = currentLot.get('dblNetWeight'),
                lotNetWgt = currentLot.get('dblNetWeight');

            var strUnitType = currentLot.get('strUnitType');

            var lotCF = currentLot.get('dblLotUOMConvFactor');
            var grossCF = currentReceiptItem.get('dblWeightUOMConvFactor');

            // Convert the item qty into lot-qty-uom
            var convertedItemQty = me.convertQtyBetweenUOM(lineItemCF, lotCF, lineItemQty);

            // Calculate the last qty.
            var lastQty = (convertedItemQty % lotQty) > 0 ? convertedItemQty % lotQty : lotQty;

            // Initialize the target tare weight.
            var addedTareWeight = 0.00;

            // If Unit-Type is a 'Packed' type, get the ceiling value. A packaging can't have a fractional value.
            if (strUnitType == "Packed")
            {
                addedTareWeight = me.convertQtyBetweenUOM(lotCF, grossCF, lastQty);
                lastQty = Math.ceil(lastQty);
                addedTareWeight = me.convertQtyBetweenUOM(lotCF, grossCF, lastQty) - addedTareWeight;
              // addedTareWeight = i21.ModuleMgr.Inventory.roundDecimalValue(addedTareWeight, 6);
            }
           /* else {
                lastQty = i21.ModuleMgr.Inventory.roundDecimalValue(lastQty, 6);
            }*/

            // Calculate how many times to loop.
            var replicaCount = (convertedItemQty - lastQty) / lotQty;
            replicaCount = Math.ceil(replicaCount);

            // Calculate the last Gross and Tare weights.
            if ((replicaCount * lotQty) < convertedItemQty ) {
                // Compute the last gross qty.
                if (lastGrossWgt > 0) {
                    lastGrossWgt = me.convertQtyBetweenUOM(lotCF, grossCF, lastQty);
                }

                // Compute the last net weight.
                
                    lastGrossWgt = Ext.isNumeric(lastGrossWgt) ? lastGrossWgt : 0;
                    lastTareWgt = Ext.isNumeric(lastTareWgt) ? lastTareWgt + addedTareWeight: addedTareWeight;
                    lastNetWgt = lastGrossWgt - lastTareWgt;
                
            }
            else {
                replicaCount -= 1;
            }

            if (replicaCount == 0) {
                iRely.Msg.showQuestion('The lots for ' + currentReceiptItem.get('strItemNo') +
                    ' is fully replicated. Are you sure you want to continue?',
                    function(p) {
                        if (p === 'no') {
                            grdLotTracking.resumeEvents(true);
                            return;
                        } else {
                            var newLot = Ext.create('Inventory.model.ReceiptItemLot', {
                                strUnitMeasure: currentLot.get('strUnitMeasure'),
                                intItemUnitMeasureId: currentLot.get('intItemUnitMeasureId'),
                                dblNetWeight: lotNetWgt,
                                dblStatedNetPerUnit: currentLot.get('dblStatedNetPerUnit'),
                                dblPhyVsStated: currentLot.get('dblPhyVsStated'),
                                strOrigin: currentLot.get('strOrigin'),
                                intSubLocationId: currentLot.get('intSubLocationId'),
                                intStorageLocationId: currentLot.get('intStorageLocationId'),
                                dblQuantity: lotQty,
                                dblGrossWeight: lotGrossWgt,
                                dblTareWeight: lotTareWgt,
                                dblCost: currentLot.get('dblCost'),
                                intUnitPallet: currentLot.get('intUnitPallet'),
                                dblStatedGrossPerUnit: currentLot.get('dblStatedGrossPerUnit'),
                                dblStatedTarePerUnit: currentLot.get('dblStatedTarePerUnit'),
                                strContainerNo: currentLot.get('strContainerNo'),
                                intEntityVendorId: currentLot.get('intEntityVendorId'),
                                strGarden: currentLot.get('strGarden'),
                                strMarkings: currentLot.get('strMarkings'),
                                strGrade: currentLot.get('strGrade'),
                                intOriginId: currentLot.get('intOriginId'),
                                intSeasonCropYear: currentLot.get('intSeasonCropYear'),
                                strVendorLotId: currentLot.get('strVendorLotId:'),
                                dtmManufacturedDate: currentLot.get('dtmManufacturedDate'),
                                strRemarks: currentLot.get('strRemarks'),
                                strCondition: currentLot.get('strCondition'),
                                dtmCertified: currentLot.get('dtmCertified'),
                                dtmExpiryDate: currentLot.get('dtmExpiryDate'),
                                intSort: currentLot.get('intSor:'),
                                strWeightUOM: currentLot.get('strWeightUOM'),
                                intParentLotId: currentLot.get('intParentLotId'),
                                strParentLotNumber: currentLot.get('strParentLotNumber'),
                                strParentLotAlias: currentLot.get('strParentLotAlias'),
                                strStorageLocation: currentLot.get('strStorageLocation'),
                                strSubLocationName: currentLot.get('strSubLocationName'),
                                dblLotUOMConvFactor: currentLot.get('dblLotUOMConvFactor')
                            });

                            grdLotTracking.suspendEvents(true);
                            currentReceiptItem.tblICInventoryReceiptItemLots().add(newLot);
                            grdLotTracking.resumeEvents(true);
                            //Calculate Gross/Net
                            me.calculateGrossNet(currentReceiptItem, 1);

                            //Calculate Line Total
                            var currentReceipt  = win.viewModel.data.current;
                            currentReceiptItem.set('dblLineTotal', me.calculateLineTotal(currentReceipt, currentReceiptItem));
                        }
                    }, Ext.MessageBox.YESNO, win);
            }

            // Show a progress message box.
            Ext.MessageBox.show({
                    title: "Please wait.",
                    msg: "Replicating as " + replicaCount + " copies of the lot.",
                    progressText: "Initializing...",
                    width: 300,
                    progress: true,
                    closable: false
                }
            );

            // Function generator for the setTimeout.
            // Used to update the progress of the message box and hide it when done with the loop.
            var f = function(ctr, replicaCount){
                return function(){
                    if(ctr === replicaCount - 1){
                        Ext.MessageBox.hide();
                    }else{
                        var progress = ctr / (replicaCount - 1);
                        Ext.MessageBox.updateProgress(progress, Math.round(100 * progress)+ '% completed');
                    }
                };
            };

            // This function will do a loop to replicate the lots.

            var doReplicateLot = function (){
                for (var ctr = 0; ctr <= replicaCount - 1; ctr++) {
                    var newLot = Ext.create('Inventory.model.ReceiptItemLot', {
                        strUnitMeasure: currentLot.get('strUnitMeasure'),
                        intItemUnitMeasureId: currentLot.get('intItemUnitMeasureId'),
                        dblNetWeight: ctr === replicaCount - 1 ? lastNetWgt : lotNetWgt,
                        dblStatedNetPerUnit: currentLot.get('dblStatedNetPerUnit'),
                        dblPhyVsStated: currentLot.get('dblPhyVsStated'),
                        strOrigin: currentLot.get('strOrigin'),
                        intSubLocationId: currentLot.get('intSubLocationId'),
                        intStorageLocationId: currentLot.get('intStorageLocationId'),
                        dblQuantity: ctr === replicaCount - 1 ? lastQty : lotQty,
                        dblGrossWeight: ctr === replicaCount - 1 ? lastGrossWgt : lotGrossWgt,
                        dblTareWeight: ctr === replicaCount - 1 ? lastTareWgt : lotTareWgt,
                        dblCost: currentLot.get('dblCost'),
                        intUnitPallet: currentLot.get('intUnitPallet'),
                        dblStatedGrossPerUnit: currentLot.get('dblStatedGrossPerUnit'),
                        dblStatedTarePerUnit: currentLot.get('dblStatedTarePerUnit'),
                        strContainerNo: currentLot.get('strContainerNo'),
                        intEntityVendorId: currentLot.get('intEntityVendorId'),
                        strGarden: currentLot.get('strGarden'),
                        strMarkings: currentLot.get('strMarkings'),
                        strGrade: currentLot.get('strGrade'),
                        intOriginId: currentLot.get('intOriginId'),
                        intSeasonCropYear: currentLot.get('intSeasonCropYear'),
                        strVendorLotId: currentLot.get('strVendorLotId:'),
                        dtmManufacturedDate: currentLot.get('dtmManufacturedDate'),
                        strRemarks: currentLot.get('strRemarks'),
                        strCondition: currentLot.get('strCondition'),
                        dtmCertified: currentLot.get('dtmCertified'),
                        dtmExpiryDate: currentLot.get('dtmExpiryDate'),
                        intSort: currentLot.get('intSor:'),
                        strWeightUOM: currentLot.get('strWeightUOM'),
                        intParentLotId: currentLot.get('intParentLotId'),
                        strParentLotNumber: currentLot.get('strParentLotNumber'),
                        strParentLotAlias: currentLot.get('strParentLotAlias'),
                        strStorageLocation: currentLot.get('strStorageLocation'),
                        strSubLocationName: currentLot.get('strSubLocationName'),
                        dblLotUOMConvFactor: currentLot.get('dblLotUOMConvFactor')
                    });

                    grdLotTracking.suspendEvents(true);

                    var totalLotQty = 0;

                    currentReceiptItem.tblICInventoryReceiptItemLots().each(function(lot) {
                        totalLotQty += lot.get('dblQuantity');
                    });

                    totalLotQty += (ctr === replicaCount - 1 ? lastQty : lotQty);

                    if (totalLotQty > lineItemQty) {
                        var itemNo = currentReceiptItem.get('strItemNo');
                        iRely.Msg.showQuestion('The lots for ' + itemNo + ' is fully replicated. Are you sure you want to continue?',
                            function(p) {
                                if (p === 'no') {
                                    grdLotTracking.resumeEvents(true);
                                    return;
                                } else {
                                    currentReceiptItem.tblICInventoryReceiptItemLots().add(newLot);
                                }
                            }, Ext.MessageBox.YESNO, win);
                    } else {
                        currentReceiptItem.tblICInventoryReceiptItemLots().add(newLot);
                    }

                    // call f function from above within a setTimeout.
                    setTimeout(f(ctr, replicaCount), (ctr + 1) * 25);

                    if ( ctr === replicaCount - 1){
                        grdLotTracking.resumeEvents(true);
                        //Calculate Gross/Net
                        me.calculateGrossNet(currentReceiptItem, 1);

                        //Calculate Line Total
                        var currentReceipt  = win.viewModel.data.current;
                        currentReceiptItem.set('dblLineTotal', me.calculateLineTotal(currentReceipt, currentReceiptItem));
                    }
                }
            };

            // Call doReplicateLot in a setTimeout to give chance for the msg box to appear.
            setTimeout(doReplicateLot, 200);
        }
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

    onBtnVendorClick: function () {
         iRely.Functions.openScreen('EntityManagement.view.Entity:searchEntityVendor', { action: 'new', viewConfig: { modal: true }});
    },

    onVendorDrilldown: function(combo) {
        var win = combo.up('window');
        var current = win.viewModel.data.current;
        
        if (iRely.Functions.isEmpty(combo.getValue())) {
            iRely.Functions.openScreen('EntityManagement.view.Entity:searchEntityVendor', { action: 'new', viewConfig: { modal: true }});
        }
        else {
              iRely.Functions.openScreen('EntityManagement.view.Entity:searchEntityVendor', {
                filters: [
                    {
                        column: 'intEntityId',
                        value: current.get('intEntityVendorId')
                    }
                ]
            });
        }
    },

    onLocationDrilldown: function(combo) {
        if (iRely.Functions.isEmpty(combo.getValue())) {
            iRely.Functions.openScreen('i21.view.CompanyLocation', { action: 'new', viewConfig: { modal: true }});
        }
        else {
            i21.ModuleMgr.Inventory.showScreen(combo.getRawValue(), 'LocationName');
        }
    },

    onTaxGroupDrilldown: function(combo) {
        if (iRely.Functions.isEmpty(combo.getValue())) {
            iRely.Functions.openScreen('i21.view.TaxGroup', { action: 'new', viewConfig: { modal: true }});
        }
        else {
            i21.ModuleMgr.Inventory.showScreen(combo.getRawValue(), 'TaxGroup');
        }
    },

    onCurrencyDrilldown: function(combo) {
        iRely.Functions.openScreen('i21.view.Currency', {viewConfig: { modal: true }});
    },

    getWeightLoss: function(ReceiptItems, sourceType, action)
    {
        var dblWeightLoss = 0;
        var dblNetShippedWt = 0;
        var dblNetReceivedWt = 0;
        var dblFranchise = 0;

        Ext.Array.each(ReceiptItems, function (item)
        {
            if (item.dummy) {

            }
            else {
              /*  dblFranchise = item.data.dblFranchise;
                dblNetShippedWt = item.data.dblOrderQty * item.data.dblContainerWeightPerQty;
                dblNetReceivedWt = item.data.dblNet;

                if (dblFranchise > 0)
                    dblNetShippedWt = (dblNetShippedWt) - (dblNetShippedWt * dblFranchise);
                if ((dblNetReceivedWt - dblNetShippedWt) !== 0)
                    dblWeightLoss = dblWeightLoss + (dblNetReceivedWt - dblNetShippedWt);*/
                
                
                // Check if item is Inbound Shipment
                if(sourceType === 2)
                    {
                        dblNetReceivedWt = item.data.dblNet;
                        dblNetShippedWt = item.data.dblOrderQty * item.data.dblContainerWeightPerQty;              
                        dblWeightLoss = dblNetReceivedWt - dblNetShippedWt;
                    }
                else
                    {
                        dblWeightLoss = 0;
                    }
                
            }
        });

        action(dblWeightLoss);
    },

    validateWeightLoss: function(win, ReceiptItems) {
        win.viewModel.data.weightLoss = 0;
        var action = function(weightLoss) {
            win.viewModel.set('weightLoss', weightLoss);
        };

        var ReceiptItems = win.viewModel.data.current.tblICInventoryReceiptItems();
        
        var current = win.viewModel.data.current;
        var sourceType = current.get('intSourceType');
            
        if (ReceiptItems) {
            this.getWeightLoss(ReceiptItems.data.items, sourceType, action);
        }

    },

    onCalculateChargeClick: function (button, e, eOpts) {
        var win = button.up('window');
        var context = win.context;
        var current = win.viewModel.data.current;

        var doPost = function () {
            if (current) {
                Ext.Ajax.request({
                    timeout: 120000,
                    url: '../Inventory/api/InventoryReceipt/CalculateCharges?id=' + current.get('intInventoryReceiptId'),
                    method: 'post',
                    success: function (response) {
                        var jsonData = Ext.decode(response.responseText);
                        if (!jsonData.success) {
                            iRely.Functions.showErrorDialog(jsonData.message.statusText);
                        }
                        else {
                            context.configuration.paging.store.load();
                        }
                    },
                    failure: function (response) {
                        var jsonData = Ext.decode(response.responseText);
                        iRely.Functions.showErrorDialog(jsonData.ExceptionMessage);
                    }
                });
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

    onPostedTransactionBeforeCheckChange: function (obj, rowIndex, checked, eOpts) {
        var grid = obj.up('grid');
        var win = obj.up('window');
        var current = win.viewModel.data.current;
        if (current && current.get('ysnPosted') === true){
                return false;
        }
    },
    
    onLocationBeforeSelect: function (combo, record, index, eOpts) {
        var win = combo.up('window');
        var current = win.viewModel.data.current;
        
        Inventory.view.InventoryReceiptViewController.orgValueLocation = current.get('intLocationId');
    },

    init: function (application) {
        this.control({
            "#cboVendor": {
                beforequery: this.onShipFromBeforeQuery,
                select: this.onVendorSelect,
                drilldown: this.onVendorDrilldown
            },
            "#cboLocation": {
                drilldown: this.onLocationDrilldown,
                beforeselect: this.onLocationBeforeSelect,
                select: this.onLocationSelect
            },
            "#cboCurrency": {
                drilldown: this.onCurrencyDrilldown,
                select: this.onCurrencySelect
            },
            "#cboTaxGroup": {
                drilldown: this.onTaxGroupDrilldown
            },
            "#cboTransferor": {
                select: this.onTransferorSelect
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
            "#btnBill": {
                click: this.onBillClick
            },
            "#btnViewItem": {
                click: this.onInventoryClick
            },
            "#btnViewOtherCharge": {
                click: this.onOtherChargeClick
            },
            "#btnQuality": {
                click: this.onQualityClick
            },
            "#btnTaxDetails": {
                click: this.onTaxDetailsClick
            },
            "#btnVendor": {
                click: this.onVendorClick
            },
            "#btnInsertInventoryReceipt": {
                click: this.onInsertChargeClick
            },
            "#btnAddOrders": {
                click: this.onAddOrderClick
            },
            "#btnInsertLot": {
                click: this.onInsertChargeClick
            },
            "#btnReplicateBalanceLots": {
                click: this.onReplicateBalanceLotsClick
            },
            "#btnPrintLabel": {
                click: this.onPrintLabelClick
            },
            "#btnInsertCharge": {
                click: this.onInsertChargeClick
            },
            "#btnshowOtherCharges": {
                click: this.onShowOtherChargesClick
            },
            "#cboShipFrom": {
                beforequery: this.onShipFromBeforeQuery,
                select: this.onShipFromSelect
            },
            "#cboOrderNumber": {
                beforequery: this.onShipFromBeforeQuery,
                select: this.onOrderNumberSelect
            },
            "#cboSourceNumber": {
                select: this.onSourceNumberSelect,
                beforeSelect: this.onSourceNumberBeforeSelect
            },
            "#colOrderNumber": {
                beforerender: this.onItemGridColumnBeforeRender
            },
            "#colSourceNumber": {
                beforerender: this.onItemGridColumnBeforeRender
            },
            "#colLotUOM": {
                beforerender: this.onLotGridColumnBeforeRender
            },
            "#colWeightUOM": {
                change: this.onWeightUOMChange
            },
            "#txtShiftNumber": {
                specialKey: this.onSpecialKeyTab
            },
            "#grdInventoryReceipt": {
                selectionchange: this.onItemSelectionChange
            },
            "#cboLotUOM": {
                select: this.onLotSelect
            },
            "#cboWeightUOM": {
                select: this.onReceiptItemSelect
            },
            "#cboCostUOM": {
                select: this.onReceiptItemSelect
            },
            "#cboStorageLocation": {
                select: this.onReceiptItemSelect
            },
            "#cboOtherCharge": {
                select: this.onChargeSelect
            },
            "#colAccrue": {
                beforecheckchange: this.onAccrueCheckChange
            },
            "#btnReplicateBalanceLots": {
                click: this.onReplicateBalanceLotClick
            },
            "#cboChargeCurrency": {
                select: this.onChargeSelect
            },
            "#cboItemSubCurrency": {
                select: this.onReceiptItemSelect
            },
            "#btnCalculateCharges": {
                click: this.onCalculateChargeClick
            },
            "#colChargeCurrency": {
                select: this.onChargeSelect
            },
            "#colLoadContract": {
                beforecheckchange: this.onPostedTransactionBeforeCheckChange
            }
        })
    }

});
