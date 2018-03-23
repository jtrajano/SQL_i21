UnitTestEngine.testStore({
    name: 'Inventory.store.Document',
    alias: "store.icdocument",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.Document"],
    config: {
        "model": "Inventory.model.Document",
        "storeId": "Document",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/document/get",
                "update": "./inventory/api/document/put",
                "create": "./inventory/api/document/post"
            }
        }
    }
});