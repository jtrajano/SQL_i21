UnitTestEngine.testStore({
    name: 'Inventory.store.LineOfBusiness',
    alias: "store.iclineofbusiness",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.LineOfBusiness"],
    config: {
        "model": "Inventory.model.LineOfBusiness",
        "storeId": "LineOfBusiness",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/LineOfBusiness/Get",
                "update": "../Inventory/api/LineOfBusiness/Put",
                "create": "../Inventory/api/LineOfBusiness/Post"
            }
        }
    }
});