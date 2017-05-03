UnitTestEngine.testStore({
    name: 'Inventory.store.PaidOut',
    alias: "store.storepaidout",
    base: 'Ext.data.BufferedStore',
    dependencies: [],
    config: {
        "storeId": "PaidOut",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/PaidOut/GetPaidOuts"
            }
        }
    }
});