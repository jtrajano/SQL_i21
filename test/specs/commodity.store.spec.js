UnitTestEngine.testStore({
    name: 'Inventory.store.Commodity',
    alias: "store.iccommodity",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.Commodity"],
    config: {
        "model": "Inventory.model.Commodity",
        "storeId": "Commodity",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/Commodity/Get",
                "update": "../Inventory/api/Commodity/Put",
                "create": "../Inventory/api/Commodity/Post"
            }
        }
    }
});