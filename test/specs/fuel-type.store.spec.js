UnitTestEngine.testStore({
    name: 'Inventory.store.FuelType',
    alias: "store.icfueltype",
    base: 'GlobalComponentEngine.store.MultiCompanyBaseStore',
    dependencies: ["Inventory.model.FuelType"],
    config: {
        "model": "Inventory.model.FuelType",
        "storeId": "FuelType",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/fueltype/get",
                "update": "./inventory/api/fueltype/put",
                "create": "./inventory/api/fueltype/post"
            }
        }
    }
});