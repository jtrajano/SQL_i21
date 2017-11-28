UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedInventoryCountStockItem',
    alias: "store.icbufferedinventorycountstockitem",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.InventoryCountStockItem"],
    config: {
        "model": "Inventory.model.InventoryCountStockItem",
        "storeId": "InventoryCountStockItem",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/itemstock/getinventorycountitemstocklookup"
            }
        }
    }
});