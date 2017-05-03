UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedQAProperty',
    alias: "store.icbufferedqaproperty",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.QAProperty"],
    config: {
        "model": "Inventory.model.QAProperty",
        "storeId": "BufferedQAProperty",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/QAProperty/Search"
            }
        }
    }
});