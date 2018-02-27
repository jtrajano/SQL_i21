UnitTestEngine.testStore({
    name: 'Inventory.store.MaterialNMFC',
    alias: "store.icmaterialnmfc",
    base: 'GlobalComponentEngine.store.MultiCompanyBaseStore',
    dependencies: ["Inventory.model.MaterialNMFC"],
    config: {
        "model": "Inventory.model.MaterialNMFC",
        "storeId": "MaterialNMFC",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/materialnmfc/getmaterialnmfcs",
                "update": "./inventory/api/materialnmfc/putmaterialnmfcs",
                "create": "./inventory/api/materialnmfc/postmaterialnmfcs"
            }
        }
    }
});