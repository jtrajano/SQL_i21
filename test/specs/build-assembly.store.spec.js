UnitTestEngine.testStore({
    name: 'Inventory.store.BuildAssembly',
    alias: "store.icbuildassembly",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.BuildAssembly"],
    config: {
        "model": "Inventory.model.BuildAssembly",
        "storeId": "BuildAssembly",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/BuildAssembly/Get",
                "update": "../Inventory/api/BuildAssembly/Put",
                "create": "../Inventory/api/BuildAssembly/Post"
            }
        }
    }
});