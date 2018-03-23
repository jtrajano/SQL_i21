UnitTestEngine.testStore({
    name: 'Inventory.store.CountGroup',
    alias: "store.iccountgroup",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.CountGroup"],
    config: {
        "model": "Inventory.model.CountGroup",
        "storeId": "CountGroup",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/countgroup/get",
                "update": "./inventory/api/countgroup/put",
                "create": "./inventory/api/countgroup/post"
            }
        }
    }
});