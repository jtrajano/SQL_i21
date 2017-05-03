UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedContainer',
    alias: "store.icbufferedcontainer",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.Container"],
    config: {
        "model": "Inventory.model.Container",
        "storeId": "BufferedContainer",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/Container/Search"
            }
        }
    }
});