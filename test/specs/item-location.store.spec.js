UnitTestEngine.testStore({
    name: 'Inventory.store.ItemLocation',
    alias: "store.icitemlocation",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.ItemLocation"],
    config: {
        "model": "Inventory.model.ItemLocation",
        "storeId": "ItemLocation",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/ItemLocation/Get",
                "update": "../Inventory/api/ItemLocation/Put",
                "create": "../Inventory/api/ItemLocation/Post"
            }
        }
    }
});