Ext.define('Inventory.view.InventoryReceiptViewController', {
    extend: 'Inventory.view.InventoryBaseViewController',
    alias: 'controller.icinventoryreceipt',
    requires: [
        'CashManagement.common.Text',
        'CashManagement.common.BusinessRules'
    ],

    config: {
        helpURL: '/display/DOC/Inventory+Receipts',
        binding: {
            bind: {
                title: '{receiptTitle}'
            },
            dtmWhse: '{current.dtmLastFreeWhseDate}',
            btnFetch: {
                text: 'Update Cost from Contract'
            },
            btnSave: {
                disabled: '{isOriginOrPosted}'
            },
            btnDelete: {
                disabled: '{isOriginOrPosted}'
            },
            btnUndo: {
                disabled: '{isOriginOrPosted}'
            },
            btnPost: {
                disabled: '{current.ysnOrigin}',
                hidden: '{hidePostButton}'
            },
            btnUnpost: {
                disabled: '{current.ysnOrigin}',
                hidden: '{hideUnpostButton}'
            },
            btnReturn: {
                hidden: '{checkHideReturnButton}'
            },
            btnVendor: {
                disabled: '{current.ysnOrigin}'
            },
            btnAddOrders: {
                hidden: '{checkHiddenAddOrders}',
                disabled: '{isOriginOrInventoryReturn}'
            },
            cboReceiptType: {
                value: '{current.strReceiptType}',
                store: '{receiptTypes}',
                readOnly: '{checkReadOnlyWithOrder}',
                disabled: '{isOriginOrInventoryReturn}',
                forceSelection: '{forceSelection}'
            },
            cboSourceType: {
                value: '{current.intSourceType}',
                store: '{sourceTypes}',
                readOnly: '{disableSourceType}',
                defaultFilters: '{filterSourceByType}',
                disabled: '{isOriginOrInventoryReturn}'
            },
            cboVendor: {
                origValueField: 'intEntityId',
                origUpdateField: 'intEntityVendorId',
                value: '{current.strVendorName}',
                store: '{vendor}',
                readOnly: '{checkReadOnlyWithOrder}',
                hidden: '{checkHiddenInTransferOrder}',
                disabled: '{current.ysnOrigin}'
            },
            cboTransferor: {
                origValueField: 'intCompanyLocationId',
                origUpdateField: 'intTransferorId',
                value: '{current.strFromLocation}',
                store: '{transferor}',
                hidden: '{checkHiddenIfNotTransferOrder}',
                readOnly: '{isOriginOrInventoryReturn}',
                disabled: '{current.ysnOrigin}'
            },
            cboLocation: {
                origValueField: 'intCompanyLocationId',
                origUpdateField: 'intLocationId',
                value: '{current.strLocationName}',
                store: '{location}',
                readOnly: '{locationCheckReadOnlyWithOrder}',
                disabled: '{current.ysnOrigin}'
            },
            dtmReceiptDate: {
                value: '{current.dtmReceiptDate}',
                readOnly: '{isOriginOrPosted}'
            },
            cboCurrency: {
                origValueField: 'strCurrency',
                origUpdateField: 'strCurrency',
                value: '{current.strCurrency}',
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
            txtWarehouseRefNo: {
                value: '{current.strWarehouseRefNo}',
                readOnly: '{isReceiptReadonly}'
            },
            txtBillOfLadingNumber: {
                value: '{current.strBillOfLading}',
                readOnly: '{isReceiptReadonly}'
            },
            cboShipVia: {
                origValueField: 'intEntityId',
                origUpdateField: 'intShipViaId',
                value: '{current.strShipVia}',
                store: '{shipvia}',
                readOnly: '{isReceiptReadonly}'
            },
            cboShipFrom: {
                origValueField: 'intEntityLocationId',
                origUpdateField: 'intShipFromId',
                value: '{current.strShipFrom}',
                store: '{shipFrom}',
                defaultFilters: [
                    {
                        column: 'intEntityId',
                        value: '{current.intEntityVendorId}',
                        conjunction: 'and'
                    },
                    {
                        column: 'ysnActive',
                        value: true,
                        conjunction: 'and'
                    }
                ],
                readOnly: '{isReceiptReadonly}',
                hidden: '{checkHiddenInTransferOrder}'
            },
            cboReceiver: {
                origValueField: 'intEntityUserSecurityId',
                origUpdateField: 'intReceiverId',
                value: '{current.strUserName}',
                store: '{users}',
                readOnly: '{isReceiptReadonly}'
            },
            txtVessel: {
                value: '{current.strVessel}',
                readOnly: '{isReceiptReadonly}'
            },
            cboFreightTerms: {
                origValueField: 'intFreightTermId',
                origUpdateField: 'intFreightTermId',
                value: '{current.strFreightTerm}',
                store: '{freightTerm}',
                defaultFilters: [
                    {
                        column: 'ysnActive',
                        value: 'true'
                    }
                ],
                readOnly: '{isFreightTermsReadonly}'
            },
            txtFobPoint: {
                value: '{current.strFobPoint}'
            },
            /*cboTaxGroup: {
                value: '{current.intTaxGroupId}',
                store: '{taxGroup}',
                readOnly: '{isReceiptReadonly}',
                disabled: '{current.ysnOrigin}'
            },*/
            txtShiftNumber: {
                value: '{current.intShiftNumber}',
                readOnly: '{isReceiptReadonly}'
            },
            btnInsertInventoryReceipt: {
                hidden: '{isReceiptReadonly}'
            },
            btnRemoveInventoryReceipt: {
                hidden: '{isOriginOrPosted}'
            },
            btnInsertLot: {
                hidden: '{isReceiptReadonly}'
            },
            btnRemoveLot: {
                hidden: '{isOriginOrPosted}'
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
            btnVoucher: {
                hidden: '{hideVoucherButton}',
                disabled: '{current.ysnOrigin}'
            },
            btnDebitMemo: {
                hidden: '{hideDebitMemoButton}',
                disabled: '{current.ysnOrigin}'
            },
            btnQuality: {
                hidden: '{current.ysnPosted}',
                disabled: '{isOriginOrInventoryReturn}'
            },
            grdInventoryReceipt: {
                readOnly: '{readOnlyReceiptItemGrid}',
                colOrderNumber: {
                    hidden: '{checkHideOrderNo}',
                    dataIndex: 'strOrderNumber',
                    text: '{colOrderNumberColumnText}'
                },
                colItemSequence: {
                    hidden: '{checkHideItemSequence}',
                    dataIndex: 'intContractSeq'
                },
                colSourceNumber: {
                    hidden: '{checkHideSourceNo}',
                    dataIndex: 'strSourceNumber'
                },
                colItemType: {
                    dataIndex: 'strItemType',
                    hidden: true
                },
                colItemNo: {
                    dataIndex: 'strItemNo',
                    editor: {
                        readOnly: '{readOnlyItemDropdown}',
                        readOnly: '{isItemComponent}',
                        defaultFilters: [
                            {
                                column: 'intLocationId',
                                value: '{current.intLocationId}',
                                conjunction: 'and'
                            },
                            // {
                            //     column: 'ysnReceiveUOMAllowPurchase',
                            //     value: true,
                            //     conjunction: 'and'
                            // },
                            {
                                column: 'strType',
                                condition: 'noteq',
                                value: 'Other Charge',
                                conjunction: 'and'
                            },
                            {
                                column: 'strStatus',
                                value: 'Active',
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
                        readOnly: '{disableFieldInReceiptGrid}',
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
                        readOnly: '{disableFieldInReceiptGrid}',
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
                        readOnly: '{disableFieldInReceiptGrid}',
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
                colUOMQtyToReceive: {
                    dataIndex: 'dblOpenReceive',
                    text: '{changeQtyToReceiveText}',
                    editor: {
                        readOnly: '{disableQtyInReceiptGrid}',
                        readOnly: '{isItemOption}'
                    }
                },
                colLoadToReceive: {
                    hidden: '{checkShowLoadContractOnly}',
                    dataIndex: 'intLoadReceive'
                },
                colItemSubCurrency: {
                    dataIndex: 'strSubCurrency'
                },
                /*colUOM: {
                    dataIndex: 'strUnitMeasure',
                    editor: {
                        readOnly: '{disableFieldInReceiptGrid}',
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
                },*/
                colWeightUOM: {
                    dataIndex: 'strWeightUOM',
                    editor: {
                        readOnly: '{disableFieldInReceiptGrid}',
                        origValueField: 'intItemUOMId',
                        origUpdateField: 'intWeightUOMId',
                        store: '{weightUOM}',
                        defaultFilters: [
                            {
                                column: 'intItemId',
                                value: '{grdInventoryReceipt.selection.intItemId}',
                                conjunction: 'and'
                            },
                            {
                                column: 'ysnAllowPurchase',
                                value: true,
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
                        origValueField: 'intItemUnitMeasureId',
                        origUpdateField: 'intCostUOMId',
                        readOnly: '{readOnlyUnitCost}',
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
                            },
                            {
                                column: 'ysnAllowPurchase',
                                value: true,
                                conjunction: 'and'
                            }
                        ]
                    }
                },
                colTax: {
                    dataIndex: 'dblTax'
                },
                colUnitRetail: {
                    dataIndex: 'dblUnitRetail',
                    editor: {
                        readOnly: '{disableFieldInReceiptGrid}'
                    }
                },
                colGross: {
                    dataIndex: 'dblGross',
                    editor: {
                        readOnly: '{readOnlyGrossTareUOM}'
                    }
                },
                colNet: {
                    dataIndex: 'dblNet',
                    editor: {
                        readOnly: '{readOnlyGrossTareUOM}'
                    }
                },
                colLineTotal: 'dblLineTotal',
                colGrossMargin: 'dblGrossMargin',
                colItemTaxGroup: {
                    dataIndex: 'strTaxGroup',
                    editor: {
                        readOnly: '{disableFieldInReceiptGrid}',
                        origValueField: 'intTaxGroupId',
                        origUpdateField: 'intTaxGroupId',
                        store: '{taxGroup}',
                        forceSelection: false 
                    }
                },
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
                },
                colItemChargesLink: {
                    dataIndex: 'strChargesLink',
                    editor: {
                        origValueField: 'strChargesLink',
                        origUpdateField: 'strChargesLink',
                        store: '{chargesItemLink}'                        
                    }
                }                
            },

            /*pnlLotTracking: {
                hidden: '{hasItemSelection}'
            },*/
            grdLotTracking: {
                //readOnly: '{readOnlyReceiptItemGrid}', -- Commented out to enable remarks even when receipt is already posted.
                colLotId: {
                    dataIndex: 'strLotNumber',
                    editor: {
                        forceSelection: '{forceSelection}',
                        origValueField: 'intLotId',
                        origUpdateField: 'intLotId',
                        store: '{lots}',
                        readOnly: '{readOnlyItemDropdown}',
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
                    dataIndex: 'strLotAlias',
                    editor: {
                        readOnly: '{readOnlyItemDropdown}'
                    }
                },
                colLotUOM: {
                    dataIndex: 'strUnitMeasure',
                    editor: {
                        store: '{lotUOM}',
                        readOnly: '{readOnlyReceiptItemGrid}',
                        defaultFilters: [
                            {
                                column: 'intItemId',
                                value: '{grdInventoryReceipt.selection.intItemId}',
                                conjunction: 'and'
                            },
                            {
                                column: 'ysnAllowPurchase',
                                value: true,
                                condition: 'eq',
                                conjunction: 'and'
                            }
                        ]
                    }
                },
                colLotQuantity: {
                    dataIndex: 'dblQuantity',
                    editor: {
                        readOnly: '{disableQtyInReceiptGrid}'
                    }
                },
                colLotGrossWeight: {
                    dataIndex: 'dblGrossWeight',
                    editor: {
                        readOnly: '{readOnlyGrossTareUOM}'
                    }
                },
                colLotTareWeight: {
                    dataIndex: 'dblTareWeight',
                    editor: {
                        readOnly: '{readOnlyGrossTareUOM}',
                    }
                },
                colLotNetWeight: {
                    dataIndex: 'dblNetWeight',
                    editor: {
                        readOnly: '{readOnlyNetUOM}'
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
                colLotStatedTotalNet: 'dblStatedTotalNet',
                colLotPhyVsStated: 'dblPhysicalVsStated',
                colLotWeightUOM: 'strWeightUOM',
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
                        ],
                        readOnly: '{readOnlyReceiptItemGrid}',
                        forceSelection: '{forceSelection}',
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
                colLotMarkings: 'strMarkings',
                colLotCondition: {
                    dataIndex: 'strCondition',
                    editor: {
                        store: '{condition}'
                    }
                },
                colLotCertified: 'dtmCertified'
            },

            // -- Incoming Inspection Tab
            btnSelectAll: {
                disabled: '{current.ysnPosted}'
            },
            btnClearAll: {
                disabled: '{current.ysnPosted}'
            },
            grdIncomingInspection: {
                colInspect: {
                    dataIndex: 'ysnSelected',
                    disabled: '{current.ysnPosted}'
                },
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
                        store: '{contractCost}'
                    }
                },
                colSequence: {
                    dataIndex: 'intContractSeq',
                    hidden: '{hideContractColumn}'
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
                colQuantity: 'dblQuantity',
                colRate: {
                    dataIndex: 'dblRate',
                    editor: {
                        readOnly: '{readOnlyChargeRate}'
                    }
                },
                colChargeUOM: {
                    dataIndex: 'strCostUOM',
                    editor: {
                        store: '{chargeUOM}',
                        readOnly: '{readOnlyChargeUOM}',
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
                        origValueField: 'intEntityId',
                        origUpdateField: 'intEntityVendorId',
                        store: '{vendor}'
                    }
                },
                colChargeAmount: {
                    dataIndex: 'dblAmount',
                    editor: {
                        disabled: '{disableAmount}'
                    }
                },
                colAllocateCostBy: {
                    dataIndex: 'strAllocateCostBy',
                    editor: {
                        readOnly: '{checkInventoryCostAndPrice}',
                        store: '{allocateBy}'
                    }
                },
                //colAccrue: {
                //     disabled: '{current.ysnPosted}',
                //     dataIndex: 'ysnAccrue'
                // },
                colChargeEntity: {
                    disabled: '{current.ysnPosted}',
                    dataIndex: 'ysnPrice'
                },
                colChargeTax: {
                    dataIndex: 'dblTax'
                },
                colChargeTaxGroup: {
                    dataIndex: 'strTaxGroup',
                    editor: {
                        readOnly: '{readyOnlyChargeTaxGroup}',
                        origValueField: 'intTaxGroupId',
                        origUpdateField: 'intTaxGroupId',
                        store: '{taxGroup}',
                        forceSelection: false 
                    }
                },
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
                },
                colChargesLink: {
                    dataIndex: 'strChargesLink',
                    editor: {
                        origValueField: 'strChargesLink',
                        origUpdateField: 'strChargesLink',
                        store: '{chargesLink}'                        
                    }
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
            },
            pgePostPreview: {
                title: '{pgePreviewTitle}'
            }
        }
    },

    setupContext: function (options) {
        "use strict";
        var me = this,
            win = me.getView(),
            store = Ext.create('Inventory.store.Receipt', { pageSize: 1 });

        var grdInventoryReceipt = win.down('#grdInventoryReceipt'),
            grdIncomingInspection = win.down('#grdIncomingInspection'),
            grdLotTracking = win.down('#grdLotTracking'),
            grdCharges = win.down('#grdCharges');

        grdInventoryReceipt.mon(grdInventoryReceipt, {
            afterlayout: me.onGridAfterLayout
        });

        // Update the summary fields whenever the receipt item data changed.
        me.getViewModel().bind('{current.tblICInventoryReceiptItems}', function (store) {
            // store.on('update', function () {
            //     me.showSummaryTotals(win);
            //     me.showOtherCharges(win);
            // });

            // store.on('datachanged', function () {
            //     me.showSummaryTotals(win);
            //     me.showOtherCharges(win);
            // });
            store.mon(store, {
                update: function(){
                    me.showSummaryTotals(win);
                    me.showOtherCharges(win);                    
                }
            });            

            store.mon(store, {
                datachanged: function(){
                    me.showSummaryTotals(win);
                    me.showOtherCharges(win);                    
                }
            });              
        });

        // Update the summary fields whenever the other charges data changed.
        me.getViewModel().bind('{current.tblICInventoryReceiptCharges}', function (store) {
            // store.on('update', function () {
            //     me.showSummaryTotals(win);
            //     me.showOtherCharges(win);
            // });

            // store.on('datachanged', function () {
            //     me.showSummaryTotals(win);
            //     me.showOtherCharges(win);
            // });

            store.mon(store, {
                update: function(){
                    me.showSummaryTotals(win);
                    me.showOtherCharges(win);                    
                }
            });            

            store.mon(store, {
                datachanged: function(){
                    me.showSummaryTotals(win);
                    me.showOtherCharges(win);                    
                }
            });              
        });

        //'vyuICGetInventoryReceipt,' +

        win.context = Ext.create('iRely.Engine', {
            window: win,
            store: store,
            createRecord: me.createRecord,
            validateRecord: me.validateRecord,
            onPageChange: me.onPageChange,
            binding: me.config.binding,
            enableActivity: true,
            enableCustomTab: true,
            createTransaction: Ext.bind(me.createTransaction, me),
            enableAudit: true,
            onSaveClick: me.saveAndPokeGrid(win, grdInventoryReceipt),
            // include: 'tblICInventoryReceiptInspections,' +
            // 'vyuICInventoryReceiptLookUp,' +
            // 'tblICInventoryReceiptItems.vyuICInventoryReceiptItemLookUp,' +
            // 'tblICInventoryReceiptItems.tblICInventoryReceiptItemLots.vyuICGetInventoryReceiptItemLot, ' +
            // 'tblICInventoryReceiptItems.tblICInventoryReceiptItemTaxes,' +
            // 'tblICInventoryReceiptItems.tblICUnitMeasure,' +
            // 'tblICInventoryReceiptCharges.vyuICGetInventoryReceiptCharge,' +
            // 'tblICInventoryReceiptCharges.tblICInventoryReceiptChargeTaxes',
            attachment: Ext.create('iRely.attachment.Manager', {
                type: 'Inventory.Receipt',
                window: win
            }),
            details: [
                {
                    key: 'tblICInventoryReceiptItems',
                    lazy: true,
                    component: Ext.create('iRely.grid.Manager', {
                        grid: grdInventoryReceipt,
                        deleteButton: grdInventoryReceipt.down('#btnRemoveInventoryReceipt'),
                        deleteRecord: Ext.bind(me.onReceiptItemDelete, me)
                    }),
                    details: [
                        {
                            key: 'tblICInventoryReceiptItemLots',
                            lazy: true,
                            component: Ext.create('iRely.grid.Manager', {
                                grid: grdLotTracking,
                                deleteButton: grdLotTracking.down('#btnRemoveLot'),
                                createRecord: me.onLotCreateRecord
                            })
                        },
                        {
                            key: 'tblICInventoryReceiptItemTaxes',
                            lazy: true
                        }
                    ]
                },
                {
                    key: 'tblICInventoryReceiptCharges',
                    lazy: true,
                    component: Ext.create('iRely.grid.Manager', {
                        grid: grdCharges,
                        deleteButton: grdCharges.down('#btnRemoveCharge'),
                        createRecord: me.onChargeCreateRecord
                    }),
                    details: [
                        {
                            key: 'tblICInventoryReceiptChargeTaxes',
                            lazy: true
                        }
                    ]

                },
                {
                    key: 'tblICInventoryReceiptInspections',
                    lazy: true,
                    component: Ext.create('iRely.grid.Manager', {
                        grid: grdIncomingInspection,
                        position: 'none'
                    })
                }
            ]
        });

        var cepItemLots = grdLotTracking.getPlugin('cepItemLots');
        if (cepItemLots) {
            // cepItemLots.on({
            //     // validateedit: me.onEditLots,
            //     beforeedit: me.onLotBeforeEdit,
            //     edit: me.onEditLots,
            //     scope: me
            // });

            grdLotTracking.mon(cepItemLots, {
                beforeedit: me.onLotBeforeEdit,
                edit: me.onEditLots,
                scope: me
            });             
        }

        var cepItem = grdInventoryReceipt.getPlugin('cepItem');
        if (cepItem) {
            // cepItem.on({
            //     beforeedit: me.onItemBeforeEdit,
            //     edit: me.onItemEdit, // @Todo: This event is fired 
            //     scope: me
            // });

            grdInventoryReceipt.mon(cepItem, {
                beforeedit: me.onItemBeforeEdit,
                edit: me.onItemEdit, // @Todo: This event is fired 
                scope: me
            });             
        }

        var cepCharges = grdCharges.getPlugin('cepCharges');
        if (cepCharges) {
            // cepCharges.on({
            //     validateedit: me.onChargeValidateEdit,
            //     //edit: me.onChargeEdit,
            //     scope: me
            // });

            grdCharges.mon(cepCharges, {
                validateedit: me.onChargeValidateEdit,
                scope: me
            });                 
        }

        // var colReceived = grdInventoryReceipt.columns[5];
        // var txtReceived = colReceived.getEditor();
        // if (txtReceived) {
        //     txtReceived.on('change', me.onCalculateTotalAmount);
        // }
        // var colUnitCost = grdInventoryReceipt.columns[7];
        // var txtUnitCost = colUnitCost.getEditor();
        // if (txtUnitCost) {
        //     txtUnitCost.on('change', me.onCalculateTotalAmount);
        // }

        var colOrderNumber = grdInventoryReceipt.columns[0];
        var colSourceNumber = grdInventoryReceipt.columns[2];
        colOrderNumber.renderer = this.onRenderNumRef;
        colSourceNumber.renderer = this.onRenderNumRef;

        return win.context;
    },

    // afterSave: function(me, win, batch, options) {
    //     var current = me.getViewModel().get('current');
    //     var grid = win.down("#grdLotTracking");
    //     grid.setSelection(current.tblICInventoryReceiptItems().data.items[0])
    // },

    createTransaction: function (config, action) {
        var me = this,
            current = me.getViewModel().get('current');

        action({
            strTransactionNo: current.get('strReceiptNumber'), //Unique field
            intEntityId: current.get('intEntityId'), //Entity Associated
            dtmDate: current.get('dtmDate') // Date
        })
    },

    onReceiptItemDelete: function(action){
        var me = this,
            win = me.getView(),
            grdInventoryReceipt = win.down('#grdInventoryReceipt'),
            grdStore = grdInventoryReceipt.getStore(),
            selectedRecords = grdInventoryReceipt.getSelectionModel().getSelection(),
            records = Ext.clone(selectedRecords);
        
        Ext.Array.forEach(selectedRecords, function(rec){
            if(!iRely.Functions.isEmpty(rec.get('strItemType')) && rec.get('intParentItemLinkId')){

                var childItems = _.filter(grdStore.data.items, function(x){
                    return !iRely.Functions.isEmpty(x.get('strItemType'))
                        && x.get('intChildItemLinkId')
                        && x.get('intChildItemLinkId') == rec.get('intParentItemLinkId') 
                        && x.get('intInventoryReceiptItemId') != rec.get('intInventoryReceiptItemId')
                        && !x.dummy;
                });

                if(childItems.length > 0) {
                    childItems.forEach(function(item){
                        records.push(item);
                    });
                }
            }
        });

        action(records);
    },

    onGridAfterLayout: function (grid) {
        // "use strict";

        // //TODO: Remove this when we upgrade to Ext 6 - workaround for the flying combo
        // var editor = grid.editingPlugin && grid.editingPlugin.activeEditor;
        // if (editor && editor.field instanceof Ext.form.field.Text) {
        //     var plugin = editor.editingPlugin,
        //         record = plugin.activeRecord,
        //         column = plugin.activeColumn,
        //         view = grid.view,
        //         row = view.getRow(record);

        //     if (row && record && column && editor.getXY().toString() !== '0,0') {
        //         var cell = plugin.getCell(record, column);
        //         if (cell && (editor.getXY() !== cell.getXY())) {
        //             editor.realign();
        //         }
        //     }
        // }
    },

    show: function (config) {
        "use strict";

        var me = this,
            win = this.getView();

        if (config) {
            // Check from what search tab it is coming from. 
            var param = config.param;
            var searchTab = param ? param.searchTab : null;
            if (searchTab && searchTab == 'Vouchers' && config.action === 'new') {
                // Exit immediately. Do not auto-create records from the vouchers tab.
                return;
            }

            win.show();

            var context = win.context ? win.context.initialize() : me.setupContext();

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
                    filters: config.filters,
                    callback: function() {
                        var cboReceiptType = win.down('#cboReceiptType');
                        if (cboReceiptType) cboReceiptType.focus();
                    }
                });
            }
            
            me.getViewModel().set('chargesLinkInc', 0);
        }

    },

    onPageChange: function (pagingStatusBar, record, eOpts) {
        var win = pagingStatusBar.up('window');
        var grd = win.down('#grdLotTracking');
        grd.getStore().removeAll();

        var me = win.controller;
        var current = win.viewModel.data.current;


        if (current) {
            if (current.phantom === false) {
                current.set('locationFromTransferOrder', current.strLocationName);
            }
            var ReceiptItems = current.tblICInventoryReceiptItems();

            me.calculateWtGainLoss(win);
            me.showSummaryTotals(win);
            me.showOtherCharges(win);
        }
    },

    createRecord: function (config, action) {
        var win = config.window;
        win.down("#txtWeightLossMsgValue").setValue("");
        
        var today = new Date();
        var newRecord = Ext.create('Inventory.model.Receipt');
        var defaultReceiptType = i21.ModuleMgr.Inventory.getCompanyPreference('strReceiptType');
        var defaultSourceType = i21.ModuleMgr.Inventory.getCompanyPreference('intReceiptSourceType');
        var defaultCurrency = i21.ModuleMgr.SystemManager.getCompanyPreference('intDefaultCurrencyId');
        var defaultLocation = iRely.config.Security.CurrentDefaultLocation; 

        if (defaultCurrency){
            newRecord.set('intCurrencyId', defaultCurrency);
            Ext.create('i21.store.CurrencyBuffered', {
                storeId: 'icReceiptCurrency',
                autoLoad: {
                    filters: [
                        {
                            dataIndex: 'intCurrencyID',
                            value: defaultCurrency,
                            condition: 'eq'
                        }
                    ],
                    params: {
                        columns: 'strCurrency:intSubCurrencyCent:intCurrencyID:'
                    },
                    callback: function(records, operation, success){
                        var record; 
                        if (records && records.length > 0) {
                            record = records[0];
                        }

                        if(success && record){                            
                            var subCurrencyCents = record.get('intSubCurrencyCent');
                            subCurrencyCents = Ext.isNumeric(subCurrencyCents) && subCurrencyCents > 0 ? subCurrencyCents : 1; 
                            newRecord.set('intSubCurrencyCents', subCurrencyCents);
                            newRecord.set('intCurrencyId', record.get('intCurrencyID'));
                            newRecord.set('strCurrency', record.get('strCurrency'));
                        }
                    }
                }
            });
        }  

        if (defaultReceiptType !== null) {
            newRecord.set('strReceiptType', defaultReceiptType);
        }
        else {
            newRecord.set('strReceiptType', 'Purchase Order');
        }

        if (defaultSourceType !== null) {
            newRecord.set('intSourceType', defaultSourceType);
        }
        else {
            newRecord.set('intSourceType', 0);
        }

        if (defaultLocation){
            newRecord.set('intLocationId', defaultLocation);
            Ext.create('i21.store.CompanyLocationBuffered', {
                storeId: 'icReceiptCompanyLocation',
                autoLoad: {
                    filters: [
                        {
                            dataIndex: 'intCompanyLocationId',
                            value: defaultLocation,
                            condition: 'eq'
                        }
                    ],
                    params: {
                        columns: 'strLocationName:intCompanyLocationId:'
                    },
                    callback: function(records, operation, success){
                        var record; 
                        if (records && records.length > 0) {
                            record = records[0];
                        }

                        if(success && record){
                            newRecord.set('strLocationName', record.get('strLocationName'));
                            newRecord.set('intLocationId', record.get('intCompanyLocationId'));
                        }
                    }
                }
            });            
        }            

        if (iRely.config.Security.EntityId > 0)
            newRecord.set('intReceiverId', iRely.config.Security.EntityId);
            
        newRecord.set('dtmReceiptDate', today);
        newRecord.set('intBlanketRelease', 0);
        newRecord.set('ysnPosted', false);        
        config.viewModel.set('locationFromTransferOrder', null);
        action(newRecord);
    },

    getLotExpiryDate: function(manufacturedDate, receiptDate, lifeTime, lifeTimeType){
        // Calculate Expiry Date by:
        // 1. Manufactured Date
        // 2. Or by Receipt Date if manufactured date is missing. 
        
        // Check if it is a valid date object. 
        var startDate = manufacturedDate ? manufacturedDate : receiptDate;
        if (!startDate || Object.prototype.toString.call(startDate) !== "[object Date]") return; 

        // Check if the lifeTime and lifeTimeType have a value. 
        if (!lifeTime || !Ext.isNumeric(lifeTime)) return;
        if (!lifeTimeType) return; 

        var expiryDate;
        switch (lifeTimeType) {
            case 'Minutes':
                expiryDate = Ext.Date.add(startDate, Ext.Date.MINUTE, lifeTime);
                break;
            case 'Hours':
                expiryDate = Ext.Date.add(startDate, Ext.Date.HOUR, lifeTime);
                break;
            case 'Days':
                expiryDate = Ext.Date.add(startDate, Ext.Date.DAY, lifeTime);
                break;
            case 'Months':
                expiryDate = Ext.Date.add(startDate, Ext.Date.MONTH, lifeTime);
                break;
            case 'Years':
                expiryDate = Ext.Date.add(startDate, Ext.Date.YEAR, lifeTime);
                break;
        }
        return expiryDate;
    },

    onLotCreateRecord: function (config, action) {
        var win = config.grid.up('window');
        var me = win.controller;

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
        record.set('strCondition', i21.ModuleMgr.Inventory.getCompanyPreference('strLotCondition'));
        record.set(
            'dtmExpiryDate', 
            me.getLotExpiryDate(
                record.get('dtmManufacturedDate'), 
                current.get('dtmReceiptDate'), 
                currentReceiptItem.get('intLifeTime'), 
                currentReceiptItem.get('strLifeTimeType')
            )
        );

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
        if (!iRely.Functions.isEmpty(currentReceiptItem.get('intWeightUOMId'))) {
            // Get the current gross.
            var grossQty = record.get('dblGrossWeight');
            grossQty = Ext.isNumeric(grossQty) ? grossQty : 0.00;

            // If current gross is zero, do the pre-calculation.
            if (grossQty == 0) {

                if (lotCF === weightCF) {
                    grossQty = qty;
                }
                else if (weightCF !== 0) {
                    //grossQty = (lotCF * qty) / weightCF;
                    grossQty = ic.utils.Uom.convertQtyBetweenUOM(lotCF, weightCF, qty);
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
        // var intDefaultCurrencyId = i21.ModuleMgr.SystemManager.getCompanyPreference('intDefaultCurrencyId');
        // var strDefaultCurrency = i21.ModuleMgr.SystemManager.getCompanyPreference('strDefaultCurrency');

        var record = Ext.create('Inventory.model.ReceiptCharge');
        record.set('strAllocateCostBy', 'Unit');
        // record.set('intCurrencyId', intDefaultCurrencyId);
        // record.set('strCurrency', strDefaultCurrency);

        action(record);
    },

    validateRequiredGrossWeight:function(receiptItems, result) {
        var ri = _.filter(receiptItems, function(x) { return x.phantom === false; });
        ri = _.map(ri, function(x) { return x.data; });
        ri = _.filter(ri, function(x) { return x.strLotTracking !== 'No' && x.ysnLotWeightsRequired === true && ((x.intWeightUOMId === null) || (x.dblGross === 0 && x.dblNet === 0)); })

        if(ri.length > 0) {
            var msgBox = iRely.Functions;
            msgBox.showCustomDialog(
                msgBox.dialogType.ERROR,
                msgBox.dialogButtonType.OK,
                "Gross/Net UOM, Weight and Net Qty are required to be filled out for Item " + ri[0].strItemNo,
                result
            );
        }

        return ri.length === 0;
    },

    validateRecord: function (config, action) {
        var current = config.window.viewModel.data.current;
        if (current) {
            var details = current.tblICInventoryReceiptCharges().data.items;
            details = _.filter(details, function(x) { return !x.dummy; });
            if (details.length > 0) {
                Ext.each(details, function (rec, idx) {
                    rec.set('ysnAccrue', '');
                });
            }
        }

        this.validateRecord(config, function (result) {
            if (result) {
                var controller = config.window.controller;
                var vm = config.window.viewModel;
                var current = vm.data.current;

                if (current) {

                    //Validate Unit Cost in not zero
                    if (current.get('strReceiptType') !== 'Purchase Contract') {
                        var receiptItems = current.tblICInventoryReceiptItems().data.items;
                        
                        if(!controller.validateRequiredGrossWeight(receiptItems, function() { })) {
                            return false;
                        }
                        var hasZeroCostOnCompanyOwnedStock = Ext.Array.findBy(receiptItems, function (item) {
                            var dblUnitCost = item.get('dblUnitCost'),
                                dummy = item.dummy, 
                                intOwnershipType = item.get('intOwnershipType');
                            
                                dblUnitCost = Ext.isNumeric(dblUnitCost) ? dblUnitCost : 0; 
                                intOwnershipType = Ext.isNumeric(intOwnershipType) ? intOwnershipType : 1; 

                            var own = 1; 

                            if (!dummy && dblUnitCost === 0 && intOwnershipType === own) {
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

                        if (hasZeroCostOnCompanyOwnedStock) {
                            var msgBox = iRely.Functions;
                            msgBox.showCustomDialog(
                                msgBox.dialogType.WARNING,
                                msgBox.dialogButtonType.YESNO,
                                hasZeroCostOnCompanyOwnedStock.get('strItemNo') + " has zero cost. Do you want to continue?",
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
            current.set('intCurrencyId', records[0].get('intCurrencyID'));
        }
    },

    fetchSetDefaultLocation: function(current, intDefaultLocation) {
        if(intDefaultLocation && current) {
            ic.utils.ajax({
                url: './entitymanagement/api/location/search',
                params: {
                    filter: iRely.Functions.encodeFilters([{ column: 'intEntityId', value: current.get('intEntityVendorId') }])
                }
            })
            .map(function(data) { return JSON.parse(data.responseText).data; })
            .subscribe(function(data) {
                var location = _.findWhere(data, { intEntityLocationId: intDefaultLocation });
                if(location) {
                    current.set('strShipFrom', location.strLocationName);
                }
            }, function(error) {
                console.log(error);
            });
        }    
    },

    onVendorSelect: function (combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var current = win.viewModel.data.current;

        if (!current) return; 

        if (current) {
            // If Vendor has its own Currency, use it. Otherwise, stick to the default currency. 
            var vendorCurrency = records[0].get('intCurrencyId');
            if (vendorCurrency){
                current.set('intCurrencyId', vendorCurrency);
                current.set('strCurrency', records[0].get('strCurrency'));

                var subCurrencyCents = records[0].get('intSubCurrencyCent');
                subCurrencyCents = subCurrencyCents && Ext.isNumeric(subCurrencyCents) && subCurrencyCents > 0 ? subCurrencyCents : 1;
                current.set('intSubCurrencyCents', subCurrencyCents);
            }            

            current.set('intShipFromId', null);
            current.set('intShipViaId', null);

            current.set('intShipFromId', records[0].get('intDefaultLocationId'));
            this.fetchSetDefaultLocation(current, records[0].get('intDefaultLocationId'));

            var vendorLocation = records[0].getDefaultLocation();
            if (vendorLocation) {
                current.set('intShipViaId', vendorLocation.get('intShipViaId'));
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
            default:
                isHidden = true;
                break;
        }
        if (isHidden === false) {
            var shipTo = current.get('strLocationName'); 
            if (shipTo) {
                this.showAddOrders(win);
            }            
        }
    },

    onLocationSelect: function (combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var current = win.viewModel.data.current;

        if (!current) return; 

        var grdInventoryReceiptCount = 0; 
        if (current.tblICInventoryReceiptItems()) {
            Ext.Array.each(current.tblICInventoryReceiptItems().data.items, function (row) {
                if (!row.dummy) {
                    grdInventoryReceiptCount++;
                }
            });
        }

        if (grdInventoryReceiptCount == 0){
            this.showAddOrders(win);
        }
    },

    onTransferorSelect: function (combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var current = win.viewModel.data.current;
        var isHidden = true;
        if (current) {
            switch (current.get('strReceiptType')) {
                case 'Transfer Order':
                    if (iRely.Functions.isEmpty(current.get('intTransferorId'))) {
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
            if (isHidden === false) {
                this.showAddOrders(win);
            }
        }
    },

    onFreightTermSelect: function (combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var win = combo.up('window'),
            current = win.viewModel.data.current,
            me = this;

        if (current) current.set('strFobPoint', records[0].get('strFobPoint'));

        // Save first before calculating the taxes
        win.context.data.saveRecord({
            successFn: function () {
                ic.utils.ajax({
                    url: './inventory/api/inventoryreceipt/gettaxgroupid',
                    params: {
                        id: current.get('intInventoryReceiptId')
                    },
                    method: 'get'
                })
                    .subscribe(
                    function (successResponse) {
                        var jsonData = Ext.decode(successResponse.responseText);
                        var tblICInventoryReceiptItems = current.tblICInventoryReceiptItems();

                        if (tblICInventoryReceiptItems) {
                            Ext.Array.each(tblICInventoryReceiptItems.data.items, function (item) {
                                if (!item.dummy) {
                                    //Set intTaxGroupId and strTaxGroup
                                    item.set('intTaxGroupId', jsonData.message.taxGroupId);
                                    item.set('strTaxGroup', jsonData.message.taxGroupN);

                                    //Calculate Taxes
                                    win.viewModel.data.currentReceiptItem = item;
                                    me.calculateItemTaxes();
                                }
                            });
                        };
                    }
                    , function (failureResponse) {
                        var jsonData = Ext.decode(failureResponse.responseText);
                        iRely.Functions.showErrorDialog(jsonData.message.statusText);
                    }
                    );
            }
        })
    },

    getDefaultReceiptTaxGroupId: function (current, cfg) {
        cfg = cfg ? cfg : {};

        ic.utils.ajax({
            url: './inventory/api/inventoryreceipt/getdefaultreceipttaxgroupid',
            params: {
                freightTermId: cfg.freightTermId,
                locationId: cfg.locationId,
                entityVendorId: cfg.entityVendorId,
                entityLocationId: cfg.entityLocationId,
                itemId: cfg.itemId 
            },
            method: 'get'
        }).subscribe(
            function (successResponse) {
                var jsonData = Ext.decode(successResponse.responseText);

                if (current) {
                    //Set intTaxGroupId and strTaxGroup
                    current.set('intTaxGroupId', jsonData.message.taxGroupId);
                    current.set('strTaxGroup', jsonData.message.taxGroupN);
                }

                if (Ext.isFunction(cfg.successFn)){
                    cfg.successFn(); 
                }
            }
            , function (failureResponse) {
                var jsonData = Ext.decode(failureResponse.responseText);
                //iRely.Functions.showErrorDialog(jsonData.message.statusText);
                iRely.Functions.showErrorDialog('Something went wrong while getting the default Tax Group for the item.');
            }
        );
    },

    getVendorCost: function (cfg, successFn, failureFn, currentItem) {
        // Sanitize parameters; 
        cfg = cfg ? cfg : {};
        successFn = successFn && (successFn instanceof Function) ? successFn : function () { /*empty function*/ };
        failureFn = failureFn && (failureFn instanceof Function) ? failureFn : function () { /*empty function*/ };

        ic.utils.ajax({
            url: './entitymanagement/api/vendorpricing/searchvendorlocationitemcurrency',
            params: {
                VendorId: cfg.vendorId,
                ItemId: cfg.itemId,
                CurrencyId: cfg.currencyId,
                VendorLocation: cfg.vendorLocation,
                ItemUOM: cfg.itemUOM,
                ValidDate: cfg.validDate
            },
            method: 'get'
        })
            .subscribe(
            function (successResponse) {
                //var jsonData = Ext.decode(successResponse.responseText);
                successFn(successResponse, currentItem);
            }
            , function (failureResponse) {
                //var jsonData = Ext.decode(failureResponse.responseText);
                failureFn(failureResponse, currentItem);
            }
            );
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

            // Get the default Forex Rate Type from the Company Preference. 
            var intRateType = i21.ModuleMgr.SystemManager.getCompanyPreference('intInventoryRateTypeId');

            // Get the functional currency:
            var functionalCurrencyId = i21.ModuleMgr.SystemManager.getCompanyPreference('intDefaultCurrencyId');

            // Get the important header data: 
            var currentHeader = win.viewModel.data.current;
            var transactionCurrencyId = currentHeader.get('intCurrencyId');
            var vendorId = currentHeader.get('intEntityVendorId');
            var vendorLocation = currentHeader.get('intShipFromId');
            var dtmReceiptDate = currentHeader.get('dtmReceiptDate');
            var intLocationId = currentHeader.get('intLocationId');
            var intFreightTermId = currentHeader.get('intFreightTermId');

            // Get the important detail data:
            var itemId = records[0].get('intItemId');
            var intItemUnitMeasureId = records[0].get('intReceiveUnitMeasureId');
            var dblLastCost = records[0].get('dblLastCost');
            var dblCostUOMConvFactor = records[0].get('dblCostUOMConvFactor');

            // Convert the last cost to the Cost UOM. 
            dblLastCost = Ext.isNumeric(dblLastCost) ? dblLastCost : 0;
            dblCostUOMConvFactor = Ext.isNumeric(dblCostUOMConvFactor) ? dblCostUOMConvFactor : 0;

            dblLastCost = dblCostUOMConvFactor != 0 ? dblLastCost * dblCostUOMConvFactor : dblLastCost;
            dblLastCost = i21.ModuleMgr.Inventory.roundDecimalFormat(dblLastCost, 6);

            // function variable to process the default forex rate. 
            var processForexRateOnSuccess = function (successResponse, isItemLastCost) {
                if (successResponse && successResponse.length > 0) {
                    var dblForexRate = successResponse[0].dblRate;
                    var strRateType = successResponse[0].strRateType;

                    dblForexRate = Ext.isNumeric(dblForexRate) ? dblForexRate : 0;

                    // Convert the last cost to the transaction currency.
                    // and round it to six decimal places.  
                    if (transactionCurrencyId != functionalCurrencyId && isItemLastCost) {
                        dblLastCost = dblForexRate != 0 ? dblLastCost / dblForexRate : 0;
                        dblLastCost = i21.ModuleMgr.Inventory.roundDecimalFormat(dblLastCost, 6);
                    }

                    current.set('intForexRateTypeId', intRateType);
                    current.set('strForexRateType', strRateType);
                    current.set('dblForexRate', dblForexRate);
                    current.set('dblUnitCost', dblLastCost);
                    current.set('dblUnitRetail', dblLastCost);
                }
            }

            // function variable to process the vendor cost. 
            var processVendorCostOnSuccess = function (successResponse) {
                var jsonData = Ext.decode(successResponse.responseText);
                var isItemLastCost = true;

                // If there is a vendor cost, replace dblLastCost with the vendor cost. 
                if (jsonData && jsonData.data && jsonData.data.length > 0) {
                    var dataArray = jsonData.data[0];
                    if (dataArray) {
                        dblLastCost = dataArray.dblUnit;
                        current.set('dblUnitCost', dblLastCost);
                        current.set('dblUnitRetail', dblLastCost);
                        isItemLastCost = false;
                    }
                }

                // If transaction currency is a foreign currency, get the default forex rate type, forex rate, and convert the last cost to the transaction currency. 
                if (transactionCurrencyId != functionalCurrencyId && intRateType) {
                    iRely.Functions.getForexRate(
                        transactionCurrencyId,
                        intRateType,
                        win.viewModel.data.current.get('dtmReceiptDate'),
                        function (successResponse) {
                            processForexRateOnSuccess(successResponse, isItemLastCost);
                        },
                        function (failureResponse) {
                            //var jsonData = Ext.decode(failureResponse.responseText);
                            //iRely.Functions.showErrorDialog(jsonData.message.statusText);                    
                            iRely.Functions.showErrorDialog('Something went wrong while getting the forex data.');
                        }
                    );
                }
            };

            var processVendorCostOnFailure = function (failureResponse) {
                var jsonData = Ext.decode(failureResponse.responseText);
                //iRely.Functions.showErrorDialog(jsonData.Message);
                iRely.Functions.showErrorDialog('Something went wrong while getting the item cost from the Vendor Pricing setup.');
            };

            // Get the vendor cost. 
            var vendorCostCfg = {
                vendorId: vendorId,
                itemId: itemId,
                currencyId: transactionCurrencyId ? transactionCurrencyId : i21.ModuleMgr.SystemManager.getCompanyPreference('intDefaultCurrencyId'),
                vendorLocation: vendorLocation,
                itemUOM: intItemUnitMeasureId,
                validDate: dtmReceiptDate
            }

            me.getVendorCost(vendorCostCfg, processVendorCostOnSuccess, processVendorCostOnFailure);

            current.set('intItemId', records[0].get('intItemId'));
            current.set('strItemDescription', records[0].get('strDescription'));
            current.set('strLotTracking', records[0].get('strLotTracking'));
            current.set('strUnitMeasure', records[0].get('strReceiveUOM'));
            current.set('intUnitMeasureId', records[0].get('intReceiveUOMId'));
            current.set('intItemUOMId', records[0].get('intReceiveUnitMeasureId'))
            current.set('strCostUOM', records[0].get('strReceiveUOM'));
            current.set('intCostUOMId', records[0].get('intReceiveUOMId'));
            current.set('intWeightUOMId', records[0].get('intGrossUOMId'));
            current.set('strWeightUOM', records[0].get('strGrossUOM'));
            current.set('intWeightUnitMeasureId', records[0].get('intGrossUnitMeasureId')); 
            current.set('dblWeightUOMConvFactor', records[0].get('dblGrossUOMConvFactor'));
            current.set('dblUnitCost', dblLastCost);
            current.set('dblUnitRetail', dblLastCost);
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

            // Get the default tax group
            var taxCfg = {
                freightTermId: intFreightTermId,
                locationId: intLocationId,
                entityVendorId: vendorId,
                entityLocationId: vendorLocation,
                itemId: itemId 
            };
            me.getDefaultReceiptTaxGroupId(current, taxCfg);
            me.calculateGrossNet(current, 1);

			// Check if Lot UOM matches with the Item UOM. 
            if (current.tblICInventoryReceiptItemLots()) {
                Ext.Array.each(current.tblICInventoryReceiptItemLots().data.items, function (lot) {
                    var lotUOM = lot.get('intItemUnitMeasureId');
                    var lotWeightUOM = lot.get('intWeightUOMId');
                    var item_intItemUOMId =  current.get('intUnitMeasureId');
                    var item_strUnitMeasure = current.get('strUnitMeasure');
                    var item_dblItemUOMConvFactor = current.get('dblItemUOMConvFactor');
                    var item_strUnitType = current.get('strUnitType');
                    var item_intWeightUOMId = current.get('intWeightUOMId');

                    // If Lot is not a dummy record, or lot UOM is blank, or lot UOM is equal to Item UOM or Item Weight, then update the Lot UOM. 
                    if (
                        !lot.dummy
                        && (
                            !lotUOM 
                            || lotUOM != item_intItemUOMId
                            || lotUOM != item_intWeightUOMId
                        )
                    ) {
                        lot.set('intItemUnitMeasureId', item_intItemUOMId);
						lot.set('dblLotUOMConvFactor', item_dblItemUOMConvFactor);
                        lot.set('strUnitMeasure', item_strUnitMeasure);
						lot.set('strUnitType', item_strUnitType);
                    }
                });
            }
            
            me.getItemAddOns(current, records[0], currentHeader, currentHeader.tblICInventoryReceiptItems());
            me.getItemSubstitutes(current, records[0], currentHeader, currentHeader.tblICInventoryReceiptItems());
            
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
            current.set('intWeightUnitMeasureId', records[0].get('intUnitMeasureId'));
            // Calculate the default gross/net qty. 
            me.calculateGrossNet(current, 1);
        }
        else if (combo.itemId === 'cboCostUOM') {
            var dblLastCost = records[0].get('dblLastCost');
            var dblUnitQty = records[0].get('dblUnitQty');
            var dblForexRate = current.get('dblForexRate');

            dblUnitQty = Ext.isNumeric(dblUnitQty) ? dblUnitQty : 0;
            dblLastCost = Ext.isNumeric(dblLastCost) ? dblLastCost : 0;
            dblForexRate = Ext.isNumeric(dblForexRate) ? dblForexRate : 0;

            // Convert the last cost from functional currency to the transaction currency. 
            dblLastCost = dblForexRate != 0 ? dblLastCost / dblForexRate : dblLastCost;
            dblLastCost = i21.ModuleMgr.Inventory.roundDecimalFormat(dblLastCost, 6);

            current.set('dblCostUOMConvFactor', dblUnitQty);
            current.set('dblUnitCost', dblLastCost);
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
        else if (combo.itemId === 'cboSubLocation') {
            current.set('intStorageLocationId', null);
            current.set('strStorageLocationName', null);
            var lots = current.tblICInventoryReceiptItemLots();

            if (lots) {
                Ext.Array.each(lots.data.items, function (lot) {
                    if (!lot.dummy) {
                        lot.set('intStorageLocationId', null);
                        lot.set('strStorageLocation', null);
                    }
                });
            }
        }
        else if (combo.itemId === 'cboForexRateType') {
            current.set('intForexRateTypeId', records[0].get('intCurrencyExchangeRateTypeId'));
            current.set('strForexRateType', records[0].get('strCurrencyExchangeRateType'));
            current.set('dblForexRate', null);

            iRely.Functions.getForexRate(
                win.viewModel.data.current.get('intCurrencyId'),
                current.get('intForexRateTypeId'),
                win.viewModel.data.current.get('dtmReceiptDate'),
                function (successResponse) {
                    if (successResponse && successResponse.length > 0) {
                        current.set('dblForexRate', successResponse[0].dblRate);
                    }
                },
                function (failureResponse) {
                    //var jsonData = Ext.decode(failureResponse.responseText);
                    iRely.Functions.showErrorDialog(jsonData.message.statusText);
                }
            );
        }

        // Calculate the taxes
        // win.viewModel.data.currentReceiptItem = current;
        // this.calculateItemTaxes();

        //Calculate Line Total        
        var currentReceiptItem = win.viewModel.data.currentReceiptItem;
        var currentReceipt = win.viewModel.data.current;

        me.resolveItemCost(win.viewModel, currentReceipt, current);

        if (currentReceiptItem) {
            currentReceiptItem.set('dblLineTotal', this.calculateLineTotal(currentReceipt, currentReceiptItem));
        }

        // Show or hide the Lot Panel (or Grid)
        var pnlLotTracking = win.down("#pnlLotTracking");

        //if (current.get('strLotTracking') === 'Yes - Serial Number' || current.get('strLotTracking') === 'Yes - Manual') {
        if (!!current.get('strLotTracking') && current.get('strLotTracking') == 'No') {
            pnlLotTracking.setVisible(false);
        }
        else {
            pnlLotTracking.setVisible(true);
        }
    },

    resolveItemCost: function(vm, receipt, receiptItem) {
        ic.utils.ajax({
            url: './inventory/api/item/searchvendorpricing',
            filters: [
                {
                    column: 'intEntityVendorId',
                    value: receipt.get('intEntityVendorId'),
                    condition: 'eq',
                    conjunction: 'and'
                }, 
                {
                    column: 'intEntityLocationId',
                    value: receipt.get('intShipFromId'),
                    condition: 'eq',
                    conjunction: 'and'
                }, 
                {
                    column: 'intItemId',
                    value: receiptItem.get('intItemId'),
                    condition: 'eq',
                    conjunction: 'and'
                }, 
                {
                    column: 'intItemUOMId',
                    value: receiptItem.get('intCostUOMId'),
                    condition: 'eq',
                    conjunction: 'and'
                },
                {
                    column: 'intCurrencyId',
                    value: receipt.get('intCurrencyId'),
                    condition: 'eq',
                    conjunction: 'and'
                },
                {
                    column: 'dtmBeginDate',
                    value: receipt.get('dtmReceiptDate'),
                    condition: 'lte',
                    conjunction: 'and'
                },
                {
                    column: 'dtmEndDate',
                    value: receipt.get('dtmReceiptDate'),
                    condition: 'gte',
                    conjunction: 'and'
                }
            ]
        })
        .subscribe(function(x) {
            var json = JSON.parse(x.responseText);
            var data = _.first(json.data);
            var cost = data ? data.dblUnit : receiptItem.get('dblUnitCost');

            var dblUnitQty = receiptItem.get('dblCostUOMConvFactor');
            var dblForexRate = receiptItem.get('dblForexRate');

            dblUnitQty = Ext.isNumeric(dblUnitQty) ? dblUnitQty : 0;
            cost = Ext.isNumeric(cost) ? cost : 0;
            dblForexRate = Ext.isNumeric(dblForexRate) ? dblForexRate : 0;

            // Convert the last cost from functional currency to the transaction currency. 
            cost = dblForexRate != 0 ? cost / dblForexRate : cost;
            cost = i21.ModuleMgr.Inventory.roundDecimalFormat(cost, 6);
            
            receiptItem.set('dblUnitCost', cost);
        });
    },

    calculateItemTaxes: function () {
        var me = this;
        var win = me.getView();
        var masterRecord = win.viewModel.data.current;
        var detailRecord = win.viewModel.data.currentReceiptItem;

        if (!masterRecord) return;
        if (!detailRecord) return;
        if (iRely.Functions.isEmpty(detailRecord.get('intItemId'))) return;
        var itemTaxUOMId = null;
        //if (detailRecord.get('intOwnershipType') === 2) return; // Do not compute the tax if item ownership is Storage. 

        //if (reset !== false) reset = true;

        var computeItemTax = function (itemTaxes, me) {

            if (!detailRecord) {
                return;
            }

            var totalItemTax = 0.00,
                qtyOrdered = detailRecord.get('dblOpenReceive'),
                unitCost = detailRecord.get('dblUnitCost'),
                taxGroupId = 0,
                taxGroupName = null;

            // Adjust the item price by the sub currency
            {
                var isSubCurrency = detailRecord.get('ysnSubCurrency');
                var costCentsFactor = masterRecord.get('intSubCurrencyCents');

                // sanitize the value for the sub currency.
                costCentsFactor = Ext.isNumeric(costCentsFactor) && costCentsFactor != 0 ? costCentsFactor : 1;

                // check if there is a need to compute for the sub currency.
                if (!isSubCurrency) {
                    costCentsFactor = 1;
                }

                unitCost = unitCost / costCentsFactor;
            }

            detailRecord.tblICInventoryReceiptItemTaxes().removeAll();

            //Calculate Cost UOM Conversion Factor
            var costCF = detailRecord.get('dblCostUOMConvFactor'),
                qtyCF = detailRecord.get('dblItemUOMConvFactor'),
                netWgtCF = detailRecord.get('dblWeightUOMConvFactor'),
                valueCostCF;

            var receiptUOMId = detailRecord.get("intUnitMeasureId");
            
            // Calculate Cost UOM Conversion Factor with respect to the Item UOM..
            if (iRely.Functions.isEmpty(detailRecord.get('intWeightUOMId'))) {
                // Sanitize the cost conversion factor.
                costCF = Ext.isNumeric(costCF) && costCF != 0 ? costCF : qtyCF;
                costCF = Ext.isNumeric(costCF) && costCF != 0 ? costCF : 1;

                unitCost = unitCost * (qtyCF / costCF);
            }

            // Calculate Cost UOM Conversion Factor with respect to the Gross UOM..
            else {
                var qtyOrdered = detailRecord.get('dblNet');
                var netWgtCF = detailRecord.get('dblWeightUOMConvFactor');

                // Sanitize the cost conversion factor.
                costCF = Ext.isNumeric(costCF) && costCF != 0 ? costCF : netWgtCF;
                costCF = Ext.isNumeric(costCF) && costCF != 0 ? costCF : 1;

                unitCost = unitCost * (netWgtCF / costCF);
                receiptUOMId = detailRecord.get('intWeightUOMId');
            }

            // Do not compute the tax if item ownership is 'Storage'. 
            if (detailRecord.get('intOwnershipType') != 2) {
                var dblForexRate = detailRecord.get('dblForexRate');
                dblForexRate = Ext.isNumeric(dblForexRate) ? dblForexRate : 0;

                Ext.Array.each(itemTaxes, function (itemDetailTax) {
                    var taxableAmount,
                        taxAmount;

                    var adjustedTax = itemDetailTax.dblAdjustedTax;
                    adjustedTax = Ext.isNumeric(adjustedTax) ? adjustedTax : 0;                                
                    // If a line is using a foreign currency, convert the adjusted tax from functional currency to the charge currency. 
                    adjustedTax = dblForexRate != 0 ? adjustedTax / dblForexRate : adjustedTax;

                    taxableAmount = me.getTaxableAmount(qtyOrdered, unitCost, itemDetailTax, itemTaxes);
                    if (itemDetailTax.strCalculationMethod === 'Percentage') {
                        taxAmount = (taxableAmount * (itemDetailTax.dblRate / 100));
                    } else {
                        taxAmount = qtyOrdered * itemDetailTax.dblRate;

                        // If a line is using a foreign currency, convert the tax from functional currency to the transaction currency. 
                        taxAmount = dblForexRate != 0 ? taxAmount / dblForexRate : taxAmount;
                        itemTaxUOMId = receiptUOMId;
                    }

                    if (itemDetailTax.ysnCheckoffTax) {
                        taxAmount = taxAmount * -1;
                    }

                    taxAmount = i21.ModuleMgr.Inventory.roundDecimalValue(taxAmount, 2);

                    if (itemDetailTax.dblTax === itemDetailTax.dblAdjustedTax && !itemDetailTax.ysnTaxAdjusted) {
                        if (itemDetailTax.ysnTaxExempt && itemDetailTax.dblExemptionPercent === 0.00)
                            taxAmount = 0.00;

                        if(itemDetailTax.ysnTaxExempt && itemDetailTax.dblExemptionPercent !== 0.00)
                            taxAmount -= (taxAmount * (itemDetailTax.dblExemptionPercent/100.00));

                        itemDetailTax.dblTax = taxAmount;
                        itemDetailTax.dblAdjustedTax = taxAmount;
                    }
                    else {
                        itemDetailTax.dblTax = taxAmount;
                        itemDetailTax.dblAdjustedTax = adjustedTax;
                        itemDetailTax.ysnTaxAdjusted = true;
                    }
                    totalItemTax = totalItemTax + itemDetailTax.dblAdjustedTax;
                    taxGroupId = itemDetailTax.intTaxGroupId;
                    taxGroupName = itemDetailTax.strTaxGroup;

                    var newItemTax = Ext.create('Inventory.model.ReceiptItemTax', {
                        intTaxGroupMasterId: itemDetailTax.intTaxGroupMasterId,
                        intTaxGroupId: itemDetailTax.intTaxGroupId,
                        intTaxCodeId: itemDetailTax.intTaxCodeId,
                        intTaxClassId: itemDetailTax.intTaxClassId,
                        strTaxCode: itemDetailTax.strTaxCode,
                        strTaxableByOtherTaxes: itemDetailTax.strTaxableByOtherTaxes,
                        strCalculationMethod: itemDetailTax.strCalculationMethod,
                        dblRate: itemDetailTax.dblRate,
                        //intUnitMeasureId: itemTaxUOMId, IC-4798 blocked by SM-3785
                        intUnitMeasureId: receiptUOMId,
                        dblTax: itemDetailTax.dblTax,
                        dblAdjustedTax: itemDetailTax.dblAdjustedTax,
                        intTaxAccountId: itemDetailTax.intTaxAccountId,
                        ysnTaxAdjusted: itemDetailTax.ysnTaxAdjusted,
                        ysnSeparateOnInvoice: itemDetailTax.ysnSeparateOnInvoice,
                        ysnCheckoffTax: itemDetailTax.ysnCheckoffTax,
                        ysnTaxOnly: itemDetailTax.ysnTaxOnly,
                        dblQty: qtyOrdered,
                        dblCost: unitCost
                    });
                    detailRecord.tblICInventoryReceiptItemTaxes().add(newItemTax);
                });

                //Set Value for Item Tax Group
                if(iRely.Functions.isEmpty(detailRecord.get('intTaxGroupId'))) {
                    detailRecord.set('intTaxGroupId', taxGroupId);
                    detailRecord.set('strTaxGroup', taxGroupName);
                }
            }

            detailRecord.set('dblTax', totalItemTax);
            detailRecord.set('dblLineTotal', me.calculateLineTotal(masterRecord, detailRecord));
        }
        
        if (detailRecord) {
            var current = {
                ItemId: detailRecord.get('intItemId'),
                TransactionDate: masterRecord.get('dtmReceiptDate'),
                LocationId: masterRecord.get('intLocationId'),
                TransactionType: 'Purchase',
                TaxGroupId: detailRecord.get('intTaxGroupId'),
                EntityId: masterRecord.get('intEntityVendorId'),
                BillShipToLocationId: masterRecord.get('intShipFromId'),
                FreightTermId: masterRecord.get('intFreightTermId'),
                CardId: null,
                VehicleId: null,
                IncludeExemptedCodes: false,
                UOMId: detailRecord.get('intWeightUOMId') ? (detailRecord.get('intWeightUOMId') ? detailRecord.get('intWeightUOMId') : detailRecord.get('intUnitMeasureId')) : detailRecord.get('intUnitMeasureId')  // IMPORTANT!!!!!This is not intItemUOMId, this is intUnitMeasureId. Mapping of field names is wrong since intUnitMeasureId was originally mapped to item uom id (Need to correct this in the future)
            };

            iRely.Functions.getItemTaxes(current, computeItemTax, me);            
        }
    },

    calculateLineTotal: function (currentReceipt, currentReceiptItem) {
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
        var defaultCurrency = i21.ModuleMgr.SystemManager.getCompanyPreference('intDefaultCurrencyId');
        var intCurrencyId = currentReceipt.get('intCurrencyId');
        var dblForexRate = currentReceiptItem.get('dblForexRate');

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

        // Convert to the functional currency. 
        // if (intCurrencyId && intCurrencyId != defaultCurrency){
        //     dblForexRate = Ext.isNumeric(dblForexRate) ? dblForexRate : 0;
        //     lineTotal = lineTotal * dblForexRate; 
        // }

        return i21.ModuleMgr.Inventory.roundDecimalFormat(lineTotal, 2)
    },

    calculateStatedNetPerUnit: function (currentReceipt, currentReceiptItem, currentReceiptItemLot) {
        if (!currentReceipt || !currentReceiptItem || !currentReceiptItemLot)
            return;

        var dblStatedGrossPerUnit = currentReceiptItemLot.get('dblStatedGrossPerUnit');
        var dblStatedTarePerUnit = currentReceiptItemLot.get('dblStatedTarePerUnit');

        dblStatedGrossPerUnit = Ext.isNumeric(dblStatedGrossPerUnit) ? dblStatedGrossPerUnit : 0.00;
        dblStatedTarePerUnit = Ext.isNumeric(dblStatedTarePerUnit) ? dblStatedTarePerUnit : 0.00;

        var dblStatedNetPerUnit = dblStatedGrossPerUnit - dblStatedTarePerUnit;
        return dblStatedNetPerUnit;
    },

    calculateStatedTotalNet: function (currentReceipt, currentReceiptItem, currentReceiptItemLot) {
        if (!currentReceipt || !currentReceiptItem || !currentReceiptItemLot)
            return;

        var me = this;

        // Get the Lot UOM and Lot Wgt UOM. 
        var lotUOMId = currentReceiptItemLot.get('intItemUnitMeasureId');
        var lotWgtUOMId = currentReceiptItem.get('intWeightUOMId');

        lotUOMId = Ext.isNumeric(lotUOMId) ? lotUOMId : 0;
        lotWgtUOMId = Ext.isNumeric(lotWgtUOMId) ? lotWgtUOMId : 0;

        // Calculate the stated net total; 
        var dblStatedNetPerUnit = me.calculateStatedNetPerUnit(currentReceipt, currentReceiptItem, currentReceiptItemLot);

        if (lotUOMId === lotWgtUOMId) {
            return dblStatedNetPerUnit;
        }
        else {
            var lotQty = currentReceiptItemLot.get('dblQuantity');
            var lotQty = Ext.isNumeric(lotQty) ? lotQty : 0.00;
            var dblStatedTotalNet = lotQty * dblStatedNetPerUnit;
        }

        return dblStatedTotalNet;
    },

    calculatePhysicalVsStated: function (currentReceipt, currentReceiptItem, currentReceiptItemLot) {
        if (!currentReceipt || !currentReceiptItem || !currentReceiptItemLot)
            return;

        var me = this;

        // Calculate the Lot Net Wgt
        var lotGrossWgt = currentReceiptItemLot.get('dblGrossWeight');
        var lotTareWgt = currentReceiptItemLot.get('dblTareWeight');

        lotGrossWgt = Ext.isNumeric(lotGrossWgt) ? lotGrossWgt : 0.00;
        lotTareWgt = Ext.isNumeric(lotTareWgt) ? lotTareWgt : 0.00;

        var lotNetWgt = lotGrossWgt - lotTareWgt;

        // Calculate the Lot Stated Net Total 
        var calculateStatedNetTotal = me.calculateStatedTotalNet(currentReceipt, currentReceiptItem, currentReceiptItemLot);

        // Calculate the stated net total; 
        var dblPhysicalVsStated = lotNetWgt - calculateStatedNetTotal;

        return dblPhysicalVsStated;
    },

    showSummaryTotals: function (win) {
        var current = win.viewModel.data.current,
            txtSubTotal = win.down('#txtSubTotal'),
            txtTax = win.down('#txtTax'),
            txtGrossWgt = win.down('#txtGrossWgt'),
            txtNetWgt = win.down('#txtNetWgt'),
            txtTotal = win.down('#txtTotal'),
            txtGrossDiff = win.down('#txtGrossDiff'),
            txtNetDiff = win.down('#txtNetDiff'),
            txtLotNetWgt = win.down('#txtLotNetWgt'),
            txtLotGrossWgt = win.down('#txtLotGrossWgt'),
            line = { amount: 0, tax: 0, gross: 0, net: 0, lot: { gross: 0, net: 0 } };        

        if (current) {
            var itemCount = current.get('intItemCount');

            var tblICInventoryReceiptItems = current.tblICInventoryReceiptItems();
            var data = tblICInventoryReceiptItems ? tblICInventoryReceiptItems.data : null;
            var items = data ? data.items : null; 

            if (items && items.length > 0) {
                itemCount = 0; 
                Ext.Array.each(items, function (item) {
                    if (!item.dummy) {
                        itemCount++;                        
                        line.amount += item.get('dblLineTotal');
                        line.tax += item.get('dblTax');
                        line.gross += item.get('dblGross');
                        line.net += item.get('dblNet');
                        if (item.tblICInventoryReceiptItemLots()) {
                            _.each(item.tblICInventoryReceiptItemLots().data.items, function (lot) {
                                line.lot.gross += lot.get('dblGrossWeight');
                                line.lot.net += lot.get('dblNetWeight');
                            });
                        }
                    }
                });
            }
            current.set('intItemCount', itemCount);
        }

        var totalCharges = this.calculateOtherCharges(win);
        var totalChargesTax = this.calculateOtherChargesTax(win);
        line.tax = line.tax + totalChargesTax;
        var total = line.amount + totalCharges + line.tax;

        if (txtSubTotal) { txtSubTotal.setValue(line.amount); }
        if (txtTax) { txtTax.setValue(line.tax); }
        if (txtGrossWgt) { txtGrossWgt.setValue(line.gross); }
        if (txtNetWgt) { txtNetWgt.setValue(line.net); }
        if (txtTotal) { txtTotal.setValue(total); }
        if (txtLotGrossWgt) { txtLotGrossWgt.setValue(line.lot.gross); }
        if (txtLotNetWgt) { txtLotNetWgt.setValue(line.lot.net); }
        if (txtGrossDiff) { txtGrossDiff.setValue(line.gross - line.lot.gross); }
        if (txtNetDiff) { txtNetDiff.setValue(line.net - line.lot.net); }
        
        var txtChargesTotal = win.down("#txtChargesTotal"),
            txtTaxesTotal = win.down("#txtTaxesTotal"),
            txtChargesAmountTotal = win.down("#txtChargesAmountTotal");

        txtChargesTotal.setValue(totalCharges);
        txtTaxesTotal.setValue(totalChargesTax);
        txtChargesAmountTotal.setValue(totalCharges + totalChargesTax);
    },

    getTaxableAmount: function (quantity, price, currentItemTax, itemTaxes) {
        quantity = Ext.isNumeric(quantity) ? quantity : 0.00;
        price = Ext.isNumeric(price) ? price : 0.00;

        var taxableAmount = quantity * price;
        var otherTaxes = 0.00; 
        var dblRate = 0.00; 

        Ext.Array.each(itemTaxes, function (itemDetailTax) {
            if (itemDetailTax.strTaxableByOtherTaxes && itemDetailTax.strTaxableByOtherTaxes !== String.empty) {
                if (itemDetailTax.strTaxableByOtherTaxes.split(",").indexOf(currentItemTax.intTaxCodeId.toString()) > -1) {
                    dblRate = Ext.isNumeric(itemDetailTax.dblRate) ? itemDetailTax.dblRate : 0.00; 

                    if(itemDetailTax.ysnTaxOnly)
                        taxableAmount = 0.000000;
                    else
                        taxableAmount = quantity * price; 

                    if (itemDetailTax.ysnTaxAdjusted) {
                        otherTaxes += itemDetailTax.dblAdjustedTax;
                    } else {
                        if (itemDetailTax.strCalculationMethod === 'Percentage') {
                            otherTaxes += 
                                ((itemDetailTax.ysnTaxExempt && itemDetailTax.dblExemptionPercent === 0.00) || itemDetailTax.ysnCheckoffTax)
                                ? 0.00 
                                : (quantity * price * dblRate / 100.0); 
                        } else {
                            otherTaxes += 
                                ((itemDetailTax.ysnTaxExempt && itemDetailTax.dblExemptionPercent === 0.00) || itemDetailTax.ysnCheckoffTax) 
                                ? 0.00 
                                : (quantity * dblRate);
                        }
                    }
                }
            }
        });
        taxableAmount = Ext.isNumeric(taxableAmount) ? taxableAmount : 0.00;
        otherTaxes = Ext.isNumeric(otherTaxes) ? otherTaxes : 0.00;

        return (taxableAmount + otherTaxes);
    },

    calculateOtherChargesTax: function (win) {
        var current = win.viewModel.data.current;
        var totalChargeTaxes = 0;
        var intDefaultCurrencyId = i21.ModuleMgr.SystemManager.getCompanyPreference('intDefaultCurrencyId');
        var transactionCurrencyId = current.get('intCurrencyId');
        var transactionVendorId = current.get('intEntityVendorId');

        if (current) {
            var charges = current.tblICInventoryReceiptCharges();
            if (charges) {
                Ext.Array.each(charges.data.items, function (charge) {
                    if (!charge.dummy) {
                        // Add the charge taxes if:
                        // 1. Charge Currency is the same as the transaction currency id and if ysnAccure = true. 
                        // 2. However, if ysnPrice = true, reduce it instead of adding it. 
                        var chargeCurrencyId = charge.get('intCurrencyId');
                        var otherChargeTax = charge.get('dblTax');
                        var chargeVendorId = charge.get('intEntityVendorId');
                        var ysnPrice = charge.get('ysnPrice');
                        var ysnAccrue = charge.get('intEntityVendorId') ? true : false;

                        otherChargeTax = Ext.isNumeric(otherChargeTax) ? otherChargeTax : 0.00;  
                        chargeCurrencyId = Ext.isNumeric(chargeCurrencyId) ? chargeCurrencyId : transactionCurrencyId;
                        if (transactionCurrencyId == chargeCurrencyId) {
                            totalChargeTaxes += ysnPrice ? -otherChargeTax : (transactionVendorId == chargeVendorId && ysnAccrue) ? otherChargeTax : 0;
                        }
                    }
                });

                if(!current.phantom && charges.data.items.length === 0) {
                    totalChargeTaxes = current.get('dblTotalChargeTax');
                }                
            }
        }
        return totalChargeTaxes;
    },

    calculateOtherCharges: function (win) {
        var current = win.viewModel.data.current;
        var me = win;
        var totalCharges = 0;
        
        //var txtCharges = win.down('#txtCharges');
        var intDefaultCurrencyId = i21.ModuleMgr.SystemManager.getCompanyPreference('intDefaultCurrencyId');
        var transactionCurrencyId = current.get('intCurrencyId');
        var transactionVendorId = current.get('intEntityVendorId');

        if (current) {
            var charges = current.tblICInventoryReceiptCharges();
            if (charges) {
                Ext.Array.each(charges.data.items, function (charge) {
                    if (!charge.dummy) {
                        // Add the charges amount where:                        
                        // 1. Charge Currency is the same as the transaction currency id. 
                        // 2. Add it if Charges Vendor is the same as the transaction vendor id and ysnAccrue = true. 
                        // 3. Reduce it if Price = true; 
                        var chargeCurrencyId = charge.get('intCurrencyId');
                        var chargeVendorId = charge.get('intEntityVendorId');
                        var amount = charge.get('dblAmount');
                        var ysnPrice = charge.get('ysnPrice');
                        var ysnAccrue = charge.get('intEntityVendorId') ? true : false;

                        amount = Ext.isNumeric(amount) ? amount : 0.00; 
                        chargeCurrencyId = Ext.isNumeric(chargeCurrencyId) ? chargeCurrencyId : transactionCurrencyId;
                        chargeVendorId = Ext.isNumeric(chargeVendorId) ? chargeVendorId : transactionVendorId;
                        if (transactionCurrencyId == chargeCurrencyId) {
                            totalCharges += ysnPrice ? -amount : (transactionVendorId == chargeVendorId && ysnAccrue) ? amount : 0;
                        }
                    }
                });

                if(!current.phantom && charges.data.items.length === 0) {
                    totalCharges = current.get('dblTotalCharge');
                }
            }
        }

        //if (txtCharges) {txtCharges.setValue(totalCharges);}
        return totalCharges;
    },

    showOtherCharges: function (win) {
        var me = this;
        var txtCharges = win.down('#txtCharges');
        var totalCharges = me.calculateOtherCharges(win);
        if (txtCharges) { txtCharges.setValue(totalCharges); }
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

    calculateGrossNet: function (record, calculateItemGrossNet) {
        if (!record) return;

        var totalGross = 0
            , totalNet = 0
            , lotGross = 0
            , lotTare = 0
            , ysnCalculatedInLot = 0
            , me = this;

        //Calculate based on Lot
        if (record.tblICInventoryReceiptItemLots()) {
            Ext.Array.each(record.tblICInventoryReceiptItemLots().data.items, function (lot) {
                if (!lot.dummy) {
                    // If Gross/Net UOM is blank, do not calculate the lot Gross and Net.
                    if (!iRely.Functions.isEmpty(record.get('intWeightUOMId'))) {
                        if (lot.get('dblQuantity') !== 0) {
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
                                else if (weightCF !== 0) {
                                    //grossQty = (lotCF * lotQty) / weightCF;
                                    grossQty = ic.utils.Uom.convertQtyBetweenUOM(lotCF, weightCF, lotQty);
                                }
                                
                                lot.set('dblGrossWeight', grossQty);
                                var tare = lot.get('dblTareWeight');

                                grossQty = Ext.isNumeric(grossQty) ? grossQty : 0.00;
                                tare = Ext.isNumeric(tare) ? tare : 0.00;

                                var netTotal = grossQty - tare;
                                lot.set('dblNetWeight', netTotal);
                            }

                            //Set Default Value for Lot UOM
                            if (lot.get('strUnitMeasure') === null || lot.get('strUnitMeasure') === '') {
                                lot.set('strUnitMeasure', record.get('strUnitMeasure'));
                                lot.set('intItemUnitMeasureId', record.get('intUnitMeasureId'));
                            }

                            // Get the Gross Qty
                            lotGross = lot.get('dblGrossWeight');
                            lotGross = Ext.isNumeric(lotGross) ? lotGross : 0.00;

                            // Get the Tare Qty
                            lotTare = lot.get('dblTareWeight');
                            lotTare = Ext.isNumeric(lotTare) ? lotTare : 0.00;

                            var dblTareWeightBeforeEdit = lot.get('dblTareWeightBeforeEdit'); 
                            dblTareWeightBeforeEdit = Ext.isNumeric(dblTareWeightBeforeEdit) ? dblTareWeightBeforeEdit : 0.00;

                            var dblQuantityBeforeEdit = lot.get('dblQuantityBeforeEdit');
                            dblQuantityBeforeEdit = Ext.isNumeric(dblQuantityBeforeEdit) ? dblQuantityBeforeEdit : 0.00;

                            var newTare = dblQuantityBeforeEdit != 0 ? (dblTareWeightBeforeEdit / dblQuantityBeforeEdit * lotQty) : lotTare;
                            var newGross = dblQuantityBeforeEdit != 0 ? (lotGross / dblQuantityBeforeEdit * lotQty) : lotGross;

                            lot.set('dblTareWeight', newTare);
                            
                            // Calculate the total Gross and total Net
                            totalGross += newGross;
                            totalNet += (newGross - newTare);
                            ysnCalculatedInLot = 1;
                        }
                    }
                }
            });
        }

        if (ysnCalculatedInLot === 1) {
            if (record.get('dblGross') === 0 && record.get('dblNet') === 0) {
                totalGross = i21.ModuleMgr.Inventory.roundDecimalFormat(totalGross, 6);
                totalNet = i21.ModuleMgr.Inventory.roundDecimalFormat(totalNet, 6);

                record.set('dblGross', totalGross);
                record.set('dblNet', totalNet);
            }
            else {
                //Gross Net is not calculated based on Lot
                ysnCalculatedInLot = 0;
            }
        }


        //Use this to calculate item's Gross/Net based on item grid
        if (ysnCalculatedInLot === 0 && calculateItemGrossNet === 1) {
            var receiptItemQty = record.get('dblOpenReceive');
            var receiptUOMCF = record.get('dblItemUOMConvFactor');
            var weightUOMCF = record.get('dblWeightUOMConvFactor');

            if (iRely.Functions.isEmpty(receiptItemQty)) receiptItemQty = 0.00;
            if (iRely.Functions.isEmpty(receiptUOMCF)) receiptUOMCF = 0.00;
            if (iRely.Functions.isEmpty(weightUOMCF)) weightUOMCF = 0.00;

            // If there is no Gross/Net UOM, do not calculate the lot gross and net.
            if (record.get('intWeightUOMId') === null || record.get('intWeightUOMId') === '') {
                totalGross = 0;
            }
            else {
                totalGross = ic.utils.Uom.convertQtyBetweenUOM(receiptUOMCF, weightUOMCF, receiptItemQty);
            }
            totalGross = Ext.isNumeric(totalGross) ? totalGross : 0.00;
            totalNet = totalGross;

            totalGross = i21.ModuleMgr.Inventory.roundDecimalFormat(totalGross, 6);
            totalNet = i21.ModuleMgr.Inventory.roundDecimalFormat(totalNet, 6);

            record.set('dblGross', totalGross);
            record.set('dblNet', totalNet);

            if(record.get('ysnQtyUOMChanged')){    
                record.set('dblGrossBeforeEdit', totalGross);
                record.set('dblNetBeforeEdit', totalNet);
                record.set('ysnQtyUOMChanged', false);
            }
        }
    },

    onItemHeaderClick: function (menu, column) {
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
                    if (currentReceiptItem.get('ysnPosted') === true) {
                        iRely.Functions.openScreen('Grain.view.QualityTicketDiscount',
                            {
                                strSourceType: 'Inventory Receipt',
                                intTicketFileId: current.get('intInventoryReceiptItemId'),
                                viewConfig: {
                                    modal: true,
                                    listeners:
                                    {
                                        show: function (win) {
                                            Ext.defer(function () {
                                                win.context.screenMgr.securityMgr.screen.setViewOnlyAccess();
                                            }, 100);
                                        }
                                    }
                                }
                            }
                        );

                    }
                    else {
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
        var me = this;
        var selected = grd.getSelectionModel().getSelection();
        var context = win.context;

        // Validate the selected item record. 
        if (!selected || selected.length <= 0) {
            iRely.Functions.showErrorDialog('Please select an Item to view.');
            return; 
        }

        // Get the current record. 
        var current = selected[0];        
        if (!current || current.dummy) {
            iRely.Functions.showErrorDialog('Please select an Item to view.');
            return;             
        }

        var showChargeTaxScreen = function () {
            var ReceiptItemId = current.get('intInventoryReceiptItemId');

            iRely.Functions.openScreen('GlobalComponentEngine.view.FloatingSearch', {
                searchSettings: {
                    scope: me,
                    type: 'Inventory.Receipt.ItemTaxDetails',
                    url: './inventory/api/inventoryreceiptitemtax/getreceiptitemtaxview?ReceiptItemId=' + ReceiptItemId ,
                    columns: [
                        { itemId: 'colInventoryReceiptItemTaxId', dataIndex: 'intInventoryReceiptItemTaxId', text: "Receipt Item Tax Id", flex: 1, dataType: 'numeric', key: true, hidden: true },
                        { itemId: 'colItemId', dataIndex: 'intItemId', text: "Item Id", flex: 1, dataType: 'numeric', key: true, hidden: true },
                        { itemId: 'colItemNo', dataIndex: 'strItemNo', text: 'Item No.', width: 100, dataType: 'string'},
                        { itemId: 'colTaxGroup', dataIndex: 'strTaxGroup', text: 'Tax Group', width: 85, dataType: 'string' },
                        { itemId: 'colTaxClass', dataIndex: 'strTaxClass', text: 'Tax Class', width: 100, dataType: 'string' },
                        { itemId: 'colTaxCode', dataIndex: 'strTaxCode', text: 'Tax Code', width: 100, dataType: 'string' },
                        { itemId: 'colCalculationMethod', dataIndex: 'strCalculationMethod', text: 'Calculation Method', width: 110, dataType: 'string' },                                
                        { itemId: 'colQty', xtype: 'numbercolumn', dataIndex: 'dblQty', text: 'Qty', width: 100, dataType: 'float' },
                        { itemId: 'colUOM', dataIndex: 'strUnitMeasure', text: 'Unit of Measure', width: 100, dataType: 'string' },
                        { itemId: 'colCost', xtype: 'numbercolumn', dataIndex: 'dblCost', text: 'Cost', width: 100, dataType: 'float' },
                        { itemId: 'colRate', xtype: 'numbercolumn', dataIndex: 'dblRate', text: 'Rate', width: 100, dataType: 'float' },
                        { 
                            itemId: 'colCheckoff', 
                            xtype: 'checkcolumn', 
                            dataIndex: 'ysnCheckoffTax', 
                            text: 'Checkoff', 
                            width: 100, 
                            dataType: 'boolean',
                            listeners: {
                                beforecheckchange: function(me, rowIndex, checked, record, e, eOpts){
                                    // Return false so that checkbox value can't be changed. 
                                    return false; 
                                }
                            }                                    
                        },
                        { itemId: 'colTax', xtype: 'numbercolumn', dataIndex: 'dblTax', text: 'Tax', width: 100, dataType: 'float' },
                        { 
                            itemId: 'colTaxAdjusted', 
                            xtype: 'checkcolumn', 
                            dataIndex: 'ysnTaxAdjusted', 
                            text: 'Adjusted', 
                            width: 100, 
                            dataType: 'boolean',
                            listeners: {
                                beforecheckchange: function(me, rowIndex, checked, record, e, eOpts){
                                    // Return false so that checkbox value can't be changed. 
                                    return false; 
                                }
                            }                                    
                        }                                
                    ],
                    title: "Item Tax Details",
                    showNew: false,
                    showOpenSelected: false
                }
            });
        }

        var task = new Ext.util.DelayedTask(function () {
            // If there is no data change, show charge tax details screen
            if (!context.data.hasChanges()) {
                showChargeTaxScreen();
            }

            // Save has data changes first before showing charge tax details screen
            context.data.saveRecord({
                successFn: function () {
                    showChargeTaxScreen();
                }
            });
        });
        task.delay(10);          
    },

    onInsertChargeClick: function (button, e, eOpts) {
        var grd = button.up('grid');
        if (grd) {
            grd.startAdd();
        }
    },

    onVoucherClick: function (button, e, eOpts) {
        var btnVoucher = button;
        if (btnVoucher){
            btnVoucher.disable();
        }
        else {            
            return;
        }
        var me = this;
        var win = button.up('window'),
            current = win.viewModel.data.current;
        if (!current){
            btnVoucher.enable();
            return; // exit immediately. 
        }

        var receiptItems = current.tblICInventoryReceiptItems(),
            countItemsToProcess = 0,       
            countItemsWithZeroCost = 0;        

        var processReceiptToVoucher = function (receiptId, callback) {
            ic.utils.ajax({
                url: './inventory/api/inventoryreceipt/processbill',
                params: {
                    id: receiptId
                },
                method: 'get'
            })
            .subscribe(
                function (successResponse) {
                    var responseText = Ext.decode(successResponse.responseText);
                    //callback(jsonData);
                    var buttonAction = function (button) {
                        if (button === 'yes') {
                            iRely.Functions.openScreen('AccountsPayable.view.Voucher', {
                                filters: [
                                    {
                                        column: 'intBillId',
                                        value: responseText.message.BillId
                                    }
                                ],
                                action: 'view',
                                showAddReceipt: false
                            });
                            win.close();
                        }
                    };
                    iRely.Functions.showCustomDialog('question', 'yesno', 'Voucher successfully processed. Do you want to view it?', buttonAction);
                    btnVoucher.enable();
                }
                , function (failureResponse) {
                    var jsonData = Ext.decode(failureResponse.responseText);
                    var message = jsonData.message;
                    iRely.Functions.showErrorDialog(message.statusText);
                    btnVoucher.enable();
                }
            );
        };
        // Loop thru the items. See if there are any zero cost items. 
        Ext.Array.each(receiptItems.data.items, function (item) {
            if (!item.dummy) {
                countItemsToProcess++;

                if (item.get('dblUnitCost') == 0) {
                    countItemsWithZeroCost++;
                    return false; // Zero cost found, break from the loop. 
                }
            }
        });

        if (countItemsToProcess > 0) {
            // If there are zero cost in the receipt, tell the user that it will not be included in the voucher. Yes will continue. No answer will stop the process. 
            if (countItemsWithZeroCost > 0) {
                var buttonActionOnZeroCost = function (button) {
                    if (button == 'yes') {
                        // Create Voucher for receipt. Ignore items with zero cost. 
                        processReceiptToVoucher(current.get('intInventoryReceiptId'));
                    }
                }

                iRely.Functions.showCustomDialog('question', 'yesno', 'Items with zero cost will not be processed to voucher. Do you want to continue?', buttonActionOnZeroCost);
            }
            else {
                // Create voucher for receipt containing cost for all items
                processReceiptToVoucher(current.get('intInventoryReceiptId'));
            }
        } 
        else {
            btnVoucher.enable();
        }           
    },

    onDebitMemoClick: function (button, e, eOpts) {
        var btnDebitMemo = button;
        if (btnDebitMemo){
            btnDebitMemo.disable();
        }
        else {            
            return;
        }

        var me = this;
        var win = button.up('window'),
            current = win.viewModel.data.current;

        if (!current){
            btnDebitMemo.enable();
            return; // exit immediately. 
        }

        var receiptItems = current.tblICInventoryReceiptItems(),
            countReceiptItems = receiptItems.getRange().length,
            countPerLine = 0,
            countItemsToProcess = 0;
            countItemsWithZeroCost = 0;

        var processReceiptToDebitMemo = function (receiptId) {
            ic.utils.ajax({
                url: './inventory/api/inventoryreceipt/processbill',
                params: {
                    id: receiptId
                },
                method: 'get'
            })
            .subscribe(
                function (successResponse) {
                    var responseText = Ext.decode(successResponse.responseText);
                    var buttonAction = function (button) {
                        if (button === 'yes') {
                            iRely.Functions.openScreen('AccountsPayable.view.Voucher', {
                                filters: [
                                    {
                                        column: 'intBillId',
                                        value: responseText.message.BillId
                                    }
                                ],
                                action: 'view',
                                showAddReceipt: false
                            });
                            win.close();
                        }
                    };
                    iRely.Functions.showCustomDialog('question', 'yesno', 'Debit Memo successfully processed. Do you want to view it?', buttonAction);
                    btnDebitMemo.enable();
                }
                , function (failureResponse) {
                    var responseText = Ext.decode(failureResponse.responseText);
                    var message = responseText ? responseText.message : {}; 
                    var statusText = message ? message.statusText : 'Oh no! Something went wrong while posting the inventory return.';
                    iRely.Functions.showErrorDialog(message.statusText);
                    btnDebitMemo.enable();
                }
            );
        };

        // Loop thru the items. See if there are any zero cost items. 
        Ext.Array.each(receiptItems.data.items, function (item) {
            if (!item.dummy) {
                countItemsToProcess++;

                if (item.get('dblUnitCost') == 0) {
                    countItemsWithZeroCost++;
                    return false; // Zero cost found, break from the loop. 
                }
            }
        });        

        if (countItemsToProcess > 0) {
            // If there are zero cost in the returns, tell the user that it will not be included in the debit memo. Yes will continue. No answer will stop the process. 
            if (countItemsWithZeroCost > 0) {
                var buttonActionOnZeroCost = function (button) {
                    if (button == 'yes') {
                        // Create Debit Memo for returns. Ignore items with zero cost. 
                        processReceiptToDebitMemo(current.get('intInventoryReceiptId'));
                    }
                }

                iRely.Functions.showCustomDialog('question', 'yesno', 'Items with zero cost will not be processed to debit memo. Do you want to continue?', buttonActionOnZeroCost);
            }
            else {
                // Create debit memo for returns. 
                processReceiptToDebitMemo(current.get('intInventoryReceiptId'));
            }
        } 
        else {
            btnDebitMemo.enable();
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

        else {
            iRely.Functions.openScreen('EntityManagement.view.Entity:searchEntityVendor', { action: 'new', viewConfig: { modal: true } });
        }
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

    onLotBeforeEdit: function(editor, context, eOpts) {
        var win = editor.grid.up('window');
        var me = win.controller;
        var vw = win.viewModel;
        var lot = context.record;

        if (context.field === 'dblQuantity' && lot){
            var dblQuantity = lot.get('dblQuantity');
            dblQuantity = Ext.isNumeric(dblQuantity) ? dblQuantity : 0.00; 
            var dblTareWeight = lot.get('dblTareWeight');
            dblTareWeight = Ext.isNumeric(dblTareWeight) ? dblTareWeight : 0.00;

            lot.set('dblQuantityBeforeEdit', dblQuantity);
            lot.set('dblTareWeightBeforeEdit', dblTareWeight);
        }
    },

    onItemBeforeEdit: function(editor, context, eOpts){
        var win = editor.grid.up('window');
        var me = win.controller;
        var vw = win.viewModel;
        var currentReceiptItem = context.record;
        
        // Save the dblOpenReceive value before edit. 
        if (context.field === 'dblOpenReceive' && currentReceiptItem){
            var dblOpenReceive = currentReceiptItem.get('dblOpenReceive');
            dblOpenReceive = Ext.isNumeric(dblOpenReceive) ? dblOpenReceive : 0.00; 
            currentReceiptItem.set('dblOpenReceiveBeforeEdit', dblOpenReceive);

            var dblGross = currentReceiptItem.get('dblGross');
            dblGross = Ext.isNumeric(dblGross) ? dblGross : 0.00; 
            currentReceiptItem.set('dblGrossBeforeEdit', dblGross);

            var dblNet = currentReceiptItem.get('dblNet');
            dblNet = Ext.isNumeric(dblNet) ? dblNet : 0.00; 
            currentReceiptItem.set('dblNetBeforeEdit', dblNet);
        }
    },

    onItemEdit: function (editor, context, eOpts) {
        var win = editor.grid.up('window');
        var me = win.controller;
        var vw = win.viewModel;
        var currentReceipt = vw.data.current;
        var currentReceiptItem = context.record;

        // If editing the open receive and unit cost, update the following too:
        // 1. Unit Retail
        // 2. Gross Margin. Set to zero.
        if (context.field === 'dblUnitCost') {
            if (currentReceiptItem) {
                currentReceiptItem.set('dblUnitRetail', context.value);
                currentReceiptItem.set('dblGrossMargin', 0);
            }
        }

        if (context.field === 'dblOpenReceive' || context.field === 'strUnitMeasure' || context.field === 'strWeightUOM') {
            if (currentReceiptItem) {
                //set default values to lot
                var pnlLotTracking = win.down('#pnlLotTracking');
                if (!pnlLotTracking.hidden) {
                    var currentReceiptItemVM = vw.data.currentReceiptItem;
                    //Check if lot table has no record except for dummy
                    if (currentReceiptItemVM.tblICInventoryReceiptItemLots().getRange().length == 1) {
                        var newReceiptItemLot = Ext.create('Inventory.model.ReceiptItemLot', {
                                intInventoryReceiptItemId: currentReceiptItem.get('intInventoryReceiptItemId'),
                                intSubLocationId: currentReceiptItem.get('intSubLocationId'),
                                intStorageLocationId: currentReceiptItem.get('intStorageLocationId'),
                                dblQuantity: currentReceiptItem.get('dblOpenReceive'),
                                dblGrossWeight: currentReceiptItem.get('dblGross'),
                                dblTareWeight: currentReceiptItem.get('dblGross') - currentReceiptItem.get('dblNet'),
                                dblNetWeight: currentReceiptItem.get('dblNet'),
                                intItemUnitMeasureId: currentReceiptItem.get('intUnitMeasureId'),
                                strWeightUOM: currentReceiptItem.get('strWeightUOM'),
                                strStorageLocation: currentReceiptItem.get('strStorageLocationName'),
                                strSubLocationName:  currentReceiptItem.get('strSubLocationName'),
                                strUnitMeasure: currentReceiptItem.get('strUnitMeasure'),
                                dblLotUOMConvFactor: currentReceiptItem.get('dblItemUOMConvFactor')
                        });

                        newReceiptItemLot.set(
                            'dtmExpiryDate', 
                            me.getLotExpiryDate(
                                null, 
                                currentReceipt.get('dtmReceiptDate'), 
                                currentReceiptItem.get('intLifeTime'), 
                                currentReceiptItem.get('strLifeTimeType')
                            )
                        );

                        currentReceiptItemVM.tblICInventoryReceiptItemLots().add(newReceiptItemLot);
                    }
                }

                me.calculateLinkedItems(currentReceipt, currentReceiptItem);
            }
        }
        
        // If editing the unit retail, update the gross margin too.
        else if (context.field === 'dblUnitRetail') {
            if (currentReceiptItem) {
                var salesPrice = context.value;
                var grossMargin = ((salesPrice - currentReceiptItem.get('dblUnitCost')) / (salesPrice)) * 100;
                currentReceiptItem.set('dblGrossMargin', grossMargin);
            }
        }

        // Calculate the default Gross/Net Qty if there is a change in the Open Receive Qty. 
        if (context.field === 'dblOpenReceive') {            
            if (currentReceiptItem) {
                var dblOpenReceiveBeforeEdit = currentReceiptItem.get('dblOpenReceiveBeforeEdit'); 
                var dblOpenReceive = currentReceiptItem.get('dblOpenReceive');

                dblOpenReceiveBeforeEdit = Ext.isNumeric(dblOpenReceiveBeforeEdit) ? dblOpenReceiveBeforeEdit : 0.00;
                dblOpenReceive = Ext.isNumeric(dblOpenReceive) ? dblOpenReceive : 0.00;

                if (dblOpenReceiveBeforeEdit !== dblOpenReceive){
                    me.calculateGrossNet(currentReceiptItem, 1);
                }

                var intItemUOMId = currentReceiptItem.get('intItemUOMId'),
                    intGrossUOMId = currentReceiptItem.get('intWeightUOMId'),
                    dblQty = currentReceiptItem.get('dblOpenReceiveBeforeEdit') ? currentReceiptItem.get('dblOpenReceiveBeforeEdit') : currentReceiptItem.get('dblOpenReceive'),
                    dblProposedQty = context.value,
                    dblProposedGrossQty = currentReceiptItem.get('dblGross');

                var dblOriginalGross = currentReceiptItem.get('dblGrossBeforeEdit') ? currentReceiptItem.get('dblGrossBeforeEdit') : currentReceiptItem.get('dblGross');
                var dblOriginalNet = currentReceiptItem.get('dblNetBeforeEdit') ? currentReceiptItem.get('dblNetBeforeEdit') : currentReceiptItem.get('dblNet');

                currentReceiptItem.set('dblGross', i21.ModuleMgr.Inventory.roundDecimalFormat(dblProposedQty * (dblOriginalGross / dblQty), 6));
                currentReceiptItem.set('dblNet', i21.ModuleMgr.Inventory.roundDecimalFormat(dblProposedQty * (dblOriginalNet / dblQty), 6));
                // ic.utils.ajax({
                //     url: './Inventory/api/InventoryReceipt/CalculateGrossQtyRatio',
                //     params: {
                //         intItemUOMId: intItemUOMId,
                //         intGrossUOMId: intGrossUOMId,
                //         dblQty: dblQty,
                //         dblProposedQty: dblProposedQty,
                //         dblProposedGrossQty: dblProposedGrossQty
                //     }
                // })
                // .subscribe(
                //     function(response) {
                //         if(response) {
                //             var ratio = i21.ModuleMgr.Inventory.roundDecimalFormat(response.responseText, 2);
                //             currentReceiptItem.set('dblGross', ratio);
                //         }
                //     },
                //     function(response) {
                //         console.log(response);
                //     }
                // )
            }
        }

        if(context.field === 'dblGross') {
            if(currentReceiptItem) {
                var intItemUOMId = currentReceiptItem.get('intItemUOMId'),
                    intGrossUOMId = currentReceiptItem.get('intWeightUOMId'),
                    dblQty = currentReceiptItem.get('dblOpenReceiveBeforeEdit') ? 
                        currentReceiptItem.get('dblOpenReceiveBeforeEdit') : currentReceiptItem.get('dblOpenReceive'),
                    dblProposedQty = currentReceiptItem.get('dblOpenReceive'),
                    dblProposedGrossQty = context.value;
            
            //     ic.utils.ajax({
            //         url: './Inventory/api/InventoryReceipt/CalculateGrossQtyRatio',
            //         params: {
            //             intItemUOMId: intItemUOMId,
            //             intGrossUOMId: intGrossUOMId,
            //             dblQty: dblQty,
            //             dblProposedQty: dblProposedQty,
            //             dblProposedGrossQty: dblProposedGrossQty
            //         }
            //     })
            //     .subscribe(
            //         function(response) {
            //             var ratio = i21.ModuleMgr.Inventory.roundDecimalFormat(response.responseText, 2);
            //             currentReceiptItem.set('dblGross', ratio);
            //         },
            //         function(response) {
            //             console.log(response);
            //         }
            //     )
            }
        }

        // Accept the data input.
        currentReceiptItem.set(context.field, context.value);

        // Validate the gross and net variance.
        vw.data.currentReceiptItem = currentReceiptItem;
        if (context.field === 'dblGross' || context.field === 'dblNet') {
            me.calculateWtGainLoss(win)
        }

        // Calculate the taxes
        me.calculateItemTaxes();

        // Calculate the line total
        currentReceiptItem.set('dblLineTotal', me.calculateLineTotal(currentReceipt, currentReceiptItem));
    },

    onEditLots: function (editor, context, eOpts) {
        
        var me = this;
        var win = editor.grid.up('window');
        var receiptItem = win.viewModel.data.currentReceiptItem;
        var totalGross = iRely.Functions.isEmpty(receiptItem.get('dblGross')) ? 0 : receiptItem.get('dblGross');
        var totalNet = iRely.Functions.isEmpty(receiptItem.get('dblNet')) ? 0 : receiptItem.get('dblNet');
        var currentReceipt = win.viewModel.data.current;

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
        receiptItem.set('dblLineTotal', me.calculateLineTotal(currentReceipt, receiptItem));

        if (context.field === 'dblQuantity') {
            me.calculateGrossNet(receiptItem, 1);
        }

        //Calculate expiryDate
        if (context.field === 'dtmManufacturedDate') {
            context.record.set(
                'dtmExpiryDate', 
                me.getLotExpiryDate(
                    context.record.get('dtmManufacturedDate'), 
                    currentReceipt.get('dtmReceiptDate'), 
                    receiptItem.get('intLifeTime'), 
                    receiptItem.get('strLifeTimeType')
                )
            );            
        }

        // Calculate the 'Stated Net Per Unit'
        if (
            context.field === 'dblStatedGrossPerUnit'
            || context.field === 'dblStatedTarePerUnit'
            || context.field === 'dblQuantity'
            || context.field === 'dblGrossWeight'
            || context.field === 'dblTareWeight'
            || context.field === 'dblTareWeight'
        ) {

            context.record.set('dblStatedNetPerUnit', me.calculateStatedNetPerUnit(currentReceipt, receiptItem, context.record));
            context.record.set('dblStatedTotalNet', me.calculateStatedTotalNet(currentReceipt, receiptItem, context.record));
            context.record.set('dblPhysicalVsStated', me.calculatePhysicalVsStated(currentReceipt, receiptItem, context.record));
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
                proxy.setExtraParams({ search: true, include: 'item' });
            }
            else if (obj.combo.itemId === 'cboVendor') {
                var proxy = obj.combo.store.proxy;
                proxy.setExtraParams({ include: 'tblEntityLocations' });
            }
            else if (obj.combo.itemId === 'cboLotUOM') {
                obj.combo.defaultFilters = [
                    {
                        column: 'intItemId',
                        value: win.viewModel.data.currentReceiptItem.get('intItemId')
                    },
                    {
                        column: 'ysnAllowPurchase',
                        value: true
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
            ic.utils.ajax({
                url: './entitymanagement/api/shipvia/searchshipviaview'
            })
                .flatMap(function (res) {
                    var json = JSON.parse(res.responseText);
                    return json.data;
                })
                .filter(function (data) {
                    return data.intEntityShipViaId === records[0].get('intShipViaId');
                })
                .subscribe(
                function (successResponse) {
                    current.set('strShipVia', successResponse.strShipVia);
                    current.set('intShipViaId', records[0].get('intShipViaId'));
                }
                , function (failureResponse) {
                    var jsonData = Ext.decode(failureResponse.responseText);
                    iRely.Functions.showErrorDialog(jsonData.message.statusText);
                }
                );
            //current.set('intTaxGroupId', records[0].get('intTaxGroupId'));
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
                var costTypes = _.filter(costTypes, function (c) { return !c.ysnBasis; });
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

                                var inventoryCost = otherCharge.ysnInventoryCost ? true : false; 
                                var newOtherCharge = Ext.create('Inventory.model.ReceiptCharge', {
                                    intInventoryReceiptId: receipt.get('intInventoryReceiptId'),
                                    intContractId: po.get('intContractHeaderId'),
                                    intContractDetailId: otherCharge.intContractDetailId,
                                    intChargeId: otherCharge.intItemId,
                                    ysnInventoryCost: inventoryCost,
                                    strCostMethod: otherCharge.strCostMethod,
                                    dblRate: otherCharge.dblRate,
                                    intCostUOMId: otherCharge.intItemUOMId,
                                    intEntityVendorId: otherCharge.intVendorId,
                                    dblAmount: 0,
                                    strAllocateCostBy: 'Unit',
                                    ysnAccrue: otherCharge.intVendorId ? true : false,
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
                        text: 'Storage Unit Id',
                        hidden: true
                    },
                    {
                        dataIndex: 'intSubLocationId',
                        dataType: 'numeric',
                        text: 'Storage Location Id',
                        hidden: true
                    },
                    {
                        dataIndex: 'strSubLocationName',
                        dataType: 'string',
                        text: 'Storage Location Name',
                        hidden: true
                    },
                    {
                        dataIndex: 'strStorageName',
                        dataType: 'string',
                        text: 'Storage Unit Name',
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
                case 'Purchase Order':
                    if (iRely.Functions.isEmpty(record.get('strOrderNumber'))) {
                        switch (columnId) {
                            case 'colOrderNumber':
                                //return controller.purchaseOrderDropdown(win);
                                return false;
                            case 'colSourceNumber':
                                return false;
                        }
                    }
                    else {
                        switch (columnId) {
                            case 'colOrderNumber':
                                return false;
                            case 'colSourceNumber':
                                return false;
                        };
                    }
                    break;
                case 'Purchase Contract':
                    switch (columnId) {
                        case 'colOrderNumber':
                            if (iRely.Functions.isEmpty(record.get('strOrderNumber')))
                                //return controller.purchaseContractDropdown(win);
                                return false;
                            else
                                return false;
                        case 'colSourceNumber':
                            switch (current.get('intSourceType')) {
                                case 2:
                                    if (iRely.Functions.isEmpty(record.get('strSourceNumber')))
                                        return controller.inboundShipmentDropdown(win, record);
                                    else
                                        return false;
                                default:
                                    return false;
                            }
                    }
                    break;
                case 'Transfer Order':
                    if (iRely.Functions.isEmpty(record.get('strOrderNumber'))) {
                        switch (columnId) {
                            case 'colOrderNumber':
                                //return controller.transferOrderDropdown(win);
                                return false;
                            case 'colSourceNumber':
                                return false;
                        }
                    }
                    else {
                        switch (columnId) {
                            case 'colOrderNumber':
                                return false;
                            case 'colSourceNumber':
                                return false;
                        };
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

            var isReadOnly = vm.data.isReceiptReadonly;

            var cboLotUOM = Ext.widget({
                xtype: 'gridcombobox',
                matchFieldWidth: false,
                readOnly: isReadOnly,
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
                        dataIndex: 'ysnAllowPurchase',
                        dataType: 'boolean',
                        text: 'Stock Unit',
                        hidden: true,
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
                    },
                    {
                        column: 'ysnAllowPurchase',
                        value: true,
                        conjunction: 'and',
                        condition: 'eq'
                    }
                ]
            });

            if (cboLotUOM) {
                // cboLotUOM.on({
                //     select: me.onLotSelect,
                //     scope: me
                // });

                column.mon(cboLotUOM, {
                    select: me.onLotSelect,
                    scope: me
                });                  
            }

            /*  switch (UOMType) {
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
              } */

            if (columnId === 'colLotUOM') {
                return Ext.create('Ext.grid.CellEditor', { field: cboLotUOM });
            }
        };
    },

    // onSpecialKeyTab: function (component, e, eOpts) {
    //     var win = component.up('window');
    //     if (win) {
    //         if (e.getKey() === Ext.event.Event.TAB) {
    //             var gridObj = win.query('#grdInventoryReceipt')[0],
    //                 sel = gridObj.getStore().getAt(0);

    //             if (sel && gridObj) {
    //                 gridObj.setSelection(sel);

    //                 var column = 1;
    //                 if (win.viewModel.data.current.get('strReceiptType') === 'Direct') {
    //                     column = 2
    //                 }

    //                 var task = new Ext.util.DelayedTask(function () {
    //                     gridObj.plugins[0].startEditByPosition({
    //                         row: 0,
    //                         column: column
    //                     });
    //                 });

    //                 task.delay(10);
    //             }
    //         }
    //     }
    // },

    onItemSelectionChange: function (selModel, selected, eOpts) {
        var me = this; 

        if (selModel && selModel.view) {
            var win = selModel.view.grid.up('window');
            var vm = win ? win.viewModel : null;
            var pnlLotTracking = win ? win.down('#pnlLotTracking') : null;
            
            // Reset the weight gain/loss back to zero. 
            if (win) {
                me.updateWeightLossText(win, true, 0);
            }

            // Exit if view model object is invalid. 
            if (!vm || !vm.data)
                return; 
            
            // Get the current receipt item for use in the lot grid. 
            var current = selected && selected[0] ? selected[0] : null;
            if (current) {                
                vm.data.currentReceiptItem = 
                    current.dummy || (!!current.get('strLotTracking') && current.get('strLotTracking') === 'No') 
                    ? null 
                    : current;
            }
            else {
                vm.data.currentReceiptItem = null;
            }

            // If currentReceiptItem is valid, show the lot panel. Otherwise, hide it. 
            var hide = vm.data.currentReceiptItem ? false : true;            
            if (pnlLotTracking) {
                pnlLotTracking.setHidden(hide);    
            }

            // Calcualte the Weight Gain/Loss per line item. 
            me.calculateWtGainLoss(win);
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
            var currentReceipt = win.viewModel.data.current;
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

        var me = this;
        var win = combo.up('window');
        var record = records[0];
        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepCharges');
        var current = plugin.getActiveRecord();
        var masterRecord = win.viewModel.data.current;
        //var cboVendor = win.down('#cboVendor');
        var cboCurrency = win.down('#cboCurrency');

        if (combo.itemId === 'cboOtherCharge') {
            // Get the default Forex Rate Type from the Company Preference. 
            var intRateType = i21.ModuleMgr.SystemManager.getCompanyPreference('intInventoryRateTypeId');

            // Get the functional currency:
            var functionalCurrencyId = i21.ModuleMgr.SystemManager.getCompanyPreference('intDefaultCurrencyId');
            var strFunctionalCurrency = i21.ModuleMgr.SystemManager.getCompanyPreference('strDefaultCurrency');

            // Get the transaction currency
            var chargeCurrencyId = masterRecord.get('intCurrencyId');

            current.set('intChargeId', record.get('intItemId'));
            current.set('ysnInventoryCost', record.get('ysnInventoryCost'));
            //current.set('ysnAccrue', record.get('ysnAccrue'));
            current.set('ysnPrice', record.get('ysnPrice'));

            // If other charge is accrue, default the vendor and currency from the transaction vendor and currency. 
            // if (record.get('ysnAccrue') === true) {
            //     current.set('intEntityVendorId', masterRecord.get('intEntityVendorId'));
            //     current.set('strVendorName', masterRecord.get('strVendorName'));
            //     current.set('intCurrencyId', masterRecord.get('intCurrencyId'));
            //     current.set('strCurrency', masterRecord.get('strCurrency'));
            // }
            // else {
                current.set('intEntityVendorId', null);
                current.set('strVendorName', null);
                current.set('intCurrencyId', functionalCurrencyId);
                current.set('strCurrency', strFunctionalCurrency);
                chargeCurrencyId = functionalCurrencyId;
            //}

            current.set('intCostUOMId', record.get('intCostUOMId'));
            current.set('strCostMethod', record.get('strCostMethod'));
            current.set('strCostUOM', record.get('strCostUOM'));
            current.set('strOnCostType', record.get('strOnCostType'));
            current.set('strCostType', record.get('strCostType'));
            if (!iRely.Functions.isEmpty(record.get('strOnCostType'))) {
                current.set('strCostMethod', 'Percentage');
            }

            var dblAmount = record.get('dblAmount');
            dblAmount = Ext.isNumeric(dblAmount) ? dblAmount : 0;

            if (record.get('strCostMethod') === 'Amount') {
                current.set('dblAmount', dblAmount);
            }
            else {
                current.set('dblRate', dblAmount);
            }

            // function variable to process the default forex rate. 
            var processForexRateOnSuccess = function (successResponse, isItemLastCost) {
                if (successResponse && successResponse.length > 0) {
                    var dblForexRate = successResponse[0].dblRate;
                    var strRateType = successResponse[0].strRateType;

                    dblForexRate = Ext.isNumeric(dblForexRate) ? dblForexRate : 0;

                    // Convert the last cost to the transaction currency.
                    // and round it to six decimal places.  
                    if (chargeCurrencyId != functionalCurrencyId) {
                        dblAmount = dblForexRate != 0 ? dblAmount / dblForexRate : 0;
                        dblAmount = i21.ModuleMgr.Inventory.roundDecimalFormat(dblAmount, 6);

                        if (record.get('strCostMethod') === 'Amount') {
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
            if (chargeCurrencyId != functionalCurrencyId && intRateType) {
                iRely.Functions.getForexRate(
                    chargeCurrencyId,
                    intRateType,
                    masterRecord.get('dtmReceiptDate'),
                    function (successResponse) {
                        processForexRateOnSuccess(successResponse);
                    },
                    function (failureResponse) {
                        //var jsonData = Ext.decode(failureResponse.responseText);
                        //iRely.Functions.showErrorDialog(jsonData.message.statusText);                    
                        iRely.Functions.showErrorDialog('Something went wrong while getting the forex data.');
                    }
                );
            }

            // Get the default tax group
            var taxCfg = {
                freightTermId: null, // Freight Terms is not applicable for other charges. 
                locationId: masterRecord.get('intLocationId'),
                entityVendorId: current.get('intEntityVendorId'),
                entityLocationId: null,
                itemId: current.get('intChargeId')
            };
            me.getDefaultReceiptTaxGroupId(current, taxCfg);
        }
        
        if (combo.itemId === 'cboCostMethod') {
            // If 'Per Unit'
            // Do Nothing 

            // If 'Percentage' 
            if (record.get('strDescription') == 'Percentage'){
                current.set('dblQuantity', 1);
                current.set('intCostUOMId', null);
                current.set('strCostUOM', null);
            }            

            // If 'Amount'
            if (record.get('strDescription') == 'Amount'){
                current.set('dblQuantity', 1);
                current.set('dblRate', 0);
                current.set('intCostUOMId', null);
                current.set('strCostUOM', null);
            }            

        }

        if (combo.itemId === 'cboChargeCurrency') {
            
            var dblRate = current.get('dblRate'); 
            var functionalCurrencyId = i21.ModuleMgr.SystemManager.getCompanyPreference('intDefaultCurrencyId');
            var strFunctionalCurrency = i21.ModuleMgr.SystemManager.getCompanyPreference('strDefaultCurrency');         
            var intRateType = i21.ModuleMgr.SystemManager.getCompanyPreference('intInventoryRateTypeId');  
            var dblCurrentForexRate = current.get('dblForexRate');
            
            // Convert the current rate to the functional currency. 
            dblCurrentForexRate = Ext.isNumeric(dblCurrentForexRate) ? dblCurrentForexRate : 0;
            dblRate = Ext.isNumeric(dblRate) ? dblRate : 0;
            dblRate = dblCurrentForexRate != 0 ? dblRate * dblCurrentForexRate : dblRate;
            dblRate = i21.ModuleMgr.Inventory.roundDecimalFormat(dblRate, 6);	            

            current.set('intCurrencyId', record.get('intCurrencyID'));
            current.set('strCurrency', record.get('strCurrency'));
            current.set('intCent', record.get('intCent'));
            current.set('ysnSubCurrency', record.get('ysnSubCurrency'));
            current.set('intForexRateTypeId', null);
            current.set('strForexRateType', null);
            current.set('dblForexRate', null);
            current.set('dblRate', dblRate);

            var chargeCurrencyId = current.get('intCurrencyId');         

            // function variable to process the default forex rate. 
            var processForexRateOnSuccess = function (successResponse, isItemLastCost) {
                if (successResponse && successResponse.length > 0) {
                    var dblForexRate = successResponse[0].dblRate;
                    var strRateType = successResponse[0].strRateType;

                    dblForexRate = Ext.isNumeric(dblForexRate) ? dblForexRate : 0;

                    // Convert the dblRate to the other charge currency.
                    // and round it to six decimal places.  
                    if (chargeCurrencyId != functionalCurrencyId && dblRate) {
                        dblRate = dblRate != 0 ? dblRate / dblForexRate : 0;
                        dblRate = i21.ModuleMgr.Inventory.roundDecimalFormat(dblRate, 6);
                    }	                    

                    current.set('intForexRateTypeId', intRateType);
                    current.set('strForexRateType', strRateType);
                    current.set('dblForexRate', dblForexRate);
                    current.set('dblRate', dblRate);
                }
            }

            // If transaction currency is a foreign currency, get the default forex rate type, forex rate, and convert the last cost to the transaction currency. 
            if (chargeCurrencyId != functionalCurrencyId && intRateType) {
                iRely.Functions.getForexRate(
                    chargeCurrencyId,
                    intRateType,
                    masterRecord.get('dtmReceiptDate'),
                    function (successResponse) {
                        processForexRateOnSuccess(successResponse);
                    },
                    function (failureResponse) {
                        var jsonData = Ext.decode(failureResponse.responseText);
                        iRely.Functions.showErrorDialog('Something went wrong while getting the forex data.');
                    }
                );
            }
        }

        if (combo.itemId === 'cboChargeTaxGroup') {
            this.doOtherChargeTaxCalculate(win);
        }

        if (combo.itemId === 'cboCostVendor') {
            current.set('intEntityVendorId', record.get('intEntityId'));
            // Get the tax group for the other charge. 
            {                
                var taxCfg = {
                    freightTermId: null, // Freight Terms is not applicable for other charges. 
                    locationId: masterRecord.get('intLocationId'),
                    entityVendorId: current.get('intEntityVendorId'),
                    entityLocationId: null,
                    itemId: current.get('intChargeId')
                };
                me.getDefaultReceiptTaxGroupId(current, taxCfg);
            }
            
            // Convert the current amount (or rate) to the functional currency; 
            var dblAmount = null;
            var dblCurrentForexRate = current.get('dblForexRate');
            dblCurrentForexRate = Ext.isNumeric(dblCurrentForexRate) ? dblCurrentForexRate : 0;

            if (current.get('strCostMethod') === 'Amount') {
                dblAmount = current.get('dblAmount');
            }
            else {
                dblAmount = current.get('dblRate');
            }

            dblAmount = Ext.isNumeric(dblAmount) ? dblAmount : 0;
            dblAmount = dblCurrentForexRate != 0 ? dblAmount * dblCurrentForexRate : dblAmount;
            dblAmount = i21.ModuleMgr.Inventory.roundDecimalFormat(dblAmount, 6);

            if (current.get('strCostMethod') === 'Amount') {
                current.set('dblAmount', dblAmount);
            }
            else {
                current.set('dblRate', dblAmount);
            }

            // Clear the forex rate
            current.set('dblForexRate', null);

            // Process the foreign currency for the 3rd party vendor. 
            if (current.get('intEntityVendorId') !== masterRecord.get('intEntityVendorId'))
            {
                // Get and set the vendor currency. 
                var thirdPartyVendorCurrencyId = record.get('intCurrencyId');
                var thirdPartyVendorCurrency = record.get('strCurrency');

                current.set('intCurrencyId', thirdPartyVendorCurrencyId);
                current.set('strCurrency', thirdPartyVendorCurrency);

                // Get the functional currency:
                var functionalCurrencyId = i21.ModuleMgr.SystemManager.getCompanyPreference('intDefaultCurrencyId');

                // Get the current forex rate type
                var intRateType = current.get('intForexRateTypeId');

                // function variable to process the default forex rate. 
                var processForexRateOnSuccess = function (successResponse, isItemLastCost) {
                    if (successResponse && successResponse.length > 0) {
                        var dblForexRate = successResponse[0].dblRate;
                        var strRateType = successResponse[0].strRateType;

                        dblForexRate = Ext.isNumeric(dblForexRate) ? dblForexRate : 0;

                        // Convert the last cost to the transaction currency.
                        // and round it to six decimal places.  
                        if (chargeCurrencyId != functionalCurrencyId) {
                            dblAmount = dblForexRate != 0 ? dblAmount / dblForexRate : 0;
                            dblAmount = i21.ModuleMgr.Inventory.roundDecimalFormat(dblAmount, 6);

                            if (current.get('strCostMethod') === 'Amount') {
                                current.set('dblAmount', dblAmount);
                            }
                            else {
                                current.set('dblRate', dblAmount);
                            }
                        }

                        current.set('dblForexRate', dblForexRate);
                        current.set('intForexRateTypeId', intRateType);
                        current.set('strForexRateType', strRateType);
                    }
                }

                // If transaction currency is a foreign currency, get the default forex rate type, forex rate, and convert the last cost to the transaction currency. 
                if (thirdPartyVendorCurrencyId != functionalCurrencyId) {

                    // If intRateType is invalid, get the default Forex Rate Type from the Company Preference.
                    if (!intRateType) {
                        intRateType = i21.ModuleMgr.SystemManager.getCompanyPreference('intInventoryRateTypeId');
                    }

                    iRely.Functions.getForexRate(
                        thirdPartyVendorCurrencyId,
                        intRateType,
                        masterRecord.get('dtmReceiptDate'),
                        function (successResponse) {
                            processForexRateOnSuccess(successResponse);
                        },
                        function (failureResponse) {
                            //var jsonData = Ext.decode(failureResponse.responseText);
                            //iRely.Functions.showErrorDialog(jsonData.message.statusText);                    
                            iRely.Functions.showErrorDialog('Something went wrong while getting the forex data.');
                        }
                    );
                }
                else {
                    // Since 3rd party vendor currency is in functional, clear the forex rate type. 
                    current.set('intForexRateTypeId', null);
                    current.set('strForexRateType', null);
                }
            }
        }

        if (combo.itemId === 'cboChargeForexRateType') {
            var chargeCurrencyId = current.get('intCurrencyId');
            var dblRate = current.get('dblRate'); 
            var functionalCurrencyId = i21.ModuleMgr.SystemManager.getCompanyPreference('intDefaultCurrencyId');
            var dblCurrentForexRate = current.get('dblForexRate');

            // Convert the current rate to the functional currency.             
            dblCurrentForexRate = Ext.isNumeric(dblCurrentForexRate) ? dblCurrentForexRate : 0;
            dblRate = Ext.isNumeric(dblRate) ? dblRate : 0;
            dblRate = dblCurrentForexRate != 0 ? dblRate * dblCurrentForexRate : dblRate;
            dblRate = i21.ModuleMgr.Inventory.roundDecimalFormat(dblRate, 6);	

            current.set('intForexRateTypeId', records[0].get('intCurrencyExchangeRateTypeId'));
            current.set('strForexRateType', records[0].get('strCurrencyExchangeRateType'));
            current.set('dblForexRate', null);

            iRely.Functions.getForexRate(
                current.get('intCurrencyId'),
                current.get('intForexRateTypeId'),
                win.viewModel.data.current.get('dtmReceiptDate'),
                function (successResponse) {
                    if (successResponse && successResponse.length > 0) {
                        current.set('dblForexRate', successResponse[0].dblRate);
                        var dblForexRate = current.get('dblForexRate');

                        // Convert the dblRate to the other charge currency.
                        // and round it to six decimal places.  
                        if (chargeCurrencyId != functionalCurrencyId && dblRate) {
                            dblRate = dblRate != 0 ? dblRate / dblForexRate : 0;
                            dblRate = i21.ModuleMgr.Inventory.roundDecimalFormat(dblRate, 6);
                        }	                          

                        current.set('dblRate', dblRate);
                    }
                },
                function (failureResponse) {
                    //var jsonData = Ext.decode(failureResponse.responseText);
                    //iRely.Functions.showErrorDialog(jsonData.message.statusText);                    
                    iRely.Functions.showErrorDialog('Something went wrong while getting the forex data.');
                }
            );
        }
    },

    // onAccrueCheckChange: function (obj, rowIndex, checked, eOpts) {
    //     if (obj.dataIndex === 'ysnAccrue') {
    //         var grid = obj.up('grid');
    //         var win = obj.up('window');
    //         var current = grid.view.getRecord(rowIndex);
    //         var masterRecord = win.viewModel.data.current;
    //         var cboVendor = win.down('#cboVendor');

    //         if (checked === true) {
    //             if (iRely.Functions.isEmpty(current.get('strVendorName'))) {
    //                 current.set('intEntityVendorId', masterRecord.get('intEntityVendorId'));
    //                 current.set('strVendorName', cboVendor.getRawValue());
    //             }
    //         }
    //         else {
    //             current.set('intEntityVendorId', null);
    //             current.set('strVendorName', null);
    //         }
    //     }
    // },

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
                    Condition: 'EQUAL TO',
                    From: strLotNo,
                    To: '',
                    Operator: ''
                }],
            directPrint: true
        });
    },

    onAddOrderClick: function (button, e, eOpts) {
        var win = button.up('window');
        this.showAddOrders(win);
    },

    onFetchClicked: function(e) {
        var me = this;
        var answer = function(button) {
            if(button === 'yes') {
                me.updateCostFromContract();
            }
        };
        
        iRely.Functions.showCustomDialog(iRely.Functions.dialogType.WARNING,
        iRely.Functions.dialogButtonType.YESNO, "This will overwrite existing costs and calculations. Do you want to continue?", answer);

    },

    updateCostFromContract: function () {
        Ext.MessageBox.show({
            title: "Fetch Costs from Contracts",
            msg: "Fetching other charges from contracts.",
            progressText: "Please wait...",
            width: 300,
            progress: false,
            closable: false
        });

        var me = this;
        var win = me.getView();
        var currentRecord = win.viewModel.data.current;
        var VendorId = null;
        var ReceiptType = currentRecord.get('strReceiptType');
        var SourceType = currentRecord.get('intSourceType').toString();
        var CurrencyId = currentRecord.get('intCurrencyId') === null ? 0 : currentRecord.get('intCurrencyId').toString();
        var ContractStore = win.viewModel.storeInfo.purchaseContractList;
        var win = me.view;

        if (ReceiptType === 'Transfer Order') {
            VendorId = currentRecord.get('intTransferorId').toString();
        }
        else {
            VendorId = currentRecord.get('intEntityVendorId').toString();
        }

        var currentVM = me.getViewModel().data.current;

        var rx = Rx.Observable.from(currentRecord.tblICInventoryReceiptItems().data.items)
            .flatMap(function(x) {
                if(x.dummy)
                    return Rx.Observable.of([]);
                var order = x.data;
                var filter = iRely.Functions.encodeFilters([
                    {
                        column: 'intContractDetailId',
                        value: order.intLineNo,
                        conjunction: 'and'
                    },
                    {
                        column: 'intContractHeaderId',
                        value: order.intOrderId,
                        conjunction: 'and'
                    }
                ]);
                var arx = ic.utils.ajax({
                    url: ContractStore.proxy.api.read,
                    params: {
                        filter: filter
                    },
                    pageSize: 50
                })
                .map(function(response) {
                    var json = JSON.parse(response.responseText);
                    return {
                        order: order,
                        contract: {
                            details: _.omit(json.data[0], 'tblCTContractCosts'),
                            costs: _.filter(json.data[0].tblCTContractCosts, function(cost) { return !cost.ysnBasis; } )
                        }
                    };

                }); 

                return Rx.Observable.forkJoin(arx);
            })
            .filter(function(x) {
                return x.length > 0;
            })
            .subscribe(function (output) {
                Ext.MessageBox.updateProgress(100, 'Calculating taxes...');
                var g = win.down("#grdCharges").store.data.removeAll();
                if(output && output.length > 0 && output[0].contract) {
                    var data = output[0];
                    _.each(data.contract.costs, function(cost) {
                        var inventoryCost = cost.ysnInventoryCost ? true : false; 
                        var newReceiptCharge = Ext.create('Inventory.model.ReceiptCharge', {
                            intInventoryReceiptId: currentVM.get('intInventoryReceiptId'),
                            intContractId: data.order.intOrderId,
                            intContractDetailId: cost.intContractDetailId,
                            intChargeId: cost.intItemId,
                            ysnInventoryCost: inventoryCost,
                            strCostMethod: cost.strCostMethod,
                            dblRate: cost.strCostMethod == "Amount" ? 0 : cost.dblRate,
                            intCostUOMId: cost.intItemUOMId,
                            intEntityVendorId: cost.intVendorId,
                            dblAmount: cost.strCostMethod == "Amount" ? cost.dblRate : 0,
                            strAllocateCostBy: 'Unit',
                            ysnAccrue: cost.intVendorId ? true : false,
                            ysnPrice: cost.ysnPrice,
                            strItemNo: cost.strItemNo,
                            intCurrencyId: cost.intCurrencyId,
                            strCurrency: cost.strCurrency,
                            ysnSubCurrency: cost.ysnSubCurrency,
                            strCostUOM: cost.strUOM,
                            strVendorName: cost.strVendorName,
                            strContractNumber: data.order.strOrderNumber

                        });
                        currentVM.tblICInventoryReceiptCharges().add(newReceiptCharge); 
                    });
                }

                Ext.MessageBox.hide();

                // If there is no data change, do the ajax request.
                if (!win.context.data.hasChanges()) {
                    me.doOtherChargeCalculate(win);
                    return;
                }

                // Save has data changes first before doing the post.
                win.context.data.saveRecord({
                    successFn: function () {
                        me.doOtherChargeCalculate(win);
                    }
                });
            }, function(failure) {
                Ext.MessageBox.hide();
            });
    },

    showAddOrders: function (win) {
        var me = this;
        var currentRecord = win.viewModel.data.current;
        var VendorId = null;
        var ReceiptType = currentRecord.get('strReceiptType');
        var SourceType = currentRecord.get('intSourceType').toString();
        var CurrencyId = currentRecord.get('intCurrencyId') === null ? 0 : currentRecord.get('intCurrencyId').toString();
        var ContractStore = win.viewModel.storeInfo.purchaseContractList;
        var win = me.view;

        if (ReceiptType === 'Transfer Order') {
            VendorId = currentRecord.get('intTransferorId').toString();
        }
        else {
            VendorId = currentRecord.get('intEntityVendorId').toString();
        }

        iRely.Functions.openScreen('GlobalComponentEngine.view.FloatingSearch', {
            searchSettings: {
                scope: me,
                type: 'Inventory.GetAddOrders',
                url: './inventory/api/inventoryreceipt/getaddorders?vendorid=' + VendorId + '&ReceiptType=' + ReceiptType + '&SourceType=' + SourceType + '&CurrencyId=' + CurrencyId,
                columns: [
                    { dataIndex: 'intKey', text: "Key", flex: 1, dataType: 'numeric', key: true, hidden: true },
                    { dataIndex: 'strOrderNumber', text: 'Order Number', width: 100, dataType: 'string', drillDownText: 'View Receipt', drillDownClick: 'onViewReceiptNo' },
                    { dataIndex: 'intContractSeq', text: 'Sequence', width: 100, dataType: 'numeric', allowNull: true },
                    { xtype: 'numbercolumn', dataIndex: 'dblOrderUOMConvFactor', text: 'Order UOM Conversion Factor', width: 100, dataType: 'float', hidden: true, required: true },
                    { xtype: 'numbercolumn', dataIndex: 'dblOrdered', text: 'Ordered Qty', width: 100, dataType: 'float' },
                    { xtype: 'numbercolumn', dataIndex: 'dblReceived', text: 'Received Qty', width: 100, dataType: 'float' },
                    { dataIndex: 'strSourceNumber', text: 'Source Number', width: 100, dataType: 'string' },
                    { dataIndex: 'strItemNo', text: 'Item No', width: 100, dataType: 'string' },
                    { dataIndex: 'strItemDescription', text: 'Item Description', width: 100, dataType: 'string' },

                    //{ xtype: 'checkcolumn', dataIndex: 'ysnIsBasket', text: 'Is Basket', width: 100, dataType: 'boolean', hidden: false, required: true },
                    { dataIndex: 'strBundleType', text: 'Bundle Type', width: 150, dataType: 'string', required: true },
                    //{ dataIndex: 'intBundledItemId', text: 'Basket Id', width: 100, dataType: 'numeric', hidden: true, required: true, allowNull: true },
                    //{ dataIndex: 'strBundledItemNo', text: 'Basket No', width: 150, dataType: 'string', required: true },
                    //{ dataIndex: 'strBundledItemDescription', text: 'Basket Name', width: 200, dataType: 'string', required: true },
                    { xtype: 'numbercolumn', dataIndex: 'dblQtyToReceive', text: 'Qty to Receive', width: 100, dataType: 'float' },
                    { xtype: 'numbercolumn', dataIndex: 'intLoadToReceive', text: 'Load to Receive', width: 100, dataType: 'numeric' },
                    { xtype: 'numbercolumn', dataIndex: 'dblUnitCost', text: 'Cost', width: 100, dataType: 'float' },
                    { xtype: 'numbercolumn', dataIndex: 'dblTax', text: 'Tax', width: 100, dataType: 'float' },
                    { xtype: 'numbercolumn', dataIndex: 'dblLineTotal', text: 'Line Total', width: 100, dataType: 'float' },

                    { dataIndex: 'strLotTracking', text: 'Lot Tracking', width: 100, dataType: 'string', hidden: true, required: true },
                    { dataIndex: 'strContainer', text: 'Container', width: 100, dataType: 'string' },
                    { dataIndex: 'strSubLocationName', text: 'Storage Location', width: 100, dataType: 'string' },
                    { dataIndex: 'strStorageLocationName', text: 'Storage Unit', width: 100, dataType: 'string' },

                    { dataIndex: 'intFreightTermId', text: 'Freight Terms Id', width: 100, dataType: 'numeric', hidden: true, required: true, allowNull: true },
                    { dataIndex: 'strFreightTerm', text: 'Freight Terms', width: 100, dataType: 'string' },

                    { dataIndex: 'intLotId', text: 'Lot Id', dataType: 'numeric', width: 100, dataType: 'numeric', hidden: true, required: true, allowNull: true },
                    { dataIndex: 'strLotNumber', text: 'Lot No', width: 100, dataType: 'string', hidden: true, required: true },
                    { dataIndex: 'dtmExpiryDate', text: 'Expiry Date', width: 100, dataType: 'date', hidden: true, required: true },
                    { dataIndex: 'dtmManufacturedDate', text: 'Manufactured Date', width: 100, dataType: 'date', hidden: true, required: true },
                    { dataIndex: 'strLotAlias', text: 'Lot Alias', width: 100, dataType: 'string', hidden: true, required: true },
                    { dataIndex: 'intParentLotId', text: 'Parent Lot Id', dataType: 'numeric', width: 100, hidden: true, required: true, allowNull: true },
                    { dataIndex: 'strParentLotNumber', text: 'Parent Lot No', width: 100, dataType: 'string', hidden: true, required: true },

                    { dataIndex: 'strUnitMeasure', text: 'Item UOM', width: 100, dataType: 'string', required: true },
                    { dataIndex: 'strOrderUOM', text: 'Order UOM', width: 100, dataType: 'string', required: true },
                    { dataIndex: 'strItemUOM', text: 'Item UOM', width: 100, dataType: 'string', required: true, hidden: true },
                    { dataIndex: 'strUnitType', text: 'Item UOM Type', width: 100, dataType: 'string', hidden: true, required: true },
                    { xtype: 'numbercolumn', dataIndex: 'dblItemUOMConvFactor', text: 'Item UOM Conversion Factor', width: 100, dataType: 'float', hidden: true, required: true },
                    { dataIndex: 'strWeightUOM', text: 'Weight UOM', width: 100, dataType: 'string' },
                    { xtype: 'numbercolumn', dataIndex: 'dblWeightUOMConvFactor', text: 'Weight UOM Conversion Factor', width: 100, dataType: 'float', hidden: true, required: true },
                    { dataIndex: 'strCostUOM', text: 'Cost UOM', width: 100, dataType: 'string' },
                    { xtype: 'numbercolumn', dataIndex: 'dblCostUOMConvFactor', text: 'Cost UOM Conversion Factor', width: 100, dataType: 'float', hidden: true, required: true },
                    { dataIndex: 'intLifeTime', text: 'Lifetime', width: 100, dataType: 'string', hidden: true, required: true, allowNull: true },
                    { dataIndex: 'strLifeTimeType', text: 'Lifetime Type', width: 100, dataType: 'string', hidden: true, required: true },
                    { dataIndex: 'ysnLoad', text: 'Load Contract', width: 100, dataType: 'boolean', xtype: 'checkcolumn' },
                    { xtype: 'numbercolumn', dataIndex: 'dblAvailableQty', text: 'Available Qty', width: 100, dataType: 'float' },
                    { dataIndex: 'strBOL', text: 'BOL', width: 100, dataType: 'string', hidden: true, required: true },
                    { dataIndex: 'intLocationId', text: 'Location Id', width: 100, dataType: 'numeric', hidden: true, required: true, allowNull: true },
                    { dataIndex: 'intEntityVendorId', text: 'Vendor Id', width: 100, dataType: 'numeric', hidden: true, required: true, allowNull: true },
                    { dataIndex: 'strVendorId', text: 'Vendor', width: 100, dataType: 'string', hidden: true, required: true },
                    { dataIndex: 'strVendorName', text: 'Vendor Name', width: 100, dataType: 'string', hidden: true, required: true },
                    { dataIndex: 'strReceiptType', text: 'Transaction Type', width: 100, dataType: 'string', hidden: true },
                    { dataIndex: 'intLineNo', text: 'Line No', width: 100, dataType: 'numeric', hidden: true, required: true, allowNull: true },
                    { dataIndex: 'intOrderId', text: 'Order Id', defaultSort: true, sortOrder: 'DESC', width: 100, dataType: 'numeric', hidden: true, required: true, allowNull: true },
                    { dataIndex: 'intSourceType', text: 'Source Type', width: 100, dataType: 'numeric', hidden: true, required: true, allowNull: true },
                    { dataIndex: 'intSourceId', text: 'Source Id', width: 100, dataType: 'string', hidden: true, required: true, allowNull: true },
                    { dataIndex: 'intItemId', text: 'Item Id', width: 100, dataType: 'string', hidden: true, required: true, allowNull: true },
                    { dataIndex: 'intCommodityId', text: 'Commodity Id', width: 100, dataType: 'string', hidden: true, required: true, allowNull: true },
                    { dataIndex: 'intContainerId', text: 'Container Id', width: 100, dataType: 'numeric', hidden: true, required: true, allowNull: true, allowNull: true },
                    { dataIndex: 'intSubLocationId', text: 'SubLocation Id', width: 100, dataType: 'numeric', hidden: true, required: true, allowNull: true, allowNull: true },
                    { dataIndex: 'intStorageLocationId', text: 'Storage Location Id', width: 100, dataType: 'numeric', hidden: true, required: true, allowNull: true, allowNull: true },
                    { dataIndex: 'intOrderUOMId', text: 'Order UOM Id', width: 100, dataType: 'string', hidden: true, required: true, allowNull: true },
                    { dataIndex: 'intItemUOMId', text: 'Item UOM Id', width: 100, dataType: 'string', hidden: true, required: true, allowNull: true },
                    { dataIndex: 'intWeightUOMId', text: 'Weight UOM Id', width: 100, dataType: 'string', hidden: true, required: true, allowNull: true },
                    { dataIndex: 'intCostUOMId', text: 'Cost UOM Id', width: 100, dataType: 'numeric', hidden: true, required: true, allowNull: true, allowNull: true },
                    { dataIndex: 'ysnSubCurrency', text: 'Cost Currency', width: 100, dataType: 'boolean', hidden: true, required: true },
                    { dataIndex: 'strSubCurrency', text: 'Cost Currency', width: 100, dataType: 'string', hidden: true, required: true },
                    { xtype: 'numbercolumn', dataIndex: 'dblFranchise', text: 'Franchise', width: 100, dataType: 'float', hidden: true, required: true },
                    { xtype: 'numbercolumn', dataIndex: 'dblContainerWeightPerQty', text: 'Container Weight Per Qty', width: 100, dataType: 'float', hidden: true, required: true },

                    { dataIndex: 'intForexRateTypeId', text: 'Forex Rate Type Id', width: 100, dataType: 'numeric', hidden: true, required: true, allowNull: true },
                    { dataIndex: 'strForexRateType', text: 'Forex Rate Type', width: 100, dataType: 'string', hidden: true, required: true },
                    { xtype: 'numbercolumn', dataIndex: 'dblForexRate', text: 'Forex Rate', width: 100, dataType: 'float', hidden: true, required: true },

                    { xtype: 'numbercolumn', dataIndex: 'dblGross', text: 'Gross', width: 100, dataType: 'float' },
                    { xtype: 'numbercolumn', dataIndex: 'dblNet', text: 'Net', width: 100, dataType: 'float' },
                    { dataIndex: 'strMarkings', text: 'Markings', width: 100, dataType: 'string', hidden: true, required: true }
                ],
                title: "Add Orders",
                showNew: false
            },
            viewConfig: {
                listeners: {
                    scope: me,
                    openselectedclick: function(button, e, result) {
                        var win = me.getView();
                        var vm = me.getViewModel();
                        var currentVM = me.getViewModel().data.current;
                        var basketErrors = [];
                        var addedBasketItem = currentVM.tblICInventoryReceiptItems().data;
                        
                        var freightTermsError = [];
                        var addOrderFreightTerms;
                        var receiptFreightTerms = currentVM.get('intFreightTermId');
                        var isValidToAdd = true; 
                        var newReceiptItem;
                        
                        Ext.each(result, function (order) {
                            //isValidToAdd = true;
                            var strBundleType = order.get('strBundleType');
                            var intContainerId = order.get('intContainerId');
                            
                            // Check if the Order's Freight Terms is the same with the Receipt Freight Terms
                            addOrderFreightTerms = order.get('intFreightTermId');                            
                            if (receiptFreightTerms != addOrderFreightTerms
                                && (
                                    ReceiptType === 'Purchase Order'
                                    || (ReceiptType === 'Purchase Contract' && (SourceType == 0 || SourceType == 2) ) 
                                )
                            ){
                                freightTermsError.push({
                                    orderId: order.get('intOrderId'),
                                    orderFreightTerm: addOrderFreightTerms
                                });
                                isValidToAdd = false; 
                            }                            

                            if (isValidToAdd){
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
                                    dblUnitCost: strBundleType == 'Kit' ? 0 : order.get('dblUnitCost'),//order.get('dblUnitCost')
                                    dblUnitRetail: strBundleType == 'Kit' ? 0 : order.get('dblUnitCost'),//order.get('dblUnitCost')
                                    dblTax: order.get('dblTax'),
                                    dblLineTotal: strBundleType == 'Kit' ? 0 : order.get('dblUnitCost'),//order.get('dblLineTotal'),
                                    strLotTracking: order.get('strLotTracking'),
                                    intCommodityId: order.get('intCommodityId'),
                                    intContainerId: order.get('intContainerId'),
                                    strContainer: order.get('strContainer'),
                                    intContractSeq: order.get('intContractSeq'),
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
                                    //intGradeId: order.get('intGradeId'),
                                    //strGrade: order.get('strGrade'),
                                    intLifeTime: order.get('intLifeTime'),
                                    strLifeTimeType: order.get('strLifeTimeType'),
                                    ysnLoad: order.get('ysnLoad'),
                                    dblAvailableQty: order.get('dblAvailableQty'),
                                    intOwnershipType: 1,
                                    strOwnershipType: 'Own',
                                    dblFranchise: order.get('dblFranchise'),
                                    dblContainerWeightPerQty: order.get('dblContainerWeightPerQty'),
                                    intContainerWeightUOMId: order.get('intWeightUOMId'),
                                    dblContainerWeightUOMConvFactor: order.get('dblWeightUOMConvFactor'),
                                    ysnSubCurrency: order.get('ysnSubCurrency'),
                                    strSubCurrency: order.get('strSubCurrency'),
                                    dblGross: order.get('dblGross'),
                                    dblNet: order.get('dblNet'),
                                    intForexRateTypeId: order.get('intForexRateTypeId'),
                                    strForexRateType: order.get('strForexRateType'),
                                    dblForexRate: order.get('dblForexRate'),
                                };
                                currentVM.set('strBillOfLading', order.get('strBOL'));

                                if (ReceiptType === 'Transfer Order') {
                                    if ((me.getViewModel().data.locationFromTransferOrder === null && currentVM.phantom) || (me.getViewModel().data.locationFromTransferOrder === null &&
                                        currentVM.get('intLocationId') === null)) {
                                        currentVM.set('intLocationId', order.get('intEntityVendorId'));
                                        currentVM.set('strLocationName', order.get('strVendorName'));
                                        me.getViewModel().set('locationFromTransferOrder', order.get('strVendorName'));
                                    } else {
                                        if (currentVM.get('intLocationId') === null) {
                                            currentVM.set('intLocationId', order.get('intEntityVendorId'));
                                            currentVM.set('strLocationName', order.get('strVendorName'));
                                            me.getViewModel().set('locationFromTransferOrder', order.get('strVendorName'));
                                        }
                                    }
                                }

                                // Add the item record.
                                if(strBundleType == 'Kit'){
                                    currentVM.tblICInventoryReceiptItems().add(newRecord);
                                    newReceiptItem = currentVM.tblICInventoryReceiptItems().findRecord('intLineNo', newRecord.intLineNo);
                                    me.getBundleComponents(newReceiptItem, order, currentVM, currentVM.tblICInventoryReceiptItems());
                                } 
                                else if(strBundleType == 'Option') {
                                    me.getBundleComponents(newReceiptItem, order, currentVM, currentVM.tblICInventoryReceiptItems());
                                }
                                else if (intContainerId) {
                                    currentVM.tblICInventoryReceiptItems().add(newRecord);
                                    newReceiptItem = currentVM.tblICInventoryReceiptItems().findRecord('intContainerId', newRecord.intContainerId);                                
                                } 
                                else {
                                    currentVM.tblICInventoryReceiptItems().add(newRecord);
                                    newReceiptItem = currentVM.tblICInventoryReceiptItems().findRecord('intLineNo', newRecord.intLineNo);
                                }

                                //newReceiptItem = currentVM.tblICInventoryReceiptItems().findRecord('intOrderId', newRecord.intOrderId);
                                
                                // Calculate the line total
                                if(newReceiptItem){
                                    newReceiptItem.set('dblLineTotal', me.calculateLineTotal(currentVM, newReceiptItem));

                                    win.viewModel.data.currentReceiptItem = newReceiptItem;
                                    // Get the default tax group from the Vendor setup
                                    var taxCfg = {
                                        freightTermId: currentRecord.get('intFreightTermId'),
                                        locationId: currentRecord.get('intLocationId'),
                                        entityVendorId: currentRecord.get('intEntityVendorId'),
                                        entityLocationId: currentRecord.get('intShipFromId'),
                                        itemId: newReceiptItem.get('intItemId'),
                                        successFn: function(){
                                            // Calculate the taxes after getting the default tax group. 
                                            me.calculateItemTaxes();
                                        }
                                    }; 
    
                                    me.getDefaultReceiptTaxGroupId(newReceiptItem, taxCfg);  
                                    // Calculate the Wgt or Volume Gain/Loss 
                                    me.calculateWtGainLoss(win);
                                }

                                if (ReceiptType === 'Purchase Contract' && strBundleType != 'Option' && newReceiptItem) {
                                    me.addContractOtherCharges(currentVM, newReceiptItem, order);
                                }

                                if (!!order.get('strLotTracking') && order.get('strLotTracking') !== 'No' && newReceiptItem.get('intWeightUOMId') === null) {
                                    //Set default value for Gross/Net UOM
                                    newReceiptItem.set('intWeightUOMId', order.get('intItemUOMId'));
                                    newReceiptItem.set('strWeightUOM', order.get('strUnitMeasure'));
                                    newReceiptItem.set('dblGross', i21.ModuleMgr.Inventory.roundDecimalFormat(order.get('dblQtyToReceive'), 6));
                                    newReceiptItem.set('dblNet', i21.ModuleMgr.Inventory.roundDecimalFormat(order.get('dblQtyToReceive'), 6));
                                    newReceiptItem.set('dblWeightUOMConvFactor', order.get('dblItemUOMConvFactor'));

                                    //Calculate Line Total
                                    var currentReceipt = win.viewModel.data.current;
                                    newReceiptItem.set('dblLineTotal', me.calculateLineTotal(currentReceipt, newReceiptItem));
                                }

                                if (order.get('intWeightUOMId') !== null) {
                                    if (order.get('dblGross') === 0 && order.get('dblNet') !== 0) {
                                        newReceiptItem.set('dblGross', i21.ModuleMgr.Inventory.roundDecimalFormat(order.get('dblNet'), 6));
                                    }

                                    else if (order.get('dblGross') !== 0 && order.get('dblNet') === 0) {
                                        newReceiptItem.set('dblNet', i21.ModuleMgr.Inventory.roundDecimalFormat(order.get('dblGross'), 6));
                                    }

                                    else if (order.get('dblGross') === 0 && order.get('dblNet') === 0) {
                                        var currentReceiptItem = win.viewModel.data.currentReceiptItem;
                                        me.calculateGrossNet(currentReceiptItem, 1);
                                    }
                                }

                                //Add default values to lot if item is lot-tracked
                                if (!iRely.Functions.isEmpty(order.get('strLotTracking')) && order.get('strLotTracking') !== 'No') {
                                    var currentReceiptItemVM = me.getViewModel().data.currentReceiptItem;

                                    var newReceiptItemLot = Ext.create('Inventory.model.ReceiptItemLot', {
                                        intLotId: order.get('intLotId'),
                                        strLotNumber: order.get('strLotNumber'),
                                        dtmExpiryDate: order.get('dtmExpiryDate'),
                                        dtmManufacturedDate: order.get('dtmManufacturedDate'),
                                        strLotAlias: order.get('strLotAlias'),
                                        intParentLotId: order.get('intParentLotId'),
                                        strParentLotNumber: order.get('strParentLotNumber'),
                                        intInventoryReceiptItemId: newReceiptItem.get('intInventoryReceiptItemId'),
                                        intSubLocationId: newReceiptItem.get('intSubLocationId'),
                                        intStorageLocationId: newReceiptItem.get('intStorageLocationId'),
                                        dblQuantity: newReceiptItem.get('dblOpenReceive'),
                                        dblGrossWeight: newReceiptItem.get('dblGross'),
                                        dblTareWeight: newReceiptItem.get('dblGross') - newReceiptItem.get('dblNet'),
                                        dblNetWeight: newReceiptItem.get('dblNet'),
                                        intItemUnitMeasureId: newReceiptItem.get('intUnitMeasureId'),
                                        strWeightUOM: newReceiptItem.get('strWeightUOM'),
                                        strStorageLocation: newReceiptItem.get('strStorageLocationName'),
                                        strSubLocationName: newReceiptItem.get('strSubLocationName'),
                                        strUnitMeasure: newReceiptItem.get('strUnitMeasure'),
                                        dblLotUOMConvFactor: newReceiptItem.get('dblItemUOMConvFactor'),
                                        strMarkings: order.get('strMarkings')
                                    });
                                    currentReceiptItemVM.tblICInventoryReceiptItemLots().add(newReceiptItemLot);
                                }
                                
                            }
                        });

                        if(basketErrors.length > 0) {
                            var msgBox = iRely.Functions;
                            var strMsg = "You should only add one basket item per order.";

                            // if(basketErrors.length <= 5) {
                            //     strMsg += "\n<table style='font-size: 14px; margin: 0 auto; border:solid 1px grey'>";
                            //     strMsg += "<tr><th>Order No</th><th>Basket</th><th>Item</th></tr><tr><td>"
                            //     _.each(basketErrors, function(e) {
                            //         strMsg += ""
                            //             .concat(e.orderNo)
                            //             .concat("</td><td>")
                            //             .concat(e.basketNo)
                            //             .concat("</td><td>")
                            //             .concat(e.itemNo)
                            //             .concat("</td></tr>");
                            //     });
                            //     strMsg = strMsg.concat("</table>");
                            // }
                            
                            msgBox.showCustomDialog(
                                msgBox.dialogType.WARNING,
                                msgBox.dialogButtonType.OK,
                                strMsg,
                                function(b) { }
                            );
                        }

                        if(freightTermsError.length > 0){
                            var strMsg = "You should only add one basket item per order.";

                            iRely.Functions.showCustomDialog(
                                iRely.Functions.dialogType.WARNING,
                                iRely.Functions.dialogButtonType.OK,
                                'Unable to add orders. Only orders of the same freight terms can be received.',
                                function(b) { }
                            );                            
                        }
                        //search.close();
                        //win.context.data.saveRecord();
                    } 
                }
            }
        });
    },

    addContractOtherCharges: function(current, adddedItemDetail, selectedOrder){
        var me = this,
            vm = me.getViewModel(),
            ContractStore = vm.get('purchaseContractList');

        ContractStore.load({
            filters: [
                {
                    column: 'intContractDetailId',
                    value: selectedOrder.get('intLineNo'),
                    conjunction: 'and'
                },
                {
                    column: 'intContractHeaderId',
                    value: selectedOrder.get('intOrderId'),
                    conjunction: 'and'
                }
            ],
            callback: function (result) {
                if (result) {
                    Ext.each(result, function (contract) {
                        var contractCosts = contract.get('tblCTContractCosts');
                        var contractCosts = _.filter(contractCosts, function (c) { return !c.ysnBasis; });
                        if (contractCosts) {
                            vm.set('chargesLinkInc', 1);
                            Ext.each(contractCosts, function (otherCharge) {
                                var receiptCharges = current.tblICInventoryReceiptCharges().data.items;
                                var exists = Ext.Array.findBy(receiptCharges, function (row) {
                                    if ((row.get('intContractId') === selectedOrder.get('intOrderId')
                                        && row.get('intChargeId') === otherCharge.intItemId)) {
                                        return true;
                                    }
                                });

                                if (!exists) {
                                    var inventoryCost = otherCharge.ysnInventoryCost ? true : false,
                                        chargesLink = 'CL-'.concat(vm.get('chargesLinkConst'));
                                    
                                    var functionalCurrencyId = i21.ModuleMgr.SystemManager.getCompanyPreference('intDefaultCurrencyId');
                                    var defaultForexRateTypeId = i21.ModuleMgr.SystemManager.getCompanyPreference('intInventoryRateTypeId');
                                    var otherChargeCurrency = otherCharge.intCurrencyId ? otherCharge.intCurrencyId : current.get('intCurrencyId'); 
                                    
                                    var intForexRateTypeId  = otherCharge.intForexRateTypeId;
                                    var dblFx = otherCharge.dblFX; 

                                    intForexRateTypeId = Ext.isNumeric(intForexRateTypeId) ? intForexRateTypeId : defaultForexRateTypeId; 

                                    // function variable to process the default forex rate. 
                                    var processForexRateOnSuccess = function (successResponse) {
                                        if (successResponse && successResponse.length > 0) {
                                            var dblForexRate = successResponse[0].dblRate;
                                            var strRateType = successResponse[0].strRateType;

                                            dblForexRate = Ext.isNumeric(dblForexRate) ? dblForexRate : 0;
                                            dblForexRate = dblFx ? dblFx : dblForexRate;

                                            var newReceiptCharge = Ext.create('Inventory.model.ReceiptCharge', {
                                                intInventoryReceiptId: current.get('intInventoryReceiptId'),
                                                intContractId: selectedOrder.get('intOrderId'),
                                                intContractDetailId: otherCharge.intContractDetailId,
                                                intContractSeq: contract.get('intContractSeq'),
                                                intChargeId: otherCharge.intItemId,
                                                strChargesLink: chargesLink,
                                                ysnInventoryCost: inventoryCost,
                                                strCostMethod: otherCharge.strCostMethod,
                                                dblRate: otherCharge.strCostMethod == "Amount" ? 0 : otherCharge.dblRate,
                                                intCostUOMId: otherCharge.intItemUOMId,
                                                intEntityVendorId: otherCharge.intVendorId ? otherCharge.intVendorId : current.get('intEntityVendorId'),
                                                dblAmount: otherCharge.strCostMethod == "Amount" ? otherCharge.dblRate : 0,
                                                strAllocateCostBy: 'Unit',
                                                ysnAccrue: otherCharge.intVendorId ? true : false,
                                                //ysnPrice: otherCharge.ysnPrice,
                                                strItemNo: otherCharge.strItemNo,
                                                intCurrencyId: otherCharge.intCurrencyId,
                                                strCurrency: otherCharge.strCurrency,
                                                ysnSubCurrency: otherCharge.ysnSubCurrency,
                                                strCostUOM: otherCharge.strUOM,
                                                strVendorName: otherCharge.strVendorName ? otherCharge.strVendorName : current.get('strVendorName'),
                                                strContractNumber: selectedOrder.get('strOrderNumber'),
                                                intForexRateTypeId: intForexRateTypeId,
                                                strForexRateType: strRateType,
                                                dblForexRate: dblForexRate 
                                            });
                                            current.tblICInventoryReceiptCharges().add(newReceiptCharge);
                                            adddedItemDetail.set('strChargesLink', chargesLink);                                            
                                        }
                                    }	                                    

                                    // If transaction currency is a foreign currency, get the default forex rate type, forex rate, and convert the last cost to the transaction currency. 
                                    if (otherChargeCurrency != functionalCurrencyId && intForexRateTypeId) {
                                        iRely.Functions.getForexRate(
                                            otherChargeCurrency,
                                            intForexRateTypeId,
                                            current.get('dtmReceiptDate'),
                                            function (successResponse) {
                                                processForexRateOnSuccess(successResponse);
                                            },
                                            function (failureResponse) {
                                                //var jsonData = Ext.decode(failureResponse.responseText);
                                                //iRely.Functions.showErrorDialog(jsonData.message.statusText);                    
                                                iRely.Functions.showErrorDialog('Something went wrong while getting the forex data for the other charges.');
                                            }
                                        );
                                    }
                                    else {
                                        var newReceiptCharge = Ext.create('Inventory.model.ReceiptCharge', {
                                            intInventoryReceiptId: current.get('intInventoryReceiptId'),
                                            intContractId: selectedOrder.get('intOrderId'),
                                            intContractDetailId: otherCharge.intContractDetailId,
                                            intContractSeq: contract.get('intContractSeq'),
                                            intChargeId: otherCharge.intItemId,
                                            strChargesLink: chargesLink,
                                            ysnInventoryCost: inventoryCost,
                                            strCostMethod: otherCharge.strCostMethod,
                                            dblRate: otherCharge.strCostMethod == "Amount" ? 0 : otherCharge.dblRate,
                                            intCostUOMId: otherCharge.intItemUOMId,
                                            intEntityVendorId: otherCharge.intVendorId ? otherCharge.intVendorId : current.get('intEntityVendorId'),
                                            dblAmount: otherCharge.strCostMethod == "Amount" ? otherCharge.dblRate : 0,
                                            strAllocateCostBy: 'Unit',
                                            ysnAccrue: otherCharge.intVendorId ? true : false,
                                            //ysnPrice: otherCharge.ysnPrice,
                                            strItemNo: otherCharge.strItemNo,
                                            intCurrencyId: otherCharge.intCurrencyId,
                                            strCurrency: otherCharge.strCurrency,
                                            ysnSubCurrency: otherCharge.ysnSubCurrency,
                                            strCostUOM: otherCharge.strUOM,
                                            strVendorName: otherCharge.strVendorName ? otherCharge.strVendorName : current.get('strVendorName'),
                                            strContractNumber: selectedOrder.get('strOrderNumber')
                                        });
                                        current.tblICInventoryReceiptCharges().add(newReceiptCharge);
                                        adddedItemDetail.set('strChargesLink', chargesLink);
                                    }
                                }
                            });

                        }
                    });
                }
            }
        });
    },

    getReplicator: function(receipt, receiptItem, lot) {   
        var analyzer = Ext.create('Inventory.domain.receipt.LotReplicationAnalyzer', {
            receipt: receipt,
            receiptItem: receiptItem,
            lot: lot,
            replicationLimit: 1000
        });
        
        var replicator = Ext.create('Inventory.domain.receipt.LotReplicator', { 
            analyzer: analyzer,
            notifyExcessiveReplication: true,
        });
        
        return replicator;
    },
    
    onReplicateBalanceLotClick: function(button) {
        var me = this;
        var win = button.up('window');
        var grdLotTracking = win.down('grdLotTracking');
        var currentReceipt = win.viewModel.data.current;
        var currentReceiptItem = win.viewModel.data.currentReceiptItem;
        var lineItemQty = currentReceiptItem.get('dblOpenReceive');
        var lineItemCF = currentReceiptItem.get('dblItemUOMConvFactor');

        // Validate the lot qty.
        if (lineItemQty <= 0) {
            iRely.Functions.showErrorDialog('Cannot replicate zero Receipt Qty.');
            return;
        }

        if (currentReceiptItem) {
            var grdLotTracking = win.down('#grdLotTracking');
            var selectedLot = grdLotTracking.getSelectionModel().getSelection();

            if (selectedLot.length <= 0) {
                iRely.Functions.showErrorDialog('Please select a lot to replicate.');
                return;
            }

            Ext.MessageBox.show({
                title: "Please wait.",
                msg: "Replicating lot.",
                progressText: "Replicating...",
                width: 300,
                progress: true,
                closable: false
            });

            setTimeout(function() {
                grdLotTracking.suspendEvents();

                try {
                    // Get the first lot record (if there are multiple selected)
                    var currentLot = selectedLot[0];
                    var lots = [];
                    var replicator = me.getReplicator(currentReceipt, currentReceiptItem, currentLot);
                        replicator.createReplicator()
                        .subscribe(function(val) {
                            var lot = val.replicatedLot;
                            lot.set('dblStatedNetPerUnit', me.calculateStatedNetPerUnit(currentReceipt, currentReceiptItem, lot));
                            lot.set('dblStatedTotalNet', me.calculateStatedTotalNet(currentReceipt, currentReceiptItem, lot));
                            lot.set('dblPhysicalVsStated', me.calculatePhysicalVsStated(currentReceipt, currentReceiptItem, lot));
                            lots.push(lot);
                        }, function(err) {
                            var a = replicator.getAnalyzer();
                            if(a.excessive()) {
                                var suggestion = ic.utils.Number.format(a.getSuggestedLotQtyToReplicate(), '0,0.[00]');
                                iRely.Functions.showErrorDialog("Stop! A quantity of " 
                                    + ic.utils.Math.roundWithPrecision(a.getLotQtyToReplicate(), 2) + " "
                                    + a.getLot().get('strUnitMeasure')
                                    + " is too small to replicate. This produces a huge number of lot replications. "
                                    + ic.utils.Number.format(a.getReplications(), '0,0')
                                    + " times to be exact. Try something like "
                                    + suggestion + " " + a.getLot().get('strUnitMeasure') + ".");
                            } else {
                                iRely.Functions.showErrorDialog(err);   
                            }
                            Ext.MessageBox.hide();  
                        }, function() {
                            grdLotTracking.store.add(lots);
                            Ext.MessageBox.hide();
                            grdLotTracking.resumeEvents();
                            if(lots.length > 0) {
                                iRely.Functions.showInfoDialog("Replicated " + ic.utils.Number.format(lots.length, '0,0') + " lot(s).");
                                //Calculate Line Total                        
                                me.calculateGrossNet(currentReceiptItem, 1);
                                currentReceiptItem.set('dblLineTotal', me.calculateLineTotal(currentReceipt, currentReceiptItem));
                            }
                        });
                } catch(e) {
                    iRely.Functions.showErrorDialog(e);   
                    Ext.MessageBox.hide(); 
                    grdLotTracking.resumeEvents();
                }
            }, 5);
        }
    },
    
    onVendorDrilldown: function (combo) {
        var win = combo.up('window');
        var current = win.viewModel.data.current;

        if (iRely.Functions.isEmpty(combo.getValue())) {
            iRely.Functions.openScreen('EntityManagement.view.Entity:searchEntityVendor', { action: 'new', viewConfig: { modal: true } });
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

    onLocationDrilldown: function (combo) {
        if (iRely.Functions.isEmpty(combo.getValue())) {
            iRely.Functions.openScreen('i21.view.CompanyLocation', { action: 'new', viewConfig: { modal: true } });
        }
        else {
            i21.ModuleMgr.Inventory.showScreen(combo.getRawValue(), 'LocationName');
        }
    },

    onTaxGroupDrilldown: function (combo) {
        if (iRely.Functions.isEmpty(combo.getValue())) {
            iRely.Functions.openScreen('i21.view.TaxGroup', { action: 'new', viewConfig: { modal: true } });
        }
        else {
            i21.ModuleMgr.Inventory.showScreen(combo.getRawValue(), 'TaxGroup');
        }
    },

    onCurrencyDrilldown: function (combo) {
        iRely.Functions.openScreen('i21.view.Currency', { viewConfig: { modal: true } });
    },

    getWeightLoss: function (ReceiptItems, sourceType) {
        if (!ReceiptItems || ReceiptItems.length <= 0) return; 

        var me = this; 
        var dblWeightLoss = 0.00;
        var dblOrderNetShippedWt = 0;
        var dblNetReceivedWt = 0;
        var dblFranchise = 0;
        var dblWeightLossPercentage = 0;

        var dblTotalWeightLoss = 0.00;
        var dblTotalOrderNetShippedWt = 0.00;
        var dblTotalReceivedWt = 0.00;  
        var dblTotalFranchise = 0.00;

        // Check if item is Inbound Shipment
        if (sourceType === 2) {
            Ext.Array.each(ReceiptItems, function (item) {
                if (!item.dummy) {
                    // Get the Net Wgt. 
                    var dblNetReceivedWt = item.get('dblNet');
                    dblNetReceivedWt = dblNetReceivedWt ? dblNetReceivedWt : 0.00;
                    
                    // Calculate the Logistic Shipped Wgt. 
                    var orderQty = item.get('dblOrderQty');
                    var wgtQty = item.get('dblContainerWeightPerQty');                    
                    
                    orderQty = orderQty ? orderQty : 0.00;
                    wgtQty = wgtQty ? wgtQty : 0.00;
                    dblOrderNetShippedWt = orderQty * wgtQty;

                    // Convert the Logistic Wgt UOM to the IR Wgt UOM.                     
                    var dblShippedWeightUOMConvFactor = item.get('dblContainerWeightUOMConvFactor');
                    var dblWeightUOMConvFactor = item.get('dblWeightUOMConvFactor');
                    dblShippedWeightUOMConvFactor = dblShippedWeightUOMConvFactor ? dblShippedWeightUOMConvFactor : 0.00;
                    dblWeightUOMConvFactor = dblWeightUOMConvFactor ? dblWeightUOMConvFactor : 0.00;

                    dblFranchise = item.get('dblFranchise');
                    dblFranchise = Ext.isNumeric(dblFranchise) ? dblFranchise * 100 : 0.00;                   
                    
                    if (dblShippedWeightUOMConvFactor != dblWeightUOMConvFactor){
                        dblOrderNetShippedWt = ic.utils.Uom.convertQtyBetweenUOM(
                            dblShippedWeightUOMConvFactor, 
                            dblWeightUOMConvFactor, 
                            dblOrderNetShippedWt
                        );
                    }                   
                    
                    dblTotalReceivedWt += dblNetReceivedWt; 
                    dblTotalOrderNetShippedWt += dblOrderNetShippedWt;                    
                    dblTotalWeightLoss += dblOrderNetShippedWt != 0.00 ? (dblNetReceivedWt - dblOrderNetShippedWt) : 0.00;
                    dblTotalFranchise += dblFranchise; 
                }
            });
        }

        dblTotalWeightLoss = ic.utils.Math.round(dblTotalWeightLoss, 2);
        dblTotalWeightLoss = dblTotalWeightLoss ? dblTotalWeightLoss : 0.00; 

        dblWeightLossPercentage = ic.utils.Math.round(
            dblTotalOrderNetShippedWt != 0 ? (dblTotalReceivedWt - dblTotalOrderNetShippedWt) / dblTotalOrderNetShippedWt * 100 : 0.00
            , 2
        );
        dblWeightLossPercentage = dblWeightLossPercentage ? dblWeightLossPercentage : 0.00; 

        dblTotalFranchise = ic.utils.Math.round(dblTotalFranchise, 2);
        dblTotalFranchise = dblTotalFranchise ? dblTotalFranchise : 0.00;        

        return {
            dblWeightLoss: dblTotalWeightLoss,
            dblWeightLossPercentage: dblWeightLossPercentage,
            dblFranchise: dblTotalFranchise
        };
    },

    calculateWtGainLoss: function (win) {
        if (!win) return;        

        var me = this;
        var grdInventoryReceipt = win.down('#grdInventoryReceipt'); 
        var ReceiptItems = grdInventoryReceipt.getSelectionModel().getSelection();       
        
        var current = win.viewModel.data.current;
        var sourceType = current.get('intSourceType');

        if (ReceiptItems) {
            var weightLoss = this.getWeightLoss(ReceiptItems, sourceType);
            win.viewModel.set('weightLoss', weightLoss);
            me.updateWeightLossText(win, false, weightLoss);
        }
    },

    updateWeightLossText: function(window, clear, weightLoss) {
        if (!window) return;

        weightLoss = weightLoss ? weightLoss : {
            dblWeightLoss: 0.00,
            dblWeightLossPercentage: 0.00,
            dblFranchise: 0.00
        }; 

        var txtWeightLossMsgValue =  window.down("#txtWeightLossMsgValue"); 
        var txtWeightLossMsgPercent = window.down("#txtWeightLossMsgPercent"); 

        if(clear) {
            txtWeightLossMsgValue.setValue(0.00);
            txtWeightLossMsgPercent.setValue(Ext.util.Format.number(0.00, "0,000.00%"));
            
            document.getElementsByName(txtWeightLossMsgValue.name)[0].style.color = 'gray';
            document.getElementsByName(txtWeightLossMsgPercent.name)[0].style.color = 'gray';
        } else {
            txtWeightLossMsgValue.setValue(weightLoss.dblWeightLoss);
            txtWeightLossMsgPercent.setValue(Ext.util.Format.number(weightLoss.dblWeightLossPercentage, "0,000.00%"));
            
            // If there is no Gain/Loss, set the color to gray. Otherwise, set it to Red.          
            // Gray is the color of Readonly fields.   
            if (weightLoss.dblWeightLoss === 0) {
                document.getElementsByName(txtWeightLossMsgValue.name)[0].style.color = 'gray';
            }
            else {
                document.getElementsByName(txtWeightLossMsgValue.name)[0].style.color = 'red';
            }

            var percentageColor = document.getElementsByName(txtWeightLossMsgPercent.name)[0].style.color;            
            var isLoss = weightLoss.dblWeightLossPercentage < 0;
            var franchise = Math.abs(weightLoss.dblFranchise ? weightLoss.dblFranchise : 0.00);
            var wgtLoss = Math.abs(weightLoss.dblWeightLossPercentage ? weightLoss.dblWeightLossPercentage : 0.00);
            if(wgtLoss >= franchise && isLoss) {
                document.getElementsByName(txtWeightLossMsgPercent.name)[0].style.color = 'red';
            } else {
                document.getElementsByName(txtWeightLossMsgPercent.name)[0].style.color = 'blue';
            }
        }
    },

    doOtherChargeTaxCalculate: function (win) {
        var current = win.viewModel.data.current;
        var me = win.controller;
        var context = win.context;

        if (current) {
            var charges = current.tblICInventoryReceiptCharges();
            var countCharges = charges.getRange().length;

            if (charges) {
                Ext.Array.each(charges.data.items, function (charge) {
                    var dblForexRate = charge.get('dblForexRate');
                    dblForexRate = Ext.isNumeric(dblForexRate) ? dblForexRate : 0;   

                    if (!charge.dummy) {
                        var computeItemTax = function (itemTaxes, me) {
                            var totalItemTax = 0.00,
                                taxGroupId = 0,
                                taxGroupName = null;

                            charge.tblICInventoryReceiptChargeTaxes().removeAll();
                            var unitMeasureId = charge.get('intCostUOMId');
                            Ext.Array.each(itemTaxes, function (itemDetailTax) {
                                var taxableAmount = charge.get('dblAmount');
                                var taxAmount = 0.00;
                                var chargeQuantity = charge.get('dblQuantity');
                                chargeQuantity = Ext.isNumeric(chargeQuantity) ? chargeQuantity : 1; 
                                var cost = taxableAmount / chargeQuantity;

                                var adjustedTax = itemDetailTax.dblAdjustedTax;
                                adjustedTax = Ext.isNumeric(adjustedTax) ? adjustedTax : 0;                                
                                // If a line is using a foreign currency, convert the adjusted tax from functional currency to the charge currency. 
                                adjustedTax = dblForexRate != 0 ? adjustedTax / dblForexRate : adjustedTax;

                                if (charge.get('ysnPrice')) {
                                    taxableAmount = -taxableAmount; 
                                }                                   

                                if (itemDetailTax.strCalculationMethod === 'Percentage') {
                                    taxAmount = (taxableAmount * (itemDetailTax.dblRate / 100));
                                } else {
                                    taxAmount = chargeQuantity * itemDetailTax.dblRate;

                                    // If a line is using a foreign currency, convert the tax from functional currency to the charge currency. 
                                    taxAmount = dblForexRate != 0 ? taxAmount / dblForexRate : taxAmount;
                                }
                                if (itemDetailTax.ysnCheckoffTax) {
                                    taxAmount = -(taxAmount);
                                }

                                taxAmount = i21.ModuleMgr.Inventory.roundDecimalValue(taxAmount, 2);

                                // Do not compute tax if it can't be converted to voucher. 
                                // This means accrue is false and price down is false. 
                                if (!charge.get('intEntityVendorId') && !charge.get('ysnPrice')){
                                    taxAmount = 0.00;
                                }

                                if (itemDetailTax.dblTax === itemDetailTax.dblAdjustedTax && !itemDetailTax.ysnTaxAdjusted) {
                                    if (itemDetailTax.ysnTaxExempt) {
                                        taxAmount = 0.00;
                                    }
                                    itemDetailTax.dblTax = taxAmount;
                                    itemDetailTax.dblAdjustedTax = taxAmount;
                                }
                                else {
                                    itemDetailTax.dblTax = taxAmount;
                                    itemDetailTax.dblAdjustedTax = adjustedTax;
                                    itemDetailTax.ysnTaxAdjusted = true;
                                }
                                totalItemTax = totalItemTax + itemDetailTax.dblAdjustedTax;
                                taxGroupId = itemDetailTax.intTaxGroupId;
                                taxGroupName = itemDetailTax.strTaxGroup;

                                var newItemTax = Ext.create('Inventory.model.ReceiptChargeTax', {
                                    intTaxGroupId: itemDetailTax.intTaxGroupId,
                                    intTaxCodeId: itemDetailTax.intTaxCodeId,
                                    intTaxClassId: itemDetailTax.intTaxClassId,
                                    strTaxCode: itemDetailTax.strTaxCode,
                                    strTaxableByOtherTaxes: itemDetailTax.strTaxableByOtherTaxes,
                                    strCalculationMethod: itemDetailTax.strCalculationMethod,
                                    intUnitMeasureId: unitMeasureId,
                                    dblRate: itemDetailTax.dblRate,
                                    dblTax: itemDetailTax.dblTax,
                                    dblAdjustedTax: itemDetailTax.dblAdjustedTax,
                                    intTaxAccountId: itemDetailTax.intTaxAccountId,
                                    ysnTaxAdjusted: itemDetailTax.ysnTaxAdjusted,
                                    ysnCheckoffTax: itemDetailTax.ysnCheckoffTax,
                                    ysnTaxOnly: itemDetailTax.ysnTaxOnly,
                                    dblQty: chargeQuantity,
                                    dblCost: cost

                                });
                                charge.tblICInventoryReceiptChargeTaxes().add(newItemTax);
                            });

                            //Set Value for Charge Tax Group
                            if (iRely.Functions.isEmpty(charge.get('intTaxGroupId'))) {
                                charge.set('intTaxGroupId', taxGroupId);
                                charge.set('strTaxGroup', taxGroupName);
                            }
                            
                            charge.set('dblTax', totalItemTax);
                        }

                         //get EntityIdId and BillShipToLocationId
                         var valEntityId, valTaxGroupId;
                         
                         valEntityId = charge.get('intEntityVendorId');
                         valEntityId = valEntityId ? valEntityId : current.get('intEntityVendorId');

                         valTaxGroupId = charge.get('intTaxGroupId');
                         
                         var currentCharge = {
                                ItemId: charge.get('intChargeId'),
                                TransactionDate: current.get('dtmReceiptDate'),
                                LocationId: current.get('intLocationId'),
                                TransactionType: 'Purchase',
                                TaxGroupId: valTaxGroupId,
                                EntityId: valEntityId,
                                BillShipToLocationId: current.get('intShipFromId'),
                                FreightTermId: current.get('intFreightTermId'),
                                CardId: null,
                                VehicleId: null,
                                IncludeExemptedCodes: false,
                                UOMId: charge.get('intCostUOMId')
                         };
                         iRely.Functions.getItemTaxes(currentCharge, computeItemTax, me);
                    }
                });
            }
        }
    },

    doOtherChargeCalculate: function (win, successCallback, failureCallback) {
        var context = win.context;
        var current = win.viewModel.data.current;
        var me = win.controller;

        if (!(context && current)) return;

        ic.utils.ajax({
            url: './inventory/api/inventoryreceipt/calculatecharges',
            params: {
                id: current.get('intInventoryReceiptId')
            },
            method: 'get'
        })
            .subscribe(
            function (successResponse) {
                var jsonData = Ext.decode(successResponse.responseText);
                if (!jsonData.success) {
                    iRely.Functions.showErrorDialog(jsonData.message.statusText);
                }
                else {
                    // Reload the other charges after computing it from the server. 
                    var tblICInventoryReceiptCharges = current._tblICInventoryReceiptCharges;                     
                    if (tblICInventoryReceiptCharges){
                        current._tblICInventoryReceiptCharges.load({
                            callback: function (records, options, success) {
                                if (successCallback) {
                                    successCallback();
                                }
                                else {
                                    me.doOtherChargeTaxCalculate(win);
                                }
                            }                            
                        }); 
                    }
                };
            }
            , function (failureResponse) {
                var jsonData = Ext.decode(failureResponse.responseText);
                iRely.Functions.showErrorDialog(jsonData.message.statusText);

                if (failureCallback) failureCallback();
            }
            );
    },

    onCalculateChargeClick: function (button, e, eOpts) {
        var me = this;
        var win = button.up('window');
        var context = win.context;
        var current = win.viewModel.data.current;

        // If there is no data change, do the ajax request.
        if (!context.data.hasChanges()) {
            me.doOtherChargeCalculate(win);
            return;
        }

        // Save has data changes first before doing the post.
        context.data.saveRecord({
            successFn: function () {
                me.doOtherChargeCalculate(win);
            }
        });
    },

    onPostedTransactionBeforeCheckChange: function (obj, rowIndex, checked, eOpts) {
        var grid = obj.up('grid');
        var win = obj.up('window');
        var current = win.viewModel.data.current;
        if (current && current.get('ysnPosted') === true) {
            return false;
        }
    },

    onLocationBeforeSelect: function (combo, record, index, eOpts) {
        var win = combo.up('window');
        var current = win.viewModel.data.current;
        var origLocation = current.get('strLocationName');
        var origLocationId = current.get('intLocationId');
        var newLocationId = record.get('intCompanyLocationId');
        var me = this;
        var grdInventoryReceiptCount = 0;

        if (current) {
            if (current.tblICInventoryReceiptItems()) {
                Ext.Array.each(current.tblICInventoryReceiptItems().data.items, function (row) {
                    if (!row.dummy) {
                        grdInventoryReceiptCount++;
                    }
                });
            }

            if (origLocationId !== newLocationId) {
                var buttonAction = function (button) {
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
                            var receiptItemLots = currentReceiptItem['tblICInventoryReceiptItemLots']();
                            if (receiptItemLots) {
                                var receiptItemLotRecords = receiptItemLots ? receiptItemLots.getRange() : [];
                                var li = receiptItemLotRecords.length - 1;

                                for (; li >= 0; li--) {
                                    if (!receiptItemLotRecords[li].dummy)
                                        receiptItemLotRecords[li].set('intStorageLocationId', null);
                                    receiptItemLotRecords[li].set('strStorageLocation', null);
                                }
                            }

                        }

                        var valFOBPoint = current.get('strFobPoint');
                        valFOBPoint = valFOBPoint ? valFOBPoint.trim().toLowerCase() : valFOBPoint;

                        //Calculate Item Taxes
                        if (current.tblICInventoryReceiptItems()) {
                            Ext.Array.each(current.tblICInventoryReceiptItems().data.items, function (item) {
                                if (!item.dummy) {
                                    //Assign Tax Group Id from Location FOB Point is Destination
                                    if (valFOBPoint === 'destination') {
                                        item.set('intTaxGroupId', current.get('intTaxGroupId'));
                                        item.set('strTaxGroup', current.get('strTaxGroup'));
                                    }

                                    win.viewModel.data.currentReceiptItem = item;
                                    me.calculateItemTaxes();
                                }
                            });
                        }
                    }
                    else {
                        current.set('strLocationName', origLocation);
                        current.set('intLocationId', origLocationId);
                    }
                };

                if (grdInventoryReceiptCount > 0) {
                    iRely.Functions.showCustomDialog('question', 'yesno', 'Changing Location will clear ALL Storage Locations and Storage Units. Do you want to continue?', buttonAction);
                }
            }
        }
    },

    doPostPreview: function (win, cfg) {
        var me = this;

        if (!win) { return; }
        cfg = cfg ? cfg : {};

        var isAfterPostCall = cfg.isAfterPostCall;
        var ysnPosted = cfg.ysnPosted;

        var context = win.context;
        var current = win.viewModel.data.current;
        var pnlLotTracking = win.down('#pnlLotTracking');
        var grdInventoryReceipt = win.down('#grdInventoryReceipt');

        //Hide Lot Tracking Grid
        if (pnlLotTracking) { pnlLotTracking.setVisible(false); }

        //Deselect all rows in Item Grid
        if (grdInventoryReceipt) { grdInventoryReceipt.getSelectionModel().deselectAll(); }

        var doRecap = function (currentRecord) {
            ic.utils.ajax({
                url: (currentRecord.get('strReceiptType') === 'Inventory Return') ? './inventory/api/inventoryreceipt/return' : './inventory/api/inventoryreceipt/receive',
                params: {
                    strTransactionId: currentRecord.get('strReceiptNumber'),
                    isPost: isAfterPostCall ? ysnPosted : currentRecord.get('ysnPosted') ? false : true,
                    isRecap: true
                },
                method: 'post'
            })
                .subscribe(
                function (successResponse) {
                    var postResult = Ext.decode(successResponse.responseText);
                    var batchId = postResult.data.strBatchId;
                    if (batchId) {
                        me.bindRecapGrid(batchId);
                    }
                }
                , function (failureResponse) {
                    // Show Post Preview failed.
                    var jsonData = Ext.decode(failureResponse.responseText);
                    iRely.Functions.showErrorDialog(jsonData.message.statusText);
                }
                )
        };

        // If there is no data change, calculate the charge and do the recap. 
        if (!context.data.hasChanges()) {
            // If already posted or preview was called right after a post or unpost, do not calculate the charges and only do the recap. 
            if ((current && current.get('ysnPosted')) || (isAfterPostCall)){
                doRecap(current); 
            }
            // If not yet posted, calculate the charges first before doing the recap. 
            else {
                me.doOtherChargeCalculate(
                    win, 
                    doRecap(current)
                );
            }
            return;
        }

        // Save has data changes first before anything else. 
        context.data.saveRecord({
            successFn: function () {
                me.doOtherChargeCalculate(
                    win,
                    doRecap(current)
                );
            }
        });
    },

    onReceiptTabChange: function (tabPanel, newCard, oldCard, eOpts) {
        var me = this;
        var win = tabPanel.up('window');
        var context = win.context;
        var current = win.viewModel.data.current;

        switch (newCard.itemId) {
            case 'pgeIncomingInspection':
                var updateReceiptInspection = function () {
                    if (current) {
                        ic.utils.ajax({
                            url: './inventory/api/inventoryreceipt/updatereceiptinspection',
                            params: {
                                id: current.get('intInventoryReceiptId')
                            },
                            method: 'get'
                        })
                            .subscribe(
                            function (successResponse) {
                                //context.configuration.paging.store.load();
                                context.configuration.paging.store.load();
                            }
                            , function (failureResponse) {
                                var jsonData = Ext.decode(failureResponse.responseText);
                                iRely.Functions.showErrorDialog(jsonData.message.statusText);
                            }
                            );
                    };
                };

                // If there is no data change, do the post.
                if (!context.data.hasChanges()) {
                    updateReceiptInspection();
                    return;
                }

                // Save has data changes first before doing the post.
                context.data.saveRecord({
                    successFn: function () {
                        updateReceiptInspection();
                    }
                });
                break;
            case 'pgePostPreview':
                me.doPostPreview(win);
        }
    },

    onSelectClearGridInspectionClick: function (button, e, eOpts) {
        var win = button.up('window');
        var current = win.viewModel.data.current;

        if (button.itemId === 'btnSelectAll') {
            if (current.tblICInventoryReceiptInspections()) {
                Ext.Array.each(current.tblICInventoryReceiptInspections().data.items, function (row) {
                    if (!row.dummy) {
                        row.set('ysnSelected', true);
                    }
                });
            }
        }

        if (button.itemId === 'btnClearAll') {
            if (current.tblICInventoryReceiptInspections()) {
                Ext.Array.each(current.tblICInventoryReceiptInspections().data.items, function (row) {
                    if (!row.dummy) {
                        row.set('ysnSelected', false);
                    }
                });
            }
        }
    },

    /* onSelectTaxGroup: function (combo, records, eOpts) {
         if (records.length <= 0)
             return;
 
         var win = combo.up('window'),
             current = win.viewModel.data.current,
             me = this;
 
         //Calculate Taxes
         if (current.tblICInventoryReceiptItems()) {
             Ext.Array.each(current.tblICInventoryReceiptItems().data.items, function (item) {
                 if (!item.dummy) {
                     win.viewModel.data.currentReceiptItem = item;
                     me.calculateItemTaxes();
                 }
             });
         }
     },*/

    onChargeTaxDetailsClick: function (button, e, eOpts) {
        var win = button.up('window');
        var grd = win.down('#grdCharges');
        var me = this;
        var selected = grd.getSelectionModel().getSelection();
        var context = win.context;

        // Validate the selected charge record. 
        if (!selected || selected.length <= 0) {
            iRely.Functions.showErrorDialog('Please select an Other Charge to view.');
            return; 
        }

        // Get the current record. 
        var current = selected[0];        
        if (!current || current.dummy) {
            iRely.Functions.showErrorDialog('Please select an Other Charge to view.');
            return;             
        }
                
        var ReceiptChargeId = current.get('intInventoryReceiptChargeId');
        var ReceiptId = current.get('intInventoryReceiptId');

        var showChargeTaxScreen = function () {
            iRely.Functions.openScreen('GlobalComponentEngine.view.FloatingSearch', {
                searchSettings: {
                    scope: me,
                    type: 'Inventory.Receipt.ChargesTaxDetails',
                    url: './inventory/api/inventoryreceipt/getchargetaxdetails?ReceiptChargeId=' + ReceiptChargeId + '&ReceiptId=' + ReceiptId,
                    columns: [
                        { itemId: 'colKey', dataIndex: 'intKey', text: "Key", flex: 1, dataType: 'numeric', key: true, hidden: true },
                        { itemId: 'colInventoryReceiptChargeTaxId', dataIndex: 'intInventoryReceiptChargeTaxId', text: "Receipt Charge Tax Id", flex: 1, dataType: 'numeric', key: true, hidden: true },
                        { itemId: 'colChargeId', dataIndex: 'intChargeId', text: "Charge Id", flex: 1, dataType: 'numeric', key: true, hidden: true },
                        { itemId: 'colItemNo', dataIndex: 'strItemNo', text: 'Other Charges', width: 100, dataType: 'string'},
                        { itemId: 'colTaxGroup', dataIndex: 'strTaxGroup', text: 'Tax Group', width: 85, dataType: 'string' },
                        { itemId: 'colTaxClass', dataIndex: 'strTaxClass', text: 'Tax Class', width: 100, dataType: 'string' },
                        { itemId: 'colTaxCode', dataIndex: 'strTaxCode', text: 'Tax Code', width: 100, dataType: 'string' },
                        { itemId: 'colUnitMeasureId', dataIndex: 'intUnitMeasureId', text: 'Unit Measure Id', dataType: 'numeric', hidden: true },
                        { itemId: 'colUnitMeasure', dataIndex: 'strUnitMeasure', text: 'Unit Measure', dataType: 'string' },
                        { itemId: 'colCalculationMethod', dataIndex: 'strCalculationMethod', text: 'Calculation Method', width: 110, dataType: 'string' },                                
                        { itemId: 'colQty', xtype: 'numbercolumn', dataIndex: 'dblQty', text: 'Qty', width: 100, dataType: 'float' },
                        { itemId: 'colCost', xtype: 'numbercolumn', dataIndex: 'dblCost', text: 'Cost', width: 100, dataType: 'float' },
                        { itemId: 'colRate', xtype: 'numbercolumn', dataIndex: 'dblRate', text: 'Rate', width: 100, dataType: 'float' },
                        { 
                            itemId: 'colCheckoff', 
                            xtype: 'checkcolumn', 
                            dataIndex: 'ysnCheckoffTax', 
                            text: 'Checkoff', 
                            width: 100, 
                            dataType: 'boolean',
                            listeners: {
                                beforecheckchange: function(me, rowIndex, checked, record, e, eOpts){
                                    // Return false so that checkbox value can't be changed. 
                                    return false; 
                                }
                            }                                    
                        },
                        { itemId: 'colTax', xtype: 'numbercolumn', dataIndex: 'dblTax', text: 'Tax', width: 100, dataType: 'float' },
                        { 
                            itemId: 'colTaxAdjusted', 
                            xtype: 'checkcolumn', 
                            dataIndex: 'ysnTaxAdjusted', 
                            text: 'Adjusted', 
                            width: 100, 
                            dataType: 'boolean',
                            listeners: {
                                beforecheckchange: function(me, rowIndex, checked, record, e, eOpts){
                                    // Return false so that checkbox value can't be changed. 
                                    return false; 
                                }
                            }                                    
                        }                                
                    ],
                    title: "Charges Tax Details",
                    showNew: false,
                    showOpenSelected: false
                }
            });
        }

        var task = new Ext.util.DelayedTask(function () {
            // If there is no data change, show charge tax details screen
            if (!context.data.hasChanges()) {
                showChargeTaxScreen();
            }

            // Save has data changes first before showing charge tax details screen
            context.data.saveRecord({
                successFn: function () {
                    showChargeTaxScreen();
                }
            });
        });
        task.delay(10);            
    },

    onReceiptTypeSelect: function (combo, records, eOpts) {
        var win = combo.up('window'),
            current = win.viewModel.data.current;

        if (current) {
            //Change Source Type to "None" for "Direct" or "Purchase Order" or "Transfer Order" Receipt Type
            if (current.get('strReceiptType') == 'Direct' || current.get('strReceiptType') == 'Purchase Order' || current.get('strReceiptType') === 'Transfer Order') {
                current.set('intSourceType', 0);
                current.set('strSourceType', 'None');
            }
        }
    },

    onCostUOMChange: function (combo, newValue, oldValue, eOpts) {
        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepItem');
        var current = plugin.getActiveRecord();

        if (current && (newValue === null || newValue === '')) {
            current.set('dblCostUOMConvFactor', current.get('dblReceiveUOMConvFactor'));
        }
    },

    onReturnClick: function (button, e, eOpts) {
        var btnReturn = button;
        if (btnReturn){
            btnReturn.disable();
        }
        else {
            return;
        }

        var win = button.up('window'),
            current = win.viewModel.data.current,
            me = this;

        if (!current) {
            btnReturn.enable();
            return;
        }

        var processReceiptToReturn = function () {
            ic.utils.ajax({
                url: './Inventory/api/InventoryReceipt/ReturnReceipt',
                params: {
                    id: current.get('intInventoryReceiptId')
                },
                method: 'get'
            })
            .subscribe(
                function (successResponse) {
                    var responseText = Ext.decode(successResponse.responseText);
                    var message = responseText ? responseText.message : {}; 
                    var InventoryReturnId = message.InventoryReturnId;

                    if (InventoryReturnId){
                        var buttonActionViewReturn = function (button) {
                            if (button === 'yes') {
                                iRely.Functions.openScreen('Inventory.view.InventoryReceipt', {
                                    filters: [
                                        {
                                            column: 'intInventoryReceiptId',
                                            value: InventoryReturnId
                                        }
                                    ],
                                    action: 'view'
                                });
                                win.close();
                            }
                        };
                        iRely.Functions.showCustomDialog('question', 'yesno', 'Inventory Return successfully created. Do you want to view it?', buttonActionViewReturn);
                    }
                    btnReturn.enable();
                }
                , function (failureResponse) {
                    var responseText = Ext.decode(failureResponse.responseText);
                    var message = responseText ? responseText.message : {}; 
                    var statusText = message ? message.statusText : 'Oh no! Something went wrong while creating the inventory return.';
                    iRely.Functions.showCustomDialog(iRely.Functions.dialogType.ERROR, iRely.Functions.dialogButtonType.OK, statusText);
                    btnReturn.enable();
                }
            );
        };

        var buttonActionDoReturn = function (button) {
            if (button == 'yes') {
                processReceiptToReturn();
            }
            else {
                btnReturn.enable();
            }
        }

        // Call an ajax to validate the receipt if receipt is valid for return. 
        ic.utils.ajax({
            url: './Inventory/api/InventoryReceipt/CheckReceiptForValidReturn',
            params: {
                receiptId: current.get('intInventoryReceiptId')
            },
            method: 'get'
        })
        .subscribe(
            function (successResponse) {
                // var jsonData = Ext.decode(successResponse.responseText);
                iRely.Functions.showCustomDialog('question', 'yesno', 'Do you want to return this inventory receipt?', buttonActionDoReturn);                
            }
            , function (failureResponse) {
                var responseText = Ext.decode(failureResponse.responseText);
                var message = responseText ? responseText.message : {}; 
                var statusText = message ? message.statusText : 'Oh no! Something went wrong while trying to check if receipt can be returned.';
                iRely.Functions.showCustomDialog(iRely.Functions.dialogType.ERROR, iRely.Functions.dialogButtonType.OK, statusText);
                btnReturn.enable();
            }
        );
    },

    onSpecialKeyTab: function (component, e, eOpts) {
        var win = component.up('window');
        if (win) {
            if (e.getKey() === Ext.event.Event.TAB) {
                var gridObj = win.down('#grdInventoryReceipt'),
                    sel = gridObj.getStore().getAt(0);

                if (sel && gridObj) {
                    gridObj.setSelection(sel);
                    var cepItem = gridObj.getPlugin('cepItem');
                    if (cepItem) {
                        var task = new Ext.util.DelayedTask(function () {
                            cepItem.startEditByPosition({ row: 0, column: 1 });
                        });
                        task.delay(10);
                    }
                }
            }
        }
    },

    onReceiveClick: function (btnPost, e, eOpts) {
        if (btnPost){
            btnPost.disable();
        }
        else {
            return;
        }

        var me = this;
        var win = btnPost.up('window');
        var currentRecord = win.viewModel.data.current;
        
        if (!currentRecord){
            btnPost.enable();
            return; 
        }
        
        var context = win.context;
        var pnlLotTracking = win.down('#pnlLotTracking');
        var grdInventoryReceipt = win.down('#grdInventoryReceipt');
        var tabInventoryReceipt = win.down('#tabInventoryReceipt');
        var activeTab = tabInventoryReceipt.getActiveTab();

        //Hide Lot Grid
        pnlLotTracking.setVisible(false);

        //Deselect all rows in Item Grid
        grdInventoryReceipt.getSelectionModel().deselectAll();

        var doPost = function () {
            var current = currentRecord;
            ic.utils.ajax({
                url: (current.get('strReceiptType') === 'Inventory Return') ? './Inventory/api/InventoryReceipt/Return' : './Inventory/api/InventoryReceipt/Receive',
                params: {
                    strTransactionId: current.get('strReceiptNumber'),
                    isPost: current.get('ysnPosted') ? false : true,
                    isRecap: false
                },
                method: 'post'
            })
            .subscribe(
                function (successResponse) {
                    me.onAfterReceive(true);
                    // Check what is the active tab. If it is the Post Preview tab, load the recap data. 
                    if (activeTab.itemId == 'pgePostPreview') {
                        var cfg = {
                            isAfterPostCall: true,
                            ysnPosted: current.get('ysnPosted') ? true : false
                        };
                        me.doPostPreview(win, cfg);
                    }
                    btnPost.enable();
                    iRely.Functions.refreshFloatingSearch('Inventory.view.InventoryReceipt');
                }
                , function (failureResponse) {
                    var responseText = Ext.decode(failureResponse.responseText);
                    var message = responseText ? responseText.message : {}; 
                    var statusText = message ? message.statusText : 'Oh no! Something went wrong while posting the inventory receipt.';

                    me.onAfterReceive(false, statusText);
                    btnPost.enable();
                }
            )
        };

        var buttonAction = function (button) {
            if (button === 'yes') {
                //  Save the data changes first. After saving calculate the other charges and do the post. 
                if (context.data.hasChanges()) {                    
                    context.data.validator.validateRecord(context.data.configuration, function(valid) {
                        // If records are valid, continue with the save. 
                        if (valid){
                            context.data.saveRecord({
                                successFn: function () {
                                    me.doOtherChargeCalculate(
                                        win
                                        , doPost
                                    );
                                }
                            });                    
                        }
                        // If records are invalid, re-enable the post button. 
                        else {
                            btnPost.enable();
                        }
                    });
                }
                // If there is no data change, then calculate the other charges and do the post. 
                else {
                    // Calculate the other charge if record is not yet posted. 
                    if (currentRecord && currentRecord.get('ysnPosted') == false){
                        me.doOtherChargeCalculate(
                            win
                            ,doPost                       
                        );
                    }
                    // Otherwise, simply do the post. 
                    else {
                        doPost();
                    }
                }
            }
        }

        var ReceivedGrossDiscrepancyItems = '';

        if (currentRecord.tblICInventoryReceiptItems()) {
            Ext.Array.each(currentRecord.tblICInventoryReceiptItems().data.items, function (row) {
                if (!row.dummy) {
                    //If there is Gross, check if the value is equivalent to Received Quantity
                    if (row.get('intWeightUOMId') !== null) {

                        var dblGross = row.get('dblGross');
                        var dblNet = row.get('dblNet');

                        dblGross = Ext.isNumeric(dblGross) ? dblGross : 0.00;
                        dblNet = Ext.isNumeric(dblNet) ? dblNet : 0.00;

                        if (dblGross < dblNet) {
                            ReceivedGrossDiscrepancyItems = ReceivedGrossDiscrepancyItems + row.get('strItemNo') + '<br/>'
                        }
                    }

                }
            });
        }

        if (ReceivedGrossDiscrepancyItems !== '' && button.text === 'Post') {
            iRely.Functions.showCustomDialog(
                'question',
                'yesno',
                'The Gross is less than Net on the following item/s: <br/> <br/>' + ReceivedGrossDiscrepancyItems + '<br/>. Do you want to continue?',
                buttonAction
            );
        }
        else {
            buttonAction('yes');
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

    onGumUOMSelect: function (plugin, records, combo) {
        if (records.length <= 0)
            return;

        var me = this;
        var win = me.getView().screenMgr.window;
        var grid = win.down('#grdInventoryReceipt');
        var current = plugin.getActiveRecord();
        
        current.set('intUnitMeasureId', records[0].get('intItemUnitMeasureId'));
        current.set('intItemUOMId', records[0].get('intUnitMeasureId'));
        current.set('dblItemUOMConvFactor', records[0].get('dblUnitQty'));
        current.set('strUnitType', records[0].get('strUnitType'));
        current.set('ysnQtyUOMChanged', true);

        if (current.get('dblWeightUOMConvFactor') === 0) {
            current.set('dblWeightUOMConvFactor', records[0].get('dblUnitQty'));
        }

        var origCF = current.get('dblOrderUOMConvFactor');
        var newCF = current.get('dblItemUOMConvFactor');
        var received = current.get('dblReceived');
        var ordered = current.get('dblOrderQty');
        var qtyToReceive = plugin.getActiveEditor().getValue();
        if (origCF > 0 && newCF > 0) {
            qtyToReceive = ic.utils.Uom.convertQtyBetweenUOM(origCF, newCF, qtyToReceive); //Ordered - Received;
            current.set('dblOpenReceive', qtyToReceive);
            plugin.getActiveEditor().field.setValue(qtyToReceive);
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
            (current.get('strWeightUOM') === null || current.get('strWeightUOM') === '')) {
            current.set('strWeightUOM', records[0].get('strUnitMeasure'));
            current.set('intWeightUOMId', records[0].get('intItemUnitMeasureId'));
            current.set('dblWeightUOMConvFactor', current.get('dblItemUOMConvFactor'));
        }

        // If there are lot records, update it. 
        if (current && current.tblICInventoryReceiptItemLots()) {
            // Loop 1: Check how may lot records already exists. 
            var receiptLotCount = 0;
            Ext.Array.each(current.tblICInventoryReceiptItemLots().data.items, function (lot) {
                if (!lot.dummy) {
                    receiptLotCount++;
                    // Exit immediately if there is more than one lot record. 
                    if (receiptLotCount > 1) {
                        return false; 
                    } 
                }
            });

            // Loop 2: Update the lot records. 
            Ext.Array.each(current.tblICInventoryReceiptItemLots().data.items, function (lot) {
                if (!lot.dummy) {
                    //If there is only one lot record, set the Lot UOM, Lot Qty, Lot Weight UOM, Gross, and Net, 
                    if (receiptLotCount == 1){
                        lot.set('dblQuantity', current.get('dblOpenReceive'));
                        lot.set('intItemUnitMeasureId', current.get('intUnitMeasureId'));                        
                        lot.set('strWeightUOM',  current.get('strWeightUOM'));
                        lot.set('strUnitMeasure', records[0].get('strUnitMeasure'));
                        lot.set('dblLotUOMConvFactor', records[0].get('dblUnitQty'));
                    }

                    //Set Default Value for Lot Wgt UOM 
                    if (lot.get('strWeightUOM') === null || lot.get('strWeightUOM') === '') {
                        lot.set('strWeightUOM', records[0].get('strUnitMeasure'));
                        lot.set('dblLotUOMConvFactor', records[0].get('dblUnitQty'));
                    }
                }
            });
        }          

        me.calculateGrossNet(current, 1);
    },

    calculateLinkedItems: function(current, activeRecord){
        var parentLinkId = activeRecord.get('intParentItemLinkId'),
            itemDetailStore = current.tblICInventoryReceiptItems(),
            linkType = activeRecord.get('strItemType'),
            searchURL;

        if(!Ext.isNumber(parentLinkId) || linkType.charAt(0) == 'O' || linkType.charAt(0) == 'S')
            return;
        
        var locationId = current.get('intLocationId'),
            itemId = activeRecord.get('intItemId'),
            itemUOMId = activeRecord.get('intUnitMeasureId'),
            quantity = activeRecord.get('dblOpenReceive');

        switch(linkType.charAt(0)){
            case 'K':
                searchURL = './inventory/api/itembundle/getbundlecomponents?intItemId=' + itemId + '&intItemUOMId=' + itemUOMId 
                    + '&intLocationId=' + locationId + '&dblQuantity=' +  quantity;
                break;
            case 'A':
                searchURL = './inventory/api/itemaddon/getitemaddons?intItemId=' + itemId + '&intItemUOMId=' + itemUOMId 
                    + '&intLocationId=' + locationId + '&dblQuantity=' +  quantity;
                break;
            // case 'S':
            //     searchURL = './inventory/api/itemsubstitute/getitemsubstitutes?intItemId=' + itemId + '&intItemUOMId=' + itemUOMId 
            //         + '&intLocationId=' + locationId + '&dblQuantity=' +  quantity;
            //     break;
        }

        ic.utils.ajax({
            url: searchURL,
            method: 'get'
        }).subscribe(
            function(successResponse){
                var result = Ext.decode(successResponse.responseText);
                Ext.Array.forEach(result.data, function(rec) {
                    var childRecord = _.find(itemDetailStore.data.items, function(x){
                        return x.get('intItemId') == rec.intComponentItemId &&  x.get('intUnitMeasureId') == rec.intComponentUOMId && x.get('intChildItemLinkId') == parentLinkId && !x.dummy;
                    });

                    if(childRecord){
                        var dblQty = 0;
                        switch(linkType.charAt(0)){
                            case 'K': dblQty = rec.dblBundleComponentQty; break;
                            case 'A': dblQty = rec.dblAddOnComponentQty; break;
                            case 'S': dblQty = rec.dblSubstituteComponentQty; break;
                            default: dblQty = 0; break;

                        }
                        childRecord.set('dblOpenReceive', dblQty);
                        childRecord.set('dblLineTotal', dblQty * childRecord.get('dblUnitCost'));
                    }

                });
            },
            function (failureResponse) {
                var jsonData = Ext.decode(failureResponse.responseText);
                iRely.Functions.showErrorDialog('Something went wrong while getting the Components of the Kit item.');
            }
        );

    },

    getBundleComponents: function(addedRecord, selectedItem, current, itemDetailStore){
        'use strict';
        var me = this,
            win = me.getView(),
            bundleType = selectedItem.get('strBundleType'),
            screenTitle = bundleType + ' - ' + selectedItem.get('strItemNo'),
            locationId = current.get('intLocationId'),
            bundleItemId = selectedItem.get('intItemId'),
            itemUOMId = selectedItem.get('intItemUOMId'),
            orderQty = selectedItem.get('dblQtyToReceive');


        var searchURL = './inventory/api/itembundle/getbundlecomponents?intItemId=' + bundleItemId + '&intItemUOMId=' + itemUOMId 
            + '&intLocationId=' + locationId + '&dblQuantity=' + orderQty;

        var addItemLotFunc = function(newItem, selectedRecord){
            if (!iRely.Functions.isEmpty(newItem.get('strLotTracking')) && newItem.get('strLotTracking') !== 'No') {
                var newItemLot = Ext.create('Inventory.model.ReceiptItemLot', {
                    intLotId: selectedRecord.get('intLotId'),
                    strLotNumber: selectedRecord.get('strLotNumber'),
                    dtmExpiryDate: selectedRecord.get('dtmExpiryDate'),
                    dtmManufacturedDate: selectedRecord.get('dtmManufacturedDate'),
                    strLotAlias: selectedRecord.get('strLotAlias'),
                    intParentLotId: selectedRecord.get('intParentLotId'),
                    strParentLotNumber: selectedRecord.get('strParentLotNumber'),
                    intInventoryReceiptItemId: newItem.get('intInventoryReceiptItemId'),
                    intSubLocationId: newItem.get('intSubLocationId'),
                    intStorageLocationId: newItem.get('intStorageLocationId'),
                    dblQuantity: newItem.get('dblOpenReceive'),
                    dblGrossWeight: newItem.get('dblGross'),
                    dblTareWeight: newItem.get('dblGross') - newItem.get('dblNet'),
                    dblNetWeight: newItem.get('dblNet'),
                    intItemUnitMeasureId: newItem.get('intUnitMeasureId'),
                    strWeightUOM: newItem.get('strWeightUOM'),
                    strStorageLocation: newItem.get('strStorageLocationName'),
                    strSubLocationName: newItem.get('strSubLocationName'),
                    strUnitMeasure: newItem.get('strUnitMeasure'),
                    dblLotUOMConvFactor: newItem.get('dblItemUOMConvFactor'),
                    strMarkings: selectedRecord.get('strMarkings')
                });
                newItem.tblICInventoryReceiptItemLots().add(newItemLot);
            }
        };

        if(bundleType == 'Kit'){
            ic.utils.ajax({
                url: searchURL,
                method: 'get'
            }).subscribe(
                function(successResponse){
                    var result = Ext.decode(successResponse.responseText);
                    addedRecord.set('dblUnitCost', 0);
                    addedRecord.set('dblUnitRetail', 0);
                    addedRecord.set('strItemType', 'Kit');
                    addedRecord.set('intParentItemLinkId', addedRecord.get('intInventoryReceiptItemId'));

                    Ext.Array.forEach(result.data, function(rec){
                        var componentQty = rec.dblBundleComponentQty;

                        var itemModel = Ext.create(itemDetailStore.role.type, {
                                intInventoryReceiptId: current.get('intInventoryReceiptId'),
                                intChildItemLinkId: addedRecord.get('intInventoryReceiptItemId'),
                                strItemType: selectedItem.get('strItemNo') + ' - Component',
                                //dtmDate: order.get('dtmDate'),
                                dblOrderQty: componentQty,
                                //dblReceived: selectedItem.get('dblReceived'),
                                intSourceId: selectedItem.get('intSourceId'),
                                strSourceNumber: selectedItem.get('strSourceNumber'),
                                intItemId: rec.intComponentItemId,
                                strItemNo: rec.strComponentItemNo,
                                strItemDescription: rec.strComponentDescription,
                                dblOpenReceive: componentQty,
                                // intLoadReceive: rec.get('intLoadToReceive'),
                                dblUnitCost: rec.dblLastCost,
                                dblUnitRetail: rec.dblLastCost,
                                // dblTax: s.get('dblTax'),
                                // dblLineTotal: rec.get('dblLineTotal'),
                                strLotTracking: rec.strLotTracking,
                                intCommodityId: rec.intCommodityId,
                                // intContainerId: rec.get('intContainerId'),
                                // strContainer: rec.get('strContainer'),
                                intSubLocationId: selectedItem.get('intSubLocationId'),
                                strSubLocationName: selectedItem.get('strSubLocationName'),
                                intStorageLocationId: selectedItem.get('intStorageLocationId'),
                                strStorageLocationName: selectedItem.get('strStorageLocationName'),
                                strOrderUOM: rec.strComponentUOM,
                                dblOrderUOMConvFactor: rec.dblComponentConvFactor,
                                intUnitMeasureId: rec.intComponentUOMId,
                                strUnitMeasure: rec.strComponentUOM,
                                strUnitType: rec.strComponentUOMType,
                                //strWeightUOM: rec.get('strComponentUOM'),
                                //intWeightUOMId: rec.get('intComponentUOMId'),
                                dblItemUOMConvFactor: rec.dblComponentConvFactor,
                                //dblWeightUOMConvFactor: rec.get('dblComponentConvFactor'),
                                intCostUOMId: rec.intComponentUOMId,
                                strCostUOM: rec.strComponentUOM,
                                dblCostUOMConvFactor: rec.dblComponentConvFactor,
                                intGradeId: null,
                                strGrade: null,
                                intLifeTime: selectedItem.get('intLifeTime'),
                                strLifeTimeType: selectedItem.get('strLifeTimeType'),
                                ysnLoad: selectedItem.get('ysnLoad'),
                                dblAvailableQty: selectedItem.get('dblAvailable'),
                                intOwnershipType: 1,
                                strOwnershipType: 'Own',
                                ysnSubCurrency: selectedItem.get('ysnSubCurrency'),
                                strSubCurrency: selectedItem.get('strSubCurrency'),
                                intForexRateTypeId: selectedItem.get('intForexRateTypeId'),
                                strForexRateType: selectedItem.get('strForexRateType'),
                                dblForexRate: selectedItem.get('dblForexRate')
                        });

                        var newItem = itemDetailStore.add(itemModel);
                        newItem = newItem[0];
                        newItem.set('dblLineTotal', me.calculateLineTotal(current, newItem));
                        me.calculateItemTaxes();
                        //addItemLotFunc(newItem, rec);
                    });
                },
                function(failureResponse) {
                    var jsonData = Ext.decode(failureResponse.responseText);
                    iRely.Functions.showErrorDialog('Something went wrong while getting the Components of the Kit item.');
                }
            );
        } else {
            var isValidToAdd = true;
            var filter = _.filter(itemDetailStore.data.items, function(x) { return x.get('intOrderId') === selectedItem.get('intOrderId') && !x.dummy; });
            
            if(filter.length > 0) 
                isValidToAdd = false; 

            if(!isValidToAdd){
                iRely.Functions.showCustomDialog(
                    iRely.Functions.dialogType.WARNING,
                    iRely.Functions.dialogButtonType.OK,
                    'You should only add one basket item per order.'
                );
                return;
            }
            
            iRely.Functions.openScreen('GlobalComponentEngine.view.FloatingSearch', {
                searchSettings: {
                    scope: me,
                    type: 'Inventory.GetAddOrders',
                    url: searchURL,
                    columns: [
                            { dataIndex: 'intItemBundleId', text: 'Bundle Item Id', dataType: 'numeric', key: true, hidden: true },
                            { dataIndex: 'intComponentItemId', text: '', dataType: 'numeric', hidden: true, required: true },
                            { dataIndex: 'intContractSeq', text: 'Sequence', width: 100, dataType: 'numeric', allowNull: true },
                            { dataIndex: 'strComponentItemNo', text: 'Item No', width: 100, dataType: 'string' },
                            { dataIndex: 'strComponentDescription', text: 'Item Description', width: 130, dataType: 'string' },
                            { xtype: 'numbercolumn', dataIndex: 'dblComponentQuantity', text: 'Component Quantity', width: 100, dataType: 'float', required: true, hidden: true  },
                            { dataIndex: 'intComponentUOMId', text: 'Component UOM Id', dataType: 'numeric', hidden: true, required: true },
                            { dataIndex: 'strComponentUOM', text: 'Item UOM', width: 100, dataType: 'string' },
                            { dataIndex: 'strComponentUOMType', text: 'Item UOM Type', width: 100, dataType: 'string' },
                            { xtype: 'numbercolumn', dataIndex: 'dblComponentConvFactor', text: 'Component UOM Conversion Factor', width: 100, dataType: 'float', hidden: true, required: true },
                            { xtype: 'numbercolumn', dataIndex: 'dblMarkUpOrDown', text: 'Mark Up/Down', width: 100, dataType: 'float' },
                            { dataIndex: 'dtmBeginDate', text: 'Begin Date', width: 100, dataType: 'date', required: true, xtype: 'datecolumn' },
                            { dataIndex: 'dtmEndDate', text: 'End Date', width: 100, dataType: 'date', required: true, xtype: 'datecolumn' },
                            
                            { dataIndex: 'strLotTracking', text: 'Lot Tracking', width: 100, dataType: 'string' },
                            { dataIndex: 'intCommodityId', text: 'Commodity Id', dataType: 'numeric', hidden: true, required: true, allowNull: true },
                            { dataIndex: 'strCommodityCode', text: 'Commodity', width: 100, dataType: 'string' },
                            { dataIndex: 'intContainerId', text: 'Container Id', dataType: 'numeric', hidden: true, required: true, allowNull: true },
                            { dataIndex: 'strContainer', text: 'Container', width: 100, dataType: 'string', required: true },

                            { dataIndex: 'intSubLocationId', text: 'Storage Location Id', dataType: 'numeric', hidden: true, required: true, allowNull: true },
                            { dataIndex: 'strSubLocationName', text: 'Storage Location', width: 100, dataType: 'string', hidden: true, required: true },
                            { dataIndex: 'intStorageLocationId', text: 'Storage Unit Id', dataType: 'numeric', hidden: true, required: true, allowNull: true },
                            { dataIndex: 'strStorageLocationName', text: 'Storage Unit', width: 100, dataType: 'string', hidden: true, required: true },
                            
                            { dataIndex: 'intStockUOMId', text: 'Stock UOM Id', dataType: 'numeric', hidden: true, required: true, allowNull: true },
                            { dataIndex: 'strStockUOM', text: 'Stock UOM', width: 100, dataType: 'string', hidden: true, required: true },
                            { dataIndex: 'strStockUOMType', text: 'Stock UOM Type', width: 100, dataType: 'string', hidden: true, required: true },
                            
                            { xtype: 'numbercolumn', dataIndex: 'dblStockUnitQty', text: 'Stock Unit Qty', width: 100, dataType: 'float', hidden: true, required: true },
                            { dataIndex: 'intItemUOMId', text: 'Item UOM Id', dataType: 'numeric', hidden: true, required: true, allowNull: true },
                            { dataIndex: 'strUnitMeasure', text: 'Unit Measure', width: 100, dataType: 'string', hidden: true, required: true },
                            { dataIndex: 'strGrossUOM', text: 'Gross UOM', width: 100, dataType: 'string', hidden: true, required: true },
                            { dataIndex: 'intGrossUOMId', text: 'Gross UOM Id', dataType: 'numeric', hidden: true, required: true, allowNull: true },
                            { dataIndex: 'intGradeId', text: 'Grade Id', dataType: 'numeric', hidden: true, required: true, allowNull: true },
                            { dataIndex: 'strGrade', text: 'Grade', width: 100, dataType: 'string' },
                    ],
                    title: screenTitle,
                    showNew: false,
                    singleSelection: true
                },
                viewConfig: {
                    listeners: {
                        scope: me,
                        openselectedclick: function(button, e, result) {
                            Ext.Array.forEach(result, function(rec){
                                var componentQty = selectedItem.get('dblQtyToReceive'),
                                    markUpOrDownCost = 0;

                                if(rec.get('dtmBeginDate') && rec.get('dtmBeginDate') && 
                                    (Ext.Date.between(current.get('dtmReceiptDate'), rec.get('dtmBeginDate'), rec.get('dtmEndDate'))))
                                    markUpOrDownCost = rec.get('dblMarkUpOrDown');
                                
                                var itemCost = (selectedItem.get('dblUnitCost') + markUpOrDownCost)
                                    * (selectedItem.get('intCostUOMId') ? selectedItem.get('dblCostUOMConvFactor') : selectedItem.get('dblOrderUOMConvFactor'));
                                    
                                var itemModel = Ext.create(itemDetailStore.role.type,{
                                        intInventoryReceiptId: current.get('intInventoryReceiptId'),
                                        strItemType: 'Option',
                                        intParentItemLinkId: rec.get('intItemBundleId'),
                                        intLineNo: selectedItem.get('intLineNo'),
                                        intOrderId: selectedItem.get('intOrderId'),
                                        intSourceId: selectedItem.get('intSourceId'),
                                        strOrderNumber: selectedItem.get('strOrderNumber'),
                                        strSourceNumber: selectedItem.get('strSourceNumber'),
                                        dblOrderQty: componentQty,
                                        dblReceived: selectedItem.get('dblReceived'),
                                        intItemId: rec.get('intComponentItemId'),
                                        strItemNo: rec.get('strComponentItemNo'),
                                        strItemDescription: rec.get('strComponentDescription'),
                                        dblOpenReceive: componentQty,
                                        intContractSeq: rec.get('intContractSeq'),
                                        // intLoadReceive: rec.get('intLoadToReceive'),
                                        dblUnitCost: i21.ModuleMgr.Inventory.roundDecimalFormat(itemCost, 6),
                                        dblUnitRetail: i21.ModuleMgr.Inventory.roundDecimalFormat(itemCost, 6),
                                        strLotTracking: rec.get('strLotTracking'),
                                        intCommodityId: rec.get('intCommodityId'),
                                        intSubLocationId: selectedItem.get('intSubLocationId'),
                                        strSubLocationName: selectedItem.get('strSubLocationName'),
                                        intStorageLocationId: selectedItem.get('intStorageLocationId'),
                                        strStorageLocationName: selectedItem.get('strStorageLocationName'),
                                        strOrderUOM: selectedItem.get('strOrderUOM'),
                                        dblOrderUOMConvFactor: selectedItem.get('dblOrderUOMConvFactor'),
                                        intUnitMeasureId: rec.get('intComponentUOMId'),
                                        strUnitMeasure: rec.get('strComponentUOM'),
                                        strUnitType: rec.get('strComponentUOMType'),
                                        strWeightUOM: rec.get('strComponentUOM'),
                                        intWeightUOMId: rec.get('intComponentUOMId'),
                                        dblItemUOMConvFactor: rec.get('dblComponentConvFactor'),
                                        dblWeightUOMConvFactor: rec.get('dblComponentConvFactor'),
                                        intCostUOMId: rec.get('intComponentUOMId'),
                                        strCostUOM: rec.get('strComponentUOM'),
                                        dblCostUOMConvFactor: rec.get('dblComponentConvFactor'),
                                        // dblGrossMargin: order.get('dblGrossMargin'),
                                        intGradeId: rec.get('intGradeId'),
                                        strGrade: rec.get('strGrade'),
                                        intLifeTime: selectedItem.get('intLifeTime'),
                                        strLifeTimeType: selectedItem.get('strLifeTimeType'),
                                        ysnLoad: selectedItem.get('ysnLoad'),
                                        dblAvailableQty: selectedItem.get('dblAvailable'),
                                        intOwnershipType: 1,
                                        strOwnershipType: 'Own',
                                        ysnSubCurrency: selectedItem.get('ysnSubCurrency'),
                                        strSubCurrency: selectedItem.get('strSubCurrency'),
                                        dblGross: selectedItem.get('dblGross'),
                                        dblNet: selectedItem.get('dblNet'),
                                        intForexRateTypeId: selectedItem.get('intForexRateTypeId'),
                                        strForexRateType: selectedItem.get('strForexRateType'),
                                        dblForexRate: selectedItem.get('dblForexRate')
                                });
                                
                                itemDetailStore.add(itemModel);
                                // newItem = newItem[0];
                                addedRecord = itemDetailStore.findRecord('intOrderId', selectedItem.get('intOrderId'));
                                win.viewModel.data.currentReceiptItem = addedRecord;

                                var taxCfg = {
                                    freightTermId: current.get('intFreightTermId'),
                                    locationId: current.get('intLocationId'),
                                    entityVendorId: current.get('intEntityVendorId'),
                                    entityLocationId: current.get('intShipFromId'),
                                    itemId: addedRecord.get('intItemId'),
                                    successFn: function(){
                                        // Calculate the taxes after getting the default tax group. 
                                        me.calculateItemTaxes();
                                    }
                                }; 

                                me.getDefaultReceiptTaxGroupId(addedRecord, taxCfg);  
                                addedRecord.set('dblLineTotal', me.calculateLineTotal(current, addedRecord));

                                // Calculate the Wgt or Volume Gain/Loss 
                                me.calculateWtGainLoss(win);
                                addItemLotFunc(addedRecord, rec);
                                me.addContractOtherCharges(current, addedRecord, selectedItem);
                            });
                        } 
                    }
                }
            });
        }
    },

    getItemAddOns: function(editingRecord, selectedItem, current, itemDetailStore){
        var me = this,
            win = me.getView(),
            bundleType = selectedItem.get('strBundleType'),
            itemAddOnId = selectedItem.get('intItemId'),
            itemUOMId = selectedItem.get('intReceiveUOMId');

        // Get the default Forex Rate Type from the Company Preference. 
        var intRateType = i21.ModuleMgr.SystemManager.getCompanyPreference('intInventoryRateTypeId');

        // Get the functional currency:
        var functionalCurrencyId = i21.ModuleMgr.SystemManager.getCompanyPreference('intDefaultCurrencyId');
        
        // Get the important header data: 
        var currentHeader = win.viewModel.data.current;
        var transactionCurrencyId = currentHeader.get('intCurrencyId');
        var vendorId = currentHeader.get('intEntityVendorId');
        var vendorLocation = currentHeader.get('intShipFromId');
        var dtmReceiptDate = currentHeader.get('dtmReceiptDate');
        var intLocationId = currentHeader.get('intLocationId');
        var intFreightTermId = currentHeader.get('intFreightTermId');

        var vendorCostCfg = {
            vendorId: vendorId,
            itemId: null,
            currencyId: transactionCurrencyId ? transactionCurrencyId : i21.ModuleMgr.SystemManager.getCompanyPreference('intDefaultCurrencyId'),
            vendorLocation: vendorLocation,
            itemUOM: null,
            validDate: dtmReceiptDate
        };

        var taxCfg = {
            freightTermId: intFreightTermId,
            locationId: intLocationId,
            entityVendorId: vendorId,
            entityLocationId: vendorLocation,
            itemId: null 
        };

        var processForexRateOnSuccess = function (successResponse, isItemLastCost, currentItem) {
            if (successResponse && successResponse.length > 0) {
                var dblForexRate = successResponse[0].dblRate;
                var strRateType = successResponse[0].strRateType;
                var dblLastCost = currentItem.get('dblLastCost')
                dblForexRate = Ext.isNumeric(dblForexRate) ? dblForexRate : 0;

                // Convert the last cost to the transaction currency.
                // and round it to six decimal places.  
                if (transactionCurrencyId != functionalCurrencyId && isItemLastCost) {
                    dblLastCost = dblForexRate != 0 ? dblLastCost / dblForexRate : 0;
                    dblLastCost = i21.ModuleMgr.Inventory.roundDecimalFormat(dblLastCost, 6);
                }

                currentItem.set('intForexRateTypeId', intRateType);
                currentItem.set('strForexRateType', strRateType);
                currentItem.set('dblForexRate', dblForexRate);
                currentItem.set('dblUnitCost', dblLastCost);
                currentItem.set('dblUnitRetail', dblLastCost);
            }
        }

        // function variable to process the vendor cost. 
        var processVendorCostOnSuccess = function (successResponse, currentItem) {
            var jsonData = Ext.decode(successResponse.responseText);
            var dblLastCost = currentItem.get('dblLastCost');
            var isItemLastCost = true;

            // If there is a vendor cost, replace dblLastCost with the vendor cost. 
            if (jsonData && jsonData.data && jsonData.data.length > 0) {
                var dataArray = jsonData.data[0];
                if (dataArray) {
                    dblLastCost = dataArray.dblUnit;
                    currentItem.set('dblUnitCost', dblLastCost);
                    currentItem.set('dblUnitRetail', dblLastCost);
                    isItemLastCost = false;
                }
            }

            // If transaction currency is a foreign currency, get the default forex rate type, forex rate, and convert the last cost to the transaction currency. 
            if (transactionCurrencyId != functionalCurrencyId && intRateType) {
                iRely.Functions.getForexRate(
                    transactionCurrencyId,
                    intRateType,
                    win.viewModel.data.current.get('dtmReceiptDate'),
                    function (successResponse) {
                        processForexRateOnSuccess(successResponse, isItemLastCost);
                    },
                    function (failureResponse) {
                        //var jsonData = Ext.decode(failureResponse.responseText);
                        //iRely.Functions.showErrorDialog(jsonData.message.statusText);                    
                        iRely.Functions.showErrorDialog('Something went wrong while getting the forex data.');
                    }
                );
            }

           
        };

        var processVendorCostOnFailure = function (failureResponse) {
            var jsonData = Ext.decode(failureResponse.responseText);
            //iRely.Functions.showErrorDialog(jsonData.Message);
            iRely.Functions.showErrorDialog('Something went wrong while getting the item cost from the Vendor Pricing setup.');
        };

        ic.utils.ajax({
            url: './inventory/api/itemaddon/getitemaddons?intItemId=' + itemAddOnId + '&intItemUOMId=' + itemUOMId 
                + '&intLocationId=' + intLocationId + '&dblQuantity=1',
            method: 'get'
        }).subscribe(
            function (successResponse) {
                var result = Ext.decode(successResponse.responseText);
                if(current && itemDetailStore && result.data.length > 0){
                    editingRecord.set('intParentItemLinkId', editingRecord.get('intInventoryReceiptItemId'));
                    editingRecord.set('strItemType', 'Add-On');
                    editingRecord.set('dblOpenReceive', 1);
                    win.down('#colItemNo').focus();

                    var recordIdx = itemDetailStore.findBy(function(rec){
                        return rec.id == editingRecord.id;
                    });

                    Ext.Array.forEach(result.data, function(rec, idx){
      
                        var itemDetail = Ext.create(itemDetailStore.role.type, {
                                intInventoryShipmentId: current.get('intInventoryReceiptId'),
                                strItemType: 'Add-On Item',
                                intChildItemLinkId: editingRecord.get('intInventoryReceiptItemId'),
                                dblComponentQty: rec.dblAddOnComponentQty,
                                dblOpenReceive: rec.dblAddOnComponentQty,
                                intItemId: rec.intComponentItemId,
                                strItemNo: rec.strComponentItemNo,
                                strItemDescription: rec.strComponentDescription,
                                intUnitMeasureId: rec.intComponentUOMId,
                                strUnitMeasure: rec.strComponentUOM,
                                dblItemUOMConvFactor: rec.dblComponentConvFactor,
                                strCostUOM: rec.strComponentStockUOM,
                                intCostUOMId: rec.intComponentStockUOMId,
                                dblCostUOMConvFactor: 1,
                                dblLastCost: rec.dblLastCost,
                                dblUnitCost: rec.dblLastCost,
                                dblUnitRetail: rec.dblLastCost,

                                strLotTracking: rec.strLotTracking,
                                intSubLocationId: rec.intSubLocationId,
                                strSubLocationName: rec.strSubLocationName,
                                intStorageLocationId: rec.intStorageLocationId,
                                strStorageLocationName: rec.strStorageLocationName,
                                intGradeId: rec.intGradeId,
                                strGrade: rec.strGrade,
                                intCommodityId: rec.intCommodityId,
                                strOwnershipType: 'Own',
                                intOwnershipType: 1,
                        });
                        
                        itemDetailStore.insert(recordIdx + (idx + 1), itemDetail);

                        vendorCostCfg.itemId = rec.intComponentItemId;
                        vendorCostCfg.itemUOM = rec.intComponentUOMId;
                        
                        me.getVendorCost(vendorCostCfg, processVendorCostOnSuccess, processVendorCostOnFailure, itemDetail);

                        taxCfg.itemId = rec.intComponentItemId;

                        me.getDefaultReceiptTaxGroupId(itemDetail, taxCfg);
                        me.calculateGrossNet(itemDetail, 1);

                        itemDetail.set('dblLineTotal', me.calculateLineTotal(current, itemDetail));
                    });
                }


            }, function (failureResponse) {
                var jsonData = Ext.decode(failureResponse.responseText);
                
                iRely.Functions.showErrorDialog('Something went wrong while getting the Add On Items.');
            }
        );
    },

    getItemSubstitutes: function(editingRecord, selectedItem, current, itemDetailStore){
        var me = this,
            win = me.getView(),
            bundleType = selectedItem.get('strBundleType'),
            itemSubstituteId = selectedItem.get('intItemId'),
            itemUOMId = selectedItem.get('intReceiveUOMId');

        // Get the default Forex Rate Type from the Company Preference. 
        var intRateType = i21.ModuleMgr.SystemManager.getCompanyPreference('intInventoryRateTypeId');

        // Get the functional currency:
        var functionalCurrencyId = i21.ModuleMgr.SystemManager.getCompanyPreference('intDefaultCurrencyId');
        
        // Get the important header data: 
        var currentHeader = win.viewModel.data.current;
        var transactionCurrencyId = currentHeader.get('intCurrencyId');
        var vendorId = currentHeader.get('intEntityVendorId');
        var vendorLocation = currentHeader.get('intShipFromId');
        var dtmReceiptDate = currentHeader.get('dtmReceiptDate');
        var intLocationId = currentHeader.get('intLocationId');
        var intFreightTermId = currentHeader.get('intFreightTermId');

        var vendorCostCfg = {
            vendorId: vendorId,
            itemId: null,
            currencyId: transactionCurrencyId ? transactionCurrencyId : i21.ModuleMgr.SystemManager.getCompanyPreference('intDefaultCurrencyId'),
            vendorLocation: vendorLocation,
            itemUOM: null,
            validDate: dtmReceiptDate
        };

        var taxCfg = {
            freightTermId: intFreightTermId,
            locationId: intLocationId,
            entityVendorId: vendorId,
            entityLocationId: vendorLocation,
            itemId: null 
        };

        var processForexRateOnSuccess = function (successResponse, isItemLastCost, currentItem) {
            if (successResponse && successResponse.length > 0) {
                var dblForexRate = successResponse[0].dblRate;
                var strRateType = successResponse[0].strRateType;
                var dblLastCost = currentItem.get('dblLastCost')
                dblForexRate = Ext.isNumeric(dblForexRate) ? dblForexRate : 0;

                // Convert the last cost to the transaction currency.
                // and round it to six decimal places.  
                if (transactionCurrencyId != functionalCurrencyId && isItemLastCost) {
                    dblLastCost = dblForexRate != 0 ? dblLastCost / dblForexRate : 0;
                    dblLastCost = i21.ModuleMgr.Inventory.roundDecimalFormat(dblLastCost, 6);
                }

                currentItem.set('intForexRateTypeId', intRateType);
                currentItem.set('strForexRateType', strRateType);
                currentItem.set('dblForexRate', dblForexRate);
                currentItem.set('dblUnitCost', dblLastCost);
                currentItem.set('dblUnitRetail', dblLastCost);
            }
        }

        // function variable to process the vendor cost. 
        var processVendorCostOnSuccess = function (successResponse, currentItem) {
            var jsonData = Ext.decode(successResponse.responseText);
            var dblLastCost = currentItem.get('dblLastCost');
            var isItemLastCost = true;

            // If there is a vendor cost, replace dblLastCost with the vendor cost. 
            if (jsonData && jsonData.data && jsonData.data.length > 0) {
                var dataArray = jsonData.data[0];
                if (dataArray) {
                    dblLastCost = dataArray.dblUnit;
                    currentItem.set('dblUnitCost', dblLastCost);
                    currentItem.set('dblUnitRetail', dblLastCost);
                    isItemLastCost = false;
                }
            }

            // If transaction currency is a foreign currency, get the default forex rate type, forex rate, and convert the last cost to the transaction currency. 
            if (transactionCurrencyId != functionalCurrencyId && intRateType) {
                iRely.Functions.getForexRate(
                    transactionCurrencyId,
                    intRateType,
                    win.viewModel.data.current.get('dtmReceiptDate'),
                    function (successResponse) {
                        processForexRateOnSuccess(successResponse, isItemLastCost);
                    },
                    function (failureResponse) {
                        //var jsonData = Ext.decode(failureResponse.responseText);
                        //iRely.Functions.showErrorDialog(jsonData.message.statusText);                    
                        iRely.Functions.showErrorDialog('Something went wrong while getting the forex data.');
                    }
                );
            }

        
        };

        var processVendorCostOnFailure = function (failureResponse) {
            var jsonData = Ext.decode(failureResponse.responseText);
            //iRely.Functions.showErrorDialog(jsonData.Message);
            iRely.Functions.showErrorDialog('Something went wrong while getting the item cost from the Vendor Pricing setup.');
        };
        
        ic.utils.ajax({
            url: './inventory/api/itemsubstitute/getitemsubstitutes?intItemId=' + itemSubstituteId + '&intItemUOMId=' + itemUOMId 
                + '&intLocationId=' + intLocationId + '&dblQuantity=1',
            method: 'get'
        }).subscribe(
            function (successResponse) {
                var result = Ext.decode(successResponse.responseText);
                if(current && itemDetailStore && result.data.length > 0) {
                    editingRecord.set('intParentItemLinkId', editingRecord.get('intInventoryShipmentItemId'));
                    editingRecord.set('strItemType', 'Substitute');
                    editingRecord.set('dblOpenReceive', 1);
                    win.down('#colItemNo').focus();

                    var recordIdx = itemDetailStore.findBy(function(rec){
                            return rec.id == editingRecord.id;
                        });

                    Ext.Array.forEach(result.data, function(rec, idx){
                        // var componentQty = rec.get('dblComponentQuantity') * selectedItem.get('dblQtyToShip'),
                        //             markUpOrDownCost = 0;

                        // if(rec.get('dtmBeginDate') && rec.get('dtmBeginDate') && 
                        //     (Ext.Date.between(current.get('dtmShipDate'), rec.get('dtmBeginDate'), rec.get('dtmEndDate'))))
                        //     markUpOrDownCost = rec.get('dblMarkUpOrDown');
                        
                        // var itemCost = (selectedItem.get('dblPrice') + markUpOrDownCost)
                        //     * (selectedItem.get('intCostUOMId') ? selectedItem.get('dblCostUOMConvFactor') : selectedItem.get('dblOrderUOMConvFactor'));

                        var itemDetail = Ext.create(itemDetailStore.role.type, {
                                intInventoryShipmentId: current.get('intInventoryShipmentId'),
                                strItemType: 'Substitute Item',
                                intChildItemLinkId: editingRecord.get('intInventoryShipmentItemId'),
                                strItemLink: 'S',
                                dblComponentQty: rec.dblSubstituteComponentQty,
                                dblOpenReceive: rec.dblSubstituteComponentQty,
                                intItemId: rec.intComponentItemId,
                                strItemNo: rec.strComponentItemNo,
                                strItemDescription: rec.strComponentDescription,
                                intUnitMeasureId: rec.intComponentUOMId,
                                strUnitMeasure: rec.strComponentUOM,
                                dblItemUOMConvFactor: rec.dblComponentConvFactor,
                                strCostUOM: rec.strComponentStockUOM,
                                intCostUOMId: rec.intComponentStockUOMId,
                                dblCostUOMConvFactor: 1,
                                dblLastCost: rec.dblLastCost,
                                dblUnitCost: rec.dblLastCost,
                                dblUnitRetail: rec.dblLastCost,
                                strLotTracking: rec.strLotTracking,
                                intSubLocationId: rec.intSubLocationId,
                                strSubLocationName: rec.strSubLocationName,
                                intStorageLocationId: rec.intStorageLocationId,
                                strStorageLocationName: rec.strStorageLocationName,
                                intGradeId: rec.intGradeId,
                                strGrade: rec.strGrade,
                                intCommodityId: rec.intCommodityId,
                                strOwnershipType: 'Own',
                                intOwnershipType: 1,
                        });

                        itemDetailStore.insert(recordIdx + (idx + 1), itemDetail);

                        vendorCostCfg.itemId = rec.intComponentItemId;
                        vendorCostCfg.itemUOM = rec.intComponentUOMId;
                        
                        me.getVendorCost(vendorCostCfg, processVendorCostOnSuccess, processVendorCostOnFailure, itemDetail);

                        taxCfg.itemId = rec.intComponentItemId; 
                        me.getDefaultReceiptTaxGroupId(itemDetail, taxCfg);
                        me.calculateGrossNet(itemDetail, 1);

                        itemDetail.set('dblLineTotal', me.calculateLineTotal(current, itemDetail));
                    });
                }


            },function (failureResponse) {
                var jsonData = Ext.decode(failureResponse.responseText);
                
                iRely.Functions.showErrorDialog('Something went wrong while getting the Substitute Items.');
            }
        );
    },

    onChargeCurrencyBeforeQuery: function (obj) {
        if (obj.combo) {
            var grid = obj.combo.up('grid');
            var plugin = grid.getPlugin('cepCharges');
            var current = plugin.getActiveRecord();

            if (obj.combo.itemId === 'cboChargeCurrency') {
                if (iRely.Functions.isEmpty(current.get('strContractNumber'))) {
                    obj.combo.defaultFilters = [
                        {
                            column: 'ysnSubCurrency',
                            value: false
                        }
                    ];
                }
                else {
                    obj.combo.defaultFilters = [
                        {
                            column: 'ysnSubCurrency',
                            value: true,
                            conjunction: 'or'
                        },
                        {
                            column: 'ysnSubCurrency',
                            value: false,
                            conjunction: 'or'
                        }
                    ];
                }
            }
        }
    },

    onRenderNumRef: function (value, opt, record) {
        var rt = record.intInventoryReceipt.get('strReceiptType');
        var st = record.intInventoryReceipt.get('intSourceType');
        if (rt === 'Purchase Order' || rt === 'Purchase Contract' || rt === 'Scale' || rt === 'Inbound Shipment' || rt === 'Transfer Order' || (rt === 'Direct' && st === 3))
            return '<a style="color: #005FB2;text-decoration: none;" onMouseOut="this.style.textDecoration=\'none\'" onMouseOver="this.style.textDecoration=\'underline\'" href="javascript:void(0);">' + value + '</a>';
        return value;
    },

    onItemCellClick: function (view, cell, cellIndex, record, row, rowIndex, e) {
        var linkClicked = (e.target.tagName == 'A');
        var clickedDataIndex =
            view.panel.headerCt.getHeaderAtIndex(cellIndex).dataIndex;

        if (linkClicked && (clickedDataIndex == 'strOrderNumber' || clickedDataIndex === 'strSourceNumber')) {
            var win = view.up('window');
            var me = win.controller;
            var vm = win.getViewModel();

            if (!record) {
                //iRely.Functions.showErrorDialog('Please select a location to edit.');
                return;
            }

            if (vm.data.current.phantom === true) {
                win.context.data.saveRecord({
                    successFn: function (batch, eOpts) {
                        me.openOrderItem(win, record, clickedDataIndex === 'strOrderNumber');
                        return;
                    }
                });
            }
            else {
                win.context.data.validator.validateRecord(win.context.data.configuration, function (valid) {
                    if (valid) {
                        me.openOrderItem(win, record, clickedDataIndex === 'strOrderNumber');
                        return;
                    }
                });
            }
        }
    },

    openOrderItem: function (win, record, isOrder) {
        var orderScreen = [
            {
                screen: 'AccountsPayable.view.PurchaseOrder',
                orderType: 'Purchase Order',
                keyColumn: 'intPurchaseId',
                cellColumn: 'intOrderId'
            },
            {
                screen: 'ContractManagement.view.Contract',
                orderType: 'Purchase Contract',
                keyColumn: 'intContractHeaderId',
                cellColumn: 'intOrderId',
                source: [
                    { type: 1, screen: 'Grain.view.ScaleStationSelection', keyColumn: 'intTicketId', cellColumn: 'intSourceId' }, //Scale
                    { type: 2, screen: 'Logistics.view.ShipmentSchedule', keyColumn: 'strLoadNumber', cellColumn: 'strSourceNumber' }, //Inbound Shipment
                    { type: 3, screen: 'Transport.view.Transport', keyColumn: 'intTransportId', cellColumn: 'intSourceId' }, //Transport
                    { type: 4, screen: 'Grain.view.Storage', keyColumn: 'intCustomerStorageId', cellColumn: 'intSourceId' }, //Settle Storage
                ]
            },
            {
                screen: 'Inventory.view.InventoryTransfer',
                orderType: 'Transfer Order',
                keyColumn: 'intInventoryTransferId',
                cellColumn: 'intOrderId'
            },
            {
                screen: 'Inventory.view.InventoryTransfer',
                orderType: 'Direct',
                keyColumn: 'intInventoryTransferId',
                cellColumn: 'intOrderId',
                source: [
                    { type: 3, screen: 'Transports.view.TransportLoads', keyColumn: 'strTransaction', cellColumn: 'strSourceNumber' }, //Transport
                ]
            }
        ];

        var orderType = record.intInventoryReceipt.get('strReceiptType');
        var sourceType = record.intInventoryReceipt.get('intSourceType');

        var order = _.findWhere(orderScreen, { orderType: orderType });
        if(order && order.source && !isOrder) {
            var source = _.findWhere(order.source, { type: sourceType });
            order = source ? source : order;
        }

        if(order) {
            if(order.screen === 'Grain.view.ScaleStationSelection') {
                ScaleTicketStore = Ext.create('Grain.store.ScaleTicket');
                var filter = [{ column: 'intTicketId', value: record.get(order.cellColumn), condition: 'eq', conjunction:'or'}];
                ScaleTicketStore.setRemoteFilter(true);
                ScaleTicketStore.clearFilter();
                ScaleTicketStore.addFilter(filter,false);
                ScaleTicketStore.load({
                    callback: function(records, operation, success) {
                        iRely.Functions.openScreen('Grain.view.ScaleStationSelection', {action: 'edit',filters:[{column: "intTicketId",
                            value: record.get('intTicketId')}],data:records});
                    }
                });
            } else {
                var params = {
                    action: 'view',
                    filters: [
                        {
                            column: order.keyColumn,
                            value: record.get(order.cellColumn),
                            condition: 'eq'
                        }
                    ]
                };
                    
                iRely.Functions.openScreen(order.screen, params);
            }
        }
    },

    onCurrencyBeforeSelect: function(field, record){
        var me = this;
        var current = me.getViewModel().data.current;
        var receiptItemCount = 0;

        var currentCurrencyId = current.get('intCurrencyId');
        currencyCurrencyId = currentCurrencyId ? currentCurrencyId : 0;
        var selectedCurrencyId = record.get('intCurrencyID');
        selectedCurrencyId = selectedCurrencyId ? selectedCurrencyId : 0; 
        var selectedCurrency = record.get('strCurrency');

        if (current){
			if (current.tblICInventoryReceiptItems()) {
                Ext.Array.each(current.tblICInventoryReceiptItems().data.items, function (row) {
                    if (!row.dummy) {
                        receiptItemCount++;  
                        return false;                       
                    }
                });
            }
        }

        if (receiptItemCount > 0 && currencyCurrencyId != selectedCurrencyId){
            var buttonAction = function (button) {
                if (button === 'yes') {
                    var items = current.tblICInventoryReceiptItems().data.items; 
                    for (var i = items.length - 1; i >= 0; i--){
                        if (!items[i].dummy){
                            var item = items[i];
                            // Remove the taxes related to the item. 
                            if (item){
                                item.tblICInventoryReceiptItemTaxes().removeAll();                                
                            }
                            // and then remove the item itself. 
                            current.tblICInventoryReceiptItems().removeAt(i);
                        }
                    }

                    current.set('intCurrencyId', selectedCurrencyId);
                    current.set('strCurrency', selectedCurrency);
                }
            };       

            iRely.Functions.showCustomDialog('question', 'yesno', 'Changing the currency will clear all the items. Do you want to continue?', buttonAction);
            return false; 
        }

        return true;
    },

    onReceiptDateChange: function(field, newValue, oldValue, eOpts){
        if (!oldValue || !newValue) return; 
        if (oldValue == newValue) return; 
        if (oldValue.toDateString() == newValue.toDateString()) return; 

        var functionalCurrencyId = i21.ModuleMgr.SystemManager.getCompanyPreference('intDefaultCurrencyId');
        //var strFunctionalCurrency = i21.ModuleMgr.SystemManager.getCompanyPreference('strDefaultCurrency');

        if (!functionalCurrencyId) return; 

        var me = this;
        var win = me.getView().screenMgr.window;
        var dtmReceiptDate = win.down('#dtmReceiptDate');
        var cboCurrency = win.down('#cboCurrency');
        var current = me.getViewModel().data.current;
        var receiptItemCount = 0;
        
        
        var currentCurrencyId = current.get('intCurrencyId');
        var strReceiptType = current.get('strReceiptType');
        currencyCurrencyId = currentCurrencyId ? currentCurrencyId : 0;

        if (current){
			if (current.tblICInventoryReceiptItems()) {
                Ext.Array.each(current.tblICInventoryReceiptItems().data.items, function (row) {
                    if (!row.dummy) {
                        receiptItemCount++;  
                        return false;                       
                    }
                });
            }
        }

        if (receiptItemCount > 0 && ((currencyCurrencyId != functionalCurrencyId && strReceiptType != 'Inventory Return'))){
            var buttonAction = function (button) {
                if (button === 'yes') {
                    me.clearItems(current);    
                }
                else {                    
                    dtmReceiptDate.suspendEvent('change');                                        
                    dtmReceiptDate.setValue(oldValue);
                    cboCurrency.focus(); // Change control focus to force the dtmReceiptDate's Blur event to fire. 
                }
            };       
            iRely.Functions.showCustomDialog('question', 'yesno', 'Changing the date while using a foreign currency will clear all the items. Do you want to continue?', buttonAction);
        }

        me.checkVendorCost(me.getViewModel(), current, dtmReceiptDate, oldValue);
    },

    checkVendorCost: function(vm, receipt, dtmReceiptDate, oldValue) {
        var me = this;
        ic.utils.ajax({
            url: './inventory/api/item/searchvendorpricing',
            filters: [
                {
                    column: 'intEntityVendorId',
                    value: receipt.get('intEntityVendorId'),
                    condition: 'eq',
                    conjunction: 'and'
                }, 
                {
                    column: 'intEntityLocationId',
                    value: receipt.get('intShipFromId'),
                    condition: 'eq',
                    conjunction: 'and'
                }
            ]
        })
        .subscribe(function(x) {
            var json = JSON.parse(x.responseText);
            var data = _.first(json.data);
            if(data) {
                var buttonAction = function (button) {
                    if (button === 'yes') {
                        me.clearItems(receipt);    
                    }
                    else {                    
                        if(dtmReceiptDate) {
                            dtmReceiptDate.suspendEvent('change');                                        
                            dtmReceiptDate.setValue(oldValue);
                            dtmReceiptDate.blur();
                        }
                    }
                };   
                iRely.Functions.showCustomDialog('question', 'yesno', 'Changing the date while using vendor pricing will clear all the items. Do you want to continue?', buttonAction);    
            }
        });
    },

    clearItems: function(current) {
        var items = current.tblICInventoryReceiptItems().data.items; 
        for (var i = items.length - 1; i >= 0; i--){
            if (!items[i].dummy){
                var item = items[i];
                // Remove the taxes related to the item. 
                if (item){
                    item.tblICInventoryReceiptItemTaxes().removeAll();                                
                }
                // and then remove the item itself. 
                current.tblICInventoryReceiptItems().removeAt(i);
            }
        }
    },

    onReceiptDateBlur: function(dtmReceiptDate, e, eOpts){
        if (!dtmReceiptDate) return; 
        
        dtmReceiptDate.resumeEvents();

        var events = dtmReceiptDate.events;
        var change = events ? events.change : null; 
        if (change){
            dtmReceiptDate.resumeEvent('change');
        }    
    },

    onCboContractSelect: function(combo, records, eOpts){
        var me = this,
            win = me.getView(),
            vm = me.getViewModel(),
            current = vm.data.current,
            grdCharges = combo.up('grid');
            activeGridRecord = grdCharges.editingPlugin.getActiveRecord(),
            selectedRec = records[0],
            costMethod = selectedRec.get('strCostMethod');

        activeGridRecord.set('intContractId', selectedRec.get('intContractHeaderId'));
        activeGridRecord.set('strContractNumber', selectedRec.get('strContractNumber'));
        activeGridRecord.set('intContractDetailId', selectedRec.get('intContractDetailId'));
        activeGridRecord.set('intContractSeq', selectedRec.get('intContractSeq'));
        activeGridRecord.set('intChargeId', selectedRec.get('intItemId'));
        activeGridRecord.set('ysnInventoryCost', selectedRec.get('ysnInventoryCost'));
        activeGridRecord.set('strCostMethod', costMethod);
        activeGridRecord.set('dblRate', costMethod == "Amount" ? 0 : selectedRec.get('dblRate'));
        activeGridRecord.set('intCostUOMId', selectedRec.get('intItemUOMId'));
        activeGridRecord.set('intEntityVendorId', selectedRec.get('intVendorId'));
        activeGridRecord.set('dblAmount', costMethod == "Amount" ? selectedRec.get('dblRate') : 0,
        activeGridRecord.set('strAllocateCostBy', 'Unit'));
        activeGridRecord.set('ysnAccrue', selectedRec.get('intVendorId') ? true : false);
        activeGridRecord.set('ysnPrice', selectedRec.get('ysnPrice'));
        activeGridRecord.set('strItemNo', selectedRec.get('strItemNo'));
        activeGridRecord.set('intCurrencyId', selectedRec.get('intCurrencyId'));
        activeGridRecord.set('strCurrency', selectedRec.get('strCurrency'));
        //ysnSubCurrency: otherCharge.ysnSubCurrency,
        activeGridRecord.set('strCostUOM', selectedRec.get('strUOM'));
        activeGridRecord.set('strVendorName', selectedRec.get('strVendorName'));
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
                select: this.onCurrencySelect,
                beforeselect: this.onCurrencyBeforeSelect
            },
            "#dtmReceiptDate": {
                change: this.onReceiptDateChange,
                blur: this.onReceiptDateBlur
            },
            /*"#cboTaxGroup": {
                drilldown: this.onTaxGroupDrilldown,
                select: this.onSelectTaxGroup
            },*/
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
            "#btnPost": {
                click: this.onReceiveClick
            },
            "#btnUnpost": {
                click: this.onReceiveClick
            },
            /*"#btnPostPreview": {
                click: this.onRecapClick
            },  
            "#btnUnpostPreview": {
                click: this.onRecapClick
            },*/
            "#btnReturn": {
                click: this.onReturnClick
            },
            "#btnVoucher": {
                click: this.onVoucherClick
            },
            "#btnDebitMemo": {
                click: this.onDebitMemoClick
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
            // "#btnshowOtherCharges": {
            //     click: this.onShowOtherChargesClick
            // },
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
                selectionchange: this.onItemSelectionChange,
                cellclick: this.onItemCellClick
            },
            "#grdLotTracking": {
                beforecellclick: function (me, td, cellIndex, record, tr, rowIndex, e, eOpts) {
                    var win = me.up('window');
                    var vm = win.viewModel;

                    var posted = vm.get('readOnlyReceiptItemGrid');
                    if (cellIndex !== 0)
                        me.select(rowIndex); // Don't force selection when the selection checkbox is clicked                                   
                    if (posted) {
                        if (me.grid.getColumns()[cellIndex].itemId === 'colLotRemarks' && cellIndex != 0) {
                            return !record.dummy; // Enable when remarks is not in a dummy row
                        }
                        return cellIndex == 0; // Enable when selection checkbox is clicked
                    }
                    return true;
                }
            },
            "#txtLotRemarks": {
                change: function (e, newValue, oldValue) {
                    var win = e.up('#grdLotTracking').up('window');
                    var btnSave = win.down("#btnSave");
                    var vm = win.viewModel;
                    var modifiedOnPosted = vm.get('modifiedOnPosted');
                    var dirty = newValue !== oldValue;
                    vm.set('modifiedOnPosted', modifiedOnPosted || dirty);
                    modifiedOnPosted = vm.get('modifiedOnPosted');
                    btnSave.setDisabled(!modifiedOnPosted);
                }
            },
            "#btnSave": {
                click: function (e) {
                    var win = e.up('window');
                    var vm = win.viewModel;
                    vm.set('modifiedOnPosted', false);
                    var posted = vm.get('readOnlyReceiptItemGrid');
                    //Removed this part since it is already included in binding
                    // if(posted)
                    //     e.setDisabled(true);
                }
            },
            "#cboLotUOM": {
                select: this.onLotSelect
            },
            "#cboWeightUOM": {
                select: this.onReceiptItemSelect
            },
            "#cboCostUOM": {
                select: this.onReceiptItemSelect,
                change: this.onCostUOMChange
            },
            "#cboStorageLocation": {
                select: this.onReceiptItemSelect
            },
            "#cboOtherCharge": {
                select: this.onChargeSelect
            },
            '#cboCostMethod': {
                select: this.onChargeSelect
            },
            // "#colAccrue": {
            //     beforecheckchange: this.onAccrueCheckChange
            // },
            "#btnReplicateBalanceLots": {
                click: this.onReplicateBalanceLotClick
            },
            "#cboChargeCurrency": {
                beforequery: this.onChargeCurrencyBeforeQuery,
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
            },
            "#tabInventoryReceipt": {
                tabChange: this.onReceiptTabChange
            },
            "#btnSelectAll": {
                click: this.onSelectClearGridInspectionClick
            },
            "#btnClearAll": {
                click: this.onSelectClearGridInspectionClick
            },
            "#cboSubLocation": {
                select: this.onReceiptItemSelect
            },
            "#btnChargeTaxDetails": {
                click: this.onChargeTaxDetailsClick
            },
            "#cboReceiptType": {
                select: this.onReceiptTypeSelect
            },
            "#cboChargeTaxGroup": {
                select: this.onChargeSelect
            },
            "#cboCostVendor": {
                select: this.onChargeSelect
            },
            "#cboForexRateType": {
                select: this.onReceiptItemSelect,
                change: this.onItemForexRateTypeChange
            },
            "#cboChargeForexRateType": {
                select: this.onChargeSelect,
                change: this.onChargeForexRateTypeChange
            },
            "#gumReceiveQty": {
                onUOMSelect: this.onGumUOMSelect
            },
            "#btnFetch": {
                click: this.onFetchClicked
            },
            "#cboContract": {
                select: this.onCboContractSelect
            }
        })
    }
});
