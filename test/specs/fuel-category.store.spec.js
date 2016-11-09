UnitTestEngine.testStore({
    name: 'Inventory.store.FuelCategory',
    alias: "store.icfuelcategory",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.FuelCategory"],
    config: {
        "model": "Inventory.model.FuelCategory",
        "storeId": "FuelCategory",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/FuelCategory/Get",
                "update": "../Inventory/api/FuelCategory/Put",
                "create": "../Inventory/api/FuelCategory/Post"
            }
        }
    }
});