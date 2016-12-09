UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedInventoryTag',
    alias: "store.icbufferedtag",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.InventoryTag"],
    config: {
        "model": "Inventory.model.InventoryTag",
        "storeId": "BufferedTag",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/Tag/Search"
            }
        }
    }
});