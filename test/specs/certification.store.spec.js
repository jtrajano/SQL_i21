UnitTestEngine.testStore({
    name: 'Inventory.store.Certification',
    alias: "store.iccertification",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.Certification"],
    config: {
        "model": "Inventory.model.Certification",
        "storeId": "Certification",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/Certification/Get",
                "update": "../Inventory/api/Certification/Put",
                "create": "../Inventory/api/Certification/Post"
            }
        }
    }
});