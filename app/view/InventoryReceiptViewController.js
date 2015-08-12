Ext.define('Inventory.view.InventoryReceiptViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.icinventoryreceipt',

    config: {
        searchConfig: {
            title: 'Search Inventory Receipt',
            type: 'Inventory.InventoryReceipt',
            api: {
                read: '../Inventory/api/InventoryReceipt/Search'
            },
            columns: [
                {dataIndex: 'intInventoryReceiptId', text: "Receipt Id", flex: 1, defaultSort: true, sortOrder: 'DESC', dataType: 'numeric', key: true, hidden: true},
                {dataIndex: 'strReceiptNumber', text: 'Receipt No', flex: 1, dataType: 'string'},
                {dataIndex: 'dtmReceiptDate', text: 'Receipt Date', flex: 1, dataType: 'date', xtype: 'datecolumn'},
                {dataIndex: 'strReceiptType', text: 'Receipt Type', flex: 1, dataType: 'string'},
                {dataIndex: 'strVendorName', text: 'Vendor Name', flex: 1, dataType: 'string'},
                {dataIndex: 'strLocationName', text: 'Location Name', flex: 1, dataType: 'string'},
                {dataIndex: 'ysnPosted', text: 'Posted', flex: 1, dataType: 'boolean', xtype: 'checkcolumn'}
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
                text: '{getReceiveButtonText}'
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
                hidden: '{checkHiddenInTransferReceipt}'
            },
            txtVendorName: {
                value: '{current.strVendorName}',
                hidden: '{checkHiddenInTransferReceipt}'
            },
            cboTransferor: {
                value: '{current.intTransferorId}',
                store: '{transferor}',
                hidden: '{checkHiddenIfNotTransferReceipt}'
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
                        value: '{current.intVendorEntityId}'
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
            cboAllocateFreight: {
                value: '{current.strAllocateFreight}',
                store: '{allocateFreights}',
                readOnly: '{current.ysnPosted}'
            },
            txtShiftNumber: {
                value: '{current.intShiftNumber}',
                readOnly: '{current.ysnPosted}'
            },
            txtNotes: {
                value: '{current.strNotes}',
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
            btnBill: {
                hidden: '{!current.ysnPosted}'
            },
            btnQuality: {
                hidden: '{current.ysnPosted}'
            },

            grdInventoryReceipt: {
                readOnly: '{current.ysnPosted}',
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
                colOrderUOM: {
                    hidden: '{checkHideOrderNo}',
                    dataIndex: 'strOrderUOM'
                },
                colQtyOrdered: {
                    hidden: '{checkHideOrderNo}',
                    dataIndex: 'dblOrderQty'
                },
                colReceived: {
                    hidden: '{checkHideOrderNo}',
                    dataIndex: 'dblReceived'
                },
                colQtyToReceive: 'dblOpenReceive',
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
                        readOnly: '{readOnlyWeightDropdown}',
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
                colTax: {
                    dataIndex: 'dblTax'
                },
                colUnitRetail: 'dblUnitRetail',
                colGross: 'dblGross',
                colNet: 'dblNet',
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
                colLotGrossWeight: 'dblGrossWeight',
                colLotTareWeight: 'dblTareWeight',
                colLotNetWeight: 'dblNetWeight',
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
                    dataIndex: 'strParentLotId',
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
                    dataIndex: 'strVendorLocation',
                    editor: {
                        origValueField: 'intEntityLocationId',
                        origUpdateField: 'intVendorLocationId',
                        store: '{vendorLocation}',
                        defaultFilters: [
                            {
                                column: 'intEntityId',
                                value: '{current.intVendorEntityId}'
                            }
                        ]
                    }
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
                    dataIndex: 'intContractNumber',
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
                colInventoryCost: 'ysnInventoryCost',
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
                    dataIndex: 'strVendorId',
                    editor: {
                        readOnly: '{readOnlyCostBilledBy}',
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
                colCostBilledBy: {
                    dataIndex: 'strCostBilledBy',
                    editor: {
                        store: '{billedBy}'
                    }
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

    setupContext : function(options){
        "use strict";
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.Receipt', { pageSize: 1, window : options.window });

        var grdInventoryReceipt = win.down('#grdInventoryReceipt'),
            grdIncomingInspection = win.down('#grdIncomingInspection'),
            grdLotTracking = win.down('#grdLotTracking'),
            grdCharges = win.down('#grdCharges');

        win.context = Ext.create('iRely.mvvm.Engine', {
            window : win,
            store  : store,
            createRecord : me.createRecord,
            validateRecord: me.validateRecord,
            binding: me.config.binding,
            enableComment: true,
            include: 'tblICInventoryReceiptInspections,' +
                'vyuAPVendor,' +
                'tblSMFreightTerm,' +
                'tblSMCompanyLocation,' +
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
                        deleteButton : grdInventoryReceipt.down('#btnRemoveInventoryReceipt')
                    }),
                    details: [
                        {
                            key: 'tblICInventoryReceiptItemLots',
                            component: Ext.create('iRely.mvvm.grid.Manager', {
                                grid: grdLotTracking,
                                deleteButton : grdLotTracking.down('#btnRemoveLot'),
                                createRecord : me.onLotCreateRecord
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
                        deleteButton : grdCharges.down('#btnRemoveCharge')
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
        if (cepItemLots){
            cepItemLots.on({
                validateedit: me.onEditLots,
                scope: me
            });
        }

        var cepItem = grdInventoryReceipt.getPlugin('cepItem');
        if (cepItem){
            cepItem.on({
                validateedit: me.onEditItem,
                scope: me
            });
        }

        var colTaxDetails = grdInventoryReceipt.columns[23];
        var btnViewTaxDetail = colTaxDetails.items[0];
        if (btnViewTaxDetail){
            btnViewTaxDetail.handler = function(grid, rowIndex, colIndex) {
                var current = grid.store.data.items[rowIndex];
                me.onViewTaxDetailsClick(current.get('intInventoryReceiptItemId'));
            }
        }

        var colTax = grdInventoryReceipt.columns[10];
        if (colTax){
            colTax.summaryRenderer = function(val, params, data) {
                return Ext.util.Format.number(val, '0,000.00');
            }
        }

        var colGross = grdInventoryReceipt.columns[13];
        if (colGross){
            colGross.summaryRenderer = function(val, params, data) {
                var win = me.getView();
                var current = win.viewModel.data.current;

                var value = me.calculateCharges(current);
                var finalValue = Ext.util.Format.number(value, '0,000.00');

                return 'Total Charges: ' + finalValue + '';
            }
        }
        var colNet = grdInventoryReceipt.columns[14];
        if (colNet){
            colNet.summaryRenderer = function(val, params, data) {
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
        if (txtReceived){
            txtReceived.on('change', me.onCalculateTotalAmount);
        }
        var colUnitCost = grdInventoryReceipt.columns[7];
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
        record.set('strReceiptType', 'Purchase Order');
        record.set('intSourceType', 0);
        if (app.DefaultLocation > 0)
            record.set('intLocationId', app.DefaultLocation);
        if (app.UserId > 0)
            record.set('intReceiverId', app.UserId);
        record.set('dtmReceiptDate', today);
        record.set('intBlanketRelease', 0);
        record.set('ysnPosted', false);
        action(record);
    },

    onLotCreateRecord: function(config, action) {
        var win = config.grid.up('window');
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

        var total = (lotCF * qty) * weightCF;
        record.set('dblGrossWeight', total);
        var tare = config.dummy.get('dblTareWeight');
        var netTotal = total - tare;
        record.set('dblNetWeight', netTotal);

        action(record);
    },

    validateRecord: function(config, action) {
        this.validateRecord(config, function(result) {
            if (result) {
                var vm = config.window.viewModel;
                var current = vm.data.current;

                if (current) {
                    //Validate PO Date versus Receipt Date
                    if (current.get('strReceiptType') === 'Purchase Order') {
                        var grdInventoryReceipt = config.window.down('#grdInventoryReceipt');
                        var receiptItems = current.tblICInventoryReceiptItems().data.items;
                        Ext.Array.each(receiptItems, function(item) {
                            if (item.dtmDate !== null) {
                                if (current.get('dtmReceiptDate') < item.get('dtmOrderDate')) {
                                    iRely.Functions.showErrorDialog('The Purchase Order Date of ' + item.get('strOrderNumber') + ' must not be later than the Receipt Date');
                                    action(false);
                                }
                            }
                        });
                    }

                    //Validate Logged in User's default location against the selected Location for the receipt
                    if (current.get('strReceiptType') !== 'Direct') {
                        if (app.DefaultLocation > 0) {
                            if (app.DefaultLocation !== current.get('intLocationId')) {
                                var result = function(button) {
                                    if (button === 'yes') {
                                        action(true);
                                    }
                                    else {
                                        action(false);
                                    }
                                };
                                var msgBox = iRely.Functions;
                                msgBox.showCustomDialog(
                                    msgBox.dialogType.WARNING,
                                    msgBox.dialogButtonType.YESNO,
                                    "The Location is different from the default user location. Do you want to continue?",
                                    result
                                );
                            }
                            else { action(true) }
                        }
                        else { action(true) }
                    }
                    else { action(true) }
                }
                else { action(true) }
            }
        });
    },

    onVendorSelect: function(combo, records, eOpts) {
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
            }
        }
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
        var grid = combo.up('grid');
        var grdLotTracking = win.down('#grdLotTracking');
        var plugin = grid.getPlugin('cepItem');
        var current = plugin.getActiveRecord();

        if (combo.itemId === 'cboItem')
        {
            current.set('intItemId', records[0].get('intItemId'));
            current.set('strItemDescription', records[0].get('strDescription'));
            current.set('strLotTracking', records[0].get('strLotTracking'));
            current.set('intUnitMeasureId', records[0].get('intReceiveUOMId'));
            current.set('strUnitMeasure', records[0].get('strReceiveUOM'));
            current.set('dblUnitCost', records[0].get('dblLastCost'));
            current.set('dblUnitRetail', records[0].get('dblLastCost'));
            current.set('dblItemUOMConvFactor', records[0].get('dblReceiveUOMConvFactor'));
            current.set('strUnitType', records[0].get('strReceiveUOMType'));
            current.set('intCommodityId', records[0].get('intCommodityId'));
            current.set('intOwnershipType', 1);
            current.set('strOwnershipType', 'Own');

            current.set('intSubLocationId', records[0].get('intSubLocationId'));
            current.set('strSubLocationName', records[0].get('strSubLocationName'));
            current.set('intStorageLocationId', records[0].get('intStorageLocationId'));
            current.set('strStorageLocationName', records[0].get('strStorageLocationName'));

            var intUOM = null;
            var strUOM = '';
            var strWeightUOM = '';
            var dblLotUOMConvFactor = 0;

            if (records[0].get('strReceiveUOMType') === 'Weight'){
                intUOM = records[0].get('intReceiveUOMId');
                strUOM = records[0].get('strReceiveUOM');
                strWeightUOM = records[0].get('strReceiveUOM');
                dblLotUOMConvFactor = records[0].get('dblReceiveUOMConvFactor');
                current.set('intWeightUOMId', intUOM);
                current.set('strWeightUOM', strUOM);
                current.set('dblWeightUOMConvFactor', records[0].get('dblReceiveUOMConvFactor'));
            }
            else if (records[0].get('strStockUOMType') === 'Weight'){
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

            switch (records[0].get('strLotTracking')){
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
                        dblStatedTarePerUnit: ''
                    });
                    current.tblICInventoryReceiptItemLots().add(newLot);
                    break;
            }
        }
        else if (combo.itemId === 'cboItemUOM') {
            current.set('intUnitMeasureId', records[0].get('intItemUnitMeasureId'));
            current.set('dblItemUOMConvFactor', records[0].get('dblUnitQty'));
            current.set('dblUnitCost', records[0].get('dblLastCost'));
            current.set('dblUnitRetail', records[0].get('dblLastCost'));
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
        }
        else if (combo.itemId === 'cboWeightUOM')
        {
            current.set('dblWeightUOMConvFactor', records[0].get('dblUnitQty'));
            if (current.tblICInventoryReceiptItemLots()) {
                Ext.Array.each(current.tblICInventoryReceiptItemLots().data.items, function(lot) {
                    if (!lot.dummy) {
                        lot.set('strWeightUOM', records[0].get('strUnitMeasure'));
                    }
                });
            }
        }
        this.calculateGrossWeight(current);
        win.viewModel.data.currentReceiptItem = current;
        this.calculateItemTaxes();
    },

    calculateItemTaxes: function(reset) {
        var me = this;
        var win = me.getView();
        var masterRecord = win.viewModel.data.current;
        var detailRecord = win.viewModel.data.currentReceiptItem;

        if (!masterRecord) return;
        if (!detailRecord) return;
        if (iRely.Functions.isEmpty(detailRecord.get('intItemId'))) return;

        if(reset !== false) reset = true;

        if (detailRecord) {
            var current = {
                ItemId: detailRecord.get('intItemId'),
                LocationId: masterRecord.get('intLocationId'),
                TransactionDate: masterRecord.get('dtmReceiptDate'),
                TransactionType: 'Purchase',
                EntityId: masterRecord.get('intEntityVendorId')
            };

            if (reset)
                iRely.Functions.getItemTaxes(current, me.computeItemTax, me);
            else {
                var receiptItemTaxes = detailRecord.tblICInventoryReceiptItemTaxes();
                if (receiptItemTaxes){
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

    computeItemTax: function(itemTaxes, me, reset) {
        var win = me.getView();
        var currentRecord = win.viewModel.data.currentReceiptItem;
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

            if (itemDetailTax.dblTax === itemDetailTax.dblAdjustedTax && !itemDetailTax.ysnTaxAdjusted) {
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
        currentRecord.set('dblLineTotal', totalItemTax + (qty * unitCost));

    },

    getTaxableAmount: function(quantity, price, currentItemTax, itemTaxes){
        var taxableAmount = quantity * price;

        Ext.Array.each(itemTaxes, function (itemDetailTax) {
            if(itemDetailTax.strTaxableByOtherTaxes && itemDetailTax.strTaxableByOtherTaxes !== String.empty){
                if(itemDetailTax.strTaxableByOtherTaxes.split(",").indexOf(currentItemTax.intTaxClassId.toString()) > -1){
                    if(itemDetailTax.ysnTaxAdjusted){
                        taxableAmount = (quantity * price) + (itemDetailTax.dblAdjustedTax);
                    }else{
                        if(itemDetailTax.strCalculationMethod === 'Percentage'){
                            taxableAmount = (quantity * price) + ((quantity * price) * (itemDetailTax.dblRate/100));
                        }else{
                            taxableAmount = (quantity * price) + itemDetailTax.dblRate;
                        }
                    }
                }
            }
        });

        return taxableAmount;
    },

    calculateCharges: function(current) {
        var totalCharges = 0;
        if (current) {
            var charges = current.tblICInventoryReceiptCharges();
            if (charges) {

                Ext.Array.each(charges.data.items, function(charge) {
                    if (!charge.dummy) {
                        var amount = charge.get('dblAmount');
                        totalCharges += amount;
                    }
                });
            }
        }
        return totalCharges;
    },

    calculateLineTotals: function(current) {
        var totalAmount = 0;
        if (current) {
            var items = current.tblICInventoryReceiptItems();
            if (items) {
                Ext.Array.each(items.data.items, function(item) {
                    if (!item.dummy) {
                        var amount = item.get('dblLineTotal');
                        totalAmount += amount;
                    }
                });
            }
        }
        return totalAmount;
    },

    calculateGrossWeight: function(record){
        if (!record) return;

        if (record.tblICInventoryReceiptItemLots()){
            Ext.Array.each(record.tblICInventoryReceiptItemLots().data.items, function(lot) {
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
            var view = Ext.create(screenName, { controller: 'ic' + screen.toLowerCase(), viewModel: 'ic' + screen.toLowerCase() });
            var controller = view.getController();
            controller.show({ id: ReceiptItemId});
        });
    },

    onInventoryClick: function(button, e, eOpts) {
        var win = button.up('window');
        var grd = win.down('#grdInventoryReceipt');

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

    onQualityClick: function(button, e, eOpts) {
        var win = button.up('window');
        var grd = win.down('#grdInventoryReceipt');

        var selected = grd.getSelectionModel().getSelection();

        if (selected) {
            if (selected.length > 0){
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

    onInsertChargeClick: function(button, e, eOpts) {
        var grd = button.up('grid');
        if (grd) {
            grd.startAdd();
        }
    },

    onBillClick: function(button, e, eOpts) {
        var win = button.up('window');
        var current = win.viewModel.data.current;

        if (current) {
            Ext.Ajax.request({
                timeout: 120000,
                url: '../Inventory/api/InventoryReceipt/ProcessBill?id=' + current.get('intInventoryReceiptId'),
                method: 'post',
                success: function(response){
                    var jsonData = Ext.decode(response.responseText);
                    if (jsonData.success) {
                        var buttonAction = function(button) {
                            if (button === 'yes') {
                                iRely.Functions.openScreen('AccountsPayable.view.Bill', {
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
                        iRely.Functions.showCustomDialog('question', 'yesno', 'Bill succesfully processed. Do you want to view this bill?', buttonAction);
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

    onVendorClick: function(button, e, eOpts) {
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

    onReceiveClick: function(button, e, eOpts) {
        var me = this;
        var win = button.up('window');
        var context = win.context;

        var doPost = function() {
            var strReceiptNumber = win.viewModel.data.current.get('strReceiptNumber');
            var posted = win.viewModel.data.current.get('ysnPosted');

            var options = {
                postURL             : '../Inventory/api/InventoryReceipt/Receive',
                strTransactionId    : strReceiptNumber,
                isPost              : !posted,
                isRecap             : false,
                callback            : me.onAfterReceive,
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
        var cboCurrency = win.down('#cboCurrency');
        var context = win.context;

        var doRecap = function(recapButton, currentRecord, currency){

            // Call the buildRecapData to generate the recap data
            CashManagement.common.BusinessRules.buildRecapData({
                postURL: '../Inventory/api/InventoryReceipt/Receive',
                strTransactionId: currentRecord.get('strReceiptNumber'),
                ysnPosted: currentRecord.get('ysnPosted'),
                scope: me,
                success: function(){
                    // If data is generated, show the recap screen.
                    CashManagement.common.BusinessRules.showRecap({
                        strTransactionId: currentRecord.get('strReceiptNumber'),
                        ysnPosted: currentRecord.get('ysnPosted'),
                        dtmDate: currentRecord.get('dtmReceiptDate'),
                        strCurrencyId: currency,
                        dblExchangeRate: 1,
                        scope: me,
                        postCallback: function(){
                            me.onReceiveClick(recapButton);
                        },
                        unpostCallback: function(){
                            me.onReceiveClick(recapButton);
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
            doRecap(button, win.viewModel.data.current, cboCurrency.getRawValue());
            return;
        }

        // Save has data changes first before doing the post.
        context.data.saveRecord({
            successFn: function() {
                doRecap(button, win.viewModel.data.current, cboCurrency.getRawValue());
            }
        });
    },

    onAfterReceive: function(success, message) {
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
        var unitRateSurcharge = (unitRate * (txtFuelSurcharge.getValue() / 100));

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
            var calculatedTotal = 0;
            Ext.Array.each(data.items, function(row) {
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

        if (context.field === 'dblOpenReceive' || context.field === 'dblUnitCost')
        {
            if (context.record) {
                var value = 0;
                var record = context.record;
                if (context.field === 'dblOpenReceive'){
                    value = context.value * (record.get('dblUnitCost'));

                    if (!vw.data.currentReceiptItem) {
                        vw.data.currentReceiptItem = context.record;
                    }
                    me.calculateGrossWeight(record);
                }
                else if (context.field === 'dblUnitCost'){
                    value = context.value * (record.get('dblOpenReceive'));
                    record.set('dblUnitRetail', context.value);
                    record.set('dblGrossMargin', 0);
                }
                value += record.get('dblTax');
                record.set('dblLineTotal', value);
            }
        }
        else if (context.field === 'dblUnitRetail')
        {
            if (context.record) {
                var unitCost = context.record.get('dblUnitCost');
                var salesPrice = context.value;
                var grossMargin = ((salesPrice - unitCost) / (salesPrice)) * 100;
                context.record.set('dblGrossMargin', grossMargin);
            }
        }
        else if (context.field === 'strWeightUOM') {
            if (iRely.Functions.isEmpty(context.value)) {
                context.record.set('intWeightUOMId', null);
                context.record.set('dblWeightUOMConvFactor', 0);
                context.record.set('dblItemUOMConvFactor', 0);

                var tblICInventoryReceiptItemLots = vw.data.currentReceiptItem.tblICInventoryReceiptItemLots().data.items;
                Ext.Array.each(tblICInventoryReceiptItemLots, function(lot) {
                    lot.set('strWeightUOM', '');
                });
                win.controller.calculateGrossWeight(context.record);
            }
        }
        context.record.set(context.field, context.value);
        vw.data.currentReceiptItem = context.record;
        me.calculateItemTaxes();
    },

    onEditLots: function (editor, context, eOpts) {
        if (context.field === 'dblQuantity')
        {
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

            if (context.field === 'dblGrossWeight') { gross = context.value; }
            else if (context.field === 'dblTareWeight') { tare = context.value; }

            context.record.set('dblNetWeight', gross - tare);
        }
    },

    onShipFromBeforeQuery: function(obj) {
        if (obj.combo) {
            var store = obj.combo.store;
            var win = obj.combo.up('window');
            if (store) {
                store.remoteFilter = true;
                store.remoteSort = true;
            }

            if (obj.combo.itemId === 'cboOrderNumber') {
                var proxy = obj.combo.store.proxy;
                proxy.setExtraParams({search:true, include:'item'});
            }
            else if (obj.combo.itemId === 'cboVendor') {
                var proxy = obj.combo.store.proxy;
                proxy.setExtraParams({include:'tblEntityLocations'});
            }
            else if (obj.combo.itemId === 'cboLotUOM') {
                obj.combo.defaultFilters = [{
                    column: 'intItemId',
                    value: win.viewModel.data.currentReceiptItem.get('intItemId')
                }];
            }
            else if (obj.combo.itemId === 'cboWeightUOM') {
                obj.combo.defaultFilters = [{
                    column: 'intItemId',
                    value: win.viewModel.data.currentReceiptItem.get('intItemId'),
                    conjunction: 'and'
                }];
            }
        }
    },

    onShipFromSelect: function(combo, records) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var current = win.viewModel.data.current;

        if (current) current.set('intShipViaId', records[0].get('intShipViaId'));
    },

    onOrderNumberSelect: function(combo, records) {
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
                current.set('dblUnitCost', po.get('dblCost'));
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
                break;

            case 'Purchase Contract':
                current.set('intLineNo', po.get('intContractDetailId'));
                current.set('intOrderId', po.get('intContractHeaderId'));

                var costTypes =  po.get('tblCTContractCosts');
                if (costTypes) {
                    if (costTypes.length > 0) {
                        costTypes.forEach(function(cost){
                            var newCost = Ext.create('Inventory.model.ReceiptCharge', {
                                intInventoryReceiptId : receipt.get('intInventoryReceiptId'),
                                intContractId : po.get('intContractHeaderId'),
                                intChargeId : cost.intItemId,
                                ysnInventoryCost : false,
                                strCostMethod : cost.strCostMethod,
                                dblRate : cost.dblRate,
                                intCostUOMId : cost.intItemUOMId,
                                intEntityVendorId : cost.intVendorId,
                                dblAmount : 0,
                                strAllocateCostBy : '',
                                strCostBilledBy : 'Vendor',

                                strItemNo : cost.strItemNo,
                                strCostUOM : cost.strUOM,
                                strVendorId : cost.strVendorName,
                                intContractNumber : po.get('intContractNumber')
                            });
                            receipt.tblICInventoryReceiptCharges().add(newCost);
                        });
                    }
                }

                if (win.viewModel.data.current) {
                    if (win.viewModel.data.current.get('intSourceType') === 0) {
                        current.set('dblOrderQty', po.get('dblDetailQuantity'));
                        current.set('dblReceived', po.get('dblDetailQuantity') - po.get('dblBalance'));
                        current.set('dblOpenReceive', po.get('dblBalance'));
                        current.set('strItemDescription', po.get('strItemDescription'));
                        current.set('intItemId', po.get('intItemId'));
                        current.set('strItemNo', po.get('strItemNo'));
                        current.set('intUnitMeasureId', po.get('intItemUOMId'));
                        current.set('strUnitMeasure', po.get('strItemUOM'));
                        current.set('strOrderUOM', po.get('strItemUOM'));
                        current.set('dblUnitCost', po.get('dblCashPrice'));
                        current.set('dblLineTotal', po.get('dblTotal'));
                        current.set('strLotTracking', po.get('strLotTracking'));
                        current.set('intCommodityId', po.get('intCommodityId'));
                        current.set('intOwnershipType', 1);
                        current.set('strOwnershipType', 'Own');
                        current.set('intStorageLocationId', po.get('intStorageLocationId'));
                        current.set('strStorageLocationName', po.get('strStorageLocationName'));
                        current.set('dblItemUOMConvFactor', po.get('dblItemUOMCF'));
                        current.set('dblOrderUOMConvFactor', po.get('dblItemUOMCF'));
                        current.set('strUnitType', po.get('strStockUOMType'));
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

    onSourceNumberSelect: function(combo, records) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepItem');
        var current = plugin.getActiveRecord();
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
                current.set('strUnitType', po.get('strStockUOMType'));
                current.set('strContainer', po.get('strContainerNumber'));
                current.set('intContainerId', po.get('intShipmentBLContainerId'));

                if (iRely.Functions.isEmpty(current.get('intOrderId'))) {
                    current.set('intLineNo', po.get('intContractDetailId'));
                    current.set('intOrderId', po.get('intContractHeaderId'));
                    current.set('strOrderNumber', po.get('intContractNumber'));
                }
                break;

            case 1:
                break;
        }
        win.viewModel.data.currentReceiptItem = current;
    },

    purchaseOrderDropdown: function(win) {
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
                },{
                    column: 'intLocationId',
                    value: win.viewModel.data.current.get('intLocationId'),
                    conjunction: 'and'
                }]
            })
        });
    },

    purchaseContractDropdown: function(win) {
        return Ext.create('Ext.grid.CellEditor', {
            field: Ext.widget({
                xtype: 'gridcombobox',
                matchFieldWidth: false,
                columns: [
                    {
                        dataIndex: 'intContractNumber',
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
                    }
                ],
                itemId: 'cboOrderNumber',
                displayField: 'intContractNumber',
                valueField: 'intContractNumber',
                store: win.viewModel.storeInfo.purchaseContract,
                pickerWidth: 800,
                defaultFilters: [{
                    column: 'strContractType',
                    value: 'Purchase',
                    conjunction: 'and'
                },{
                    column: 'intEntityId',
                    value: win.viewModel.data.current.get('intEntityVendorId'),
                    conjunction: 'and'
                },{
                    column: 'ysnAllowedToShow',
                    value: true,
                    conjunction: 'and'
                },{
                    column: 'intCompanyLocationId',
                    value: win.viewModel.data.current.get('intLocationId'),
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

    inboundShipmentDropdown: function(win, record) {
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

            var receiptType = current.get('strReceiptType');
            var columnId = column.itemId;

            switch (receiptType) {
                case 'Purchase Order' :
                    if (iRely.Functions.isEmpty(record.get('strOrderNumber')))
                    {
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
                        };
                    }
                    break;
                case 'Purchase Contract' :
                    if (iRely.Functions.isEmpty(record.get('strOrderNumber')))
                    {
                        switch (columnId) {
                            case 'colOrderNumber' :
                                return controller.purchaseContractDropdown(win);
                                break;
                            case 'colSourceNumber' :
                                switch (current.get('intSourceType')) {
                                    case 2:
                                        return controller.inboundShipmentDropdown(win, record);
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
                                        return controller.inboundShipmentDropdown(win, record);
                                        break;
                                    default:
                                        return false;
                                        break;
                                }
                                break;
                        };
                    }
                    break;
                case 'Transfer Order' :
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

    onLotGridColumnBeforeRender: function(column) {
        "use strict";
        if (!column) return false;
        var me = this,
            win = column.up('window');

        // Show or hide the editor based on the selected Field type.
        column.getEditor = function(record){

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
                                    defaultFilters: [{
                                        column: 'intItemId',
                                        value: currentReceiptItem.get('intItemId'),
                                        conjunction: 'and'
                                    }]
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

    onSpecialKeyTab: function(component, e, eOpts) {
        var win = component.up('window');
        if(win) {
            if (e.getKey() === Ext.event.Event.TAB) {
                var gridObj = win.query('#grdInventoryReceipt')[0],
                    sel = gridObj.getStore().getAt(0);

                if(sel && gridObj){
                    gridObj.setSelection(sel);

                    var column = 1;
                    if(win.viewModel.data.current.get('strReceiptType') === 'Direct'){
                        column = 2
                    }

                    var task = new Ext.util.DelayedTask(function(){
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

    onItemSelectionChange: function(selModel, selected, eOpts) {
        if (selModel) {
            var win = selModel.view.grid.up('window');
            var vm = win.viewModel;

            if (selected.length > 0) {
                var current = selected[0];
                if (current.dummy) {
                    vm.data.currentReceiptItem = null;
                }
                else if (current.get('strLotTracking') === 'Yes - Serial Number' || current.get('strLotTracking') === 'Yes - Manual'){
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

    onLotSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var me = win.controller;
        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepItemLots');
        var current = plugin.getActiveRecord();

        if (combo.itemId === 'cboLotUOM')
        {
            current.set('intItemUnitMeasureId', records[0].get('intItemUOMId'));
            current.set('dblLotUOMConvFactor', records[0].get('dblUnitQty'));
            me.calculateGrossWeight(win.viewModel.data.currentReceiptItem);
        }
    },

    onWeightUOMChange: function(combo, newValue, oldValue, eOpts) {
        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepItem');
        var current = plugin.getActiveRecord();
        if (current && (newValue === null || newValue === '')){
            current.set('intWeightUOMId', null);
            current.set('dblWeightUOMConvFactor', null);
            if (current.tblICInventoryReceiptItemLots()) {
                Ext.Array.each(current.tblICInventoryReceiptItemLots().data.items, function(lot) {
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
            current.set('ysnInventoryCost', record.get('ysnInventoryCost'));
            current.set('dblRate', record.get('dblAmount'));
            current.set('intCostUOMId', record.get('intCostUOMId'));
            current.set('strCostMethod', record.get('strCostMethod'));
            current.set('strCostUOM', record.get('strCostUOM'));
            current.set('strOnCostType', record.get('strOnCostType'));
            if (!iRely.Functions.isEmpty(record.get('strOnCostType'))) {
                current.set('strCostMethod', 'Percentage');
            }
        }
        else if (combo.itemId === 'cboCostBilledBy') {
            switch (record.get('strDescription')) {
                case 'Vendor':
                    current.set('intEntityVendorId', masterRecord.get('intEntityVendorId'));
                    current.set('strVendorId', masterRecord.get('strVendorName'));
                    break;
                case 'Third Party':

                    break;
                default:
                    current.set('intEntityVendorId', null);
                    current.set('strVendorId', null);
                    break;
            }
        }
    },

    onStorageLocationSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var record = records[0];
        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepItem');
        var current = plugin.getActiveRecord();
        var lots = current.tblICInventoryReceiptItemLots();

        if (lots) {
            Ext.Array.each(lots.data.items, function (lot) {
                if (!lot.dummy) {
                    lot.set('intStorageLocationId', record.get('intStorageLocationId'));
                    lot.set('strStorageLocation', record.get('strName'));
                }
            });
        }
    },

    onColumnBeforeRender: function(column) {
        "use strict";

        if (column.itemId === 'colUnitCost') {
            column.summaryRenderer = function(val) {
                return '<div style="text-align:right;">Total:</div>';
            }
        }
        else {
            column.summaryRenderer = function(val){
                var value = (!Ext.isNumber(val) ? 0.00 : val).toFixed(2).replace(/./g, function(c, i, a) {
                    return i && c !== "." && ((a.length - i) % 3 === 0) ? ',' + c : c;
                });;
                return value;
            };
        }
    },

    init: function(application) {
        this.control({
            "#cboVendor": {
                beforequery: this.onShipFromBeforeQuery,
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
            "#btnQuality": {
                click: this.onQualityClick
            },
            "#btnVendor": {
                click: this.onVendorClick
            },
            "#btnInsertCharge": {
                click: this.onInsertChargeClick
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
                select: this.onSourceNumberSelect
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
            "#cboOtherCharge": {
                select: this.onChargeSelect
            },
            "#cboStorageLocation": {
                select: this.onStorageLocationSelect
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
            "#cboCostBilledBy": {
                select: this.onChargeSelect
            }
        })
    }

});
