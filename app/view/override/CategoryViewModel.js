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