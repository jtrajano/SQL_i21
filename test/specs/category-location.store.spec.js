UnitTestEngine.testStore({
    name: 'Inventory.store.CategoryLocation',
    alias: "store.iccategorylocation",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.CategoryLocation"],
    config: {
        "model": "Inventory.model.CategoryLocation",
        "storeId": "CategoryLocation",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/CategoryLocation/Get",
                "update": "../Inventory/api/CategoryLocation/Put",
                "create": "../Inventory/api/CategoryLocation/Post"
            }
        }
    }
});