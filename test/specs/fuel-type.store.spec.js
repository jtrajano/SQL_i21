UnitTestEngine.testStore({
    name: 'Inventory.store.FuelType',
    alias: "store.icfueltype",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.FuelType"],
    config: {
        "model": "Inventory.model.FuelType",
        "storeId": "FuelType",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/FuelType/Get",
                "update": "../Inventory/api/FuelType/Put",
                "create": "../Inventory/api/FuelType/Post"
            }
        }
    }
});