UnitTestEngine.testStore({
    name: 'Inventory.store.FuelCode',
    alias: "store.icfuelcode",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.FuelCode"],
    config: {
        "model": "Inventory.model.FuelCode",
        "storeId": "FuelCode",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/FuelCode/Get",
                "update": "../Inventory/api/FuelCode/Put",
                "create": "../Inventory/api/FuelCode/Post"
            }
        }
    }
});