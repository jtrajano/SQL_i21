UnitTestEngine.testStore({
    name: 'Inventory.store.ItemPricing',
    alias: "store.icitempricing",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.ItemPricing"],
    config: {
        "model": "Inventory.model.ItemPricing",
        "storeId": "ItemPricing",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/ItemPricing/Get",
                "update": "../Inventory/api/ItemPricing/Put",
                "create": "../Inventory/api/ItemPricing/Post"
            }
        }
    }
});