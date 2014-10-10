Ext.define('Inventory.view.override.InventoryReceiptViewModel', {
    override: 'Inventory.view.InventoryReceiptViewModel',

    requires: [
        'Inventory.store.Item'
    ],

    stores: {
        ReceiptTypes: {
            autoLoad: true,
            data: [
                {
                    strDescription: 'Contract'
                },{
                    strDescription: 'Purchase Order'
                },{
                    strDescription: 'Transfer Order'
                },{
                    strDescription: 'Direct'
                }
            ],
            fields: {
                name: 'strDescription'
            }
        },
        AllocateFreights: {
            autoLoad: true,
            data: [
                {
                    strDescription: 'Weight'
                },{
                    strDescription: 'Cost'
                },{
                    strDescription: 'No'
                }
            ],
            fields: {
                name: 'strDescription'
            }
        },
        FreightBilledBys: {
            autoLoad: true,
            data: [
                {
                    strDescription: 'Vendor'
                },{
                    strDescription: 'Outside Carrier'
                },{
                    strDescription: 'No'
                }
            ],
            fields: {
                name: 'strDescription'
            }
        },
        CalculationBasis: {
            autoLoad: true,
            data: [
                {
                    strDescription: 'Per Unit'
                },{
                    strDescription: 'Per Ton'
                },{
                    strDescription: 'Per Miles'
                },{
                    strDescription: 'Flat Rate'
                }
            ],
            fields: {
                name: 'strDescription'
            }
        },
        SealStatuses: {
            autoLoad: true,
            data: [
                {
                    strDescription: '01 - Intact'
                },{
                    strDescription: '02 - Broken'
                },{
                    strDescription: '03 - Missing'
                },{
                    strDescription: '04 - Replaced'
                }
            ],
            fields: {
                name: 'strDescription'
            }
        },
        Items: {
            type: 'inventoryitem'
        }
    }
    
});