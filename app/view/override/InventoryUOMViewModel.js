Ext.define('Inventory.view.override.InventoryUOMViewModel', {
    override: 'Inventory.view.InventoryUOMViewModel',

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
        }
    }

});