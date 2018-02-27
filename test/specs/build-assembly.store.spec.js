UnitTestEngine.testStore({
    name: 'Inventory.store.BuildAssembly',
    alias: "store.icbuildassembly",
    base: 'GlobalComponentEngine.store.MultiCompanyBaseStore',
    dependencies: ["Inventory.model.BuildAssembly"],
    config: {
        "model": "Inventory.model.BuildAssembly",
        "storeId": "BuildAssembly",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/buildassembly/get",
                "update": "./inventory/api/buildassembly/put",
                "create": "./inventory/api/buildassembly/post"
            }
        }
    }
});