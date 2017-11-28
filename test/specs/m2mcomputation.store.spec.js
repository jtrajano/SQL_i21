UnitTestEngine.testStore({
    name: 'Inventory.store.M2MComputation',
    alias: "store.icm2mcomputation",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.M2MComputation"],
    config: {
        "model": "Inventory.model.M2MComputation",
        "storeId": "M2MComputation",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/m2mcomputation/get",
                "update": "./inventory/api/m2mcomputation/put",
                "create": "./inventory/api/m2mcomputation/post"
            }
        }
    }
});