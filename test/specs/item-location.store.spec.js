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
                "read": "./inventory/api/itemlocation/get",
                "update": "./inventory/api/itemlocation/put",
                "create": "./inventory/api/itemlocation/post"
            }
        }
    }
});