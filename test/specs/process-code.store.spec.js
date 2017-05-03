UnitTestEngine.testStore({
    name: 'Inventory.store.ProcessCode',
    alias: "store.icprocesscode",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.ProcessCode"],
    config: {
        "model": "Inventory.model.ProcessCode",
        "storeId": "ProcessCode",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/ProcessCode/Get",
                "update": "../Inventory/api/ProcessCode/Put",
                "create": "../Inventory/api/ProcessCode/Post"
            }
        }
    }
});