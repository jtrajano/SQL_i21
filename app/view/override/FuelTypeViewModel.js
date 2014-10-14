Ext.define('Inventory.view.override.FuelTypeViewModel', {
    override: 'Inventory.view.FuelTypeViewModel',

    requires: [
        'Inventory.store.FeedStockCode',
        'Inventory.store.FeedStockUom',
        'Inventory.store.FuelCategory',
        'Inventory.store.FuelCode',
        'Inventory.store.ProcessCode'
    ],

    stores: {
        FeedStockCode: {
            type: 'inventoryfeedstockcode'
        },
        FeedStockUom: {
            type: 'inventoryfeedstockuom'
        },
        FuelCategory: {
            type: 'inventoryfuelcategory'
        },
        FuelCode: {
            type: 'inventoryfuelcode'
        },
        ProcessCode: {
            type: 'inventoryprocesscode'
        }
    }
    
});