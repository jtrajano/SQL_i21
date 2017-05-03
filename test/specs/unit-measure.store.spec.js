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
                "read": "../Inventory/api/UnitMeasure/Get",
                "update": "../Inventory/api/UnitMeasure/Put",
                "create": "../Inventory/api/UnitMeasure/Post"
            }
        }
    }
});