Ext.define('Inventory.store.RebuildInventory', {
    extend: 'Ext.data.Store',
    alias: 'store.icrebuildinventory',

    requires: [
        'Inventory.model.RebuildInventory'
    ],

    model: 'Inventory.model.RebuildInventory',
    storeId: 'RebuildInventory'
});
