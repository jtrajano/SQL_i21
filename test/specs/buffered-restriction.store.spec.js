UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedRestriction',
    alias: "store.icbufferedrestriction",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.Restriction"],
    config: {
        "model": "Inventory.model.Restriction",
        "storeId": "BufferedRestriction",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/Restriction/Search"
            }
        }
    }
});