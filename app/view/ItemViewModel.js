Ext.define('Inventory.view.ItemViewModel', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.icitem',

    requires: [
        'Inventory.store.BufferedCompactItem',
        'Inventory.store.BufferedManufacturer',
        'Inventory.store.BufferedCategory',
        'Inventory.store.BufferedInventoryTag',
        'Inventory.store.BufferedItemUnitMeasure',
        'Inventory.store.BufferedOtherCharges',
        'Inventory.store.BufferedItemLocation',
        'Inventory.store.BufferedUnitMeasure',
        'Inventory.store.BufferedBrand',
        'Inventory.store.BufferedFuelCategory',
        'Inventory.store.BufferedFuelTaxClass',
        'Inventory.store.BufferedDocument',
        'Inventory.store.BufferedCertification',
        'Warehouse.store.BufferedItemNMFC',
        'Inventory.store.BufferedCountGroup',
        'Inventory.store.BufferedCommodity',
        'Inventory.store.BufferedClassAttribute',
        'Inventory.store.BufferedRegionAttribute',
        'Inventory.store.BufferedOriginAttribute',
        'Inventory.store.BufferedProductLineAttribute',
        'Inventory.store.BufferedProductTypeAttribute',
        'Inventory.store.BufferedSeasonAttribute',
        'Inventory.store.BufferedGradeAttribute',
        'Inventory.store.BufferedCategory',
        'Inventory.store.BufferedLotStatus',
        'EntityManagement.store.VendorBuffered',
        'EntityManagement.store.CustomerBuffered',
        'i21.store.CompanyLocationBuffered',
        'i21.store.CompanyLocationSubLocationBuffered',
        'i21.store.CountryBuffered',
        'i21.store.TaxGroupMasterBuffered',
        'i21.store.CompanyLocationPricingLevelBuffered',
        'i21.store.ModuleBuffered',
        'GeneralLedger.store.BufAccountCategoryGroup',
        //'GeneralLedger.store.BufAccountId',
        'Manufacturing.store.BufferedManufacturingCell',
        'Manufacturing.store.BufferedPackType',
        'Patronage.store.BufferedPatronageCategory',
        'TaxForm.store.BufferedTaxAuthority',
        'TaxForm.store.BufferedProductCode',
        'Inventory.store.BufferedM2MComputation',
        'i21.store.CurrencyBuffered'
    ],

    stores: {
        subLocations: {
            type: 'smcompanylocationsublocationbuffered'
        },
        m2mComputations: {
            type: 'icbufferedm2mcomputation',
            
            sorters: {
                direction: 'ASC',
                property: 'intM2MComputationId'
            },
        },
        itemTypes: {
            autoLoad: true,
            data: [
                {
                    strType: 'Bundle'
                },
                {
                    strType: 'Inventory'
                },
                {
                    strType: 'Kit'
                },
                {
                    strType: 'Finished Good'
                },
                {
                    strType: 'Non-Inventory'
                },
                {
                    strType: 'Other Charge'
                },
                {
                    strType: 'Raw Material'
                },
                {
                    strType: 'Service'
                },
                {
                    strType: 'Software'
                },
                {
                    strType: 'Comment'
                }
            ],
            fields: [
                {
                    name: 'strType'
                }
            ]
        },
        manufacturer: {
            type: 'icbufferedmanufacturer'
        },
        brand: {
            type: 'icbufferedbrand'
        },
        itemStatuses: {
            autoLoad: true,
            data: [
                {
                    strStatus: 'Active'
                },
                {
                    strStatus: 'Phased Out'
                },
                {
                    strStatus: 'Discontinued'
                }
            ],
            fields: [
                {
                    name: 'strStatus'
                }
            ]
        },
        itemCategory: {
            type: 'icbufferedcategory',
            proxy: {
                extraParams: {
                    include: 'tblICCategoryUOMs.tblICUnitMeasure, tblICCategoryAccounts.tblGLAccount, tblICCategoryAccounts.tblGLAccountCategory'
                },
                type: 'rest',
                api: {
                    read: '../Inventory/api/Category/Search'
                },
                reader: {
                    type: 'json',
                    rootProperty: 'data',
                    messageProperty: 'message'
                }
            }
        },
        categoryList: {
            autoLoad: true,
            type: 'icbufferedcategory',
            proxy: {
                extraParams: {
                    include: 'tblICCategoryUOMs.tblICUnitMeasure, tblICCategoryAccounts.tblGLAccount, tblICCategoryAccounts.tblGLAccountCategory'
                },
                type: 'rest',
                api: {
                    read: '../Inventory/api/Category/Search'
                },
                reader: {
                    type: 'json',
                    rootProperty: 'data',
                    messageProperty: 'message'
                }
            }
        },
        lotTracking: {
            autoLoad: true,
            data: [
                {
                    strLotTracking: 'Yes - Manual'
                },
                {
                    strLotTracking: 'Yes - Serial Number'
                },
                {
                    strLotTracking: 'Yes - Manual/Serial Number'
                },                
                {
                    strLotTracking: 'No'
                }
            ],
            fields: [
                {
                    name: 'strLotTracking'
                }
            ]
        },
        invTracking: {
            autoLoad: true,
            data: [
                {
                    strDescription: 'Item Level'
                },
                {
                    strDescription: 'Category Level'
                }
            ],
            fields: [
                {
                    name: 'strDescription'
                }
            ]
        },
        weightUOMs: {
            model: Ext.create('Ext.data.Model', {
                idProperty: 'id',
                fields: [
                    { name: 'intUnitMeasureId', type: 'int' },
                    { name: 'strUnitMeasure', type: 'string' },
                    { name: 'strUnitType', type: 'string' },
                    { name: 'strSymbol', type: 'string' }
                ]
            }),
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/Item/GetItemUOMsByType'
                },
                extraParams: {
                    intItemId: '{current.intItemId}',
                    strUnitType: 'Weight'   
                },
                reader: {
                    type: 'json',
                    rootProperty: 'data',
                    messageProperty: 'message'
                }
            }
        },
        uomUnitMeasure: {
            type: 'icbuffereduom'
        },
        uomTonnageTax: {
            type: 'icbuffereduom',
            sorters: {
                direction: 'ASC',
                property: 'strUnitMeasure'
            }
        },
        uomConversion: {
            autoLoad: true,
            type: 'icbuffereduom'
        },
        weightUOM: {
            type: 'icbuffereduom'
        },
        dimensionUOM: {
            type: 'icbuffereduom'
        },
        volumeUOM: {
            type: 'icbuffereduom'
        },


        accountCategory: {
            type: 'glbufaccountcategorygroup'
        },
        accountCategoryList: {
            autoLoad: true,
            type: 'glbufaccountcategorygroup'
        },
        copyLocation: {
            type: 'icbuffereditemlocation'
        },

        patronage: {
            type: 'patbufferedpatronagecategory'
        },
        directSale: {
            type: 'patbufferedpatronagecategory'
        },
        taxClass: {
            type: 'icbufferedfueltaxclass'
        },
        salesTaxGroup: {
            type: 'smtaxgroupmasterbuffered'
        },
        purchaseTaxGroup: {
            type: 'smtaxgroupmasterbuffered'
        },
        barcodePrints: {
            autoLoad: true,
            data: [
                {
                    strDescription: 'UPC'
                },
                {
                    strDescription: 'Item'
                },
                {
                    strDescription: 'None'
                }
            ],
            fields: [
                {
                    name: 'strDescription'
                }
            ]
        },
        drugCategory: {
            autoLoad: true,
            data: [
                {
                    strDescription: 'MSDS'
                },
                {
                    strDescription: 'VFD Order'
                }
            ],
            fields: [
                {
                    name: 'strDescription'
                }
            ]
        },
        fuelInspectFees: {
            autoLoad: true,
            data: [
                {
                    strDescription: 'Yes (Fuel Item)'
                },
                {
                    strDescription: 'No (Not Fuel Item)'
                },
                {
                    strDescription: 'No (Fuel Item)'
                }
            ],
            fields: [
                {
                    name: 'strDescription'
                }
            ]
        },
        rinRequires: {
            autoLoad: true,
            data: [
                {
                    strDescription: 'No RIN'
                },
                {
                    strDescription: 'Resell RIN Only'
                },
                {
                    strDescription: 'Issued'
                }
            ],
            fields: [
                {
                    name: 'strDescription'
                }
            ]
        },
        fuelCategory: {
            type: 'icbufferedfuelcategory'
        },
        medicationTag: {
            type: 'icbufferedtag'
        },
        ingredientTag: {
            type: 'icbufferedtag'
        },
        physicalItem: {
            type: 'icbufferedcompactitem'
        },
        maintenancaCalculationMethods: {
            autoLoad: true,
            data: [
                {
                    strDescription: 'Percentage'
                },
                {
                    strDescription: 'Fixed'
                }
            ],
            fields: [
                {
                    name: 'strDescription'
                }
            ]
        },
        module: {
            type: 'smmodulebuffered'
        },
        costMethods: {
            autoLoad: true,
            data: [
                {
                    strDescription: 'Per Unit'
                },
                {
                    strDescription: 'Percentage'
                },
                {
                    strDescription: 'Amount'
                }
            ],
            fields: [
                {
                    name: 'strDescription'
                }
            ]
        },
        costTypes: {
            autoLoad: true,
            data: [
                {
                    strDescription: 'Freight'
                },
                {
                    strDescription: 'Other Charges',
                }
                ,
                {
                    strDescription: 'Discount',
                }
                ,
                {
                    strDescription: 'Storage Charge',
                }
            ],
            fields: [
                {
                    name: 'strDescription'
                }
            ]
        },
        otherCharges: {
            type: 'icbufferedothercharges'
        },
        costUOM: {
            type: 'icbuffereditemunitmeasure'
        },


        posUom: {
            type: 'icbuffereduom'
        },
        wicCodes: {
            autoLoad: true,
            data: [
                {
                    strDescription: 'Woman'
                },
                {
                    strDescription: 'Infant'
                },
                {
                    strDescription: 'Child'
                }
            ],
            fields: [
                {
                    name: 'strDescription'
                }
            ]
        },
        agCategory: {
            type: 'icbufferedcategory'
        },
        countCodes: {
            autoLoad: true,
            data: [
                {
                    strDescription: 'Item'
                },{
                    strDescription: 'Package'
                },{
                    strDescription: 'Cases'
                }
            ],
            fields: [
                {
                    name: 'strDescription'
                }
            ]
        },
        posCategory: {
            type: 'icbufferedcategory'
        },


        lifeTimeTypes: {
            autoLoad: true,
            data: [
                {
                    strDescription: 'Minutes'
                },{
                    strDescription: 'Hours'
                },{
                    strDescription: 'Days'
                },{
                    strDescription: 'Months'
                },{
                    strDescription: 'Years'
                }
            ],
            fields: [
                {
                    name: 'strDescription'
                }
            ]
        },
        rotationTypes: {
            autoLoad: true,
            data: [
                {
                    strDescription: 'FIFO'
                },
                {
                    strDescription: 'LIFO'
                },
                {
                    strDescription: 'NONE'
                }
            ],
            fields: [
                {
                    name: 'strDescription'
                }
            ]
        },
        materialNMFC: {
            type: 'whbuffereditemnmfc'
        },
        mfgDimensionUom: {
            type: 'icbuffereduom'
        },
        mfgWeightUom: {
            type: 'icbuffereduom'
        },
        packType: {
            type: 'mfbufferedpacktype'
        },
        owner: {
            type: 'customerbuffered'
        },
        customer: {
            type: 'customerbuffered'
        },
        warehouseStatus: {
            autoLoad: true,
            data: [
                {
                    strDescription: 'Release'
                },
                {
                    strDescription: 'Hold'
                }
            ],
            fields: [
                {
                    name: 'strDescription'
                }
            ]
        },


        upcUom: {
            type: 'icbuffereditemunitmeasure'
        },


        custXrefLocation: {
            type: 'icbuffereditemlocation'
        },
        custXrefCustomer: {
            type: 'customerbuffered'
        },
        vendorXrefLocation: {
            type: 'icbuffereditemlocation'
        },
        vendorXrefVendor: {
            type: 'emvendorbuffered'
        },
        vendorXrefUom: {
            type: 'icbuffereditemunitmeasure'
        },

        taxAuthority: {
            type: 'tfbufferedtaxauthority'
        },
        productCode: {
            type: 'tfbufferedproductcode'
        },

        contractLocation: {
            type: 'icbuffereditemlocation'
        },
        origin: {
            type: 'countrybuffered'
        },
        document: {
            type: 'icbuffereddocument'
        },
        certification: {
            type: 'icbufferedcertification'
        },

        pricingLocation: {
            type: 'icbuffereditemlocation'
        },
        pricingPricingMethods: {
            data: [
                {
                    strDescription: 'None'
                },
                {
                    strDescription: 'Fixed Dollar Amount'
                },
                {
                    strDescription: 'Markup Standard Cost'
                },
                {
                    strDescription: 'Percent of Margin'
                }
            ],
            fields: [
                {
                    name: 'strDescription'
                }
            ]
        },

        pricingLevelLocation: {
            type: 'icbuffereditemlocation'
        },
        pricingLevel: {
            type: 'smcompanylocationpricinglevelbuffered'
        },
        pricingLevelUOM: {
            type: 'icbuffereditemunitmeasure'
        },

        pricingMethods: {
            autoLoad: true,
            data: [
                {
                    strDescription: 'None'
                },
                {
                    strDescription: 'Fixed Dollar Amount'
                },
                {
                    strDescription: 'Markup Standard Cost'
                },
                {
                    strDescription: 'Percent of Margin'
                },
                {
                    strDescription: 'Discount Retail Price'
                },
                {
                    strDescription: 'MSRP Discount'
                },
                {
                    strDescription: 'Percent of Margin (MSRP)'
                }
            ],
            fields: [
                {
                    name: 'strDescription'
                }
            ]
        },
        commissionsOn:{
            autoLoad: true,
            data: [
                {
                    strDescription: 'Percent'
                },{
                    strDescription: 'Units'
                },{
                    strDescription: 'Amount'
                },{
                    strDescription: 'Gross Profit'
                }
            ],
            fields: [
                {
                    name: 'strDescription'
                }
            ]
        },
        specialPricingLocation: {
            type: 'icbuffereditemlocation'
        },
        promotionTypes:{
            autoLoad: true,
            data: [
                {
                    strDescription: 'Rebate'
                },{
                    strDescription: 'Discount'
                },{
                    strDescription: 'Vendor Discount'
                },{
                    strDescription: 'Terms Discount'
                }
            ],
            fields: [
                {
                    name: 'strDescription'
                }
            ]
        },
        specialPricingUOM: {
            type: 'icbuffereditemunitmeasure'
        },
        discountsBy:{
            autoLoad: true,
            data: [
                {
                    strDescription: 'Percent'
                },{
                    strDescription: 'Amount'
                },{
                    strDescription: 'Terms Rate'
                }
            ],
            fields: [
                {
                    name: 'strDescription'
                }
            ]
        },


        stockLocation: {
            type: 'icbuffereditemlocation'
        },
        stockUOM: {
            type: 'icbuffereditemunitmeasure'
        },


        commodity: {
            type: 'icbufferedcommodity',
            proxy: {
                extraParams: {
                    include: 'tblICCommodityUnitMeasures.tblICUnitMeasure, tblICCommodityAccounts.tblGLAccount, tblICCommodityAccounts.tblGLAccountCategory'
                },
                type: 'rest',
                api: {
                    read: '../Inventory/api/Commodity/Search'
                },
                reader: {
                    type: 'json',
                    rootProperty: 'data',
                    messageProperty: 'message'
                }
            }
        },
        commodityList: {
            autoLoad: true,
            type: 'icbufferedcommodity',
            proxy: {
                extraParams: {
                    include: 'tblICCommodityUnitMeasures.tblICUnitMeasure, tblICCommodityAccounts.tblGLAccount, tblICCommodityAccounts.tblGLAccountCategory'
                },
                type: 'rest',
                api: {
                    read: '../Inventory/api/Commodity/Search'
                },
                reader: {
                    type: 'json',
                    rootProperty: 'data',
                    messageProperty: 'message'
                }
            }
        },
        originAttribute: {
            type: 'icbufferedoriginattribute'
        },
        productTypeAttribute: {
            type: 'icbufferedproducttypeattribute'
        },
        regionAttribute: {
            type: 'icbufferedregionattribute'
        },
        seasonAttribute: {
            type: 'icbufferedseasonattribute'
        },
        classAttribute: {
            type: 'icbufferedclassattribute'
        },
        productLineAttribute: {
            type: 'icbufferedproductlineattribute'
        },
        gradeAttribute: {
            type: 'icbufferedgradeattribute'
        },
        marketValuations:{
            autoLoad: true,
            data: [
                {
                    strDescription: 'Outright Price'
                },{
                    strDescription: 'Futures + Basis/Differential/Premium Price'
                }
            ],
            fields: [
                {
                    name: 'strDescription'
                }
            ]
        },
        commodityLocations: {
            type: 'icbuffereditemlocation'
        },


        assemblyItem: {
            type: 'icbufferedcompactitem',
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/Item/SearchAssemblyComponents'
                },
                reader: {
                    type: 'json',
                    rootProperty: 'data',
                    messageProperty: 'message'
                }
            }
        },
        assemblyUOM: {
            type: 'icbuffereditemunitmeasure'
        },


        bundleItem: {
            type: 'icbufferedcompactitem'
        },
        bundleUOM: {
            type: 'icbuffereditemunitmeasure'
        },


        inputTypes:{
            autoLoad: true,
            data: [
                {
                    strDescription: 'Included - Hidden'
                },{
                    strDescription: 'Included - Shown'
                },{
                    strDescription: 'Drop Down'
                },{
                    strDescription: 'Radio Button'
                },{
                    strDescription: 'Check Box'
                }
            ],
            fields: [
                {
                    name: 'strDescription'
                }
            ]
        },
        kitItem: {
            type: 'icbufferedcompactitem'
        },
        kitUOM: {
            type: 'icbuffereditemunitmeasure'
        },

        factory: {
            type: 'companylocationbuffered'
        },
        factoryManufacturingCell: {
            type: 'mfbufferedmanufacturingcell'
        },
        owner: {
            type: 'customerbuffered'
        },

        noteLocation: {
            type: 'icbuffereditemlocation'
        },
        commentTypes: {
            autoLoad: true,
            data: [
                {
                    strDescription: 'Invoice'
                },{
                    strDescription: 'Pick Ticket'
                },{
                    strDescription: 'Others'
                }
            ],
            fields: [
                {
                    name: 'strDescription'
                }
            ]
        },
        
        lotStatus: {
            type: 'icbufferedlotstatus',
            proxy: {
                type: 'rest',
                api: {
                    read: '../Inventory/api/LotStatus/Get'
                },
                reader: {
                    type: 'json',
                    rootProperty: 'data',
                    messageProperty: 'message'
                }
            },
            sortOnLoad: true,
            sorters: {
                direction: 'ASC',
                property: 'intSort'
            }
        },
        currency: {
            type: 'currencybuffered'
        }
    },
    

    formulas: {
        accountCategoryFilter: function(get) {
            var category = get('grdGlAccounts.selection.strAccountCategory');
            switch(category) {
                case 'AP Clearing':
                case 'Inventory':
                case 'Work In Progress':
                case 'Inventory In-Transit':
                    return category;
                default:
                    return 'General|^|' + category;
            }
        },

        checkLotTracking: function (get) {
            if (get('current.strLotTracking') === 'No') {
                this.data.current.set('strInventoryTracking', 'Item Level');
                return true;
            }
            else {
                if (get('current.strType') === 'Comment') {
                        this.data.current.set('strInventoryTracking', null);
                    }
                else {
                        this.data.current.set('strInventoryTracking', 'Lot Level');
                    }
                return true;
            }
        },
        hideBuildAssembly: function (get) {
            return true;
//            if (get('current.strLotTracking') === 'No' && get('current.strType') === 'Assembly/Blend') {
//                return false;
//            }
//            else {
//                return true;
//            }
        },
        readOnlyCommodity: function (get) {
            //For Discount Item
            var itemId = get('current.intItemId');
            var me = this;           

           if (get('current.strType') === 'Other Charge' && get('current.strCostType') === 'Discount') {
               
               var success = function (option, success, serverResponse)
                {
                   var RequiredData = serverResponse;

                    if (RequiredData.intItemUsedInDiscountCode === 1) {
                       me.data.current.set('ysnItemUsedInDiscountCode', true);
                    }   

                    else {
                      me.data.current.set('ysnItemUsedInDiscountCode', false); 
                    }

                }
                i21.ModuleMgr.Grain.IsItemUsedInDiscountCode(itemId, success);     

               var usedInDiscountStatus = get('current.ysnItemUsedInDiscountCode');        
               
               if(usedInDiscountStatus === true) {
                     return true;  
                }
               
                else {
                    return false;
                }
            }
            
            else {
                 switch (get('current.strType')) {
                    case 'Kit':
                    case 'Non-Inventory':
                    case 'Service':
                    case 'Software':
                    //case 'Bundle':
                    case 'Comment':
                        this.data.current.set('intCommodityId', null);
                        return true;
                        break;
                    default:
                        return false;
                        break;
                  };
            }

        },
        readOnlyBundle: function (get) {
            switch (get('current.strType')) {
                case 'Bundle':
                    return true;
                    break;
                default:
                    return false;
                    break;
            };
        },
        checkStockTracking: function (get) {
            var isNotStockTracked = false;

            switch (get('current.strType')) {
                case 'Assembly/Blend':
                    isNotStockTracked = false;
                    break;
                case 'Bundle':
                    isNotStockTracked = true;
                    break;
                case 'Inventory':
                    isNotStockTracked = false;
                    break;
                case 'Kit':
                    isNotStockTracked = true;
                    break;
                case 'Manufacturing':
                    isNotStockTracked = false;
                    break;
                case 'Non-Inventory':
                    isNotStockTracked = true;
                    break;
                case 'Other Charge':
                    isNotStockTracked = true;
                    break;
                case 'Service':
                    isNotStockTracked = true;
                    break;
                case 'Software':
                    isNotStockTracked = true;
                    break;
                case 'Raw Material':
                    isNotStockTracked = false;
                    break;
                case 'Comment':
                    isNotStockTracked = true;
                    break;
            };

            if (isNotStockTracked) {
                this.data.current.set('strLotTracking', 'No');
            }

            return isNotStockTracked;
        },
        checkPerUnitCostMethod: function(get) {
            if (get('current.strCostMethod') !== 'Per Unit') {
                this.data.current.set('intCostUOMId', null);
                return true;
            }
            else
                return false;
        },
        pgeStockHide: function(get) {
            switch(get('current.strType')) {
                case 'Assembly':
                case 'Assembly/Blend':
                case 'Assembly/Formula/Blend':
                case 'Inventory Item':
                case 'Inventory':
                case 'Manufacturing Item':
                case 'Manufacturing':
                case 'Finished Good' :
                case 'Raw Material':
                    return false;
                    break;

                case 'Bundle':
                case 'Kit':
                case 'Software':
                case 'Non-Inventory':
                case 'Other Charge':
                case 'Service':
                case 'Comment':
                    return true;
                    break;
            }
        },
        pgeCommodityHide: function(get) {
            if (get('current.intCommodityId')) {
                return false;
            }
            else {
                return true;
            }
        },
        pgeAssemblyHide: function(get) {
            switch(get('current.strType')) {
                case 'Assembly':
                case 'Assembly/Blend':
                case 'Assembly/Formula/Blend':
                    return false;
                    break;

                case 'Bundle':
                case 'Inventory Item':
                case 'Inventory':
                case 'Kit':
                case 'Manufacturing Item':
                case 'Manufacturing':
                case 'Finished Good' :
                case 'Software':
                case 'Non-Inventory':
                case 'Other Charge':
                case 'Service':
                case 'Raw Material':
                case 'Comment':
                    return true;
                    break;
            }
        },
        pgeBundleHide: function(get) {
            switch(get('current.strType')) {
                case 'Bundle':
                    return false;
                    break;

                case 'Assembly':
                case 'Assembly/Blend':
                case 'Assembly/Formula/Blend':
                case 'Inventory Item':
                case 'Inventory':
                case 'Kit':
                case 'Manufacturing Item':
                case 'Manufacturing':
                case 'Finished Good' :
                case 'Software':
                case 'Non-Inventory':
                case 'Other Charge':
                case 'Service':
                case 'Raw Material':
                case 'Comment':
                    return true;
                    break;
            }
        },
        pgeKitHide: function(get) {
            switch(get('current.strType')) {
                case 'Kit':
                    return false;
                    break;

                case 'Assembly':
                case 'Assembly/Blend':
                case 'Assembly/Formula/Blend':
                case 'Bundle':
                case 'Inventory Item':
                case 'Inventory':
                case 'Manufacturing Item':
                case 'Manufacturing':
                case 'Finished Good' :
                case 'Software':
                case 'Non-Inventory':
                case 'Other Charge':
                case 'Service':
                case 'Raw Material':
                case 'Comment':
                    return true;
                    break;
            }
        },
        pgeFactoryHide: function(get) {
            switch(get('current.strType')) {
                case 'Assembly':
                case 'Assembly/Blend':
                case 'Assembly/Formula/Blend':
                case 'Manufacturing Item':
                case 'Manufacturing':
                case 'Finished Good' :
                case 'Raw Material':
                    return false;
                    break;

                case 'Bundle':
                case 'Inventory Item':
                case 'Inventory':
                case 'Kit':
                case 'Software':
                case 'Non-Inventory':
                case 'Other Charge':
                case 'Service':
                case 'Comment':
                    return true;
                    break;
            }
        },
        pgeSalesHide: function(get) {
            switch(get('current.strType')) {
                case 'Assembly':
                case 'Assembly/Blend':
                case 'Assembly/Formula/Blend':
                case 'Bundle':
                case 'Inventory Item':
                case 'Inventory':
                case 'Kit':
                case 'Manufacturing Item':
                case 'Manufacturing':
                case 'Finished Good' :
                case 'Software':
                case 'Raw Material':
                    return false;
                    break;

                case 'Non-Inventory':
                case 'Other Charge':
                case 'Service':
                case 'Comment':
                    return true;
                    break;
            }
        },
        pgePOSHide: function(get) {
            switch(get('current.strType')) {
                case 'Assembly':
                case 'Assembly/Blend':
                case 'Assembly/Formula/Blend':
                case 'Bundle':
                case 'Inventory Item':
                case 'Inventory':
                case 'Kit':
                    return false;
                    break;

                case 'Manufacturing Item':
                case 'Manufacturing':
                case 'Finished Good' :
                case 'Software':
                case 'Non-Inventory':
                case 'Other Charge':
                case 'Service':
                case 'Raw Material':
                case 'Comment':
                    return true;
                    break;
            }
        },
        pgeManufacturingHide: function(get) {
            switch(get('current.strType')) {
                case 'Assembly':
                case 'Assembly/Blend':
                case 'Assembly/Formula/Blend':
                case 'Manufacturing Item':
                case 'Manufacturing':
                case 'Finished Good' :
                case 'Raw Material':
                    if (get('current.intLotStatusId') === null) {
                      this.data.current.set('intLotStatusId', 1);  
                    }
                    return false;
                    break;

                case 'Bundle':
                case 'Inventory Item':
                case 'Inventory':
                case 'Kit':
                case 'Software':
                case 'Non-Inventory':
                case 'Other Charge':
                case 'Service':
                case 'Comment':
                    return true;
                    break;
            }
        },
        pgeContractHide: function(get) {
            switch(get('current.strType')) {
                case 'Software':
                case 'Non-Inventory':
                case 'Other Charge':
                case 'Service':
                case 'Comment':
                    return true;
                    break;

                case 'Assembly':
                case 'Assembly/Blend':
                case 'Assembly/Formula/Blend':
                case 'Bundle':
                case 'Inventory Item':
                case 'Inventory':
                case 'Kit':
                case 'Manufacturing Item':
                case 'Manufacturing':
                case 'Finished Good' :
                case 'Raw Material':
                    return false;
                    break;
            }
        },
        pgeXrefHide: function(get) {
            switch(get('current.strType')) {
                case 'Assembly':
                case 'Assembly/Blend':
                case 'Assembly/Formula/Blend':
                case 'Bundle':
                case 'Inventory Item':
                case 'Inventory':
                case 'Kit':
                case 'Manufacturing Item':
                case 'Manufacturing':
                case 'Finished Good' :
                case 'Non-Inventory':
                case 'Service':
                case 'Raw Material':
                    return false;
                    break;

                case 'Other Charge':
                case 'Software':
                case 'Comment':
                    return true
                    break;
            }
        },
        pgeCostHide: function(get) {
            switch(get('current.strType')) {
                case 'Other Charge':
                    return false;
                    break;

                case 'Assembly':
                case 'Assembly/Blend':
                case 'Assembly/Formula/Blend':
                case 'Bundle':
                case 'Inventory Item':
                case 'Inventory':
                case 'Kit':
                case 'Manufacturing Item':
                case 'Manufacturing':
                case 'Finished Good' :
                case 'Non-Inventory':
                case 'Software':
                case 'Service':
                case 'Raw Material':
                case 'Comment':
                    return true
                    break;
            }
        },
        pgeOthersHide: function(get) {
            switch(get('current.strType')) {
                case 'Bundle':
                case 'Inventory Item':
                case 'Inventory':
                case 'Finished Good' :
                case 'Non-Inventory':
                case 'Other Charge':
                case 'Service':
                case 'Raw Material':
                    return false;
                    break;

                case 'Assembly':
                case 'Assembly/Blend':
                case 'Assembly/Formula/Blend':
                case 'Kit':
                case 'Manufacturing Item':
                case 'Manufacturing':
                case 'Software':
                case 'Comment':
                    return true;
                    break;
            }
        },
        HideDisableForComment: function(get) {
            if(get('current.strType') === 'Comment') {
                    this.data.current.set('strStatus', null);
                    this.data.current.set('strInventoryTracking', null);
                    this.data.current.set('strLotTracking', null);
                    this.data.current.set('ysnListBundleSeparately', null);
                    this.data.current.set('strShortName', null);
                    this.data.current.set('intManufacturerId', null);
                    this.data.current.set('intBrandId', null);
                    this.data.current.set('strModelNo', null);
                    this.data.current.set('intCategoryId', null);
                    return true;
                }
            else {
                    return false;
                }
        },
        readOnlyCostMethod: function (get) {
            if (iRely.Functions.isEmpty(get('current.intOnCostTypeId'))) {
                return false;
            }
            else {
                this.data.current.set('strCostMethod', 'Percentage');
                return true;
            }
        },
        hiddenNotSoftware: function (get) {
            if (get('current.strType') === 'Software') {
                return false;
            }
            else {
                return true;
            }
        },
        readOnlyLongUPC: function(get) {
            if (iRely.Functions.isEmpty(get('grdUnitOfMeasure.selection.strUpcCode'))) {
                return false;
            }
            else {
                return true;
            }
        },
        readOnlyStockUnit: function(get) {
            if (get('grdUnitOfMeasure.selection.ysnStockUnit') === false) {
                return false;
            }
            else {
                return true;
            }
        },
        readOnlyOnBundleItems: function(get) {
            if (get('current.strType') === 'Bundle') {
                return true;
            }
            else {
                return false;
            }
        },
        readOnlyForDiscountType: function(get) {
            var itemId = get('current.intItemId');
            var me = this;           

           if (get('current.strType') === 'Other Charge' && get('current.strCostType') === 'Discount') {
               
               var success = function (option, success, serverResponse)
                {
                   var RequiredData = serverResponse;

                    if (RequiredData.intItemUsedInDiscountCode === 1) {
                       me.data.current.set('ysnItemUsedInDiscountCode', true);
                    }   

                    else {
                      me.data.current.set('ysnItemUsedInDiscountCode', false); 
                    }

                }
                i21.ModuleMgr.Grain.IsItemUsedInDiscountCode(itemId, success);     

               var usedInDiscountStatus = get('current.ysnItemUsedInDiscountCode');        
               
               if(usedInDiscountStatus === true) {
                     return true;  
                }
               
                else {
                    return false;
                }
            }
            
            else if(get('current.strType') === 'Comment') {
                return true;
            }
                
            else {
                    return false;
            }
        }
    }

});