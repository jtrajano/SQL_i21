Ext.define('Inventory.view.ItemViewModel', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.icitem',

    requires: [
        'Inventory.store.BufferedCompactItem',
        'Inventory.store.BufferedManufacturer',
        'Inventory.store.BufferedCategory',
        'Inventory.store.BufferedPatronageCategory',
        'Inventory.store.BufferedInventoryTag',
        'Inventory.store.BufferedItemUnitMeasure',
        'Inventory.store.BufferedOtherCharges',
        'Inventory.store.BufferedItemLocation',
        'Inventory.store.BufferedUnitMeasure',
        'Inventory.store.BufferedPricingLevel',
        'Inventory.store.BufferedBrand',
        'Inventory.store.BufferedFuelCategory',
        'Inventory.store.BufferedFuelTaxClass',
        'Inventory.store.BufferedDocument',
        'Inventory.store.BufferedCertification',
        'Inventory.store.BufferedMaterialNMFC',
        'Inventory.store.BufferedCountGroup',
        'Inventory.store.BufferedCommodity',
        'Inventory.store.BufferedClassAttribute',
        'Inventory.store.BufferedRegionAttribute',
        'Inventory.store.BufferedOriginAttribute',
        'Inventory.store.BufferedProductLineAttribute',
        'Inventory.store.BufferedProductTypeAttribute',
        'Inventory.store.BufferedSeasonAttribute',
        'Inventory.store.BufferedCategory',
        'EntityManagement.store.VendorBuffered',
        'EntityManagement.store.CustomerBuffered',
        'i21.store.CompanyLocationBuffered',
        'i21.store.CountryBuffered',
        'i21.store.TaxGroupMasterBuffered',
        'GeneralLedger.store.BufAccountId',
        'GeneralLedger.store.BufAccountCategoryGroup',
        'Manufacturing.store.BufferedManufacturingCell'
    ],

    stores: {
        itemTypes: {
            autoLoad: true,
            data: [
                {
                    strType: 'Assembly/Blend'
                },
                {
                    strType: 'Bundle'
                },
                {
                    strType: 'Commodity'
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
                    include: 'tblICCategoryUOMs.tblICUnitMeasure'
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
        uomUnitMeasure: {
            type: 'icbuffereduom'
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
        glAccountId: {
            type: 'glbufaccountid'
        },


        patronage: {
            type: 'icbufferedpatronagecategory'
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
            type: 'icbufferedmaterialnmfc'
        },
        mfgDimensionUom: {
            type: 'icbuffereduom'
        },
        mfgWeightUom: {
            type: 'icbuffereduom'
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
            type: 'icbufferedpricinglevel'
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
            type: 'icbufferedcommodity'
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
                    read: '../Inventory/api/Item/GetAssemblyComponents'
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
        }

    },

    formulas: {
        checkLotTracking: function (get) {
            if (get('current.strLotTracking') === 'No') {
                this.data.current.set('strInventoryTracking', 'Item Level');
                return true;
            }
            else {
                this.data.current.set('strInventoryTracking', 'Lot Level');
                return true;
            }
        },
        hideBuildAssembly: function (get) {
            if (get('current.strLotTracking') === 'No' && get('current.strType') === 'Assembly/Blend') {
                return false;
            }
            else {
                return true;
            }
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
                case 'Commodity':
                    isNotStockTracked = false;
                    break;
                case 'Raw Material':
                    isNotStockTracked = false;
                    break;
            };

            if (isNotStockTracked) {
                this.data.current.set('strLotTracking', 'No');
            }

            return isNotStockTracked;
        },
        checkCommodityType: function (get) {
            if (get('current.strType') === 'Commodity')
                return true;
            else
                return false;
        },
        checkNotCommodityType: function (get) {
            if (get('current.strType') !== 'Commodity')
                return true;
            else
                return false;
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
                case 'Commodity':
                case 'Raw Material':
                    return false;
                    break;

                case 'Bundle':
                case 'Kit':
                case 'Software':
                case 'Non-Inventory':
                case 'Other Charge':
                case 'Service':
                    return true;
                    break;
            }
        },
        pgeCommodityHide: function(get) {
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
                case 'Non-Inventory':
                case 'Other Charge':
                case 'Service':
                case 'Raw Material':
                    return true;
                    break;

                case 'Commodity':
                    return false
                    break;
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
                case 'Commodity':
                case 'Raw Material':
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
                case 'Commodity':
                case 'Raw Material':
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
                case 'Commodity':
                case 'Raw Material':
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
                case 'Commodity':
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
                case 'Commodity':
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
                case 'Commodity':
                case 'Raw Material':
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
                case 'Commodity':
                    return true;
                    break;
            }
        },
        pgeContractHide: function(get) {
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
                case 'Non-Inventory':
                case 'Other Charge':
                case 'Service':
                case 'Commodity':
                case 'Raw Material':
                    return true;
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
                case 'Other Charge':
                case 'Service':
                case 'Commodity':
                case 'Raw Material':
                    return false;
                    break;

                case 'Software':
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
                case 'Commodity':
                case 'Raw Material':
                    return true
                    break;
            }
        }
    }

});