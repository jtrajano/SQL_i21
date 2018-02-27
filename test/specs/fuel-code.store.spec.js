UnitTestEngine.testStore({
    name: 'Inventory.store.FuelCode',
    alias: "store.icfuelcode",
    base: 'GlobalComponentEngine.store.MultiCompanyBaseStore',
    dependencies: ["Inventory.model.FuelCode"],
    config: {
        "model": "Inventory.model.FuelCode",
        "storeId": "FuelCode",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/fuelcode/get",
                "update": "./inventory/api/fuelcode/put",
                "create": "./inventory/api/fuelcode/post"
            }
        }
    }
});