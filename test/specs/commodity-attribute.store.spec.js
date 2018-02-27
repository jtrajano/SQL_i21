UnitTestEngine.testStore({
    name: 'Inventory.store.CommodityAttribute',
    alias: "store.iccommodityattribute",
    base: 'GlobalComponentEngine.store.MultiCompanyBaseStore',
    dependencies: ["Inventory.model.CommodityAttribute"],
    config: {
        "model": "Inventory.model.CommodityAttribute",
        "storeId": "CommodityAttribute",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/commodityattribute/getcommodityattributes",
                "update": "./inventory/api/commodityattribute/putcommodityattributes",
                "create": "./inventory/api/commodityattribute/postcommodityattributes"
            }
        }
    }
});