UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedReadingPoint',
    alias: "store.icbufferedreadingpoint",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.ReadingPoint"],
    config: {
        "model": "Inventory.model.ReadingPoint",
        "storeId": "BufferedReadingPoint",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/ReadingPoint/Search"
            }
        }
    }
});