Ext.define('Inventory.view.override.FeedStockUomViewModel', {
    override: 'Inventory.view.FeedStockUomViewModel',

    requires: [
        'Inventory.store.UnitMeasure'
    ],

    stores: {
        UnitMeasure: {
            type: 'inventoryuom'
        }
    }
    
});