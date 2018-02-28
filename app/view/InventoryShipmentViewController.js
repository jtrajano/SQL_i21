Ext.define('Inventory.view.InventoryShipmentViewController', {
    //extend: 'Inventory.view.InventoryBaseViewController',
    extend: 'Ext.app.ViewController',
    alias: 'controller.icinventoryshipment',
    requires: [
        'CashManagement.common.Text',
        'CashManagement.common.BusinessRules'
    ],

    config: {
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
                value: '{current.strFreightTerm}',
                origValueField: 'intFreightTermId',
                store: '{freightTerm}',
                defaultFilters: [
                    {
                        column: 'ysnActive',
                        value: 'true'
                    }
                ],                
                readOnly: '{current.ysnPosted}'
            },
            cboCurrency: {
                value: '{current.strCurrency}',                
                origValueField: 'intCurrencyID',
                origUpdateField: 'intCurrencyId',
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
                value: '{current.strCustomerName}',
                origValueField: 'intEntityId',
                origUpdateField: 'intEntityCustomerId',
                store: '{customer}',
                readOnly: '{current.ysnPosted}',
                fieldLabel: '{setCustomerFieldLabel}',
                defaultFilters: [{
                    column: 'ysnActive',
                    value: true
                }]
            },
            cboShipFromAddress: {
                value: '{current.strShipFromLocation}',
                origValueField: 'strLocationName',
                origUpdateField: 'strShipFromLocation',
                store: '{shipFromLocation}',
                readOnly: '{current.ysnPosted}'
            },
            txtShipFromAddress: '{strShipFromAddress}',
            cboShipToAddress: {
                value: '{current.strShipToLocation}',
                origValueField: 'strLocatioName',
                origUpdateField: 'strShipToLocation',
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
                value: '{current.strShipToCompanyLocation}',
                origValueField: 'strLocatioName',
                origUpdateField: 'strShipToCompanyLocation',
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
                value: '{current.strShipVia}',
                origValueField: 'intEntityId',
                origUpdateField: 'intShipViaId',
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
            txtFreeTime: {
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
                colContractSeq: {
                    hidden: '{!contractSequenceVisible}',
                    dataIndex: 'intContractSeq'
                },
                colSourceNumber: {
                    hidden: '{checkHideSourceNo}',
                    dataIndex: 'strSourceNumber'
                },
                colItemType: {
                    dataIndex: 'strItemType',
                    hidden: true,
                },
                colItemNumber: {
                    dataIndex: 'strItemNo',
                    editor: {
                        readOnly: '{readOnlyItemDropdown}',
                        readOnly: '{isItemComponent}',
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
                colGumQuantity: {
                    dataIndex: 'dblQuantity',
                    editor:{
                        readOnly: '{isItemOption}'
                    }
                },
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
                            },
                            {
                                column: 'strInternalCode',
                                value: 'WH_DOCK_DOOR',
                                conjunction: 'and',
                                condition: 'noteq'
                            }
                        ]
                    }
                },
                colDockDoor: {
                    dataIndex: 'strDockDoor',
                    editor: {
                        readOnly: '{disableFieldInShipmentGrid}',
                        store: '{storageLocation}',
                        origValueField: 'intStorageLocationId',
                        origUpdateField: 'intDockDoorId',
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
                            },
                            {
                                column: 'strInternalCode',
                                value: 'WH_DOCK_DOOR',
                                conjunction: 'and',
                                condition: 'eq'
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
                        readOnly: '{hasCustomerStorage}',
                        readOnly: '{isItemComponent}',
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
                        //readOnly: '{isItemComponent}',
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
                        store: '{forexRateType}',
                        readOnly: '{isItemComponent}'
                    }
                },
                colForexRate: {
                    dataIndex: 'dblForexRate' 
                },
                colDestinationQuantity: 'dblDestinationQuantity',
                colItemChargesLink:  {
                    dataIndex: 'strChargesLink',
                    editor: {
                        origValueField: 'strChargesLink',
                        origUpdateField: 'strChargesLink',
                        store: '{chargesItemLink}',                   
                    }
                }                     
            },

            btnRemoveLot: {
                hidden: '{readOnlyOnPickLots}'
            },
            grdLotTracking: {
                readOnly: '{readOnlyOnPickLots}',
                colLotID: {
                    dataIndex: 'strLotNumber',
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
                            column: 'strPrimaryStatus',
                            value: 'Active',
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
                    dataIndex: 'strItemUOM'
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
                colQuantity: 'dblQuantity',
                colRate: {
                    dataIndex: 'dblRate',
                    editor: {
                        readOnly: '{readOnlyChargeRate}'
                    }
                },
                colCostUOM: {
                    dataIndex: 'strCostUOM',
                    editor: {
                        readOnly: '{readOnlyChargeUOM}',
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
                        origValueField: 'intEntityId',
                        origUpdateField: 'intEntityVendorId',
                        store: '{vendor}'
                    }
                },
                colChargeEntity: {
                    dataIndex: 'ysnPrice',
                    disabled: '{current.ysnPosted}'
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
                colChargeTax: {
                    dataIndex: 'dblTax'
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
            pgePostPreview: {
                title: '{pgePreviewTitle}'
            }
        }
    },

    setupContext : function(options) {
        "use strict";
        var me = this,
            win = me.getView(),
            store = Ext.create('Inventory.store.Shipment', { pageSize: 1 });

        var grdInventoryShipment = win.down('#grdInventoryShipment'),
            grdLotTracking = win.down('#grdLotTracking'),
            grdCharges = win.down('#grdCharges');

        win.context = Ext.create('iRely.Engine', {
            window: win,
            store: store,
            enableActivity: true,
            enableCustomTab: true,
            createTransaction: Ext.bind(me.createTransaction, me),
            enableAudit: true,
            createRecord: me.createRecord,
            binding: me.config.binding,
            attachment: Ext.create('iRely.attachment.Manager', {
                type: 'Inventory.Shipment',
                window: win
            }),
            details: [
                {
                    key: 'tblICInventoryShipmentItems',
                    lazy: true,
                    component: Ext.create('iRely.grid.Manager', {
                        grid: grdInventoryShipment,
                        deleteButton: grdInventoryShipment.down('#btnRemoveItem'),
                        deleteRecord: Ext.bind(me.onShipmentItemDelete, me)
                    }),
                    details: [
                        {
                            key: 'tblICInventoryShipmentItemLots',
                            lazy: true,
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
                    lazy: true,
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

    onShipmentItemDelete: function(action) {
        var me = this,
            win = me.getView(),
            grdInventoryShipment = win.down('#grdInventoryShipment'),
            grdStore = grdInventoryShipment.getStore(),
            selectedRecords = grdInventoryShipment.getSelectionModel().getSelection(),
            records = Ext.clone(selectedRecords);
        
        Ext.Array.forEach(selectedRecords, function(rec){
            if(!iRely.Functions.isEmpty(rec.get('strItemType')) && rec.get('intParentItemLinkId')){

                var childItems = _.filter(grdStore.data.items, function(x){
                    return !iRely.Functions.isEmpty(x.get('strItemType'))
                        && x.get('intChildItemLinkId')
                        && x.get('intChildItemLinkId') == rec.get('intParentItemLinkId') 
                        && x.get('intInventoryShipmentItemId') != rec.get('intInventoryShipmentItemId')
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

    show : function(config) {
        "use strict";

        var me = this,
            win = this.getView();

        if (config) {
            win.show();

            var context = win.context ? win.context.initialize() : me.setupContext();

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
            
            me.getViewModel().set('chargesLinkInc', 0);
            
        }
    },

    createRecord: function(config, action) {
        var me = this;
        var today = new Date();
        var record = Ext.create('Inventory.model.Shipment');
        var defaultShipmentType = i21.ModuleMgr.Inventory.getCompanyPreference('intShipmentOrderType');
        var defaultSourceType = i21.ModuleMgr.Inventory.getCompanyPreference('intShipmentSourceType');
        var defaultCurrency = i21.ModuleMgr.SystemManager.getCompanyPreference('intDefaultCurrencyId');
        var defaultLocation = iRely.config.Security.CurrentDefaultLocation; 
        
        if (defaultLocation){            
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
                            record.set('intShipFromLocationId', companyLocation.get('intCompanyLocationId'));
                            record.set('strShipFromLocation', companyLocation.get('strLocationName'));
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

        if (defaultCurrency){      
            record.set('intCurrencyId', defaultCurrency);      
            Ext.create('i21.store.CurrencyBuffered', {
                storeId: 'icShipmentCurrency',
                autoLoad: {
                    filters: [
                        {
                            dataIndex: 'intCurrencyID',
                            value: defaultCurrency,
                            condition: 'eq'
                        }
                    ],
                    params: {
                        columns: 'strCurrency:intCurrencyID:'
                    },
                    callback: function(records, operation, success){
                        var currency; 
                        if (records && records.length > 0) {
                            currency = records[0];
                        }

                        if(success && currency){
                            record.set('intCurrencyId', currency.get('intCurrencyID'));
                            record.set('strCurrency', currency.get('strCurrency'));
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
                url: './Inventory/api/InventoryShipment/GetCustomerCurrency',
                method: 'GET',
                params: {
                    entityId: customerId
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

        var record = records[0];
        if (!record)
            return; 

        var win = combo.up('window');
        var current = win.viewModel.data.current;
        
        if (current){
            if (combo.itemId === 'cboShipFromAddress'){
                var shipmentItemCount = 0;
                if (current.tblICInventoryShipmentItems()) {
                    Ext.Array.each(current.tblICInventoryShipmentItems().data.items, function(row) {
                        if (!row.dummy) {
                            shipmentItemCount++;
                            return false; 
                        }
                    });
                }
                if (shipmentItemCount == 0){
                    current.set('intShipFromLocationId', record.get('intCompanyLocationId'));
                    current.set('strShipFromStreet', record.get('strAddress'));
                    current.set('strShipFromCity', record.get('strCity'));
                    current.set('strShipFromState', record.get('strStateProvince'));
                    current.set('strShipFromZipPostalCode', record.get('strZipPostalCode'));
                    current.set('strShipFromCountry', record.get('strCountry'));
                }                
            }
            else if (combo.itemId === 'cboShipToAddress'){
                current.set('strShipToStreet', record.get('strAddress'));
                current.set('strShipToCity', record.get('strCity'));
                current.set('strShipToState', record.get('strState'));
                current.set('strShipToZipPostalCode', record.get('strZipCode'));
                current.set('strShipToCountry', record.get('strCountry'));
                current.set('intShipToLocationId', record.get('intEntityLocationId'));
            }
            else if (combo.itemId === 'cboShipToCompanyAddress'){
                current.set('strShipToStreet', record.get('strAddress'));
                current.set('strShipToCity', record.get('strCity'));
                current.set('strShipToState', record.get('strStateProvince'));
                current.set('strShipToZipPostalCode', record.get('strZipPostalCode'));
                current.set('strShipToCountry', record.get('strCountry'));
                current.set('strShipToLocation', record.get('strLocationName'));
                current.set('intShipToLocationId', record.get('intEntityLocationId'));               
                current.set('intShipToCompanyLocationId', record.get('intEntityLocationId'));
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
            current.set('intEntityCustomerId', record.get('intEntityId'));
            current.set('strCustomerName', record.get('strName'));
            current.set('intFreightTermId', record.get('intFreightTermId') != 0 ? record.get('intFreightTermId') : null);
            current.set('strFreightTerm', record.get('strFreightTerm'));
            
            // If Order Type is a 'Transfer Order', do not populate the ship to. 
            if (current.get('intOrderType') != 3){
                current.set('intShipToLocationId', record.get('intShipToId'));   
                current.set('strShipToLocation', record.get('strShipToLocationName'));   
                current.set('strShipToStreet', record.get('strShipToAddress'));
                current.set('strShipToCity', record.get('strShipToCity'));
                current.set('strShipToState', record.get('strShipToState'));
                current.set('strShipToZipPostalCode', record.get('strShipToZipCode'));
                current.set('strShipToCountry', record.get('strShipToCountry'));            
            }
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

    getItemSalesPrice: function(cfg, successFn, failureFn, currentItem){
        // Sanitize parameters; 
        cfg = cfg ? cfg : {}; 
        successFn = successFn && (successFn instanceof Function) ? successFn : function(){ /*empty function*/ };
        failureFn = failureFn && (failureFn instanceof Function) ? failureFn : function(){ /*empty function*/ };

        ic.utils.ajax({
            url: './accountsreceivable/api/common/getitemprice',
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
                successFn(response, currentItem);                
            },
            function(response) {
                failureFn(response, currentItem);
            }
        );
    },

    onItemNoSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var me = this;
        var win = combo.up('window');
        var viewModel = me.getViewModel();
        var currentVM = viewModel.data.current;
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
                            //var jsonData = Ext.decode(failureResponse.responseText);
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
            

            me.getItemAddOns(current, records[0], currentVM, currentVM.tblICInventoryShipmentItems());

            me.getItemSubstitutes(current, records[0], currentVM, currentVM.tblICInventoryShipmentItems());
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
                current.set('intDockDoorId', null);
                current.set('strDockDoor', null);
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
            if(records[0].get('intStorageTypeId')) {
                current.set('intOwnershipType', 2);
                current.set('strOwnershipType', 'Storage');
            }
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
                    //var jsonData = Ext.decode(failureResponse.responseText);
                    iRely.Functions.showErrorDialog(failureResponse);                    
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
            current.set('strItemUOM', records[0].get('strItemUOM'));
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
                postURL: './Inventory/api/InventoryShipment/Ship',
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
        if (button){
            button.disable();
        }
        else {
            return;
        }

        var win = button.up('window');
        var current = win.viewModel.data.current;
        
        if (current) {
            if(current.get('intOrderType') === 3) { //'Transfer Order'
                iRely.Functions.showErrorDialog('Invalid order type. An invoice is not applicable on transfer orders.');
                return;
            }

            ic.utils.ajax({
                timeout: 120000,
                url: './Inventory/api/InventoryShipment/ProcessShipmentToInvoice',
                params: {
                    id: current.get('intInventoryShipmentId')
                },
                method: 'post'
            })
            .subscribe(
                function(successResponse){
                    var jsonData = Ext.decode(successResponse.responseText);
                    var message = jsonData.message; 
                    var invoiceId = message ? message.InvoiceId : null;

                    var buttonAction = function(button) {
                        if (button === 'yes') {
                            iRely.Functions.openScreen('AccountsReceivable.view.Invoice', {
                                filters: [
                                    {
                                        column: 'intInvoiceId',
                                        value: invoiceId
                                    }
                                ],
                                action: 'view'
                            });
                            win.close();
                        }
                    };
                    iRely.Functions.showCustomDialog('question', 'yesno', 'Invoice successfully processed. Do you want to view this Invoice?', buttonAction);

                    button.enable();
                },
                function(failureResponse) {
                    var jsonData = Ext.decode(failureResponse.responseText);
                    var message = jsonData.message; 
                    iRely.Functions.showErrorDialog(message.statusText);
                    button.enable();
                }
            );
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
                        dataIndex: 'strStorageLocationName',
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

    getDefaultTaxGroupId: function (current, cfg) {
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
            }
            , function (failureResponse) {
                var jsonData = Ext.decode(failureResponse.responseText);
                //iRely.Functions.showErrorDialog(jsonData.message.statusText);
                iRely.Functions.showErrorDialog('Something went wrong while getting the default Tax Group for the item.');
            }
        );
    },    
    
    onChargeSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;
        
        var me = this; 
        var win = combo.up('window');
        var record = records[0];
        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepCharges');
        var current = plugin.getActiveRecord();
        var masterRecord = win.viewModel.data.current;
        //var cboCurrency = win.down('#cboCurrency');
        
        if (combo.itemId === 'cboOtherCharge') {
            // Get the default Forex Rate Type from the Company Preference. 
            var intRateType = i21.ModuleMgr.SystemManager.getCompanyPreference('intInventoryRateTypeId');

            // Get the functional currency:
            var functionalCurrencyId = i21.ModuleMgr.SystemManager.getCompanyPreference('intDefaultCurrencyId');
            var strFunctionalCurrency = i21.ModuleMgr.SystemManager.getCompanyPreference('strDefaultCurrency');

            // Get the transaction currency
            var chargeCurrencyId = masterRecord.get('intCurrencyId');
            var chargeCurrency = masterRecord.get('strCurrency');

            current.set('intChargeId', record.get('intItemId'));
            current.set('intCostUOMId', record.get('intCostUOMId'));
            current.set('strCostMethod', record.get('strCostMethod'));
            current.set('strCostUOM', record.get('strCostUOM'));
            current.set('strOnCostType', record.get('strOnCostType'));
            current.set('ysnPrice', record.get('ysnPrice'));
            current.set('ysnAccrue', record.get('ysnAccrue'));
            current.set('intCurrencyId', chargeCurrencyId);
            current.set('strCurrency', chargeCurrency);
            current.set('dblTax', null);

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
                        //var jsonData = Ext.decode(failureResponse.responseText);
                        //iRely.Functions.showErrorDialog(jsonData.message.statusText);                    
                        iRely.Functions.showErrorDialog('Something went wrong while getting the forex data.');
                    }
                );                      
            }
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
                    //var jsonData = Ext.decode(failureResponse.responseText);
                    //iRely.Functions.showErrorDialog(jsonData.message.statusText);      
                    iRely.Functions.showErrorDialog('Something went wrong while getting the forex data.');                                  
                }
            );                
        }     
        
        if (combo.itemId === 'cboCostVendor') {
            current.set('intEntityVendorId', record.get('intEntityId'));
    
            // Get the tax group for the other charge. 
            if (current.get('intEntityVendorId'))
            {                
                current.set('intTaxGroupId', null);
                current.set('strTaxGroup', null);
                current.set('dblTax', null);
    
                var taxCfg = {
                    freightTermId: null, // Freight Terms is not applicable for other charges. 
                    locationId: masterRecord.get('intShipFromLocationId'),
                    entityVendorId: current.get('intEntityVendorId'),
                    entityLocationId: null,
                    itemId: current.get('intChargeId')
                };
                me.getDefaultTaxGroupId(current, taxCfg);
            }
        }

        if (combo.itemId === 'cboChargeTaxGroup') {
            this.doOtherChargeTaxCalculate(win);
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
            iRely.Functions.showErrorDialog('Atleast one(1) line item must have a Storage Location specified.');
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
        var txtShipToAddress = win.down('#txtShipToAddress');        

        var CustomerId = currentRecord.get('intEntityCustomerId').toString();
        var OrderType = cboOrderType.getRawValue().toString();
        var SourceType = cboSourceType.getRawValue().toString();
        var ContractStore = win.viewModel.storeInfo.salesContractList;
        var newISItem;
        var me = this, vm = me.getViewModel();

        iRely.Functions.openScreen('GlobalComponentEngine.view.FloatingSearch', {
            searchSettings: {
                scope: me,
                type: 'Inventory.GetAddOrders',
                url: './inventory/api/inventoryshipment/getaddorders?customerid=' + CustomerId + '&ordertype=' + OrderType + '&sourcetype=' + SourceType,
                hiddenRequired: true,
                columns: [
                    { dataIndex: 'intLineNo', text: 'intLineNo', width: 100, dataType: 'numeric', defaultSort: true, sortOrder: 'DESC', key: true, hidden: true },
                    
                    { dataIndex: 'strOrderNumber', text: 'Order Number', width: 100, dataType: 'string' },
                    { dataIndex: 'intContractSeq', text: 'Sequence', width: 100, dataType: 'numeric', allowNull: true },
                    { dataIndex: 'strSourceNumber', text: 'Source Number', width: 100, dataType: 'string' },
                    { dataIndex: 'strShipFromLocation', text: 'Ship From Location', width: 100, dataType: 'string' },
                    { dataIndex: 'strCustomerNumber', text: 'Customer Number', width: 100, dataType: 'string' },
                    { dataIndex: 'strCustomerName', text: 'Customer Name', width: 100, dataType: 'string' },
    
                    { dataIndex: 'intLocationId', text: 'Location Id', width: 100, dataType: 'numeric', hidden: true, allowNull: true },
                    { dataIndex: 'intItemId', text: 'Item Id', width: 100, dataType: 'numeric', hidden: true, allowNull: true },
                    { dataIndex: 'strItemNo', text: 'Item No', width: 100, dataType: 'string' },
                    { dataIndex: 'strItemDescription', text: 'Item Description', width: 100, dataType: 'string' },
                    { dataIndex: 'strBundleType', text: 'Bundle Type', width: 150, dataType: 'string', required: true },
                    { dataIndex: 'strLotTracking', text: 'Lot Tracking', width: 100, dataType: 'string' },
                    { dataIndex: 'intCommodityId', text: 'Commodity Id', width: 100, dataType: 'numeric', hidden: true, allowNull: true },
                    { dataIndex: 'intSubLocationId', text: 'SubLocation Id', width: 100, dataType: 'numeric', hidden: true, allowNull: true, allowNull: true },
                    { dataIndex: 'strSubLocationName', text: 'Storage Location', width: 100, dataType: 'string' },
                    { dataIndex: 'intStorageLocationId', text: 'Storage Location Id', width: 100, dataType: 'numeric', hidden: true, allowNull: true },
                    { dataIndex: 'strStorageLocationName', text: 'Storage Unit', width: 100, dataType: 'string' },
    
                    { dataIndex: 'intFreightTermId', text: 'Freight Terms Id', width: 100, dataType: 'numeric', hidden: true, allowNull: true },
                    { dataIndex: 'strFreightTerm', text: 'Freight Terms', width: 100, dataType: 'string' },           
                    
                    { dataIndex: 'intOrderUOMId', text: 'Order UOM Id', width: 100, dataType: 'numeric', hidden: true, allowNull: true },
                    { dataIndex: 'strOrderUOM', text: 'Order UOM', width: 100, dataType: 'string' },
                    { xtype: 'numbercolumn', dataIndex: 'dblOrderUOMConvFactor', text: 'Order UOM Conversion Factor', width: 100, dataType: 'float', hidden: true },
                    { dataIndex: 'intItemUOMId', text: 'Item UOM Id', width: 100, dataType: 'numeric', hidden: true, allowNull: true },
                    { dataIndex: 'strItemUOM', text: 'Item UOM', width: 100, dataType: 'string' },
                    { xtype: 'numbercolumn', dataIndex: 'dblItemUOMConv', text: 'Item UOM Conversion Factor', width: 100, dataType: 'float', hidden: true },
                    { dataIndex: 'intWeightUOMId', text: 'Weight UOM Id', width: 100, dataType: 'numeric', hidden: true, allowNull: true },
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
                    { dataIndex: 'intGradeId', text: 'Grade Id', width: 100, dataType: 'numeric', hidden: true, allowNull: true },
                    { dataIndex: 'strGrade', text: 'Grade', width: 100, dataType: 'numeric', hidden: true },
                    { dataIndex: 'intDestinationGradeId', text: 'Destination Grade Id', width: 100, dataType: 'numeric', hidden: true, allowNull: true },
                    { dataIndex: 'strDestinationGrades', text: 'Destination Grades', width: 100, dataType: 'string' },
                    { dataIndex: 'intDestinationWeightId', text: 'Destination Weight Id', width: 100, dataType: 'numeric', hidden: true, allowNull: true },
                    { dataIndex: 'strDestinationWeights', text: 'Destination Weights', width: 100, dataType: 'string' },
    
                    { dataIndex: 'intForexRateTypeId', text: 'Forex Rate Type Id', width: 100, dataType: 'numeric', hidden: true, allowNull: true },
                    { dataIndex: 'strForexRateType', text: 'Forex Rate Type', width: 100, dataType: 'string', hidden: true },
                    { xtype: 'numbercolumn', dataIndex: 'dblForexRate', text: 'Forex Rate', width: 100, dataType: 'float', hidden: true },               
                    
                    { dataIndex: 'intOrderId', text: 'intOrderId', width: 100, dataType: 'numeric', hidden: true, allowNull: true },
                    { dataIndex: 'intSourceId', text: 'intSourceId', width: 100, dataType: 'numeric', hidden: true, allowNull: true },
                    { dataIndex: 'intCurrencyId', text: 'Currency Id', dataType: 'numeric', hidden: true, allowNull: true },
                    { dataIndex: 'strCurrency', text: 'Currency', dataType: 'numeric' },
                    { dataIndex: 'intShipToLocationId', text: 'Ship To Location Id', hidden: true, dataType: 'numeric', allowNull: true },
                    { dataIndex: 'strShipToLocation', text: 'Ship To Location', width: 100, dataType: 'string', hidden: true },
                    { dataIndex: 'strShipToStreet', text: 'Ship To Street', width: 100, dataType: 'string',  hidden: true },
                    { dataIndex: 'strShipToCity', text: 'Ship To City', width: 100, dataType: 'string',  hidden: true },
                    { dataIndex: 'strShipToState', text: 'Ship To State', width: 100, dataType: 'string',  hidden: true },
                    { dataIndex: 'strShipToZipCode', text: 'Ship To Zip Code', width: 100, dataType: 'string', hidden: true },
                    { dataIndex: 'strShipToCountry', text: 'Ship To Country', width: 100, dataType: 'string', hidden: true },
                    { dataIndex: 'strShipToAddress', text: 'Ship To Address', width: 100, dataType: 'string', hidden: true }
                ],
                title: "Add Orders",
                showNew: false
            },
            viewConfig: {
                listeners: {
                    scope: me,
                    openselectedclick: function(button, e, result) {
                        var win = me.getView();
                        var currentVM = me.getViewModel().data.current;

                        var pickLotList = win.viewModel.storeInfo.pickedLotList;

                        var freightTermsError = [];
                        var shipmentFreightTerms = currentVM.get('intFreightTermId');
                        var isValidToAdd = true;                         
                        
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
                                                                lotDetails.get('intPickLotHeaderId') === lot.get('intPickLotHeaderId') 
                                                            ) {
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
                                                        
                                                        newISItem = currentVM.tblICInventoryShipmentItems().add(newRecord);
                                                        newISItem = newISItem.length > 0 ? newISItem[0] : null;
                                                    }
                                                });
                                            }
                                        });
                                    }
                                });
                            }
                            else {
                                // Check if the Order's Freight Terms is the same with the Receipt Freight Terms
                                addOrderFreightTerms = order.get('intFreightTermId');                            
                                if (shipmentFreightTerms != addOrderFreightTerms
                                    && (
                                        OrderType === 'Sales Order'
                                        || (OrderType === 'Sales Contract') 
                                    )
                                ){
                                    freightTermsError.push({
                                        orderId: order.get('intOrderId'),
                                        orderFreightTerm: addOrderFreightTerms
                                    });
                                    isValidToAdd = false; 
                                }

                                if(isValidToAdd && !currentRecord.get('strCurrency')) {
                                    currentRecord.set('intCurrencyId', order.get('intCurrencyId'));
                                    currentRecord.set('strCurrency', order.get('strCurrency'));
                                }                               

                                if(isValidToAdd && !currentRecord.get('strShipToLocation')){
                                    currentRecord.set('intShipToLocationId', order.get('intShipToLocationId'));
                                    currentRecord.set('strShipToLocation', order.get('strShipToLocation'));
                                    currentRecord.set('strShipToStreet', order.get('strShipToStreet'));                                
                                    currentRecord.set('strShipToCity', order.get('strShipToCity'));
                                    currentRecord.set('strShipToState', order.get('strShipToState'));
                                    currentRecord.set('strShipToZipPostalCode', order.get('strShipToZipCode'));
                                    currentRecord.set('strShipToCountry', order.get('strShipToCountry'));
                                    if (txtShipToAddress) txtShipToAddress.setValue(order.get('strShipToAddress'));

                                } 

                                if (isValidToAdd) {
                                        var newRecord = {
                                            intInventoryShipmentId: currentVM.get('intInventoryShipmentId'),
                                            intOrderId: order.get('intOrderId'),
                                            intSourceId: order.get('intSourceId'),
                                            intContractSeq: order.get('intContractSeq'),
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
                                        
                                        var strBundleType = order.get('strBundleType'); 

                                        if(strBundleType == 'Kit') {
                                            currentVM.tblICInventoryShipmentItems().add(newRecord);
                                            newISItem = currentVM.tblICInventoryShipmentItems().findRecord('intLineNo', newRecord.intLineNo);
                                            me.getBundleComponents(newISItem, order, currentVM, currentVM.tblICInventoryShipmentItems());
                                        }
                                        else if(strBundleType == 'Option'){
                                            me.getBundleComponents(newISItem, order, currentVM, currentVM.tblICInventoryShipmentItems());
                                        }    
                                        else {
                                            currentVM.tblICInventoryShipmentItems().add(newRecord);
                                            newISItem = currentVM.tblICInventoryShipmentItems().findRecord('intLineNo', newRecord.intLineNo);
                                        }                                        
                                    }        
                                
                                    if (OrderType === 'Sales Contract' && isValidToAdd) {
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
                                                            vm.set('chargesLinkInc', 1);
                                                            Ext.each(contractCosts, function (otherCharge) {
                                                                var shipmentCharges = currentVM.tblICInventoryShipmentCharges().data.items;
                                                                var exists = Ext.Array.findBy(shipmentCharges, function (row) {
                                                                    if ((row.get('intContractId') === order.get('intOrderId')
                                                                        && row.get('intChargeId') === otherCharge.intItemId)) {
                                                                        return true;
                                                                    }
                                                                });
            
                                                                if (!exists) {
                                                                    var chargesLink = 'CL-'.concat(vm.get('chargesLinkConst'));

                                                                    var newCost = Ext.create('Inventory.model.ShipmentCharge', {
                                                                        intInventoryReceiptId: currentVM.get('intInventoryShipmentId'),
                                                                        intContractId: order.get('intOrderId'),
                                                                        intContractDetailId: otherCharge.intContractDetailId,//order.get('intOrderId'),
                                                                        intChargeId: otherCharge.intItemId,
                                                                        strChargesLink: chargesLink,
                                                                        ysnInventoryCost: false,
                                                                        strCostMethod: otherCharge.strCostMethod,
                                                                        dblQuantity: otherCharge.strCostMethod == 'Amount' ? 1 : order.get('dblQtyToShip'),
                                                                        dblRate: otherCharge.strCostMethod == 'Amount' ? 0 : otherCharge.dblRate,
                                                                        intCostUOMId: otherCharge.intItemUOMId,
                                                                        intEntityVendorId: otherCharge.intVendorId,
                                                                        dblAmount: otherCharge.strCostMethod == 'Amount' ? otherCharge.dblRate : 0,
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

                                                                    newISItem.set('strChargesLink', chargesLink);
                                                                }
                                                            });
                                                            
                                                        }
                                                    });
                                                }
                                            }
                                        });    
                                    }
                                }

                                if(freightTermsError.length > 0){
                                    iRely.Functions.showCustomDialog(
                                        iRely.Functions.dialogType.WARNING,
                                        iRely.Functions.dialogButtonType.OK,
                                        'Unable to add orders. Only orders of the same freight terms can be shipped.',
                                        function(b) { }
                                    );                            
                                }  
                                                         
                        });
                    }
                }
            }
        });
    },

    onOrderTypeSelect: function(combo, records, eOpts) {
        if (!records || records.length <= 0)
            return;

        var win = combo.up('window');
        var current = win.viewModel.data.current;

        if (current){
            current.set('intShipToCompanyLocationId', null);
            current.set('intShipToLocationId', null);
            current.set('strShipToAddress', null);
            
            current.set('strShipToLocation', null);
            current.set('strShipToStreet', null);
            current.set('strShipToCity', null);
            current.set('strShipToState', null);
            current.set('strShipToZipPostalCode', null);
            current.set('strShipToCountry', null);

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

        var grdInventoryShipment = win.down('#grdInventoryShipment');
        var grdInventoryShipmentCount = 0;
        var origShipFromLocation = current.get('strShipFromLocation');
        var origShipFromLocationId = current.get('intShipFromLocationId');
        var newShipFromLocationId =  record.get('intCompanyLocationId');

        if (current.tblICInventoryShipmentItems()) {
            Ext.Array.each(current.tblICInventoryShipmentItems().data.items, function(row) {
                if (!row.dummy) {
                    grdInventoryShipmentCount++;
                }
                if (grdInventoryShipmentCount > 0){
                    return false;                 
                }                    
            });
        }
        
        if(origShipFromLocationId !== newShipFromLocationId) {
            var buttonAction = function(button) {
                if (button === 'yes') {                      
                    //Remove all items in the Shipment Grid                   
                    var shipmentItems = current['tblICInventoryShipmentItems'](),
                        shipmentItemRecords = shipmentItems ? shipmentItems.getRange() : [];

                    var i = shipmentItemRecords.length - 1;
                    for (; i >= 0; i--) {
                        if (!shipmentItemRecords[i].dummy)
                            shipmentItems.removeAt(i);
                    }
                }
            };
                        
            if(grdInventoryShipmentCount > 0) {
                iRely.Functions.showCustomDialog('question', 'yesno', 'Changing Ship From location will clear all Items. Do you want to continue?', buttonAction);
            }
        }
    },

    onShipFromAddressBeforeQuery: function(queryPlan, eOpts){
        var combo = queryPlan.combo; 
        var win = combo.up('window');
        var current = win.viewModel.data.current;
        var grdInventoryShipment = win.down('#grdInventoryShipment');
        var grdInventoryShipmentCount = 0;

        if (current.tblICInventoryShipmentItems()) {
            Ext.Array.each(current.tblICInventoryShipmentItems().data.items, function(row) {
                if (!row.dummy) {
                    grdInventoryShipmentCount++;
                }
                if (grdInventoryShipmentCount > 0){
                    return false;                 
                }                    
            });
        }
                
        if(grdInventoryShipmentCount > 0) {
            var buttonAction = function(button) {
                if (button === 'yes') {                      
                    //Remove all items in the Shipment Grid                   
                    var shipmentItems = current['tblICInventoryShipmentItems'](),
                        shipmentItemRecords = shipmentItems ? shipmentItems.getRange() : [];

                    var i = shipmentItemRecords.length - 1;
                    for (; i >= 0; i--) {
                        if (!shipmentItemRecords[i].dummy)
                            shipmentItems.removeAt(i);
                    }
                    combo.focus();
                }
            };

            iRely.Functions.showCustomDialog('question', 'yesno', 'Changing Ship From location will clear all Items. Do you want to continue?', buttonAction);
            return false;
        }
    },

    doOtherChargeTaxCalculate: function (win) {
        if (!win) return; 

        var current = win.viewModel.data.current;
        var me = win.controller;
        var context = win.context;

        if (current) {
            var charges = current.tblICInventoryShipmentCharges();
            //var countCharges = charges.getRange().length;

            if (charges) {
                Ext.Array.each(charges.data.items, function (charge) {
                    var dblForexRate = charge.get('dblForexRate');
                    dblForexRate = Ext.isNumeric(dblForexRate) ? dblForexRate : 0;   

                    if (!charge.dummy) {
                        var computeItemTax = function (itemTaxes, me) {
                            var totalItemTax = 0.00,
                                taxGroupId = 0,
                                taxGroupName = null;

                            charge.tblICInventoryShipmentChargeTaxes().removeAll();
                            var unitMeasureId = charge.get('intCostUOMId');
                            Ext.Array.each(itemTaxes, function (itemDetailTax) {
                                var taxableAmount = charge.get('dblAmount');
                                var taxAmount = 0.00;
                                var chargeQuantity = charge.get('dblQuantity');
                                chargeQuantity = Ext.isNumeric(chargeQuantity) ? chargeQuantity : 1; 
                                var cost = taxableAmount / chargeQuantity;

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
                                if (!charge.get('ysnAccrue') && !charge.get('ysnPrice')){
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
                                    itemDetailTax.dblAdjustedTax = itemDetailTax.dblAdjustedTax;
                                    itemDetailTax.ysnTaxAdjusted = true;
                                }
                                totalItemTax = totalItemTax + itemDetailTax.dblAdjustedTax;
                                taxGroupId = itemDetailTax.intTaxGroupId;
                                taxGroupName = itemDetailTax.strTaxGroup;

                                var newItemTax = Ext.create('Inventory.model.ShipmentChargeTax', {
                                    intTaxGroupId: itemDetailTax.intTaxGroupId,
                                    intTaxCodeId: itemDetailTax.intTaxCodeId,
                                    intTaxClassId: itemDetailTax.intTaxClassId,
                                    strTaxCode: itemDetailTax.strTaxCode,
                                    strTaxableByOtherTaxes: itemDetailTax.strTaxableByOtherTaxes,
                                    strCalculationMethod: itemDetailTax.strCalculationMethod,
                                    dblRate: itemDetailTax.dblRate,
                                    dblTax: itemDetailTax.dblTax,
                                    intUnitMeasureId: unitMeasureId,
                                    dblAdjustedTax: itemDetailTax.dblAdjustedTax,
                                    intTaxAccountId: itemDetailTax.intTaxAccountId,
                                    ysnTaxAdjusted: itemDetailTax.ysnTaxAdjusted,
                                    ysnCheckoffTax: itemDetailTax.ysnCheckoffTax,
                                    ysnTaxOnly: itemDetailTax.ysnTaxOnly,
                                    dblQty: chargeQuantity,
                                    dblCost: cost

                                });
                                charge.tblICInventoryShipmentChargeTaxes().add(newItemTax);
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
                         //valEntityId = valEntityId ? valEntityId : current.get('intEntityVendorId');

                         valTaxGroupId = charge.get('intTaxGroupId');
                         
                         var currentCharge = {
                                ItemId: charge.get('intChargeId'),
                                TransactionDate: current.get('dtmShipDate'),
                                LocationId: current.get('intShipFromLocationId'),
                                TransactionType: 'Purchase',
                                TaxGroupId: valTaxGroupId,
                                EntityId: valEntityId,
                                BillShipToLocationId: null, //current.get('intShipToLocationId'),
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

    doOtherChargeCalculate: function (win) {
        if (!win) return; 

        var current = win.viewModel.data.current;
        var me = win.controller;
        var context = win.context;

        if (current) {
            ic.utils.ajax(
                {
                    timeout: 120000,
                    url: './Inventory/api/InventoryShipment/CalculateCharges',
                    params: {
                        id: current.get('intInventoryShipmentId')
                    },
                    method: 'POST'
                }
            )
            .subscribe(
                function (response) {
                    var jsonData = Ext.decode(response.responseText);
                    if (!jsonData.success) {
                        iRely.Functions.showErrorDialog(jsonData.message.statusText);
                    }
                    else {
                        // context.configuration.paging.store.load(
                        //     {
                        //         callback: function (records, options, success) {
                        //             me.doOtherChargeTaxCalculate(win);
                        //         }                            
                        //     }                            
                        // );

                        // Reload the other charges after computing it from the server. 
                        var tblICInventoryShipmentCharges = current._tblICInventoryShipmentCharges;                     
                        if (tblICInventoryShipmentCharges){
                            current._tblICInventoryShipmentCharges.load({
                                callback: function (records, options, success) {
                                    me.doOtherChargeTaxCalculate(win);
                                }                            
                            }); 
                        }                        
                    }
                },
                function (response) {
                    var jsonData = Ext.decode(response.responseText);
                    iRely.Functions.showErrorDialog(jsonData.ExceptionMessage);
                }
            );
        }
    },
    
    onCalculateChargeClick: function (button, e, eOpts) {
        var me = this; 
        var win = button.up('window');
        var context = win.context;
        var current = win.viewModel.data.current;

        // If there is no data change, do the post.
        if (!context.data.hasChanges()){
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
    
    onAccrueCheckChange: function (obj, rowIndex, checked, eOpts) {
        if (obj.dataIndex === 'ysnAccrue') {
            var grid = obj.up('grid');
            var win = obj.up('window');
            var current = grid.view.getRecord(rowIndex);

            if (checked === false) {
                current.set('intEntityVendorId', null);
                current.set('strVendorName', null);
                current.set('dblTax', null);
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
                    },
                    {
                        column: 'ysnIssueUOMAllowSale',
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

    onPostClick: function(btnPost, e, eOpts) {
        if (btnPost){
            btnPost.disable();
        }
        else {
            return;
        }

        var me = this;
        var win = btnPost.up('window');
        var context = win.context;
        var currentRecord = win.viewModel.data.current;
        var tabInventoryShipment = win.down('#tabInventoryShipment');
        var activeTab = tabInventoryShipment.getActiveTab();       

        var doPost = function (){
            var current = currentRecord; 
            ic.utils.ajax({
                url: './Inventory/api/InventoryShipment/Ship',
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
                    btnPost.enable();
                    iRely.Functions.refreshFloatingSearch('Inventory.view.InventoryShipment');
                }
                ,function(failureResponse) {
                    var responseText = Ext.decode(failureResponse.responseText);
                    var message = responseText ? responseText.message : {}; 
                    var statusText = message ? message.statusText : 'Oh no! Something went wrong while posting the shipment.';

                    me.onAfterShip(false, statusText);
                    btnPost.enable();
                }
            )
        };    

        // Save any unsaved data first before doing the post. 
        if (context.data.hasChanges()) {
            context.data.validator.validateRecord(context.data.configuration, function(valid) {
                // If records are valid, continue with the save. 
                if (valid){
                    context.data.saveRecord({
                        successFn: function () {
                            doPost();             
                        }
                    });
                }
                // If records are invalid, re-enable the post button. 
                else {
                    btnPost.enable();
                }
            });            
        }
        else {
            doPost();
        }

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

                me.calculateLinkedItems(currentHeader, currentItem);
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
    //             url: './i21/api/companylocation/search'
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
                url: './Inventory/api/InventoryShipment/Ship',
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
                
        var ShipmentChargeId = current.get('intInventoryShipmentChargeId');
        var ShipmentId = current.get('intInventoryShipmentId');

        var showChargeTaxScreen = function () {
            iRely.Functions.openScreen('GlobalComponentEngine.view.FloatingSearch', {
                searchSettings: {
                    scope: me,
                    type: 'Inventory.Shipment.ChargesTaxDetails',
                    url: './inventory/api/inventoryShipment/getchargetaxdetails?ShipmentChargeId=' + ShipmentChargeId + '&ShipmentId=' + ShipmentId,
                    columns: [
                        //{ itemId: 'colKey', dataIndex: 'intKey', text: "Key", flex: 1, dataType: 'numeric', key: true, hidden: true },
                        { itemId: 'colInventoryShipmentChargeTaxId', dataIndex: 'intInventoryShipmentChargeTaxId', text: "Shipment Charge Tax Id", flex: 1, dataType: 'numeric', key: true, hidden: true },
                        { itemId: 'colChargeId', dataIndex: 'intChargeId', text: "Charge Id", flex: 1, dataType: 'numeric', key: true, hidden: true },
                        { itemId: 'colItemNo', dataIndex: 'strItemNo', text: 'Other Charges', width: 100, dataType: 'string'},
                        { itemId: 'colTaxGroup', dataIndex: 'strTaxGroup', text: 'Tax Group', width: 85, dataType: 'string' },
                        { itemId: 'colTaxClass', dataIndex: 'strTaxClass', text: 'Tax Class', width: 100, dataType: 'string' },
                        { itemId: 'colTaxCode', dataIndex: 'strTaxCode', text: 'Tax Code', width: 100, dataType: 'string' },
                        { itemId: 'colCalculationMethod', dataIndex: 'strCalculationMethod', text: 'Calculation Method', width: 110, dataType: 'string' },                                
                        { itemId: 'colUnitMeasureId', dataIndex: 'intUnitMeasureId', text: 'Unit Measure Id', dataType: 'numeric', hidden: true },
                        { itemId: 'colUnitMeasure', dataIndex: 'strUnitMeasure', text: 'Unit Measure', dataType: 'string' },                 
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

    calculateLinkedItems: function(current, activeRecord){
        var parentLinkId = activeRecord.get('intParentItemLinkId'),
            itemDetailStore = current.tblICInventoryShipmentItems(),
            linkType = activeRecord.get('strItemType'),
            searchURL;

        if(!Ext.isNumber(parentLinkId) || linkType.charAt(0) == 'O' || linkType.charAt(0) == 'S')
            return;
        
        var itemId = activeRecord.get('intItemId'),
            itemUOMId = activeRecord.get('intItemUOMId'),
            locationId = current.get('intShipFromLocationId'),
            quantity = activeRecord.get('dblQuantity');

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
                        return x.get('intItemId') == rec.intComponentItemId &&  x.get('intItemUOMId') == rec.intComponentUOMId && x.get('intChildItemLinkId') == parentLinkId && !x.dummy;
                    });

                    if(childRecord){
                        var dblQty = 0;
                        switch(linkType.charAt(0)){
                            case 'K': dblQty = rec.dblBundleComponentQty; break;
                            case 'A': dblQty = rec.dblAddOnComponentQty; break;
                            case 'S': dblQty = rec.dblSubstituteComponentQty; break;
                            default: dblQty = 0; break;

                        }
                        childRecord.set('dblQuantity', dblQty);
                        childRecord.set('dblLineTotal', dblQty * childRecord.get('dblUnitPrice'));
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
            bundleType = selectedItem.get('strBundleType'),
            screenTitle = bundleType + ' - ' + selectedItem.get('strItemNo'),
            locationId = current.get('intShipFromLocationId'),
            bundleItemId = selectedItem.get('intItemId'),
            itemUOMId = selectedItem.get('intOrderUOMId'),
            orderQty = selectedItem.get('dblQtyToShip');

        var searchURL = './inventory/api/itembundle/getbundlecomponents?intItemId=' + bundleItemId + '&intItemUOMId=' + itemUOMId 
            + '&intLocationId=' + locationId + '&dblQuantity=' + orderQty;
        
        if(bundleType == 'Kit') {

            ic.utils.ajax({
                url: searchURL,
                method: 'get'
            }).subscribe(
                function(successResponse){
                    var result = Ext.decode(successResponse.responseText);
                    addedRecord.set('strItemType', 'Kit');

                    Ext.Array.forEach(result.data, function(rec) {
                        var componentQty = rec.dblBundleComponentQty;
                        var itemCost = rec.dblSalePrice;
                        
                        var itemModel = Ext.create(itemDetailStore.role.type, {
                                intInventoryShipmentId: current.get('intInventoryShipmentId'),
                                intChildItemLinkId: addedRecord.get('intInventoryShipmentItemId'),
                                strItemType: bundleType + ' Item',
                                // intLineNo: selectedItem.get('intLineNo'),
                                // intOrderId: selectedItem.get('intOrderId'),
                                // intSourceId: selectedItem.get('intSourceId'),
                                // strOrderNumber: selectedItem.get('strOrderNumber'),
                                // strSourceNumber: selectedItem:.get('strSourceNumber'),
                                dblQuantity: componentQty,
                                intItemId: rec.intComponentItemId,
                                strItemNo: rec.strComponentItemNo,
                                strItemDescription: rec.strComponentDescription,
                                //dblQtyOrdered: componentQty,
                                dblUnitPrice: 0,//itemCost,
                                dblLineTotal: 0,//componentQty * itemCost,
                                strLotTracking: rec.strLotTracking,
                                intSubLocationId: selectedItem.get('intSubLocationId'),
                                strSubLocationName: selectedItem.get('strSubLocationName'),
                                intStorageLocationId: selectedItem.get('intStorageLocationId'),
                                strStorageLocationName: selectedItem.get('strStorageLocationName'),
                                //strOrderUOM: selectedItem.get('strOrderUOM'),
                                intItemUOMId: rec.intComponentUOMId,
                                strUnitMeasure: rec.strComponentUOM,
                                strWeightUOM: rec.strComponentUOM,
                                intWeightUOMId: rec.intComponentItemId,
                                dblItemUOMConv: rec.dblComponentConvFactor,
                                dblWeightItemUOMConv: rec.dblComponentConvFactor,
                                intDestinationGradeId: selectedItem.get('intDestinationGradeId'),
                                strDestinationGrades: selectedItem.get('strDestinationGrades'),
                                intDestinationWeightId: selectedItem.get('intDestinationWeightId'),
                                strDestinationWeights: selectedItem.get('strDestinationWeights'),
                                intGradeId: rec.intGradeId,
                                strGrade: rec.strGrade,
                                strOwnershipType: 'Own',
                                intOwnershipType: 1,
                                intCommodityId: rec.intCommodityId,
                                intForexRateTypeId: selectedItem.get('intForexRateTypeId'),
                                strForexRateType: selectedItem.get('strForexRateType'),
                                dblForexRate: selectedItem.get('dblForexRate')
                        });

                        itemDetailStore.add(itemModel);
                        
                        addedRecord.set('intParentItemLinkId', addedRecord.get('intInventoryShipmentItemId'));
                    });
                },
                function (failureResponse) {
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
                            { dataIndex: 'intItemBundleId', text: 'Key', dataType: 'numeric', key: true, hidden: true },
                            { dataIndex: 'intComponentItemId', text: '', dataType: 'numeric', hidden: true, required: true },
                            { dataIndex: 'strComponentItemNo', text: 'Item No', width: 100, dataType: 'string' },
                            { dataIndex: 'strComponentDescription', text: 'Item Description', width: 100, dataType: 'string' },
                            { xtype: 'numbercolumn', dataIndex: 'dblComponentQuantity', text: 'Component Quantity', width: 100, dataType: 'float' },
                            { xtype: 'numbercolumn', dataIndex: 'dblMarkUpOrDown', text: 'Mark Up/Down', width: 100, dataType: 'float' },
                            { dataIndex: 'dtmBeginDate', text: 'Begin Date', width: 100, dataType: 'date', required: true, xtype: 'datecolumn' },
                            { dataIndex: 'dtmEndDate', text: 'End Date', width: 100, dataType: 'date', required: true, xtype: 'datecolumn' },
                            
                            { dataIndex: 'intComponentUOMId', text: 'Component UOM Id', dataType: 'numeric', hidden: true, required: true },
                            { dataIndex: 'strComponentUOM', text: 'Item UOM', width: 100, dataType: 'string' },
                            { dataIndex: 'strComponentUOMType', text: 'Item UOM Type', width: 100, dataType: 'string' },
                            { xtype: 'numbercolumn', dataIndex: 'dblComponentConvFactor', text: 'Component UOM Conversion Factor', width: 100, dataType: 'float', hidden: true, required: true },

                            { dataIndex: 'strLotTracking', text: 'Lot Tracking', width: 100, dataType: 'string' },
                            { dataIndex: 'intCommodityId', text: 'Commodity Id', dataType: 'numeric', hidden: true, required: true, allowNull: true },
                            { dataIndex: 'intContainerId', text: 'Container Id', dataType: 'numeric', hidden: true, required: true, allowNull: true },
                            { dataIndex: 'strContainer', text: 'Container', width: 100, dataType: 'string', required: true },
                            { dataIndex: 'intSubLocationId', text: 'Storage Location Id', dataType: 'numeric', hidden: true, required: true, allowNull: true },
                            { dataIndex: 'strSubLocationName', text: 'Storage Location', width: 100, dataType: 'string', required: true },
                            { dataIndex: 'intStorageLocationId', text: 'Storage Unit Id', dataType: 'numeric', hidden: true, required: true, allowNull: true },
                            { dataIndex: 'strStorageLocationName', text: 'Storage Unit', width: 100, dataType: 'string', required: true },

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
                                var componentQty = selectedItem.get('dblQtyToShip'),
                                    markUpOrDownCost = 0;

                                if(rec.get('dtmBeginDate') && rec.get('dtmBeginDate') && 
                                    (Ext.Date.between(current.get('dtmShipDate'), rec.get('dtmBeginDate'), rec.get('dtmEndDate'))))
                                    markUpOrDownCost = rec.get('dblMarkUpOrDown');
                                
                                var itemCost = (selectedItem.get('dblPrice') + markUpOrDownCost)
                                    * (selectedItem.get('intCostUOMId') ? selectedItem.get('dblCostUOMConvFactor') : selectedItem.get('dblOrderUOMConvFactor'));
                                    
                                    var itemModel = Ext.create(itemDetailStore.role.type, {
                                        intInventoryShipmentId: current.get('intInventoryShipmentId'),
                                        strItemType: 'Option',
                                        intParentItemLinkId: rec.get('intItemBundleId'),
                                        intLineNo: selectedItem.get('intLineNo'),
                                        intOrderId: selectedItem.get('intOrderId'),
                                        intSourceId: selectedItem.get('intSourceId'),
                                        strOrderNumber: selectedItem.get('strOrderNumber'),
                                        strSourceNumber: selectedItem.get('strSourceNumber'),
                                        dblQuantity: componentQty,
                                        intItemId: rec.get('intComponentItemId'),
                                        strItemNo: rec.get('strComponentItemNo'),
                                        strItemDescription: rec.get('strComponentDescription'),
                                        dblQtyOrdered: componentQty,
                                        dblUnitPrice: itemCost,
                                        dblLineTotal: itemCost * componentQty,
                                        strLotTracking: rec.get('strLotTracking'),
                                        intSubLocationId: selectedItem.get('intSubLocationId'),
                                        strSubLocationName: selectedItem.get('strSubLocationName'),
                                        intStorageLocationId: selectedItem.get('intStorageLocationId'),
                                        strStorageLocationName: selectedItem.get('strStorageLocationName'),
                                        intItemUOMId: rec.get('intComponentUOMId'),
                                        strUnitMeasure: rec.get('strComponentUOM'),
                                        strOrderUOM: selectedItem.get('strOrderUOM'),
                                        strWeightUOM: rec.get('strComponentUOM'),
                                        intWeightUOMId: rec.get('intComponentUOMId'),
                                        dblItemUOMConv: rec.get('dblComponentConvFactor'),
                                        dblWeightItemUOMConv: rec.get('dblComponentConvFactor'),
                                        intDestinationGradeId: selectedItem.get('intDestinationGradeId'),
                                        strDestinationGrades: selectedItem.get('strDestinationGrades'),
                                        intDestinationWeightId: selectedItem.get('intDestinationWeightId'),
                                        strDestinationWeights: selectedItem.get('strDestinationWeights'),
                                        intGradeId: rec.get('intGradeId'),
                                        strGrade: rec.get('strGrade'),
                                        strOwnershipType: 'Own',
                                        intOwnershipType: 1,
                                        intCommodityId: rec.get('intCommodityId'),
                                        intForexRateTypeId: selectedItem.get('intForexRateTypeId'),
                                        strForexRateType: selectedItem.get('strForexRateType'),
                                        dblForexRate: selectedItem.get('dblForexRate')
                                });
                                
                                var newItem = itemDetailStore.add(itemModel);
                                newItem = newItem[0];

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
            locationId = current.get('intShipFromLocationId'),
            itemAddOnId = selectedItem.get('intItemId'),
            itemUOMId = selectedItem.get('intIssueUOMId');

        var intRateType = i21.ModuleMgr.SystemManager.getCompanyPreference('intInventoryRateTypeId');

        // Get the functional currency:
        var functionalCurrencyId = i21.ModuleMgr.SystemManager.getCompanyPreference('intDefaultCurrencyId');  

        var transactionCurrencyId = current.get('intCurrencyId');
        var customerId = current.get('intEntityCustomerId');            
        var shipFromLocationId = current.get('intShipFromLocationId');
        var shipToLocationId = current.get('intShipToLocationId');            
        var dtmShipDate = current.get('dtmShipDate');

        // Get the customer cost from the hierarchy.  
        var customerPriceCfg = {
            ItemId: null,
            CustomerId: customerId,
            CurrencyId: transactionCurrencyId,
            LocationId: shipFromLocationId,
            TransactionDate: dtmShipDate,
            Quantity: 0,
            ShipToLocationId: shipToLocationId,
            ItemUOMId: null
        };

        var processForexRateOnSuccess = function(successResponse, isItemRetailPrice, currentItem){
            if (successResponse && successResponse.length > 0 ){
                var dblForexRate = successResponse[0].dblRate;
                var strRateType = successResponse[0].strRateType;             
                var dblUnitPrice = currentItem.get('dblUnitPrice')
                dblForexRate = Ext.isNumeric(dblForexRate) ? dblForexRate : 0;                       

                // Convert the sales price to the transaction currency.
                // and round it to six decimal places.  
                if (transactionCurrencyId != functionalCurrencyId && isItemRetailPrice){
                    dblUnitPrice = dblForexRate != 0 ?  dblUnitPrice / dblForexRate : 0;
                    dblUnitPrice = i21.ModuleMgr.Inventory.roundDecimalFormat(dblUnitPrice, 6);
                }
                
                currentItem.set('intForexRateTypeId', intRateType);
                currentItem.set('strForexRateType', strRateType);
                currentItem.set('dblForexRate', dblForexRate);
                currentItem.set('dblUnitPrice', dblUnitPrice);                                 
            }
        }            

        var processCustomerPriceOnSuccess = function(successResponse, currentItem){
            var jsonData = Ext.decode(successResponse.responseText);
            var isItemRetailPrice = true;                

            // If there is a customer cost, replace dblUnitPrice with the customer sales price. 
            var itemPricing = jsonData ? jsonData.itemPricing : null;
            if (itemPricing) {
                var dblUnitPrice = itemPricing.dblPrice; 
                currentItem.set('dblUnitPrice', dblUnitPrice);

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
                        iRely.Functions.showErrorDialog('Something went wrong while getting the forex data.');
                    }
                );                      
            }

        };

        var processCustomerPriceOnFailure = function(failureResponse){
            var jsonData = Ext.decode(failureResponse.responseText);
            iRely.Functions.showErrorDialog('Something went wrong while getting the item price from the customer pricing hierarchy.');
        };   
        
        ic.utils.ajax({
            url: './inventory/api/itemaddon/getitemaddons?intItemId=' + itemAddOnId + '&intItemUOMId=' + itemUOMId 
                + '&intLocationId=' + locationId + '&dblQuantity=1',
            method: 'get'
        }).subscribe(
            function (successResponse) {
                var result = Ext.decode(successResponse.responseText);
                if(current && itemDetailStore && result.data.length > 0){
                    editingRecord.set('intParentItemLinkId', editingRecord.get('intInventoryShipmentItemId'));
                    editingRecord.set('strItemType', 'Add-On');
                    editingRecord.set('dblQuantity', 1);
                    win.down('#colItemNumber').focus();

                    var recordIdx = itemDetailStore.findBy(function(rec){
                        return rec.id == editingRecord.id;
                    });

                    Ext.Array.forEach(result.data, function(rec, idx){
      
                        var itemDetail = Ext.create(itemDetailStore.role.type, {
                                intInventoryShipmentId: current.get('intInventoryShipmentId'),
                                strItemType: 'Add-On Item',
                                intChildItemLinkId: editingRecord.get('intInventoryShipmentItemId'),
                                dblComponentQty: rec.dblAddOnComponentQty,
                                dblQuantity: rec.dblAddOnComponentQty,
                                intItemId: rec.intComponentItemId,
                                strItemNo: rec.strComponentItemNo,
                                strItemDescription: rec.strComponentDescription,
                                intItemUOMId: rec.intComponentUOMId,
                                strUnitMeasure: rec.strComponentUOM,
                                dblItemUOMConvFactor: rec.dblComponentConvFactor,
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

                        customerPriceCfg.ItemId = rec.intItemId;
                        customerPriceCfg.Quantity = rec.dblAddOnComponentQty; 
                        customerPriceCfg.ItemUOMId = rec.intAddOnItemUOMId;
                        
                        me.getItemSalesPrice(customerPriceCfg, processCustomerPriceOnSuccess, processCustomerPriceOnFailure, itemDetail);
                    });
                }


            },function (failureResponse) {
                var jsonData = Ext.decode(failureResponse.responseText);
                
                iRely.Functions.showErrorDialog('Something went wrong while getting the Add On Items.');
            }
        );
    },

    getItemSubstitutes: function(editingRecord, selectedItem, current, itemDetailStore){
        var me = this,
            win = me.getView(),
            bundleType = selectedItem.get('strBundleType'),
            locationId = current.get('intShipFromLocationId'),
            itemSubstituteId = selectedItem.get('intItemId'),
            itemUOMId = selectedItem.get('intIssueUOMId');

        var intRateType = i21.ModuleMgr.SystemManager.getCompanyPreference('intInventoryRateTypeId');

        // Get the functional currency:
        var functionalCurrencyId = i21.ModuleMgr.SystemManager.getCompanyPreference('intDefaultCurrencyId');  

        var transactionCurrencyId = current.get('intCurrencyId');
        var customerId = current.get('intEntityCustomerId');            
        var shipFromLocationId = current.get('intShipFromLocationId');
        var shipToLocationId = current.get('intShipToLocationId');            
        var dtmShipDate = current.get('dtmShipDate');

        // Get the customer cost from the hierarchy.  
        var customerPriceCfg = {
            ItemId: null,
            CustomerId: customerId,
            CurrencyId: transactionCurrencyId,
            LocationId: shipFromLocationId,
            TransactionDate: dtmShipDate,
            Quantity: 0,
            ShipToLocationId: shipToLocationId,
            ItemUOMId: null
        };

        var processForexRateOnSuccess = function(successResponse, isItemRetailPrice, currentItem){
            if (successResponse && successResponse.length > 0 ){
                var dblForexRate = successResponse[0].dblRate;
                var strRateType = successResponse[0].strRateType;             
                var dblUnitPrice = currentItem.get('dblUnitPrice')
                dblForexRate = Ext.isNumeric(dblForexRate) ? dblForexRate : 0;                       

                // Convert the sales price to the transaction currency.
                // and round it to six decimal places.  
                if (transactionCurrencyId != functionalCurrencyId && isItemRetailPrice){
                    dblUnitPrice = dblForexRate != 0 ?  dblUnitPrice / dblForexRate : 0;
                    dblUnitPrice = i21.ModuleMgr.Inventory.roundDecimalFormat(dblUnitPrice, 6);
                }
                
                currentItem.set('intForexRateTypeId', intRateType);
                currentItem.set('strForexRateType', strRateType);
                currentItem.set('dblForexRate', dblForexRate);
                currentItem.set('dblUnitPrice', dblUnitPrice);                                 
            }
        }            

        var processCustomerPriceOnSuccess = function(successResponse, currentItem){
            var jsonData = Ext.decode(successResponse.responseText);
            var isItemRetailPrice = true;                

            // If there is a customer cost, replace dblUnitPrice with the customer sales price. 
            var itemPricing = jsonData ? jsonData.itemPricing : null;
            if (itemPricing) {
                var dblUnitPrice = itemPricing.dblPrice; 
                currentItem.set('dblUnitPrice', dblUnitPrice);

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
                        iRely.Functions.showErrorDialog('Something went wrong while getting the forex data.');
                    }
                );                      
            }

        };

        var processCustomerPriceOnFailure = function(failureResponse){
            var jsonData = Ext.decode(failureResponse.responseText);
            iRely.Functions.showErrorDialog('Something went wrong while getting the item price from the customer pricing hierarchy.');
        };   
        
        ic.utils.ajax({
            url: './inventory/api/itemsubstitute/getitemsubstitutes?intItemId=' + itemSubstituteId + '&intItemUOMId=' + itemUOMId 
                + '&intLocationId=' + locationId + '&dblQuantity=1',
            method: 'get'
        }).subscribe(
            function (successResponse) {
                var result = Ext.decode(successResponse.responseText);
                if(current && itemDetailStore && result.data.length > 0) {
                    editingRecord.set('intParentItemLinkId', editingRecord.get('intInventoryShipmentItemId'));
                    editingRecord.set('strItemType', 'Substitute');
                    editingRecord.set('dblQuantity', 1);
                    win.down('#colItemNumber').focus();

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
                                dblQuantity: rec.dblSubstituteComponentQty,
                                intItemId: rec.intComponentItemId,
                                strItemNo: rec.strComponentItemNo,
                                strItemDescription: rec.strComponentDescription,
                                intItemUOMId: rec.intComponentUOMId,
                                strUnitMeasure: rec.strComponentUOM,
                                dblItemUOMConvFactor: rec.dblComponentConvFactor,
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

                        customerPriceCfg.ItemId = rec.intItemId;
                        customerPriceCfg.Quantity = rec.dblSubstituteComponentQty; 
                        customerPriceCfg.ItemUOMId = rec.intSubstituteItemUOMId;
                        
                        me.getItemSalesPrice(customerPriceCfg, processCustomerPriceOnSuccess, processCustomerPriceOnFailure, itemDetail);
                    });
                }


            },function (failureResponse) {
                var jsonData = Ext.decode(failureResponse.responseText);
                
                iRely.Functions.showErrorDialog('Something went wrong while getting the Substitute Items.');
            }
        );
    },

    onShipViaSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var record = records[0];
        if (!record)
            return; 

        var win = combo.up('window');
        var current = win.viewModel.data.current;
        
        if (current){
            current.set('intShipViaId', record.get('intEntityId'));
        }
    },    

    init: function(application) {
        this.control({
            "#cboShipFromAddress":{
                beforequery: this.onShipFromAddressBeforeQuery,
                select: this.onShipLocationSelect
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
            "#cboCostMethod": {
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
            },
            "#cboCostVendor": {
                select: this.onChargeSelect
            },
            "#cboChargeTaxGroup": {
                select: this.onChargeSelect
            },
            "#btnChargeTaxDetails": {
                click: this.onChargeTaxDetailsClick
            },
            "#cboShipVia": {
                select: this.onShipViaSelect
            }
        })
    }

});
