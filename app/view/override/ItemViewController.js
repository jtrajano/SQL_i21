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
            cboManufacturer: {
                value: '{current.intManufacturerId}',
                store: 'Manufacturer'
            } ,
            cboBrand: '{current.intBrandId}',
            cboStatus: {
                value: '{current.strStatus}',
                store: '{ItemStatuses}'
            },
            cboLotTracking: {
                value: '{current.strLotTracking}',
                store: '{LotTrackings}'
            },
            cboTracking: {
                value: '{current.intTrackingId}',
                store: '{Category}'
            },
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
            cboPatronage: {
                value: '{current.intPatronageCategoryId}',
                store: '{PatronageCategory}'
            },
//            cboTaxClass: {
//                value: '{current.intTaxClassId}',
//                store: '{}'
//            },
            chkStockedItem: '{current.ysnStockedItem}',
            chkDyedFuel: '{current.ysnDyedFuel}',
            cboBarcodePrint: {
                value: '{current.strBarcodePrint}',
                store: '{BarcodePrints}'
            },
            chkMsdsRequired: '{current.ysnMSDSRequired}',
            txtEpaNumber: '{current.strEPANumber}',
            chkInboundTax: '{current.ysnInboundTax}',
            chkOutboundTax: '{current.ysnOutboundTax}',
            chkRestrictedChemical: '{current.ysnRestrictedChemical}',
            chkTankRequired: '{current.ysnTankRequired}',
            chkAvailableForTm: '{current.ysnAvailableTM}',
            txtDefaultPercentFull: '{current.dblDefaultFull}',
            cboFuelInspectionFee: {
                value: '{current.strFuelInspectFee}',
                store: '{FuelInspectionFees}'
            },
            cboRinRequired: {
                value: '{current.strRINRequired}',
                store: '{RinRequires}'
            },
