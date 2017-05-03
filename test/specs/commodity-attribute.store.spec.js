UnitTestEngine.testStore({
    name: 'Inventory.store.CommodityAttribute',
    alias: "store.iccommodityattribute",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.CommodityAttribute"],
    config: {
        "model": "Inventory.model.CommodityAttribute",
        "storeId": "CommodityAttribute",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/CommodityAttribute/GetCommodityAttributes",
                "update": "../Inventory/api/CommodityAttribute/PutCommodityAttributes",
                "create": "../Inventory/api/CommodityAttribute/PostCommodityAttributes"
            }
        }
    }
});