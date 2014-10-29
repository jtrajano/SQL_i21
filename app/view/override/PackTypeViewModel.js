Ext.define('Inventory.view.override.PackTypeViewModel', {
    override: 'Inventory.view.PackTypeViewModel',

    requires: [
        'Inventory.store.BufferedUnitMeasure'
    ],

    stores: {
        sourceUnitMeasure: {
            type: 'inventorybuffereduom'
        },
        targetUnitMeasure: {
            type: 'inventorybuffereduom'
        }
    }
    
});