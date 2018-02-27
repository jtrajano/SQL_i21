UnitTestEngine.testStore({
    name: 'Inventory.store.CompactItem',
    alias: "store.iccompactitem",
    base: 'GlobalComponentEngine.store.MultiCompanyBaseStore',
    dependencies: ["Inventory.model.CompactItem"],
    config: {
        "model": "Inventory.model.CompactItem",
        "storeId": "CompactItem",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/item/searchcompactitems"
            }
        }
    }
});