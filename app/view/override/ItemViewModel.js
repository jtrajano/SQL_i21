Ext.define('Inventory.view.override.ItemViewModel', {
    override: 'Inventory.view.ItemViewModel',

    requires: [
        'Inventory.model.ItemUOM',
        'Inventory.model.ItemLocationStore',
        'Inventory.store.Manufacturer',
        'Inventory.store.Category',
        'Inventory.store.PatronageCategory',
        'Inventory.store.InventoryTag',
        'Inventory.store.UnitMeasure',
        'Inventory.store.Brand',
        'Inventory.store.FuelCategory',
        'AccountsPayable.store.VendorBuffered',
        'i21.store.CompanyLocation'
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
                    name: 'intCostingMethodId'
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
        Location: {
            type: 'companylocation'
        }

    }
});