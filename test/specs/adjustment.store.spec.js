UnitTestEngine.testStore({
    name: 'Inventory.store.Adjustment',
    alias: "store.icadjustment",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.Adjustment"],
    config: {
        "model": "Inventory.model.Adjustment",
        "storeId": "Adjustment",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/InventoryAdjustment/Get",
                "update": "../Inventory/api/InventoryAdjustment/Put",
                "create": "../Inventory/api/InventoryAdjustment/Post"
            }
        }
    }
});