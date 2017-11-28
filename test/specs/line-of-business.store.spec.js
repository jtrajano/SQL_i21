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
                "read": "./inventory/api/lineofbusiness/get",
                "update": "./inventory/api/lineofbusiness/put",
                "create": "./inventory/api/lineofbusiness/post"
            }
        }
    }
});