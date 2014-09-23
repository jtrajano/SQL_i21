Ext.define('Inventory.view.override.FuelTypeViewModel', {
    override: 'Inventory.view.FuelTypeViewModel',

    requires: [
        'Inventory.store.FeedStockCode',
        'Inventory.store.FeedStockUom',
        'Inventory.store.FuelCategory',
        'Inventory.store.FuelCode',
        'Inventory.store.ProcessCode'

    ]
    
});