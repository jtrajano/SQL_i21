Ext.define('Inventory.view.override.BrandViewModel', {
    override: 'Inventory.view.BrandViewModel',

    requires: [
        'Inventory.store.Manufacturer'
    ],

    stores: {
        Manufacturer: {
            type: 'inventorymanufacturer'
        }
    }
});