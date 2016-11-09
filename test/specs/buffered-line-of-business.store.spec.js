UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedLineOfBusiness',
    alias: "store.icbufferedlineofbusiness",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.LineOfBusiness"],
    config: {
        "model": "Inventory.model.LineOfBusiness",
        "storeId": "BufferedLineOfBusiness",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/LineOfBusiness/Search"
            }
        }
    }
});