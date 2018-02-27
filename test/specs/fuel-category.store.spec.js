UnitTestEngine.testStore({
    name: 'Inventory.store.FuelCategory',
    alias: "store.icfuelcategory",
    base: 'GlobalComponentEngine.store.MultiCompanyBaseStore',
    dependencies: ["Inventory.model.FuelCategory"],
    config: {
        "model": "Inventory.model.FuelCategory",
        "storeId": "FuelCategory",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/fuelcategory/get",
                "update": "./inventory/api/fuelcategory/put",
                "create": "./inventory/api/fuelcategory/post"
            }
        }
    }
});