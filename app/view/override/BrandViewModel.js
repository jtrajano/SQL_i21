Ext.define('Inventory.view.override.BrandViewModel', {
    override: 'Inventory.view.BrandViewModel',

    requires: [
        'Inventory.store.Manufacturer'
    ],

    stores: {
        Manufacturers:{
            type: 'inventorymanufacturer'
        }
    }
});