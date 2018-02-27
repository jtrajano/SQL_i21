UnitTestEngine.testStore({
    name: 'Inventory.store.PaidOut',
    alias: "store.storepaidout",
    base: 'GlobalComponentEngine.store.MultiCompanyBaseStore',
    dependencies: [],
    config: {
        "storeId": "PaidOut",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/paidout/getpaidouts"
            }
        }
    }
});