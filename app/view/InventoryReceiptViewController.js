Ext.define('Inventory.view.InventoryReceiptViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.icinventoryreceipt',

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
                {dataIndex: 'strReceiptType', text: 'Receipt Type', flex: 1, dataType: 'string'},
                {dataIndex: 'strVendorName', text: 'Vendor Name', flex: 1, dataType: 'string', drillDownText: 'View Vendor', drillDownClick: 'onViewVendorName'},
                {dataIndex: 'strLocationName', text: 'Location Name', flex: 1, dataType: 'string', drillDownText: 'View Location', drillDownClick: 'onViewLocationName'},
                {dataIndex: 'strBillOfLading', text: 'Bill Of Lading No', flex: 1, dataType: 'string'},
                {dataIndex: 'ysnPosted', text: 'Posted', flex: 1, dataType: 'boolean', xtype: 'checkcolumn'},

                {dataIndex: 'strSourceType', text: 'strSourceType', flex: 1, dataType: 'string', hidden: true },
                {dataIndex: 'strVendorId', text: 'strVendorId', flex: 1, dataType: 'string', hidden: true },
                {dataIndex: 'strTransferor', text: 'strTransferor', flex: 1, dataType: 'string', hidden: true },
                {dataIndex: 'strCurrency', text: 'strCurrency', flex: 1, dataType: 'string', hidden: true },
                {dataIndex: 'intBlanketRelease', text: 'intBlanketRelease', flex: 1, dataType: 'int', hidden: true },
                {dataIndex: 'strVendorRefNo', text: 'strVendorRefNo', flex: 1, dataType: 'string', hidden: true },
                {dataIndex: 'strShipVia', text: 'strShipVia', flex: 1, dataType: 'string', hidden: true },
                {dataIndex: 'strShipFrom', text: 'strShipFrom', flex: 1, dataType: 'string', hidden: true },
                {dataIndex: 'strReceiver', text: 'strReceiver', flex: 1, dataType: 'string', hidden: true },
                {dataIndex: 'strVessel', text: 'strVessel', flex: 1, dataType: 'string', hidden: true },
                {dataIndex: 'strFreightTerm', text: 'strFreightTerm', flex: 1, dataType: 'string', hidden: true },
                {dataIndex: 'strFobPoint', text: 'strFobPoint', flex: 1, dataType: 'string', hidden: true },
                {dataIndex: 'intShiftNumber', text: 'intShiftNumber', flex: 1, dataType: 'int', hidden: true },
                {dataIndex: 'dblInvoiceAmount', text: 'dblInvoiceAmount', flex: 1, dataType: 'float', hidden: true },
                {dataIndex: 'ysnPrepaid', text: 'ysnPrepaid', flex: 1, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                {dataIndex: 'ysnInvoicePaid', text: 'ysnInvoicePaid', flex: 1, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                {dataIndex: 'intCheckNo', text: 'intCheckNo', flex: 1, dataType: 'int', hidden: true },
                {dataIndex: 'dtmCheckDate', text: 'dtmCheckDate', flex: 1, dataType: 'date', xtype: 'datecolumn', hidden: true },
                {dataIndex: 'intTrailerTypeId', text: 'intTrailerTypeId', flex: 1, dataType: 'int', hidden: true },
                {dataIndex: 'dtmTrailerArrivalDate', text: 'dtmTrailerArrivalDate', flex: 1, dataType: 'date', xtype: 'datecolumn', hidden: true },
                {dataIndex: 'dtmTrailerArrivalTime', text: 'dtmTrailerArrivalTime', flex: 1, dataType: 'date', xtype: 'datecolumn', hidden: true },
                {dataIndex: 'strSealNo', text: 'strSealNo', flex: 1, dataType: 'string', hidden: true },
                {dataIndex: 'strSealStatus', text: 'strSealStatus', flex: 1, dataType: 'string', hidden: true },
                {dataIndex: 'dtmReceiveTime', text: 'dtmReceiveTime', flex: 1, dataType: 'date', xtype: 'datecolumn', hidden: true },
                {dataIndex: 'dblActualTempReading', text: 'dblActualTempReading', flex: 1, dataType: 'float', hidden: true },
                {dataIndex: 'strEntityName', text: 'strEntityName', flex: 1, dataType: 'string', hidden: true },
                {dataIndex: 'strActualCostId', text: 'strActualCostId', flex: 1, dataType: 'string', hidden: true }
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
                    clickHandler: 'onVendorClick',
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
                        {dataIndex: 'strReceiptType', text: 'Receipt Type', flex: 1, dataType: 'string'},
                        {dataIndex: 'strItemNo', text: 'Item No', flex: 1, dataType: 'string', drillDownText: 'View Item', drillDownClick: 'onViewItemNo'},
                        {dataIndex: 'strItemDescription', text: 'Description', flex: 1, dataType: 'string', drillDownText: 'View Item', drillDownClick: 'onViewItemNo'},
                        {dataIndex: 'strOrderNumber', text: 'Order Number', flex: 1, dataType: 'string'},
                        {dataIndex: 'strSourceNumber', text: 'Source Number', flex: 1, dataType: 'string'},
                        {dataIndex: 'strUnitMeasure', text: 'Receipt UOM', flex: 1, dataType: 'string'},

                        { xtype: 'numbercolumn', dataIndex: 'dblQtyToReceive', text: 'Qty to Receive', flex: 1, dataType: 'float'},
                        { xtype: 'numbercolumn', dataIndex: 'dblUnitCost', text: 'Cost', flex: 1, dataType: 'float'},
                        { xtype: 'numbercolumn', dataIndex: 'dblTax', text: 'Tax', flex: 1, dataType: 'float'},
                        { xtype: 'numbercolumn', dataIndex: 'dblLineTotal', text: 'Line Total', flex: 1, dataType: 'float'},

                        {dataIndex: 'strCostUOM', text: 'Cost UOM', flex: 1, dataType: 'string', hidden: true},
                        {dataIndex: 'dtmReceiptDate', text: 'Receipt Date', flex: 1, dataType: 'date', xtype: 'datecolumn', hidden: true},
                        {dataIndex: 'strVendorName', text: 'Vendor Name', flex: 1, dataType: 'string', drillDownText: 'View Vendor', drillDownClick: 'onViewVendorName', hidden: true},
                        {dataIndex: 'strLocationName', text: 'Location Name', flex: 1, dataType: 'string', drillDownText: 'View Location', drillDownClick: 'onViewLocationName', hidden: true},
                        {dataIndex: 'strBillOfLading', text: 'Bill Of Lading No', flex: 1, dataType: 'string', hidden: true},
                        {dataIndex: 'ysnPosted', text: 'Posted', flex: 1, dataType: 'boolean', xtype: 'checkcolumn', hidden: true}
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
                        {dataIndex: 'strReceiptType', text: 'Receipt Type', flex: 1, dataType: 'string'},
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
                }
            ]
        },
        binding: {
            bind: {
                title: 'Inventory Receipt - {current.strReceiptNumber}'
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
            btnReceive: {
                text: '{getReceiveButtonText}',
                hidden: '{checkTransportPosting}'
            },
            btnAddOrders: {
                hidden: '{checkHiddenAddOrders}'
            },

            cboReceiptType: {
                value: '{current.strReceiptType}',
                store: '{receiptTypes}',
                readOnly: '{checkReadOnlyWithOrder}'
            },
            cboSourceType: {
                value: '{current.intSourceType}',
                store: '{sourceTypes}',
                readOnly: '{disableSourceType}'
            },
            cboVendor: {
                value: '{current.intEntityVendorId}',
                store: '{vendor}',
                readOnly: '{checkReadOnlyWithOrder}',
                hidden: '{checkHiddenInTransferOrder}'
            },
            cboTransferor: {
                value: '{current.intTransferorId}',
                store: '{transferor}',
                hidden: '{checkHiddenIfNotTransferOrder}'
            },
            cboLocation: {
                value: '{current.intLocationId}',
                store: '{location}',
                readOnly: '{checkReadOnlyWithOrder}'
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
                defaultFilters: [
                    {
                        column: 'intEntityId',
                        value: '{current.intEntityVendorId}'
                    }
                ],
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
                defaultFilters: [
                    {
                        column: 'ysnActive',
                        value: 'true'
                    }
                ],
                readOnly: '{current.ysnPosted}'
            },
            txtFobPoint: {
                value: '{current.strFobPoint}',
                readOnly: '{current.ysnPosted}'
            },
            cboTaxGroup: {
                value: '{current.intTaxGroupId}',
                store: '{taxGroup}',
                readOnly: '{current.ysnPosted}'
            },
            txtShiftNumber: {
                value: '{current.intShiftNumber}',
                readOnly: '{current.ysnPosted}'
            },
            btnInsertInventoryReceipt: {
                hidden: '{current.ysnPosted}'
            },
            btnRemoveInventoryReceipt: {
                hidden: '{current.ysnPosted}'
            },
            btnInsertLot: {
                hidden: '{current.ysnPosted}'
            },
            btnRemoveLot: {
                hidden: '{current.ysnPosted}'
            },
            btnReplicateBalanceLots: {
                hidden: '{current.ysnPosted}'
            },
            btnPrintLabel: {
                hidden: '{!current.ysnPosted}'
            },
            btnInsertCharge: {
                hidden: '{current.ysnPosted}'
            },
            btnRemoveCharge: {
                hidden: '{current.ysnPosted}'
            },
            btnCalculateCharges: {
                hidden: '{current.ysnPosted}'
            },
            btnBill: {
                hidden: '{!current.ysnPosted}'
            },
            btnQuality: {
                hidden: '{current.ysnPosted}'
            },

            grdInventoryReceipt: {
                readOnly: '{readOnlyReceiptItemGrid}',
                colOrderNumber: {
                    hidden: '{checkHideOrderNo}',
                    dataIndex: 'strOrderNumber',
                    editor: {
                        readOnly: '{readOnlyOrderNumberDropdown}',
                        store: '{orderNumbers}',
                        defaultFilters: [
                            {
                                column: 'ysnCompleted',
                                value: 'false',
                                conjunction: 'and'
                            },
                            {
                                column: 'intEntityVendorId',
                                value: '{current.intEntityVendorId}',
                                conjunction: 'and'
                            }
                        ]
                    }
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
                    hidden: '{checkHideLoadContract}',
                    dataIndex: 'strOrderUOM'
                },
                colQtyOrdered: {
                    hidden: '{checkHideLoadContract}',
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
                        origValueField: 'intCostUOMId',
                        origUpdateField: 'intCostUOMId',
                        store: '{costUOM}',
                        defaultFilters: [
                            {
                                column: 'intItemId',
                                value: '{grdInventoryReceipt.selection.intItemId}',
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

            pnlLotTracking: {
                hidden: '{hasItemSelection}'
            },
            grdLotTracking: {
                readOnly: '{current.ysnPosted}',
                colLotId: {
                    dataIndex: 'strLotNumber'
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
                readOnly: '{current.ysnPosted}',
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
                colRate: 'dblRate',
                colCostUOM: {
                    dataIndex: 'strCostUOM',
                    editor: {
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
                colChargeAmount: 'dblAmount',
                colAllocateCostBy: {
                    dataIndex: 'strAllocateCostBy',
                    editor: {
                        readOnly: '{checkInventoryCost}',
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

    setupContext: function (options) {
        "use strict";
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.Receipt', { pageSize: 1, window: options.window });

        var grdInventoryReceipt = win.down('#grdInventoryReceipt'),
            grdIncomingInspection = win.down('#grdIncomingInspection'),
            grdLotTracking = win.down('#grdLotTracking'),
            grdCharges = win.down('#grdCharges');

        grdInventoryReceipt.mon(grdInventoryReceipt, {
            afterlayout: me.onGridAfterLayout
        });

        win.context = Ext.create('iRely.mvvm.Engine', {
            window: win,
            store: store,
            createRecord: me.createRecord,
            validateRecord: me.validateRecord,
            binding: me.config.binding,
            enableComment: true,
            enableAudit: true,
            include: 'tblICInventoryReceiptInspections,' +
                'vyuICGetInventoryReceipt,' +
                'tblICInventoryReceiptItems.vyuICGetInventoryReceiptItem,' +
                'tblICInventoryReceiptItems.tblICInventoryReceiptItemLots.vyuICGetInventoryReceiptItemLot, ' +
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
                        deleteButton: grdCharges.down('#btnRemoveCharge')
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
                validateedit: me.onEditLots,
                scope: me
            });
        }

        var cepItem = grdInventoryReceipt.getPlugin('cepItem');
        if (cepItem) {
            cepItem.on({
                validateedit: me.onEditItem,
                scope: me
            });
        }

        var cepCharges = grdCharges.getPlugin('cepCharges');
        if (cepCharges) {
            cepCharges.on({
                validateedit: me.onEditCharge,
                scope: me
            });
        }

        var colTax = grdInventoryReceipt.columns[10];
        if (colTax) {
            colTax.summaryRenderer = function (val, params, data) {
                return Ext.util.Format.number(val, '0,000.00');
            }
        }

        var colGross = grdInventoryReceipt.columns[13];
        if (colGross) {
            colGross.summaryRenderer = function (val, params, data) {
                var win = me.getView();
                var current = win.viewModel.data.current;

                var value = me.calculateCharges(current);
                var finalValue = Ext.util.Format.number(value, '0,000.00');

                return 'Total Charges: ' + finalValue + '';
            }
        }
        var colNet = grdInventoryReceipt.columns[14];
        if (colNet) {
            colNet.summaryRenderer = function (val, params, data) {
                var win = me.getView();
                var current = win.viewModel.data.current;

                var charges = me.calculateCharges(current);
                var lineItems = me.calculateLineTotals(current);
                var finalValue = Ext.util.Format.number((lineItems + charges), '0,000.00');

                return 'Grand Total: ' + finalValue + '';
            }
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

    createRecord: function (config, action) {
        var today = new Date();
        var record = Ext.create('Inventory.model.Receipt');
        record.set('strReceiptType', 'Purchase Order');
        record.set('intSourceType', 0);
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

        if (currentReceiptItem.get('intWeightUOMId') === null || currentReceiptItem.get('intWeightUOMId') === undefined) {
            weightCF = itemUOMCF;
        }

        if (!iRely.Functions.isEmpty(currentReceiptItem.get('strContainer'))) {
            record.set('strContainerNo', currentReceiptItem.get('strContainer'));
        }

        var total = (lotCF * qty) * weightCF;
        record.set('dblGrossWeight', total);
        var tare = config.dummy.get('dblTareWeight');
        var netTotal = total - tare;
        record.set('dblNetWeight', netTotal);

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
                        Ext.Array.each(receiptItems, function (item) {
                            if (item.get('dblUnitCost') === 0 && item.dummy !== true) {
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
                                var msgBox = iRely.Functions;
                                msgBox.showCustomDialog(
                                    msgBox.dialogType.WARNING,
                                    msgBox.dialogButtonType.YESNO,
                                        item.get('strItemNo') + " has zero cost. Do you want to continue?",
                                    result
                                );
                            }
                        });
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

//    validateLocation: function(current) {
//        //Validate Logged in User's default location against the selected Location for the receipt
//        if (current.get('strReceiptType') !== 'Direct') {
//            if (app.DefaultLocation > 0) {
//                if (app.DefaultLocation !== current.get('intLocationId')) {
//                    var result = function (button) {
//                        if (button === 'yes') {
//                            return true;
//                        }
//                        else {
//                            return false;
//                        }
//                    };
//                    var msgBox = iRely.Functions;
//                    msgBox.showCustomDialog(
//                        msgBox.dialogType.WARNING,
//                        msgBox.dialogButtonType.YESNO,
//                        "The Location is different from the default user location. Do you want to continue?",
//                        result
//                    );
//                }
//                else {
//                    action(true)
//                }
//            }
//            else {
//                action(true)
//            }
//        }
//        else {
//            action(true)
//        }
//    },

    onVendorSelect: function (combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var current = win.viewModel.data.current;

        if (current) {
            current.set('strVendorName', records[0].get('strName'));
            current.set('intVendorEntityId', records[0].get('intEntityVendorId'));
            current.set('intCurrencyId', records[0].get('intCurrencyId'));

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
    },

    onReceiptItemSelect: function (combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var grid = combo.up('grid');
        var grdLotTracking = win.down('#grdLotTracking');
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

            switch (records[0].get('strLotTracking')) {
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
                    current.tblICInventoryReceiptItemLots().add(newLot);
                    break;
            }
        }
        else if (combo.itemId === 'cboItemUOM') {
            current.set('intUnitMeasureId', records[0].get('intItemUnitMeasureId'));
            current.set('dblItemUOMConvFactor', records[0].get('dblUnitQty'));
            current.set('intCostUOMId', records[0].get('intItemUnitMeasureId'));
            current.set('dblCostUOMConvFactor', records[0].get('dblUnitQty'));
            current.set('strCostUOM', records[0].get('strUnitMeasure'));
            current.set('strUnitType', records[0].get('strUnitType'));

            var origCF = current.get('dblOrderUOMConvFactor');
            var newCF = current.get('dblItemUOMConvFactor');
            var received = current.get('dblReceived');
            var ordered = current.get('dblOrderQty');
            var qtyToReceive = ordered - received;
            if (origCF > 0 && newCF > 0) {
                qtyToReceive = (qtyToReceive * origCF) / newCF;
                current.set('dblOpenReceive', qtyToReceive);
            }

            if (current.tblICInventoryReceiptItemLots()) {
                Ext.Array.each(current.tblICInventoryReceiptItemLots().data.items, function (lot) {
                    if (!lot.dummy) {
                        lot.set('strUnitMeasure', records[0].get('strUnitMeasure'));
                        lot.set('intItemUnitMeasureId', records[0].get('intItemUnitMeasureId'));
                        lot.set('dblLotUOMConvFactor', records[0].get('dblUnitQty'));
                    }
                });
            }

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
        else if (combo.itemId === 'cboWeightUOM') {
            current.set('dblWeightUOMConvFactor', records[0].get('dblUnitQty'));
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
        }
        else if (combo.itemId === 'cboStorageLocation') {
            if (current.get('intSubLocationId') !== records[0].get('intSubLocationId')) {
                current.set('intSubLocationId', records[0].get('intSubLocationId'));
                current.set('strSubLocationName', records[0].get('strSubLocationName'));
            }
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

        this.calculateGrossWeight(current);
        win.viewModel.data.currentReceiptItem = current;
        this.calculateItemTaxes();
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
                LocationId: masterRecord.get('intLocationId'),
                TransactionDate: masterRecord.get('dtmReceiptDate'),
                TransactionType: 'Purchase',
                EntityId: masterRecord.get('intEntityVendorId'),
                TaxGroupId: masterRecord.get('intTaxGroupId')
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
        var currentRecord = win.viewModel.data.currentReceiptItem;

        if (!currentRecord) {
            return;
        }

        var totalItemTax,
            qtyOrdered = currentRecord.get('dblOpenReceive'),
            itemPrice = currentRecord.get('dblUnitCost');

        if (reset !== false) reset = true;

        totalItemTax = 0.00;
        currentRecord.tblICInventoryReceiptItemTaxes().removeAll();

        Ext.Array.each(itemTaxes, function (itemDetailTax) {
            var taxableAmount,
                taxAmount;

            taxableAmount = me.getTaxableAmount(qtyOrdered, itemPrice, itemDetailTax, itemTaxes);
            if (itemDetailTax.strCalculationMethod === 'Percentage') {
                taxAmount = (taxableAmount * (itemDetailTax.dblRate / 100));
            } else {
                taxAmount = qtyOrdered * itemDetailTax.dblRate;
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
            currentRecord.tblICInventoryReceiptItemTaxes().add(newItemTax);
        });

        currentRecord.set('dblTax', totalItemTax);
        var unitCost = currentRecord.get('dblUnitCost');
        var qty = currentRecord.get('dblOpenReceive');
        var lineTotal = 0;

        if (iRely.Functions.isEmpty(currentRecord.get('intWeightUOMId'))) {
            lineTotal = totalItemTax + (qty * unitCost)
        }
        else {
            var netWgt = currentRecord.get('dblNet');
            var costCF = currentRecord.get('dblCostUOMConvFactor');
            lineTotal = totalItemTax + ((netWgt / costCF) * unitCost)
        }
        currentRecord.set('dblLineTotal', i21.ModuleMgr.Inventory.roundDecimalFormat(lineTotal, 2));
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

    calculateCharges: function (current) {
        var totalCharges = 0;
        if (current) {
            var charges = current.tblICInventoryReceiptCharges();
            if (charges) {

                Ext.Array.each(charges.data.items, function (charge) {
                    if (!charge.dummy) {
                        var amount = charge.get('dblAmount');
                        totalCharges += amount;
                    }
                });
            }
        }
        return totalCharges;
    },

    calculateLineTotals: function (current) {
        var totalAmount = 0;
        if (current) {
            var items = current.tblICInventoryReceiptItems();
            if (items) {
                Ext.Array.each(items.data.items, function (item) {
                    if (!item.dummy) {
                        var amount = item.get('dblLineTotal');
                        totalAmount += amount;
                    }
                });
            }
        }
        return totalAmount;
    },

    calculateGrossWeight: function (record) {
        if (!record) return;

        if (record.tblICInventoryReceiptItemLots()) {
            Ext.Array.each(record.tblICInventoryReceiptItemLots().data.items, function (lot) {
                if (!lot.dummy) {
                    var qty = lot.get('dblQuantity');
                    var lotCF = lot.get('dblLotUOMConvFactor');
                    var itemUOMCF = record.get('dblItemUOMConvFactor');
                    var weightCF = record.get('dblWeightUOMConvFactor');

                    if (iRely.Functions.isEmpty(qty)) qty = 0.00;
                    if (iRely.Functions.isEmpty(lotCF)) lotCF = 0.00;
                    if (iRely.Functions.isEmpty(itemUOMCF)) itemUOMCF = 0.00;
                    if (iRely.Functions.isEmpty(weightCF)) weightCF = 0.00;

                    if (record.get('intWeightUOMId') === null || record.get('intWeightUOMId') === undefined) {
                        weightCF = itemUOMCF;
                    }

                    var total = (lotCF * qty) * weightCF;
                    lot.set('dblGrossWeight', total);
                    var tare = lot.get('dblTareWeight');
                    var netTotal = total - tare;
                    lot.set('dblNetWeight', netTotal);
                }
            });
        }
    },

    onViewReceiptNo: function (value, record) {
        i21.ModuleMgr.Inventory.showScreen(value, 'ReceiptNo');
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

        if (selected) {
            if (selected.length > 0) {
                var current = selected[0];
                if (!current.dummy)
                    iRely.Functions.openScreen('Grain.view.QualityTicketDiscount', { strSourceType: 'Inventory Receipt', intTicketFileId: current.get('intInventoryReceiptItemId') });
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
            iRely.Functions.openScreen('EntityManagement.view.Entity', {
                filters: [
                    {
                        column: 'intEntityId',
                        value: current.get('intEntityVendorId')
                    }
                ]
            });
        }
    },

    onReceiveClick: function (button, e, eOpts) {
        var me = this;
        var win = button.up('window');
        var context = win.context;
        var current = win.viewModel.data.current;

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

    onEditItem: function (editor, context, eOpts) {
        var win = editor.grid.up('window');
        var me = win.controller;
        var win = context.grid.up('window');
        var vw = win.viewModel;

        if (context.field === 'dblOpenReceive' || context.field === 'dblUnitCost') {
            if (context.record) {
                var value = 0;
                var record = context.record;
                var qty = record.get('dblOpenReceive');
                var unitCost = record.get('dblUnitCost');
                if (context.field === 'dblOpenReceive') {
                    qty = context.value;

                    if (!vw.data.currentReceiptItem)
                        context.record.set('intWeightUOMId', null);
                    context.record.set('dblWeightUOMConvFactor', 0);
                    context.record.set('dblItemUOMConvFactor', 0);

                    if (vw.data.currentReceiptItem) {
                        var tblICInventoryReceiptItemLots = vw.data.currentReceiptItem.tblICInventoryReceiptItemLots().data.items;
                        Ext.Array.each(tblICInventoryReceiptItemLots, function (lot) {
                            lot.set('strWeightUOM', '');
                        });
                    }

                    win.controller.calculateGrossWeight(context.record);
                    {
                        vw.data.currentReceiptItem = context.record;
                    }
                    me.calculateGrossWeight(record);
                }
                else if (context.field === 'dblUnitCost') {
                    unitCost = context.value
                    record.set('dblUnitRetail', context.value);
                    record.set('dblGrossMargin', 0);
                }

                var tax = record.get('dblTax');
                if (iRely.Functions.isEmpty(record.get('intWeightUOMId'))) {
                    value = tax + (qty * unitCost)
                }
                else {
                    var netWgt = record.get('dblNet');
                    var costCF = record.get('dblCostUOMConvFactor');
                    value = tax + ((netWgt / costCF) * unitCost)
                }

                record.set('dblLineTotal', value);
            }
        }
        else if (context.field === 'dblUnitRetail') {
            if (context.record) {
                var unitCost = context.record.get('dblUnitCost');
                var salesPrice = context.value;
                var grossMargin = ((salesPrice - unitCost) / (salesPrice)) * 100;
                context.record.set('dblGrossMargin', grossMargin);
            }
        }
        else if (context.field === 'strWeightUOM') {
            if (iRely.Functions.isEmpty(context.value)) {
            }
        }
        context.record.set(context.field, context.value);
        vw.data.currentReceiptItem = context.record;
        me.calculateItemTaxes();
    },

    onEditLots: function (editor, context, eOpts) {
        if (context.field === 'dblQuantity') {
            var win = editor.grid.up('window');
            var qty = context.value;
            var lotCF = context.record.get('dblLotUOMConvFactor');
            var itemUOMCF = win.viewModel.data.currentReceiptItem.get('dblItemUOMConvFactor');
            var weightCF = win.viewModel.data.currentReceiptItem.get('dblWeightUOMConvFactor');

            if (iRely.Functions.isEmpty(qty)) qty = 0.00;
            if (iRely.Functions.isEmpty(lotCF)) lotCF = 0.00;
            if (iRely.Functions.isEmpty(itemUOMCF)) itemUOMCF = 0.00;
            if (iRely.Functions.isEmpty(weightCF)) weightCF = 0.00;

            if (win.viewModel.data.currentReceiptItem.get('intWeightUOMId') === null || win.viewModel.data.currentReceiptItem.get('intWeightUOMId') === undefined) {
                weightCF = itemUOMCF;
            }
            var total = (lotCF * qty) * weightCF;
            context.record.set('dblGrossWeight', total);
            var tare = context.record.get('dblTareWeight');
            var netTotal = total - tare;
            context.record.set('dblNetWeight', netTotal);
        }
        else if (context.field === 'dblGrossWeight' || context.field === 'dblTareWeight') {
            var gross = context.record.get('dblGrossWeight');
            var tare = context.record.get('dblTareWeight');

            if (context.field === 'dblGrossWeight') {
                gross = context.value;
            }
            else if (context.field === 'dblTareWeight') {
                tare = context.value;
            }

            context.record.set('dblNetWeight', gross - tare);
        }
    },

    onEditCharge: function (editor, context, eOpts) {
        if (context.field === 'dblAmount') {
            var amount = i21.ModuleMgr.Inventory.roundDecimalFormat(context.value, 2);
            context.record.set('dblAmount', amount);
            return false;
        }
    },

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
                current.set('dblLineTotal', po.get('dblTotal') + po.get('dblTax'));
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
                        costTypes.forEach(function (cost) {
                            var charges = receipt.tblICInventoryReceiptCharges().data.items;
                            var exists = Ext.Array.findBy(charges, function (row) {
                                if ((row.get('intContractId') === po.get('intContractHeaderId')
                                    && row.get('intChargeId') === cost.intItemId)) {
                                    return true;
                                }
                            });

                            if (!exists) {
                                var newCost = Ext.create('Inventory.model.ReceiptCharge', {
                                    intInventoryReceiptId: receipt.get('intInventoryReceiptId'),
                                    intContractId: po.get('intContractHeaderId'),
                                    intChargeId: cost.intItemId,
                                    ysnInventoryCost: false,
                                    strCostMethod: cost.strCostMethod,
                                    dblRate: cost.dblRate,
                                    intCostUOMId: cost.intItemUOMId,
                                    intEntityVendorId: cost.intVendorId,
                                    dblAmount: 0,
                                    strAllocateCostBy: '',
                                    ysnAccrue: cost.ysnAccrue,
                                    ysnPrice: cost.ysnPrice,

                                    strItemNo: cost.strItemNo,
                                    strCostUOM: cost.strUOM,
                                    strVendorId: cost.strVendorName,
                                    strContractNumber: po.get('strContractNumber')
                                });
                                receipt.tblICInventoryReceiptCharges().add(newCost);
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
                        current.set('intCostUOMId', po.get('intItemUOMId'));
                        current.set('strUnitMeasure', po.get('strItemUOM'));
                        current.set('strOrderUOM', po.get('strItemUOM'));
                        current.set('strCostUOM', po.get('strItemUOM'));

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
                    },
                    {
                        column: 'intLocationId',
                        value: win.viewModel.data.current.get('intLocationId'),
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
                                return controller.purchaseOrderDropdown(win);
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
                                return controller.purchaseContractDropdown(win);
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

            switch (UOMType) {
                case 'Weight':
                    switch (columnId) {
                        case 'colLotUOM' :
                            return Ext.create('Ext.grid.CellEditor', {
                                field: Ext.widget({
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
                                })
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
            var win = selModel.view.grid.up('window');
            var vm = win.viewModel;

            if (selected.length > 0) {
                var current = selected[0];
                if (current.dummy) {
                    vm.data.currentReceiptItem = null;
                }
                else if (current.get('strLotTracking') === 'Yes - Serial Number' || current.get('strLotTracking') === 'Yes - Manual') {
                    vm.data.currentReceiptItem = current;
                }
                else {
                    vm.data.currentReceiptItem = null;
                }
            }
            else {
                vm.data.currentReceiptItem = null;
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

        if (combo.itemId === 'cboLotUOM') {
            current.set('intItemUnitMeasureId', records[0].get('intItemUOMId'));
            current.set('dblLotUOMConvFactor', records[0].get('dblUnitQty'));
            me.calculateGrossWeight(win.viewModel.data.currentReceiptItem);
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
                current.set('strVendorId', cboVendor.getRawValue());
            }
            else {
                current.set('intEntityVendorId', null);
                current.set('strVendorId', null);
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
    },

    onColumnBeforeRender: function (column) {
        "use strict";

        if (column.itemId === 'colUnitCost') {
            column.summaryRenderer = function (val) {
                return '<div style="text-align:right;">Total:</div>';
            }
        }
        else {
            column.summaryRenderer = function (val) {
                var value = (!Ext.isNumber(val) ? 0.00 : val).toFixed(2).replace(/./g, function (c, i, a) {
                    return i && c !== "." && ((a.length - i) % 3 === 0) ? ',' + c : c;
                });
                ;
                return value;
            };
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
                if (iRely.Functions.isEmpty(current.get('strVendorId'))) {
                    current.set('intEntityVendorId', masterRecord.get('intEntityVendorId'));
                    current.set('strVendorId', cboVendor.getRawValue());
                }
            }
            else {
                current.set('intEntityVendorId', null);
                current.set('strVendorId', null);
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

        var strLotNo = selectedObj[0].data.strLotNumber

        iRely.Functions.openScreen('Reporting.view.ReportViewer', {
            selectedReport: 'LotLabel',
            selectedGroup: 'Manufacturing',
            selectedParameters: [
                {
                    Name: 'strLotNo',
                    Type: 'int',
                    Condition: 'EQUAL TO',
                    From: strLotNo,
                    To: '',
                    Operator: ''
                }
            ],
            directPrint: true
        });
    },

    onAddOrderClick: function(button, e, eOpts) {
        var win = button.up('window');
        this.showAddOrders(win);
    },

    showAddOrders: function(win) {
        var currentRecord = win.viewModel.data.current;
        var VendorId = null;
        var ReceiptType = currentRecord.get('strReceiptType');
        var SourceType = currentRecord.get('intSourceType').toString();
        if (ReceiptType === 'Transfer Order') {
            VendorId = currentRecord.get('intTransferorId').toString();
        }
        else {
            VendorId = currentRecord.get('intEntityVendorId').toString();
        }
        var me = this;
        var showAddScreen = function() {
            var search = i21.ModuleMgr.Search;
            search.scope = me;
            search.url = '../Inventory/api/InventoryReceipt/GetAddOrders?VendorId=' + VendorId + '&ReceiptType=' + ReceiptType + '&SourceType=' + SourceType;
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
                {dataIndex: 'intCostUOMId', text: 'Cost UOM Id', width: 100, dataType: 'numeric', hidden: true}

            ];
            search.title = "Add Orders";
            search.showNew = false;
            search.on({
                scope: me,
                openselectedclick: function (button, e, result) {
                    var win = this.getView();
                    var currentVM = this.getViewModel().data.current;

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
                            strOwnershipType: 'Own'
                        };
                        currentVM.tblICInventoryReceiptItems().add(newRecord);
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
        showAddScreen();
    },

    onReplicateBalanceLotClick: function(button) {
        var win = button.up('window');
        var currentReceiptItem = win.viewModel.data.currentReceiptItem;
        var lineItemQty = currentReceiptItem.get('dblOpenReceive');

        if (currentReceiptItem) {
            var grdLotTracking = win.down('#grdLotTracking');
            var selectedLot = grdLotTracking.getSelectionModel().getSelection();

            if (selectedLot.length > 0) {
                var currentLot = selectedLot[0];
                var lotQty = currentLot.get('dblQuantity');

                if (currentLot.get('dblQuantity') <= 0) {
                    iRely.Functions.showErrorDialog('Cannot replicate zero(0) quantity lot.');
                    return;
                }

                var lastQty = (lineItemQty % lotQty) > 0 ? lineItemQty % lotQty : currentLot.get('dblQuantity');
                var replicaCount = (lineItemQty - lastQty) / lotQty;
                var lastGrossWgt = currentLot.get('dblGrossWeight');
                var lastTareWgt = currentLot.get('dblTareWeight');
                var lastNetWgt = currentLot.get('dblNetWeight');
                if ((replicaCount * lotQty) < lineItemQty ) {
                    if (lastGrossWgt > 0) {
                        lastGrossWgt = (lotQty / lastGrossWgt) * lastQty;
                    }
                    if (lastTareWgt > 0) {
                        lastTareWgt = (lotQty / lastTareWgt) * lastQty;
                    }
                    if (lastNetWgt > 0) {
                        lastNetWgt = (lotQty / lastNetWgt) * lastQty;
                    }
                }
                else {
                    replicaCount -= 1;
                }

                for (var ctr = 0; ctr <= replicaCount - 1; ctr++) {
                    var newLot = Ext.create('Inventory.model.ReceiptItemLot', {
                        strUnitMeasure: currentLot.get('strUnitMeasure'),
                        intItemUnitMeasureId: currentLot.get('intItemUnitMeasureId'),
                        dblNetWeight: ctr === replicaCount - 1 ? lastNetWgt : currentLot.get('dblNetWeight'),
                        dblStatedNetPerUnit: currentLot.get('dblStatedNetPerUnit'),
                        dblPhyVsStated: currentLot.get('dblPhyVsStated'),
                        strOrigin: currentLot.get('strOrigin'),
                        intSubLocationId: currentLot.get('intSubLocationId'),
                        intStorageLocationId: currentLot.get('intStorageLocationId'),
                        dblQuantity: ctr === replicaCount - 1 ? lastQty : currentLot.get('dblQuantity'),
                        dblGrossWeight: ctr === replicaCount - 1 ? lastGrossWgt : currentLot.get('dblGrossWeight'),
                        dblTareWeight: ctr === replicaCount - 1 ? lastTareWgt : currentLot.get('dblTareWeight'),
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
                        dblNetWeight: currentLot.get('dblNetWeight'),
                        strWeightUOM: currentLot.get('strWeightUOM'),
                        intParentLotId: currentLot.get('intParentLotId'),
                        strParentLotNumber: currentLot.get('strParentLotNumber'),
                        strParentLotAlias: currentLot.get('strParentLotAlias'),
                        strStorageLocation: currentLot.get('strStorageLocation'),
                        strSubLocationName: currentLot.get('strSubLocationName')
                    });
                    currentReceiptItem.tblICInventoryReceiptItemLots().add(newLot);
                }
            }
            else {
                iRely.Functions.showErrorDialog('Please select a lot to replicate.');
            }
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

    onVendorClick: function () {
        iRely.Functions.openScreen('EntityManagement.view.Entity:searchEntityVendor',{ action: 'view' });
    },

    init: function (application) {
        this.control({
            "#cboVendor": {
                beforequery: this.onShipFromBeforeQuery,
                select: this.onVendorSelect
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
            "#btnPrintLabel": {
                click: this.onPrintLabelClick
            },
            "#btnInsertCharge": {
                click: this.onInsertChargeClick
            },
            "#btnCalculateCharges": {
                click: this.onCalculateChargeClick
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
            "#colLineTotal": {
                beforerender: this.onColumnBeforeRender
            },
            "#colGrossMargin": {
                beforerender: this.onColumnBeforeRender
            },
            "#colUnitCost": {
                beforerender: this.onColumnBeforeRender
            },
            "#colAccrue": {
                beforecheckchange: this.onAccrueCheckChange
            },
            "#btnReplicateBalanceLots": {
                click: this.onReplicateBalanceLotClick
            }
        })
    }

});
