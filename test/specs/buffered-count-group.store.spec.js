UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedCountGroup',
    alias: "store.icbufferedcountgroup",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.CountGroup"],
    config: {
        "model": "Inventory.model.CountGroup",
        "storeId": "BufferedCountGroup",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/CountGroup/Search"
            }
        }
    }
});