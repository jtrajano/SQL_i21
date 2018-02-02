Ext.define('Inventory.store.RebuildInventory', {
    extend: 'GlobalComponentEngine.store.MultiCompanyBaseStore',
    alias: 'store.icrebuildinventory',

    requires: [
        'Inventory.model.RebuildInventory'
    ],

    model: 'Inventory.model.RebuildInventory',
    storeId: 'RebuildInventory'
});
