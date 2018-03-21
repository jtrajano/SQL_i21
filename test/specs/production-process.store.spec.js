UnitTestEngine.testStore({
    name: 'Inventory.store.ProductionProcess',
    alias: "store.icproductionprocess",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.ProductionProcess"],
    config: {
        "model": "Inventory.model.ProductionProcess",
        "storeId": "ProductionProcess",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/processcode/get",
                "update": "./inventory/api/processcode/put",
                "create": "./inventory/api/processcode/post"
            }
        }
    }
});