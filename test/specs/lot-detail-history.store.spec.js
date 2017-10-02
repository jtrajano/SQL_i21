UnitTestEngine.testStore({
    name: 'Inventory.store.LotHistory',
    alias: "store.iclothistory",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.LotHistory"],
    config: {
        "model": "Inventory.model.LotHistory",
        "storeId": "LotHistory",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./Inventory/api/Lot/GetHistory"
            }
        }
    }
});