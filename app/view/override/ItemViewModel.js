Ext.define('Inventory.view.override.ItemViewModel', {
    override: 'Inventory.view.ItemViewModel',

    requires: [
        'Inventory.model.ItemUOM',
        'Inventory.model.ItemLocationStore'
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
        }
    }
});