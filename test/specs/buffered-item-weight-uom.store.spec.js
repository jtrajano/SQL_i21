UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedItemWeightUOM',
    alias: "store.icbuffereditemweightuom",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.ItemUOM"],
    config: {
        "model": "Inventory.model.ItemUOM",
        "storeId": "BufferedItemWeightUOM",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/ItemUOM/SearchWeightUOMs"
            }
        }
    }
});