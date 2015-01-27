/*
 * File: app/view/ItemViewModel.js
 *
 * This file was generated by Sencha Architect version 3.1.0.
 * http://www.sencha.com/products/architect/
 *
 * This file requires use of the Ext JS 5.0.x library, under independent license.
 * License of Sencha Architect does not include license for Ext JS 5.0.x. For more
 * details see http://www.sencha.com/license or contact license@sencha.com.
 *
 * This file will be auto-generated each and everytime you save your project.
 *
 * Do NOT hand edit this file.
 */

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
        'AccountsPayable.store.VendorBuffered',
        'AccountsReceivable.store.CustomerBuffered',
        'i21.store.CompanyLocationBuffered',
        'i21.store.CountryBuffered',
        'GeneralLedger.store.BufAccountId'
    ],

    stores: {
        itemTypes: {
            autoLoad: true,
            data: [
                {
                    strType: 'Inventory'
                },
                {
                    strType: 'Non-Inventory'
                },
                {
                    strType: 'Assembly/Blend'
                },
                {
                    strType: 'Bundle'
                },
                {
                    strType: 'Kit'
                },
                {
                    strType: 'Manufacturing'
                },
                {
                    strType: 'Raw Material'
                },
                {
                    strType: 'Other Charge'
                },
                {
                    strType: 'Service'
                },
                {
                    strType: 'Commodity'
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
        lotTrackings: {
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
        tracking: {
            autoLoad: true,
            data: [
                {
                    intTracking: '1',
                    strDescription: 'Item Level'
                },
                {
                    intTracking: '2',
                    strDescription: 'Category Level'
                },
                {
                    intTracking: '3',
                    strDescription: 'Lot Level'
                }

            ],
            fields: [
                {
                    name: 'strDescription'
                },
                {
                    name: 'intTrackingId'
                }
            ]
        },
        uomUnitMeasure: {
            type: 'icbuffereduom'
        },


        accountDescriptions: {
            autoLoad: true,
            data: [
                {
                    strDescription: 'Sales'
                },
                {
                    strDescription: 'Purchase'
                },
                {
                    strDescription: 'Inventory'
                },
                {
                    strDescription: 'Variance'
                },
                {
                    strDescription: 'COGS'
                },
                {
                    strDescription: 'Expenses'
                },
                {
                    strDescription: 'Write Off Sold'
                },
                {
                    strDescription: 'Revalue Sold'
                },
                {
                    strDescription: 'Auto Negative'
                },
                {
                    strDescription: 'A/P Clearing'
                },
                {
                    strDescription: 'Inventory In-Transit'
                }
            ],
            fields: [
                {
                    name: 'strDescription'
                }
            ]
        },
        glAccountId: {
            type: 'bufAccountid'
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
            type: 'icbuffereduom'
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
            type: 'icbuffereduom'
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
            type: 'icbuffereduom'
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
            type: 'icbuffereduom'
        },


        bundleItem: {
            type: 'icbufferedcompactitem'
        },
        bundleUOM: {
            type: 'icbuffereduom'
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
            type: 'icbuffereduom'
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
        checkLotTrackingVisibility: function(get) {
            var isNotItemLevel = (get('current.strInventoryTracking') !== 'Item Level');
            if (isNotItemLevel) {
                this.data.current.set('strLotTracking', 'No');
            }
            return isNotItemLevel;
        }
    }

});