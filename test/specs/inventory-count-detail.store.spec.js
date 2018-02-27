UnitTestEngine.testStore({
    name: 'Inventory.store.InventoryCountDetail',
    alias: "store.icinventorycountdetail",
    base: 'GlobalComponentEngine.store.MultiCompanyBaseStore',
    dependencies: ["Inventory.model.InventoryCountDetail"],
    config: {
        "model": "Inventory.model.InventoryCountDetail",
        "storeId": "InventoryCountDetail",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/inventorycountdetail/get",
                "update": "./inventory/api/inventorycountdetail/put",
                "create": "./inventory/api/inventorycountdetail/post"
            }
        }
    }
});