Ext.define('Inventory.store.RepostInventory', {
    extend: 'Ext.data.Store',
    alias: 'store.icrepostinventory',

    requires: [
        'Inventory.model.RepostInventory'
    ],

    model: 'Inventory.model.RepostInventory',
    storeId: 'RepostInventory'
});
