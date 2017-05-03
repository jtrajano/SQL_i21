UnitTestEngine.testStore({
    name: 'Inventory.store.CompactItem',
    alias: "store.iccompactitem",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.CompactItem"],
    config: {
        "model": "Inventory.model.CompactItem",
        "storeId": "CompactItem",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/Item/SearchCompactItems"
            }
        }
    }
});