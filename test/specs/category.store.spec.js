UnitTestEngine.testStore({
    name: 'Inventory.store.Category',
    alias: "store.iccategory",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.Category"],
    config: {
        "model": "Inventory.model.Category",
        "storeId": "Category",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/Category/Get",
                "update": "../Inventory/api/Category/Put",
                "create": "../Inventory/api/Category/Post"
            }
        }
    }
});