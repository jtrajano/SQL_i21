UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedItem',
    alias: "store.icbuffereditem",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.Item"],
    config: {
        "model": "Inventory.model.Item",
        "storeId": "BufferedItem",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/Item/Search"
            }
        }
    }
});