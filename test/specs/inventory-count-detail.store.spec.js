UnitTestEngine.testStore({
    name: 'Inventory.store.InventoryCountDetail',
    alias: "store.icinventorycountdetail",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.InventoryCountDetail"],
    config: {
        "model": "Inventory.model.InventoryCountDetail",
        "storeId": "InventoryCountDetail",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./Inventory/api/InventoryCountDetail/Get",
                "update": "./Inventory/api/InventoryCountDetail/Put",
                "create": "./Inventory/api/InventoryCountDetail/Post"
            }
        }
    }
});