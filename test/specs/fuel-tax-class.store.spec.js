UnitTestEngine.testStore({
    name: 'Inventory.store.FuelTaxClass',
    alias: "store.icfueltaxclass",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.FuelTaxClass"],
    config: {
        "model": "Inventory.model.FuelTaxClass",
        "storeId": "FuelTaxClass",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/fueltaxclass/get",
                "update": "./inventory/api/fueltaxclass/put",
                "create": "./inventory/api/fueltaxclass/post"
            }
        }
    }
});