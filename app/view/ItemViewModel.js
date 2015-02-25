Ext.define('Inventory.view.ItemViewModel', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.icitem',

    requires: [
        'Inventory.store.BufferedCompactItem',
        'Inventory.store.BufferedManufacturer',
        'Inventory.store.BufferedManufacturingCell',
        'Inventory.store.BufferedCategory',
        'Inventory.store.BufferedPatronageCategory',
        'Inventory.store.BufferedInventoryTag',
        'Inventory.store.BufferedItemUnitMeasure',
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
        'AccountsPayable.store.VendorBuffered',
        'AccountsReceivable.store.CustomerBuffered',
        'i21.store.CompanyLocationBuffered',
        'i21.store.CountryBuffered',
        'GeneralLedger.store.BufAccountId',
        'GeneralLedger.store.BufAccountCategory'
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
                    strType: 'Manufacturing'
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
            type: 'icbufferedcategory'
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
            type: 'glbufaccountcategory'
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
            type: 'vendorbuffered'
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
                    strDescription: 'Discount Sales Price'
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
                    strDescription: 'Customer Discount'
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


        assemblyItem: {
            type: 'icbufferedcompactitem'
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
            type: 'icbufferedmanufacturingcell'
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
        formatUOMDisplayDecimal: function (get) {
            return i21.ModuleMgr.Inventory.createNumberFormat(get('current.intDecimalDisplay'));
        },
        formatUOMCalculationDecimal: function (get) {
            return i21.ModuleMgr.Inventory.createNumberFormat(get('current.intDecimalCalculation'));
        },
        checkLotTracking: function (get) {
            if (get('current.strLotTracking') === 'No') {
                this.data.current.set('strInventoryTracking', 'Item Level');
                return false;
            }
            else {
                this.data.current.set('strInventoryTracking', 'Lot Level');
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
        }
    }

});