UnitTestEngine.testStore({
    name: 'Inventory.store.PackType',
    alias: "store.icpacktype",
    base: 'GlobalComponentEngine.store.MultiCompanyBaseStore',
    dependencies: ["Inventory.model.PackType"],
    config: {
        "model": "Inventory.model.PackType",
        "storeId": "PackType",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/packtype/getpacktypes",
                "update": "./inventory/api/packtype/putpacktypes",
                "create": "./inventory/api/packtype/postpacktypes"
            }
        }
    }
});