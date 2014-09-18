Ext.define('Inventory.view.override.ItemViewModel', {
    override: 'Inventory.view.ItemViewModel',

    stores: {
        Manufacturer: {
            autoLoad: true,
            data: [
                {
                    strManufacturer: 'Active'
                },
                {
                    strManufacturer: 'Phased Out'
                },
                {
                    strManufacturer: 'Discontinued'
                }
            ],
            fields: [
                {
                    name: 'strManufacturer'
                }
            ]
        },
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
        }
    }
});