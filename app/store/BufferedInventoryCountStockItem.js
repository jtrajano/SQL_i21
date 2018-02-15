Ext.define('Inventory.store.BufferedInventoryCountStockItem', {
    extend: 'GlobalComponentEngine.store.MultiCompanyBaseBufferedStore',
    alias: 'store.icbufferedinventorycountstockitem',

    requires: [
        'Inventory.model.InventoryCountStockItem'
    ],

    model: 'Inventory.model.InventoryCountStockItem',
    storeId: 'InventoryCountStockItem',
    pageSize: 50,
    batchActions: true,
    proxy: {
        type: 'rest',
        api: {
            read: './inventory/api/itemstock/getinventorycountitemstocklookup'
        },
        reader: {
            type: 'json',
            rootProperty: 'data',
            messageProperty: 'message'
        },
        writer: {
            type: 'json',
            allowSingle: false
        }
    }
});