UnitTestEngine.testStore({
    name: 'Inventory.store.UnitMeasure',
    alias: "store.icuom",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.UnitMeasure"],
    config: {
        "model": "Inventory.model.UnitMeasure",
        "storeId": "UnitMeasure",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/unitmeasure/get",
                "update": "./inventory/api/unitmeasure/put",
                "create": "./inventory/api/unitmeasure/post"
            }
        }
    }
});