UnitTestEngine.testStore({
    name: 'Inventory.store.ItemPricing',
    alias: "store.icitempricing",
    base: 'GlobalComponentEngine.store.MultiCompanyBaseStore',
    dependencies: ["Inventory.model.ItemPricing"],
    config: {
        "model": "Inventory.model.ItemPricing",
        "storeId": "ItemPricing",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/itempricing/get",
                "update": "./inventory/api/itempricing/put",
                "create": "./inventory/api/itempricing/post"
            }
        }
    }
});