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
                store: '{Manufacturer}'
            } ,
            cboBrand: {
                value: '{current.intBrandId}',
                store: '{Brand}'
            },
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
            colLocationLocation: 'intLocationId',
            colLocationPOSDescription: 'strDescription',
            colLocationCategory: 'intCategoryId',
            colLocationVendor: 'intVendorId',
            colLocationCostingMethod: 'intCostingMethod',
            colLocationUOM: 'intDefaultUOMId',

            //--------------//
            //GL Account Tab//
            //--------------//
            colGLAccountLocation: 'intLocationId',
            colGLAccountDescription: 'strAccountDescription',
            colGLAccountId: 'intAccountId',
            colGLAccountProfitCenter: 'intProfitCenterId',

            //---------//
            //Sales Tab//
            //---------//
            cboPatronage: {
                value: '{current.intPatronageCategoryId}',
                store: '{PatronageCategory}'
            },
            cboTaxClass: {
                value: '{current.intTaxClassId}',
                store: '{FuelTaxClass}'
            },
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
            cboRinFuelType: {
                value: '{current.intRINFuelTypeId}',
                store: '{FuelCategory}'
            },
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
            cboPhysicalItem: {
                value: '{current.intPhysicalItem}',
                store: '{Item}'
            },
            chkExtendOnPickTicket: '{current.ysnExtendPickTicket}',
            chkExportEdi: '{current.ysnExportEDI}',
            chkHazardMaterial: '{current.ysnHazardMaterial}',
            chkMaterialFee: '{current.ysnMaterialFee}',

            //-------//
            //POS Tab//
            //-------//
            txtOrderUpcNo: '{current.strUPCNo}',
            cboCaseUom: {
                value: '{current.intCaseUOM}',
                store: '{UnitMeasure}'
            },
            txtNacsCategory: '{current.strNACSCategory}',
            cboWicCode: {
                value: '{current.strWICCode}',
                store: '{WICCodes}'
            },
            cboAgCategory: {
                value: '{current.intAGCategory}',
                store: '{Category}'
            },
            chkReceiptCommentReq: '{current.ysnReceiptCommentRequired}',
            cboCountCode: {
                value: '{current.strCountCode}',
                store: '{CountCodes}'
            },
            chkLandedCost: '{current.ysnLandedCost}',
            txtLeadTime: '{current.strLeadTime}',
            chkTaxable: '{current.ysnTaxable}',
            txtKeywords: '{current.strKeywords}',
            txtCaseQty: '{current.dblCaseQty}',
            dtmDateShip: '{current.dtmDateShip}',
            txtTaxExempt: '{current.dblTaxExempt}',
            chkDropShip: '{current.ysnDropShip}',
            chkCommissionable: '{current.ysnCommisionable}',
            chkSpecialCommission: '{current.ysnSpecialCommission}',

            colPOSCategoryName: 'intCategoryId',

            colPOSSLAContract: 'strSLAContract',
            colPOSSLAPrice: 'dblContractPrice',
            colPOSSLAWarranty: 'ysnServiceWarranty',

            //-----------------//
            //Manufacturing Tab//
            //-----------------//
            chkRequireApproval: '{current.ysnRequireCustomerApproval}',
            cboAssociatedRecipe: '{current.intRecipeId}',
            chkSanitizationRequired: '{current.ysnSanitationRequired}',
            txtLifeTime: '{current.intLifeTime}',
            cboLifetimeType: {
                value: '{current.strLifeTimeType}',
                store: '{LifeTimes}'
            },
            txtReceiveLife: '{current.intReceiveLife}',
            txtGTIN: '{current.strGTIN}',
            cboRotationType: {
                value: '{current.strRotationType}',
                store: '{RotationTypes}'
            },
            cboNFMC: {
                value: '{current.intNMFCId}',
                store: '{MaterialNMFC}'
            },
            chkStrictFIFO: '{current.ysnStrictFIFO}',
            txtHeight: '{current.dblHeight}',
            txtWidth: '{current.dblWidth}',
            txtDepth: '{current.dblDepth}',
            cboDimensionUOM: {
                value: '{current.intDimensionUOMId}',
                store: '{UnitMeasure}'
            },
            cboWeightUOM: {
                value: '{current.intWeightUOMId}',
                store: '{UnitMeasure}'
            },
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

            colCertification: 'intCertificationId',

            colStockLocation: 'intLocationId',
            colStockSubLocation: 'strWarehouse',
            colStockUOM: 'intUnitMeasureId',
            colStockOnHand: 'dblUnitOnHand',
            colStockCommitted: 'dblOrderCommitted',
            colStockOnOrder: 'dblOnOrder',
            colStockReorderPoint: 'dblReorderPoint',
            colStockMinOrder: 'dblMinOrder',
            colStockSuggestedQty: 'dblSuggestedQuantity',
            colStockLeadTime: 'dblLeadTime',
            colStockCounted: 'strCounted',
            colStockInventoryGroup: 'strInventoryGroup',
            colStockCountedDaily: 'ysnCountedDaily',

            colPricingLocation: 'intLocationId',
            colPricingSalePrice: 'dblSalePrice',
            colPricingRetailPrice: 'dblRetailPrice',
            colPricingWholesalePrice: 'dblWholesalePrice',
            colPricingLargeVolumePrice: 'dblLargeVolumePrice',
            colPricingMSRP: 'dblMSRPPrice',
            colPricingMethod: 'strPricingMethod',
            colPricingLastCost: 'dblLastCost',
            colPricingStandardCost: 'dblStandardCost',
            colPricingAverageCost: 'dblMovingAverageCost',
            colPricingEOMCost: 'dblEndMonthCost',
            colPricingActive: 'ysnActive',

            colPricingLevelLocation: 'intLocationId',
            colPricingLevelPriceLevel: 'strPriceLevel',
            colPricingLevelUOM: 'intUnitMeasureId',
            colPricingLevelUnits: 'dblUnit',
            colPricingLevelMin: 'dblMin',
            colPricingLevelMax: 'dblMax',
            colPricingLevelMethod: 'strPricingMethod',
            colPricingLevelCommissionOn: 'strCommissionOn',
            colPricingLevelCommissionRate: 'dblCommissionRate',
            colPricingLevelAmount: '',
            colPricingLevelUnitPrice: 'dblUnitPrice',
            colPricingLevelActive: 'ysnActive',

            colSpecialPricingLocation: 'intLocationId',
            colSpecialPricingPromotionType: 'strPromotionType',
            colSpecialPricingBeginDate: 'dtmBeginDate',
            colSpecialPricingEndDate: 'dtmEndDate',
            colSpecialPricingUnit: 'intUnitMeasureId',
            colSpecialPricingQty: 'dblUnit',
            colSpecialPricingDiscountBy: 'strDiscountBy',
            colSpecialPricingDiscountRate: 'dblDiscount',
            colSpecialPricingUnitPrice: 'dblUnitAfterDiscount',
            colSpecialPricingAccumQty: 'dblAccumulatedQty',
            colSpecialPricingAccumAmount: 'dblAccumulatedAmount',

            colNoteLocation: 'intLocationId',
            colNoteCommentType: 'strCommentType',
            colNoteComment: 'strComments'
        }
    },

    setupContext : function(options){
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.Item', { pageSize: 1 });

        var grdUOM = win.down('#grdUnitOfMeasure'),
            grdLocationStore = win.down('#grdLocationStore'),
            grdCategory = win.down('#grdCategory'),
            grdGlAccounts = win.down('#grdGlAccounts'),
            grdUPC = win.down('#grdUPC'),
            grdVendorXref = win.down('#grdVendorXref'),
            grdCustomerXref = win.down('#grdCustomerXref'),
            grdContractItem = win.down('#grdContractItem'),
            grdDocumentAssociation = win.down('#grdDocumentAssociation'),
            grdCertification = win.down('#grdCertification'),
            grdStock = win.down('#grdStock'),

            grdPricing = win.down('#grdPricing'),
            grdPricingLevel = win.down('#grdPricingLevel'),
            grdSpecialPricing = win.down('#grdSpecialPricing'),

            grdNotes = win.down('#grdNotes');

        win.context = Ext.create('iRely.mvvm.Engine', {
            window : win,
            store  : store,
            createRecord : me.createRecord,
            binding: me.config.binding,
            details: [
                {
                    key: 'tblICItemUOMs',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: grdUOM,
                        deleteButton : grdUOM.down('#btnDeleteLocation')
                    })
                },
                {
                    key: 'tblICItemLocations',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: grdLocationStore,
                        deleteButton : grdLocationStore.down('#btnDeleteLocation'),
                        position: 'none'
                    })
                },
                {
                    key: 'tblICItemUPCs',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: grdUPC,
                        deleteButton : win.down('#btnDeleteUPC')
                    })
                },
                {
                    key: 'tblICItemVendorXrefs',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: grdVendorXref,
                        deleteButton : grdVendorXref.down('#btnDeleteVendorXref')
                    })
                },
                {
                    key: 'tblICItemCustomerXrefs',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: grdCustomerXref,
                        deleteButton : grdCustomerXref.down('#btnDeleteCustomerXref')
                    })
                },
                {
                    key: 'tblICItemContracts',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: grdContractItem,
                        deleteButton : grdContractItem.down('#btnDeleteContractItem')
                    }),
                    details: [
                        {
                            key: 'tblICItemContractDocuments',
                            component: Ext.create('iRely.mvvm.grid.Manager', {
                                grid: grdDocumentAssociation,
                                deleteButton : grdDocumentAssociation.down('#btnDeleteDocumentAssociation')
                            })
                        }
                    ]
                },
                {
                    key: 'tblICItemCertifications',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: grdCertification,
                        deleteButton : grdCertification.down('#btnDeleteCertification')
                    })
                },
                {
                    key: 'tblICItemPOSCategories',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: grdCategory,
                        deleteButton : win.down('#btnDeleteCategories')
                    })
                },
                {
                    key: 'tblICItemPOSSLAs',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: win.down('#grdServiceLevelAgreement'),
                        deleteButton : win.down('#btnDeleteSLA')
                    })
                },
                {
                    key: 'tblICItemAccounts',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: grdGlAccounts,
                        deleteButton : grdGlAccounts.down('#btnDeleteGlAccounts')
                    })
                },
                {
                    key: 'tblICItemStocks',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: grdStock,
                        deleteButton : grdStock.down('#btnDeleteStock')
                    })
                },
                {
                    key: 'tblICItemNotes',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: grdNotes,
                        deleteButton : grdNotes.down('#btnDeleteNotes')
                    })
                },
                {
                    key: 'tblICItemPricings',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: grdPricing,
                        deleteButton : grdPricing.down('#btnDeletePricing'),
                        position: 'none'
                    })
                },
                {
                    key: 'tblICItemPricingLevels',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: grdPricingLevel,
                        deleteButton : grdPricingLevel.down('#btnDeletePricingLevel')
                    })
                },
                {
                    key: 'tblICItemSpecialPricings',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: grdSpecialPricing,
                        deleteButton : grdSpecialPricing.down('#btnDeleteSpecialPricing')
                    })
                }
            ]
        });

        var btnAddLocation = grdLocationStore.down('#btnAddLocation');
        btnAddLocation.on('click', me.onAddLocationClick);
        var btnEditLocation = grdLocationStore.down('#btnEditLocation');
        btnEditLocation.on('click', me.onEditLocationClick);

        var btnAddPricing = grdPricing.down('#btnAddPricing');
        btnAddPricing.on('click', me.onAddPricingClick);
        var btnEditPricing = grdPricing.down('#btnEditPricing');
        btnEditPricing.on('click', me.onEditPricingClick);

        // <editor-fold desc="Subscribe to Renderers and Cell Editing Plugins">
        var colLocationLocation = grdLocationStore.columns[0];
        colLocationLocation.renderer = me.LocationRenderer;
        var colLocationCategory = grdLocationStore.columns[2];
        colLocationCategory.renderer = me.CategoryRenderer;
        var colLocationVendor = grdLocationStore.columns[3];
        colLocationVendor.renderer = me.VendorRenderer;
        var colLocationCostingMethod = grdLocationStore.columns[4];
        colLocationCostingMethod.renderer = me.CostingMethodRenderer;
        var colLocationUOM = grdLocationStore.columns[5];
        colLocationUOM.renderer = me.UOMRenderer;

        var colDetailUOM = grdUOM.columns[0];
        colDetailUOM.renderer = me.UOMRenderer;

        var cepDetailUOM = grdUOM.getPlugin('cepDetailUOM');
        cepDetailUOM.on({
            edit: me.onGridUOMEdit,
            scope: me
        });

        var colCategory = grdCategory.columns[0];
        colCategory.renderer = me.CategoryRenderer;

        var cepPOSCategory = grdCategory.getPlugin('cepPOSCategory');
        cepPOSCategory.on({
            edit: me.onGridCategoryEdit,
            scope: me
        });

        var colUPUom = grdUPC.columns[0];
        colUPUom.renderer = me.UOMRenderer;

        var cepUPC = grdUPC.getPlugin('cepUPC');
        cepUPC.on({
            edit: me.onGridUOMEdit,
            scope: me
        });

        var colNoteLocation = grdNotes.columns[0];
        colNoteLocation.renderer = me.LocationRenderer;

        var cepNotes = grdNotes.getPlugin('cepNotes');
        cepNotes.on({
            edit: me.onGridLocationEdit,
            scope: me
        });

        var colAccountLocation = grdGlAccounts.columns[0];
        colAccountLocation.renderer = me.LocationRenderer;

        var colAccountId = grdGlAccounts.columns[2];
        colAccountId.renderer = me.AccountRenderer;

        var colProfitCenterId = grdGlAccounts.columns[3];
        colProfitCenterId.renderer = me.ProfitCenterRenderer;

        var cepAccount = grdGlAccounts.getPlugin('cepAccount');
        cepAccount.on({
            edit: me.onGridAccountEdit,
            scope: me
        });


        var colCustomerLocation = grdCustomerXref.columns[0];
        colCustomerLocation.renderer = me.LocationRenderer;
        var colCustomerXref = grdCustomerXref.columns[1];
        colCustomerXref.renderer = me.CustomerRenderer;

        var cepCustomerXref = grdCustomerXref.getPlugin('cepCustomerXref');
        cepCustomerXref.on({
            edit: me.onGridCustomerXrefEdit,
            scope: me
        });

        var colVendorLocation = grdVendorXref.columns[0];
        colVendorLocation.renderer = me.LocationRenderer;
        var colVendorXref = grdVendorXref.columns[1];
        colVendorXref.renderer = me.VendorRenderer;
        var colVendorUom = grdVendorXref.columns[5];
        colVendorUom.renderer = me.UOMRenderer;

        var cepVendorXref = grdVendorXref.getPlugin('cepVendorXref');
        cepVendorXref.on({
            edit: me.onGridVendorXrefEdit,
            scope: me
        });

        var colContractLocation = grdContractItem.columns[0];
        colContractLocation.renderer = me.LocationRenderer;
        var colContractCountry = grdContractItem.columns[2];
        colContractCountry.renderer = me.CountryRenderer;

        var cepContractItem = grdContractItem.getPlugin('cepContractItem');
        cepContractItem.on({
            edit: me.onGridContractEdit,
            scope: me
        });

        var colDocument = grdDocumentAssociation.columns[0];
        colDocument.renderer = me.DocumentRenderer;

        var cepDocument = grdDocumentAssociation.getPlugin('cepDocument');
        cepDocument.on({
            edit: me.onGridDocumentEdit,
            scope: me
        });

        var colCertification = grdCertification.columns[0];
        colCertification.renderer = me.CertificationRenderer;

        var cepCertification = grdCertification.getPlugin('cepCertification');
        cepCertification.on({
            edit: me.onGridCertificationEdit,
            scope: me
        });


        var colStockLocation = grdStock.columns[0];
        colStockLocation.renderer = me.LocationRenderer;
        var colStockUOM = grdStock.columns[2];
        colStockUOM.renderer = me.UOMRenderer;
        var colStockCountGroup = grdStock.columns[11];
        colStockCountGroup.renderer = me.CountGroupRenderer;

        var cepStock = grdStock.getPlugin('cepStock');
        cepStock.on({
            edit: me.onGridStockEdit,
            scope: me
        });

        var colPricingLocation = grdPricing.columns[0];
        colPricingLocation.renderer = me.LocationRenderer;

        var colPricingLevelLocation = grdPricingLevel.columns[0];
        colPricingLevelLocation.renderer = me.LocationRenderer;
        var colPricingLevelUOM = grdPricingLevel.columns[2];
        colPricingLevelUOM.renderer = me.UOMRenderer;

        var cepPricingLevel = grdPricingLevel.getPlugin('cepPricingLevel');
        cepPricingLevel.on({
            edit: me.onGridPricingLevelEdit,
            scope: me
        });

        var colPricingLevelLocation = grdSpecialPricing.columns[0];
        colPricingLevelLocation.renderer = me.LocationRenderer;
        var colPricingLevelUOM = grdSpecialPricing.columns[3];
        colPricingLevelUOM.renderer = me.UOMRenderer;

        var cepSpecialPricing = grdSpecialPricing.getPlugin('cepSpecialPricing');
        cepSpecialPricing   .on({
            edit: me.onGridSpecialPricingEdit,
            scope: me
        });


        // </editor-fold>


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
                        column: 'intItemId',
                        value: config.id
                    }];
                }
                context.data.load({
                    filters: config.filters
                });
            }
        }
    },

    CategoryRenderer: function (value, metadata, record) {
        var category = record.get('strCategory');
        return category;
    },

    UOMRenderer: function (value, metadata, record) {
        var unitmeasure = record.get('strUnitMeasure');
        return unitmeasure;
    },

    LocationRenderer: function (value, metadata, record) {
        var location = record.get('strLocationName');
        return location;
    },

    AccountRenderer: function (value, metadata, record) {
        var account = record.get('strAccountId');
        return account;
    },

    ProfitCenterRenderer: function (value, metadata, record) {
        var profitcenter = record.get('strProfitCenter');
        return profitcenter;
    },

    CustomerRenderer: function (value, metadata, record) {
        var customer = record.get('strCustomerNumber');
        return customer;
    },

    VendorRenderer: function (value, metadata, record) {
        var vendor = record.get('strVendorId');
        return vendor;
    },

    CountryRenderer: function (value, metadata, record) {
        var country = record.get('strCountry');
        return country;
    },

    DocumentRenderer: function (value, metadata, record) {
        var document = record.get('strDocumentName');
        return document;
    },

    CertificationRenderer: function (value, metadata, record) {
        var certification = record.get('strCertificationName');
        return certification;
    },

    CountGroupRenderer: function (value, metadata, record) {
        var countgroup = record.get('strCountGroup');
        return countgroup;
    },

    CostingMethodRenderer: function (value, metadata, record) {
        var intMethod = record.get('intCostingMethod');
        var costingMethod = '';
        switch (intMethod) {
            case 1:
                costingMethod = 'AVG';
                break;
            case 2:
                costingMethod = 'FIFO';
                break;
            case 3:
                costingMethod = 'LIFO';
                break;
        }
        return costingMethod;
    },

    onGridCategoryEdit: function(editor, e, eOpts){
        var me = this;
        var record = e.record
        var column = e.column;

        if (column.itemId !== 'colPOSCategoryName')
            return;

        var grid = column.up('grid');
        var view = grid.view;

        var cboCategory = column.getEditor();
        if (cboCategory.getSelectedRecord())
        {
            var strCategory = cboCategory.getSelectedRecord().get('strCategory');
            record.set('strCategory', strCategory);
            view.refresh();
        }
    },

    onGridUOMEdit: function(editor, e, eOpts){
        var me = this;
        var record = e.record
        var column = e.column;

        if (column.itemId !== 'colUPCUnitMeasure' &&
            column.itemId !== 'colDetailUnitMeasure')
        return;

        var grid = column.up('grid');
        var view = grid.view;

        var cboUOM = column.getEditor();
        if (cboUOM.getSelectedRecord())
        {
            var strUnitMeasure = cboUOM.getSelectedRecord().get('strUnitMeasure');
            record.set('strUnitMeasure', strUnitMeasure);
            view.refresh();
        }
    },

    onGridLocationEdit: function(editor, e, eOpts){
        var me = this;
        var record = e.record
        var column = e.column;

        if (column.itemId !== 'colNoteLocation')
            return;

        var grid = column.up('grid');
        var view = grid.view;

        var cboLocation = column.getEditor();
        if (cboLocation.getSelectedRecord())
        {
            var strLocationName = cboLocation.getSelectedRecord().get('strLocationName');
            record.set('strLocationName', strLocationName);
            view.refresh();
        }
    },

    onGridDocumentEdit: function(editor, e, eOpts){
        var me = this;
        var record = e.record
        var column = e.column;

        if (column.itemId !== 'colCertification')
            return;

        var grid = column.up('grid');
        var view = grid.view;

        var cboCertification = column.getEditor();
        if (cboCertification.getSelectedRecord())
        {
            var strDocumentName = cboCertification.getSelectedRecord().get('strDocumentName');
            record.set('strDocumentName', strDocumentName);
            view.refresh();
        }
    },

    onGridCertificationEdit: function(editor, e, eOpts){
        var me = this;
        var record = e.record
        var column = e.column;

        if (column.itemId !== 'colDocument')
            return;

        var grid = column.up('grid');
        var view = grid.view;

        var cboDocument = column.getEditor();
        if (cboDocument.getSelectedRecord())
        {
            var strCertificationName = cboDocument.getSelectedRecord().get('strCertificationName');
            record.set('strCertificationName', strCertificationName);
            view.refresh();
        }
    },

    onGridAccountEdit: function(editor, e, eOpts){
        var me = this;
        var record = e.record
        var column = e.column;

        var grid = column.up('grid');
        var view = grid.view;

        if (column.itemId === 'colGLAccountLocation')
        {
            var cboLocation = column.getEditor();
            if (cboLocation.getSelectedRecord())
            {
                var strLocationName = cboLocation.getSelectedRecord().get('strLocationName');
                record.set('strLocationName', strLocationName);
                view.refresh();
            }
        }
        else if (column.itemId === 'colGLAccountId')
        {
            var cboAccount = column.getEditor();
            if (cboAccount.getSelectedRecord())
            {
                var strAccountId = cboAccount.getSelectedRecord().get('strAccountId');
                record.set('strAccountId', strAccountId);
                view.refresh();
            }
        }
        else if (column.itemId === 'colGLAccountProfitCenter')
        {
            var cboProfitCenter = column.getEditor();
            if (cboProfitCenter.getSelectedRecord())
            {
                var strProfitCenter = cboProfitCenter.getSelectedRecord().get('strProfitCenter');
                record.set('strProfitCenter', strProfitCenter);
                view.refresh();
            }
        }
    },

    onGridStockEdit: function(editor, e, eOpts){
        var me = this;
        var record = e.record
        var column = e.column;

        var grid = column.up('grid');
        var view = grid.view;

        if (column.itemId === 'colStockLocation')
        {
            var cboLocation = column.getEditor();
            if (cboLocation.getSelectedRecord())
            {
                var strLocationName = cboLocation.getSelectedRecord().get('strLocationName');
                record.set('strLocationName', strLocationName);
                view.refresh();
            }
        }
        else if (column.itemId === 'colStockUOM')
        {
            var cboUOM = column.getEditor();
            if (cboUOM.getSelectedRecord())
            {
                var strUnitMeasure = cboUOM.getSelectedRecord().get('strUnitMeasure');
                record.set('strUnitMeasure', strUnitMeasure);
                view.refresh();
            }
        }
        else if (column.itemId === 'colStockInventoryGroup')
        {
            var cboCountGroup = column.getEditor();
            if (cboCountGroup.getSelectedRecord())
            {
                var strCountGroup = cboCountGroup.getSelectedRecord().get('strCountGroup');
                record.set('strCountGroup', strCountGroup);
                view.refresh();
            }
        }
    },

    onGridPricingLevelEdit: function(editor, e, eOpts){
        var me = this;
        var record = e.record
        var column = e.column;

        var grid = column.up('grid');
        var view = grid.view;

        if (column.itemId === 'colPricingLevelLocation')
        {
            var cboLocation = column.getEditor();
            if (cboLocation.getSelectedRecord())
            {
                var strLocationName = cboLocation.getSelectedRecord().get('strLocationName');
                record.set('strLocationName', strLocationName);
                view.refresh();
            }
        }
        else if (column.itemId === 'colPricingLevelUOM')
        {
            var cboUOM = column.getEditor();
            if (cboUOM.getSelectedRecord())
            {
                var strUnitMeasure = cboUOM.getSelectedRecord().get('strUnitMeasure');
                record.set('strUnitMeasure', strUnitMeasure);
                view.refresh();
            }
        }
    },

    onGridSpecialPricingEdit: function(editor, e, eOpts){
        var me = this;
        var record = e.record
        var column = e.column;

        var grid = column.up('grid');
        var view = grid.view;

        if (column.itemId === 'colSpecialPricingLocation')
        {
            var cboLocation = column.getEditor();
            if (cboLocation.getSelectedRecord())
            {
                var strLocationName = cboLocation.getSelectedRecord().get('strLocationName');
                record.set('strLocationName', strLocationName);
                view.refresh();
            }
        }
        else if (column.itemId === 'colSpecialPricingUnit')
        {
            var cboUOM = column.getEditor();
            if (cboUOM.getSelectedRecord())
            {
                var strUnitMeasure = cboUOM.getSelectedRecord().get('strUnitMeasure');
                record.set('strUnitMeasure', strUnitMeasure);
                view.refresh();
            }
        }
    },

    onGridCustomerXrefEdit: function(editor, e, eOpts){
        var me = this;
        var record = e.record
        var column = e.column;

        var grid = column.up('grid');
        var view = grid.view;

        if (column.itemId === 'colCustomerXrefLocation')
        {
            var cboLocation = column.getEditor();
            if (cboLocation.getSelectedRecord())
            {
                var strLocationName = cboLocation.getSelectedRecord().get('strLocationName');
                record.set('strLocationName', strLocationName);
                view.refresh();
            }
        }
        else if (column.itemId === 'colCustomerXrefCustomer')
        {
            var cboCustomer = column.getEditor();
            if (cboCustomer.getSelectedRecord())
            {
                var strCustomerNumber = cboCustomer.getSelectedRecord().get('strCustomerNumber');
                record.set('strCustomerNumber', strCustomerNumber);
                view.refresh();
            }
        }
    },

    onGridVendorXrefEdit: function(editor, e, eOpts){
        var me = this;
        var record = e.record
        var column = e.column;

        var grid = column.up('grid');
        var view = grid.view;

        if (column.itemId === 'colVendorXrefLocation')
        {
            var cboLocation = column.getEditor();
            if (cboLocation.getSelectedRecord())
            {
                var strLocationName = cboLocation.getSelectedRecord().get('strLocationName');
                record.set('strLocationName', strLocationName);
                view.refresh();
            }
        }
        else if (column.itemId === 'colVendorXrefVendor')
        {
            var cboVendor = column.getEditor();
            if (cboVendor.getSelectedRecord())
            {
                var strVendorId = cboVendor.getSelectedRecord().get('strVendorId');
                record.set('strVendorId', strVendorId);
                view.refresh();
            }
        }
        else if (column.itemId === 'colVendorXrefUnitMeasure')
        {
            var cboUom = column.getEditor();
            if (cboUom.getSelectedRecord())
            {
                var strUnitMeasure = cboUom.getSelectedRecord().get('strUnitMeasure');
                record.set('strUnitMeasure', strUnitMeasure);
                view.refresh();
            }
        }
    },

    onGridContractEdit: function(editor, e, eOpts){
        var me = this;
        var record = e.record
        var column = e.column;

        var grid = column.up('grid');
        var view = grid.view;

        if (column.itemId === 'colContractLocation')
        {
            var cboLocation = column.getEditor();
            if (cboLocation.getSelectedRecord())
            {
                var strLocationName = cboLocation.getSelectedRecord().get('strLocationName');
                record.set('strLocationName', strLocationName);
                view.refresh();
            }
        }
        else if (column.itemId === 'colContractOrigin')
        {
            var cboCountry = column.getEditor();
            if (cboCountry.getSelectedRecord())
            {
                var strCountry = cboCountry.getSelectedRecord().get('strCountry');
                record.set('strCountry', strCountry);
                view.refresh();
            }
        }
    },

    onAddLocationClick: function(button, e, eOpts) {
        var win = button.up('window');
        var me = win.controller;
        me.openItemLocationScreen('new', win);
    },

    onEditLocationClick: function(button, e, eOpts) {
        var win = button.up('window');
        var me = win.controller;
        me.openItemLocationScreen('edit', win);
    },

    openItemLocationScreen: function (action, window) {
        var win = window;
        var me = win.controller;
        var screenName = 'Inventory.view.ItemLocation';

        Ext.require([
            screenName,
            screenName + 'ViewController',
        ], function() {
            var screen = screenName.substring(screenName.indexOf('view.') + 5, screenName.length);
            var view = Ext.create(screenName, { controller: screen.toLowerCase() });
            view.on('destroy', me.onDestroyItemLocationScreen, me, { window: win });

            var controller = view.getController();
            var current = win.getViewModel().data.current;
            controller.show({ id: current.get('intItemId'), action: action });
        });
    },

    onDestroyItemLocationScreen: function(win, eOpts) {
        var me = eOpts.window.getController();
        var win = eOpts.window;
        var grdLocation = win.down('#grdLocationStore');

        grdLocation.store.reload();
    },

    onAddPricingClick: function(button, e, eOpts) {
        var win = button.up('window');
        var me = win.controller;
        me.openItemPricingScreen('new', win);
    },

    onEditPricingClick: function(button, e, eOpts) {
        var win = button.up('window');
        var me = win.controller;
        me.openItemPricingScreen('edit', win);
    },

    openItemPricingScreen: function (action, window) {
        var win = window;
        var me = win.controller;
        var screenName = 'Inventory.view.ItemPricing';

        Ext.require([
            screenName,
                screenName + 'ViewController',
        ], function() {
            var screen = screenName.substring(screenName.indexOf('view.') + 5, screenName.length);
            var view = Ext.create(screenName, { controller: screen.toLowerCase() });
            view.on('destroy', me.onDestroyItemPricingScreen, me, { window: win });

            var controller = view.getController();
            var current = win.getViewModel().data.current;
            controller.show({ id: current.get('intItemId'), action: action });
        });
    },

    onDestroyItemPricingScreen: function(win, eOpts) {
        var me = eOpts.window.getController();
        var win = eOpts.window;
        var grdPricing = win.down('#grdPricing');

        grdPricing.store.reload();
    }


});