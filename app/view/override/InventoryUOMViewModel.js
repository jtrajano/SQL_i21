Ext.define('Inventory.view.override.InventoryUOMViewModel', {
    override: 'Inventory.view.InventoryUOMViewModel',

    requires: [
        'Inventory.store.BufferedUnitMeasure'
    ],

    stores: {
        UnitTypes: {
            autoLoad: true,
            data: [
                {
                    strDescription: 'Area'
                },{
                    strDescription: 'Length'
                },{
                    strDescription: 'Quantity'
                },{
                    strDescription: 'Time'
                },{
                    strDescription: 'Volume'
                },{
                    strDescription: 'Weight'
                },
            ],
            fields: {
                name: 'strDescription'
            }
        },
        UnitMeasure: {
            type: 'inventorybuffereduom'
        }
    }

});