UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedOtherCharges',
    alias: "store.icbufferedothercharges",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.CompactItem"],
    config: {
        "model": "Inventory.model.CompactItem",
        "storeId": "BufferedOtherCharges",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/Item/SearchOtherCharges"
            }
        }
    }
});