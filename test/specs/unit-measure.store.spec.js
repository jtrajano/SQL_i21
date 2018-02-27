UnitTestEngine.testStore({
    name: 'Inventory.store.UnitMeasure',
    alias: "store.icuom",
    base: 'GlobalComponentEngine.store.MultiCompanyBaseStore',
    dependencies: ["Inventory.model.UnitMeasure", "Inventory.model.UnitMeasureConversion", "Ext.data.proxy.Rest", "Ext.data.reader.Json", "Ext.data.writer.Json"],
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