Ext.define('Inventory.view.override.ItemViewController', {
    override: 'Inventory.view.ItemViewController',

    config: {
        searchConfig: {
            title:  'Search Item',
            type: 'Inventory.Item',
            api: {
                read: '../Inventory/api/Item/SearchItems'
            },
            columns: [
                {dataIndex: 'intItemId',text: "Item Id", flex: 1, defaultSort:true, dataType: 'numeric', key: true, hidden: true},
                {dataIndex: 'strItemNo', text: 'Item No', flex: 1,  dataType: 'string'},
                {dataIndex: 'strDescription', text: 'Description', flex: 1,  dataType: 'string'},
                {dataIndex: 'strModelNo',text: 'Model No', flex: 1,  dataType: 'string'}
            ]
        },
        binding: {
            //-----------//
            //Details Tab//
            //-----------//
            txtItemNo: '{current.strItemNo}',
            txtDescription: '{current.strDescription}',
            txtModelNo: '{current.strModelNo}',
            cboType: {
                value: '{current.strType}',
                store: '{ItemTypes}'
            },
            cboManufacturer: '{current.intManufacturerId}',
            cboBrand: '{current.intBrandId}',
            cboStatus: {
                value: '{current.strStatus}',
                store: '{ItemStatuses}'
            },
            cboLotTracking: {
                value: '{current.strLotTracking}',
                store: '{LotTrackings}'
            },
            cboTracking: '{current.intTrackingId}',
            //UOM Grid Columns
            colDetailUnitMeasure: 'intUnitMeasureId',
            colDetailUnitQty: 'dblUnitQty',
            colDetailSellQty: 'dblSellQty',
            colDetailWeight: 'dblWeight',
            colDetailDescription: 'strDescription',
            colDetailLength: 'dblLength',
            colDetailWidth: 'dblWidth',
            colDetailHeight: 'dblHeight',
            colDetailVolume: 'dblVolume',
            colDetailMaxQty: 'dblMaxQty',

            //----------//
            //Setup Tab//
            //----------//

            //------------------//
            //Location Store Tab//
            //------------------//
            colLocStoreLocation: 'intLocationId',
            colLocStoreStore: 'intStoreId',
            colLocStorePOSDescription: 'strPOSDescription',
            colLocStoreCategory: 'intCategoryId',
            colLocStoreVendor: 'intVendorId',
            colLocStoreCostingMethod: 'strCostingMethod',
            colLocStoreUOM: 'intDefaultUOMId',

            //---------//
            //Sales Tab//
            //---------//
            cboPatronage: '{current.tblICItemSales.intPatronageCategoryId}',
            cboTaxClass: '{current.tblICItemSales.intTaxClassId}',
            chkStockedItem: '{current.tblICItemSales.ysnStockedItem}',
            chkDyedFuel: '{current.tblICItemSales.ysnDyedFuel}',
            cboBarcodePrint: '{current.tblICItemSales.strBarcodePrint}',
            chkMsdsRequired: '{current.tblICItemSales.ysnMSDSRequired}',
            txtEpaNumber: '{current.tblICItemSales.strEPANumber}',
            chkInboundTax: '{current.tblICItemSales.ysnInboundTax}',
            chkOutboundTax: '{current.tblICItemSales.ysnOutboundTax}',
            chkRestrictedChemical: '{current.tblICItemSales.ysnRestrictedChemical}',
            chkTankRequired: '{current.tblICItemSales.ysnTankRequired}',
            chkAvailableForTm: '{current.tblICItemSales.ysnAvailableTM}',
            chkDefaultPercentFull: '{current.tblICItemSales.dblDefaultFull}',
            cboFuelInspectionFee: '{current.tblICItemSales.strFuelInspectFee}',
            cboRinRequired: '{current.tblICItemSales.strRINRequired}',
            cboRinFuelType: '{current.tblICItemSales.intRINFuelTypeId}',
            txtPercentDenaturant: '{current.tblICItemSales.dblDenaturantPercent}',
            chkTonnageTax: '{current.tblICItemSales.ysnTonnageTax}',
            chkLoadTracking: '{current.tblICItemSales.ysnLoadTracking}',
            txtMixOrder: '{current.tblICItemSales.dblMixOrder}',
            chkHandAddIngredients: '{current.tblICItemSales.ysnHandAddIngredient}',
            cboMedicationTag: '{current.tblICItemSales.intMedicationTag}',
            cboIngredientTag: '{current.tblICItemSales.intIngredientTag}',
            txtVolumeRebateGroup: '{current.tblICItemSales.strVolumeRebateGroup}',
            cboPhysicalItem: '{current.tblICItemSales.intPhysicalItem}',
            chkExtendOnPickTicket: '{current.tblICItemSales.ysnExtendPickTicket}',
            chkExportEdi: '{current.tblICItemSales.ysnExportEDI}',
            chkHazardMaterial: '{current.tblICItemSales.ysnHazardMaterial}',
            chkMaterialFee: '{current.tblICItemSales.ysnMaterialFee}',

            //-------//
            //POS Tab//
            //-------//
            txtOrderUpcNo: '{current.tblICItemPOS.strUPCNo}',
            cboCaseUom: '{current.tblICItemPOS.intCaseUOM}',
            txtNacsCategory: '{current.tblICItemPOS.strNACSCategory}',
            cboWicCode: '{current.tblICItemPOS.strWICCode}',
            cboAgCategory: '{current.tblICItemPOS.intAGCategory}',
            chkReceiptCommentReq: '{current.tblICItemPOS.ysnReceiptCommentRequired}',
            cboCountCode: '{current.tblICItemPOS.strCountCode}',
            chkLandedCost: '{current.tblICItemPOS.ysnLandedCost}',
            txtLeadTime: '{current.tblICItemPOS.strLeadTime}',
            chkTaxable: '{current.tblICItemPOS.ysnTaxable}',
            txtKeywords: '{current.tblICItemPOS.strKeywords}',
            txtCaseQty: '{current.tblICItemPOS.dblCaseQty}',
            dtmDateShip: '{current.tblICItemPOS.dtmDateShip}',
            txtTaxExempt: '{current.tblICItemPOS.dblTaxExempt}',
            chkDropShip: '{current.tblICItemPOS.ysnDropShip}',
            chkCommissionable: '{current.tblICItemPOS.ysnCommisionable}',
            cboSpecialCommission: '{current.tblICItemPOS.strSpecialCommission}',

            colPOSCategoryName: '',

            colPOSSLAContract: '',
            colPOSSLAPrice: '',
            colPOSSLAWarranty: '',

            //-----------------//
            //Manufacturing Tab//
            //-----------------//
            chkRequireApproval: '{current.tblICItemManufacturing.ysnRequireCustomerApproval}',
            cboAssociatedRecipe: '{current.tblICItemManufacturing.intRecipeId}',
            chkSanitizationRequired: '{current.tblICItemManufacturing.ysnSanitationRequired}',
            txtLifeTime: '{current.tblICItemManufacturing.intLifeTime}',
            cboLifetimeType: '{current.tblICItemManufacturing.strLifeTimeType}',
            txtReceiveLife: '{current.tblICItemManufacturing.intReceiveLife}',
            txtGTIN: '{current.tblICItemManufacturing.strGTIN}',
            cboRotationType: '{current.tblICItemManufacturing.strRotationType}',
            cboNFMC: '{current.tblICItemManufacturing.intNMFCId}',
            chkStrictFIFO: '{current.tblICItemManufacturing.ysnStrictFIFO}',
            txtHeight: '{current.tblICItemManufacturing.dblHeight}',
            txtWidth: '{current.tblICItemManufacturing.dblWidth}',
            txtDepth: '{current.tblICItemManufacturing.dblDepth}',
            cboDimensionUOM: '{current.tblICItemManufacturing.intDimensionUOMId}',
            cboWeightUOM: '{current.tblICItemManufacturing.intWeightUOMId}',
            txtWeight: '{current.tblICItemManufacturing.dblWeight}',
            txtMaterialPack: '{current.tblICItemManufacturing.intMaterialPackTypeId}',
            txtMaterialSizeCode: '{current.tblICItemManufacturing.strMaterialSizeCode}',
            txtInnerUnits: '{current.tblICItemManufacturing.intInnerUnits}',
            txtLayersPerPallet: '{current.tblICItemManufacturing.intLayerPerPallet}',
            txtUnitsPerLayer: '{current.tblICItemManufacturing.intUnitPerLayer}',
            txtStandardPalletRatio: '{current.tblICItemManufacturing.dblStandardPalletRatio}',
            txtMask1: '{current.tblICItemManufacturing.strMask1}',
            txtMask2: '{current.tblICItemManufacturing.strMask2}',
            txtMask3: '{current.tblICItemManufacturing.strMask3}',

            colManufacturingUOM: ''



        }
    },

    setupContext : function(options){
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.Item', { pageSize: 1 });

        win.context = Ext.create('iRely.Engine', {
            window : win,
            store  : store,
            createRecord : me.createRecord,
            binding: me.config.binding,
            details: [
                {
                    key: 'tblICItemUOMs',
                    component: Ext.create('iRely.grid.Manager', {
                        grid: win.down('#grdUnitOfMeasure')
                    })
                },
                {
                    key: 'tblICItemLocationStores',
                    component: Ext.create('iRely.grid.Manager', {
                        grid: win.down('#grdLocationStore'),
                        deleteButton : win.down('#btnDeleteLocation')
                    })
                }
//                ,
//                {
//                    key: 'tblICItemPOS',
//                    component: Ext.create('iRely.grid.Manager', {
//                        grid: win.down('#grdLocationStore'),
//                        deleteButton : win.down('#btnDeleteLocation')
//                    })
//                }
//                ,
//                {
//                    key: 'tblICItemSales',
//                    component: Ext.create('iRely.grid.Manager', {
//                        grid: win.down('#grdLocationStore'),
//                        deleteButton : win.down('#btnDeleteLocation')
//                    })
//                }

            ]
        });

//        var cboType = win.down('#cboType');
//        cboType.forceSelection = true;
//
//        var cboStatus = win.down('#cboStatus');
//        cboStatus.forceSelection = true;
//
//        var cboLotTracking = win.down('#cboLotTracking');
//        cboLotTracking.forceSelection = true;

        return win.context;
    },

    show : function(config) {
        "use strict";

        var me = this,
            win = this.getView();

        if (config) {
            win.show();

//            Ext.require('Inventory.store.Item', function() {
                var context = me.setupContext( {window : win} );

                if (config.action === 'new') {
                    context.data.addRecord();
                } else {
                    if (config.id) {
                        config.filters = [{
                            column: 'intItemId',
                            value: config.id
                        }];
                    }
//                if (config.param) {
//                    console.log(config.param);
//                }
                    context.data.load({
                        filters: config.filters
                    });
                }
//            });
        }
    }

});