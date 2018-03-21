UnitTestEngine.testStore({
    name: 'Inventory.store.Manufacturer',
    alias: "store.icmanufacturer",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.Manufacturer"],
    config: {
        "model": "Inventory.model.Manufacturer",
        "storeId": "Manufacturer",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/manufacturer/get",
                "update": "./inventory/api/manufacturer/put",
                "create": "./inventory/api/manufacturer/post"
            }
        }
    }
});