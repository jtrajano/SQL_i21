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
                "read": "../Inventory/api/M2MComputation/Get",
                "update": "../Inventory/api/M2MComputation/Put",
                "create": "../Inventory/api/M2MComputation/Post"
            }
        }
    }
});