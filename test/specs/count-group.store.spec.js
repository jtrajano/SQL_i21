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
                "read": "../Inventory/api/CountGroup/Get",
                "update": "../Inventory/api/CountGroup/Put",
                "create": "../Inventory/api/CountGroup/Post"
            }
        }
    }
});