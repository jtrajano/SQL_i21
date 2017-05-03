UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedPackedUOM',
    alias: "store.icbufferedpackeduom",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.PackedUOM"],
    config: {
        "model": "Inventory.model.PackedUOM",
        "storeId": "BufferedPackedUOM",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/UnitMeasure/SearchPackedUOMs"
            }
        }
    }
});