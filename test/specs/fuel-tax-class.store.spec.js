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
                "read": "../Inventory/api/FuelTaxClass/Get",
                "update": "../Inventory/api/FuelTaxClass/Put",
                "create": "../Inventory/api/FuelTaxClass/Post"
            }
        }
    }
});