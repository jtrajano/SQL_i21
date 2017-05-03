UnitTestEngine.testStore({
    name: 'Inventory.store.PackType',
    alias: "store.icpacktype",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.PackType"],
    config: {
        "model": "Inventory.model.PackType",
        "storeId": "PackType",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/PackType/GetPackTypes",
                "update": "../Inventory/api/PackType/PutPackTypes",
                "create": "../Inventory/api/PackType/PostPackTypes"
            }
        }
    }
});