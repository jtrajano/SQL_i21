UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedValidTargetUOM',
    alias: "store.icbufferedvalidtargetuom",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.UnitMeasure"],
    config: {
        "model": "Inventory.model.UnitMeasure",
        "storeId": "BufferedUnitMeasure",
        "pageSize": 50,
        "remoteFilter": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/unitmeasure/getvalidtargetuom"
            }
        }
    }
});