Ext.define('Inventory.view.override.CategoryViewModel', {
    override: 'Inventory.view.CategoryViewModel',

    requires: [
        'Inventory.store.UnitMeasure'
    ],

    stores: {
        LinesOfBusiness: {
            autoLoad: true,
            data: [
                {
                    strDescription: 'Agronomy'
                },{
                    strDescription: 'Feed'
                },{
                    strDescription: 'Petroleum'
                },{
                    strDescription: 'Retail'
                },{
                    strDescription: 'Grain'
                },{
                    strDescription: 'Oil & Grease'
                }
            ],
            fields: {
                name: 'strDescription'
            }
        },
        CostingMethods: {
            autoLoad: true,
            data: [
                {
                    strDescription: 'AVG'
                },{
                    strDescription: 'FIFO'
                },{
                    strDescription: 'LIFO'
                }
            ],
            fields: {
                name: 'strDescription'
            }
        },
        MaterialFees: {
            autoLoad: true,
            data: [
                {
                    strDescription: 'No'
                },{
                    strDescription: 'Yes'
                },{
                    strDescription: 'Unit'
                }
            ],
            fields: {
                name: 'strDescription'
            }
        },
        UnitMeasures:{
            type: 'inventoryuom'
        }
    }

});