//            cboRinFuelType: {
//                value: '{current.intRINFuelTypeId}',
//                store: '{}'
//            },
            txtPercentDenaturant: '{current.dblDenaturantPercent}',
            chkTonnageTax: '{current.ysnTonnageTax}',
            chkLoadTracking: '{current.ysnLoadTracking}',
            txtMixOrder: '{current.dblMixOrder}',
            chkHandAddIngredients: '{current.ysnHandAddIngredient}',
            cboMedicationTag: {
                value: '{current.intMedicationTag}',
                store: '{InventoryTag}'
            },
            cboIngredientTag: {
                value: '{current.intIngredientTag}',
                store: '{InventoryTag}'
            },
            txtVolumeRebateGroup: '{current.strVolumeRebateGroup}',
            cboPhysicalItem: '{current.intPhysicalItem}',
            chkExtendOnPickTicket: '{current.ysnExtendPickTicket}',
            chkExportEdi: '{current.ysnExportEDI}',
            chkHazardMaterial: '{current.ysnHazardMaterial}',
            chkMaterialFee: '{current.ysnMaterialFee}',

            //-------//
            //POS Tab//
            //-------//
            txtOrderUpcNo: '{current.strUPCNo}',
            cboCaseUom: '{current.intCaseUOM}',
            txtNacsCategory: '{current.strNACSCategory}',
            cboWicCode: {
                value: '{current.strWICCode}',
                store: '{WICCodes}'
            },
            cboAgCategory: '{current.intAGCategory}',
            chkReceiptCommentReq: '{current.ysnReceiptCommentRequired}',
            cboCountCode: '{current.strCountCode}',
            chkLandedCost: '{current.ysnLandedCost}',
            txtLeadTime: '{current.strLeadTime}',
            chkTaxable: '{current.ysnTaxable}',
            txtKeywords: '{current.strKeywords}',
            txtCaseQty: '{current.dblCaseQty}',
            dtmDateShip: '{current.dtmDateShip}',
            txtTaxExempt: '{current.dblTaxExempt}',
            chkDropShip: '{current.ysnDropShip}',
            chkCommissionable: '{current.ysnCommisionable}',
            cboSpecialCommission: '{current.strSpecialCommission}',

            colPOSCategoryName: '',

            colPOSSLAContract: '',
            colPOSSLAPrice: '',
            colPOSSLAWarranty: '',

            //-----------------//
            //Manufacturing Tab//
            //-----------------//
            chkRequireApproval: '{current.ysnRequireCustomerApproval}',
            cboAssociatedRecipe: '{current.intRecipeId}',
            chkSanitizationRequired: '{current.ysnSanitationRequired}',
            txtLifeTime: '{current.intLifeTime}',
            cboLifetimeType: '{current.strLifeTimeType}',
            txtReceiveLife: '{current.intReceiveLife}',
            txtGTIN: '{current.strGTIN}',
            cboRotationType: {
                value: '{current.strRotationType}',
                store: '{RotationTypes}'
            },
            cboNFMC: '{current.intNMFCId}',
            chkStrictFIFO: '{current.ysnStrictFIFO}',
            txtHeight: '{current.dblHeight}',
            txtWidth: '{current.dblWidth}',
            txtDepth: '{current.dblDepth}',
            cboDimensionUOM: '{current.intDimensionUOMId}',
            cboWeightUOM: '{current.intWeightUOMId}',
            txtWeight: '{current.dblWeight}',
            txtMaterialPack: '{current.intMaterialPackTypeId}',
            txtMaterialSizeCode: '{current.strMaterialSizeCode}',
            txtInnerUnits: '{current.intInnerUnits}',
            txtLayersPerPallet: '{current.intLayerPerPallet}',
            txtUnitsPerLayer: '{current.intUnitPerLayer}',
            txtStandardPalletRatio: '{current.dblStandardPalletRatio}',
            txtMask1: '{current.strMask1}',
            txtMask2: '{current.strMask2}',
            txtMask3: '{current.strMask3}',

            colManufacturingUOM: 'intUnitMeasureId',

            colUPCUnitMeasure: 'intUnitMeasureId',
            colUPCUnitQty: 'dblUnitQty',
            colUPCCode: 'strUPCCode',

            colCustomerXrefLocation: 'intLocationId',
            colCustomerXrefStore: 'strStoreName',
            colCustomerXrefCustomer: 'intCustomerId',
            colCustomerXrefProduct: 'strCustomerProduct',
            colCustomerXrefDescription: 'strProductDescription',
            colCustomerXrefPickTicketNotes: 'strPickTicketNotes',

            colVendorXrefLocation: 'intLocationId',
            colVendorXrefStore: 'strStoreName',
            colVendorXrefVendor: 'intVendorId',
            colVendorXrefProduct: 'strVendorProduct',
            colVendorXrefDescription: 'strProductDescription',
            colVendorXrefConversionFactor: 'dblConversionFactor',
            colVendorXrefUnitMeasure: 'intUnitMeasureId',

            colContractLocation: 'intLocationId',
            colContractStore: 'strStoreName',
            colContractItemName: 'strContractItemName',
            colContractCommodity: '',
            colContractOrigin: 'intCountryId',
            colContractGrade: 'strGrade',
            colContractGarden: 'strGarden',
            colContractGradeType: 'strGradeType',
            colContractYield: 'dblYieldPercent',
            colContractTolerance: 'dblTolerancePercent',
            colContractFranchise: 'dblFranchisePercent',

            colDocument: 'intDocumentId',

            colCertification: 'intCertificationId'

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
                },
                {
                    key: 'tblICItemUPCs',
                    component: Ext.create('iRely.grid.Manager', {
                        grid: win.down('#grdUPC'),
                        deleteButton : win.down('#btnDeleteUPC')
                    })
                },
                {
                    key: 'tblICItemVendorXrefs',
                    component: Ext.create('iRely.grid.Manager', {
                        grid: win.down('#grdVendorXref'),
                        deleteButton : win.down('#btnDeleteVendorXref')
                    })
                },
                {
                    key: 'tblICItemCustomerXrefs',
                    component: Ext.create('iRely.grid.Manager', {
                        grid: win.down('#grdCustomerXref'),
                        deleteButton : win.down('#btnDeleteCustomerXref')
                    })
                },
                {
                    key: 'tblICItemContracts',
                    component: Ext.create('iRely.grid.Manager', {
                        grid: win.down('#grdContractItem'),
                        deleteButton : win.down('#btnDeleteContractItem')
                    })
                },
                {
                    key: 'tblICItemCertifications',
                    component: Ext.create('iRely.grid.Manager', {
                        grid: win.down('#grdCertification'),
                        deleteButton : win.down('#btnDeleteCertification')
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