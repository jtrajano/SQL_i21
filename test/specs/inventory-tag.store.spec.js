UnitTestEngine.testStore({
    name: 'Inventory.store.InventoryTag',
    alias: "store.ictag",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.InventoryTag"],
    config: {
        "model": "Inventory.model.InventoryTag",
        "storeId": "Tag",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/Tag/Get",
                "update": "../Inventory/api/Tag/Put",
                "create": "../Inventory/api/Tag/Post"
            }
        }
    }
});