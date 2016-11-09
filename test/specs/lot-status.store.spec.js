UnitTestEngine.testStore({
    name: 'Inventory.store.LotStatus',
    alias: "store.iclotstatus",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.LotStatus"],
    config: {
        "model": "Inventory.model.LotStatus",
        "storeId": "LotStatus",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/LotStatus/Get",
                "update": "../Inventory/api/LotStatus/Put",
                "create": "../Inventory/api/LotStatus/Post"
            }
        }
    }
});