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
    alias: 'viewmodel.item',

    requires: [
        'Inventory.store.BufferedCompactItem',
        'Inventory.store.BufferedManufacturer',
        'Inventory.store.BufferedManufacturingCell',
        'Inventory.store.BufferedCategory',
        'Inventory.store.BufferedPatronageCategory',
        'Inventory.store.BufferedInventoryTag',
        'Inventory.store.BufferedUnitMeasure',
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
                    strType: 'Assembly'
                },
                {
                    strType: 'Bundle'
                },
                {
                    strType: 'Inventory Item'
                },
                {
                    strType: 'Kit'
                },
                {
                    strType: 'Manufacturing Item'
                },
                {
                    strType: 'Matrix Group'
                },
                {
                    strType: 'Non-Inventory'
                },
                {
                    strType: 'Other Charge'
                },
                {
                    strType: 'Service'
                },
                {
                    strType: 'Commodity'
                },
                {
                    strType: 'PreMix Item'
                },
                {
                    strType: 'Raw Material'
                },
                {
                    strType: 'Finished Goods'
                }
            ],
            fields: [
                {
                    name: 'strType'
                }
            ]
        },
        manufacturer: {
            type: 'inventorybufferedmanufacturer'
        },
        brand: {
            type: 'inventorybufferedbrand'
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
            type: 'inventorybuffereduom'
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
                    strDescription: 'Variance'
                },
                {
                    strDescription: 'COGS'
                },
                {
                    strDescription: 'Expenses'
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
            type: 'inventorybufferedpatronagecategory'
        },
        taxClass: {
            type: 'inventorybufferedfueltaxclass'
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
            type: 'inventorybufferedfuelcategory'
        },
        medicationTag: {
            type: 'inventorybufferedtag'
        },
        ingredientTag: {
            type: 'inventorybufferedtag'
        },
        physicalItem: {
            type: 'inventorybufferedcompactitem'
        },


        posUom: {
            type: 'inventorybuffereduom'
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
            type: 'inventorybufferedcategory'
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
            type: 'inventorybufferedcategory'
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
            type: 'inventorybufferedmaterialnmfc'
        },
        mfgDimensionUom: {
            type: 'inventorybuffereduom'
        },
        mfgWeightUom: {
            type: 'inventorybuffereduom'
        },


        upcUom: {
            type: 'inventorybuffereduom'
        },


        custXrefLocation: {
            type: 'companylocationbuffered'
        },
        custXrefCustomer: {
            type: 'customerbuffered'
        },
        vendorXrefLocation: {
            type: 'companylocationbuffered'
        },
        vendorXrefVendor: {
            type: 'vendorbuffered'
        },
        vendorXrefUom: {
            type: 'inventorybuffereduom'
        },


        contractLocation: {
            type: 'companylocationbuffered'
        },
        origin: {
            type: 'countrybuffered'
        },
        document: {
            type: 'inventorybuffereddocument'
        },
        certification: {
            type: 'inventorybufferedcertification'
        },


        pricingLevelLocation: {
            type: 'companylocationbuffered'
        },
        pricingLevelUOM: {
            type: 'inventorybuffereduom'
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
            type: 'companylocationbuffered'
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
            type: 'inventorybuffereduom'
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
            type: 'companylocationbuffered'
        },
        stockUOM: {
            type: 'inventorybuffereduom'
        },


        commodity: {
            type: 'inventorybufferedcommodity'
        },
        originAttribute: {
            type: 'inventorybufferedoriginattribute'
        },
        productTypeAttribute: {
            type: 'inventorybufferedproducttypeattribute'
        },
        regionAttribute: {
            type: 'inventorybufferedregionattribute'
        },
        seasonAttribute: {
            type: 'inventorybufferedseasonattribute'
        },
        classAttribute: {
            type: 'inventorybufferedclassattribute'
        },
        productLineAttribute: {
            type: 'inventorybufferedproductlineattribute'
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
            type: 'inventorybufferedcompactitem'
        },
        assemblyUOM: {
            type: 'inventorybuffereduom'
        },


        bundleItem: {
            type: 'inventorybufferedcompactitem'
        },
        bundleUOM: {
            type: 'inventorybuffereduom'
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
            type: 'inventorybufferedcompactitem'
        },
        kitUOM: {
            type: 'inventorybuffereduom'
        },

        factory: {
            type: 'companylocationbuffered'
        },
        factoryManufacturingCell: {
            type: 'inventorybufferedmanufacturingcell'
        },
        owner: {
            type: 'customerbuffered'
        },

        noteLocation: {
            type: 'companylocationbuffered'
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

    }

});