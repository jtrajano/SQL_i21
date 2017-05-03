UnitTestEngine.testStore({
    name: 'Inventory.store.MaterialNMFC',
    alias: "store.icmaterialnmfc",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.MaterialNMFC"],
    config: {
        "model": "Inventory.model.MaterialNMFC",
        "storeId": "MaterialNMFC",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/MaterialNMFC/GetMaterialNMFCs",
                "update": "../Inventory/api/MaterialNMFC/PutMaterialNMFCs",
                "create": "../Inventory/api/MaterialNMFC/PostMaterialNMFCs"
            }
        }
    }
});