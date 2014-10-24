Ext.define('Inventory.view.override.ItemViewModel', {
    override: 'Inventory.view.ItemViewModel',

    requires: [
        'Inventory.store.Item',
        'Inventory.store.Manufacturer',
        'Inventory.store.Category',
        'Inventory.store.PatronageCategory',
        'Inventory.store.InventoryTag',
        'Inventory.store.UnitMeasure',
        'Inventory.store.Brand',
        'Inventory.store.FuelCategory',
        'Inventory.store.FuelTaxClass',
        'Inventory.store.Document',
        'Inventory.store.Certification',
        'Inventory.store.MaterialNMFC',
        'Inventory.store.CountGroup',
        'AccountsPayable.store.VendorBuffered',
        'AccountsReceivable.store.Customer',
        'i21.store.CompanyLocation',
        'i21.store.Country',
        'GeneralLedger.store.BufAccountId'
    ],

    stores: {
        ItemTypes: {
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
        ItemStatuses: {
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
        LotTrackings: {
            autoLoad: true,
            data: [
                {
                    strLotTracking: 'Yes'
                },
                {
                    strLotTracking: 'No'
                },
                {
                    strLotTracking: 'Serial Number'
                },
                {
                    strLotTracking: 'Bulk'
                }
            ],
            fields: [
                {
                    name: 'strLotTracking'
                }
            ]
        },
        CostingMethods: {
            autoLoad: true,
            data: [
                {
                    intCostingMethodId: '1',
                    strDescription: 'AVG'
                },
                {
                    intCostingMethodId: '2',
                    strDescription: 'FIFO'
                },
                {
                    intCostingMethodId: '3',
                    strDescription: 'LIFO'
                }
            ],
            fields: [
                {
                    name: 'intCostingMethodId',
                    type: 'int'
                },
                {
                    name: 'strDescription'
                }
            ]
        },
        BarcodePrints: {
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
        FuelInspectionFees: {
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
        RinRequires: {
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
        WICCodes: {
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
        RotationTypes: {
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
        PricingMethods: {
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
        Counteds: {
            autoLoad: true,
            data: [
                {
                    strDescription: 'Counted'
                },
                {
                    strDescription: 'Not Counted'
                },
                {
                    strDescription: 'Obsolete'
                },
                {
                    strDescription: 'Blended'
                },
                {
                    strDescription: 'Automatic Blend'
                },
                {
                    strDescription: 'Special Order'
                }
            ],
            fields: [
                {
                    name: 'strDescription'
                }
            ]
        },
        AccountDescriptions: {
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
        CountCodes: {
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
        CommentTypes: {
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
        LifeTimes: {
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
        PromotionTypes:{
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
        DiscountsBy:{
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
        PricingMethods:{
            autoLoad: true,
            data: [
                {
                    strDescription: 'Fixed Dollar Amount'
                },{
                    strDescription: 'Markup Standard Cost'
                },{
                    strDescription: 'Percent of Margin'
                },{
                    strDescription: 'Discount Sales Price'
                },{
                    strDescription: 'MSRP Discount'
                },{
                    strDescription: 'Percent of Margin (MSRP)'
                }
            ],
            fields: [
                {
                    name: 'strDescription'
                }
            ]
        },
        CommissionsOn:{
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


        Manufacturer: {
            type: 'inventorymanufacturer'
        },
        Category: {
            type: 'inventorycategory'
        },
        PatronageCategory: {
            type: 'inventorypatronagecategory'
        },
        InventoryTag: {
            type: 'inventorytag'
        },
        UnitMeasure: {
            type: 'inventoryuom'
        },
        Brand: {
            type: 'inventorybrand'
        },
        FuelCategory: {
            type: 'inventoryfuelcategory'
        },
        Vendor: {
            type: 'vendorbuffered'
        },
        Customer: {
            type: 'customer'
        },
        CompanyLocation: {
            type: 'companylocation'
        },
        Country: {
            type: 'country'
        },
        FuelTaxClass: {
            type: 'inventoryfueltaxclass'
        },
        Item: {
            type: 'inventoryitem'
        },
        GLAccount: {
            type: 'bufaccountid'
        },
        Document: {
            type: 'inventorydocument'
        },
        Certification: {
            type: 'inventorycertification'
        },
        MaterialNMFC: {
            type: 'inventorymaterialnmfc'
        },
        CountGroup: {
            type: 'inventorycountgroup'
        }





    }
});