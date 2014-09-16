Ext.define('Inventory.view.override.ItemViewModel', {
    override: 'Inventory.view.ItemViewModel',

    stores: {
        ItemTypes: {
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