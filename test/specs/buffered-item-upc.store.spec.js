UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedItemUPC',
    alias: "store.icbuffereditemupc",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.ItemUOM"],
    config: {
        "model": "Inventory.model.ItemUOM",
        "storeId": "BufferedItemUPC",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/Item/SearchItemUPCs"
            }
        }
    }
});