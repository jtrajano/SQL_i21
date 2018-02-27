UnitTestEngine.testStore({
    name: 'Inventory.store.Certification',
    alias: "store.iccertification",
    base: 'GlobalComponentEngine.store.MultiCompanyBaseStore',
    dependencies: ["Inventory.model.Certification"],
    config: {
        "model": "Inventory.model.Certification",
        "storeId": "Certification",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/certification/get",
                "update": "./inventory/api/certification/put",
                "create": "./inventory/api/certification/post"
            }
        }
    }
});