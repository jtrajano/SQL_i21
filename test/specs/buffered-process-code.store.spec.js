UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedProcessCode',
    alias: "store.icbufferedprocesscode",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.ProcessCode"],
    config: {
        "model": "Inventory.model.ProcessCode",
        "storeId": "BufferedProcessCode",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/ProcessCode/Search"
            }
        }
    }
});