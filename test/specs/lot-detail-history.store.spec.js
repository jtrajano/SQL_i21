UnitTestEngine.testStore({
    name: 'Inventory.store.LotDetailHistory',
    alias: "store.iclotdetailhistory",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.LotDetailHistory"],
    config: {
        "model": "Inventory.model.LotDetailHistory",
        "storeId": "LotDetailHistory",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/Lot/GetHistory"
            }
        }
    }
});