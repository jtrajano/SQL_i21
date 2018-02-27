UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedInventoryCountDetail',
    alias: "store.icbufferedinventorycountdetail",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.InventoryCountDetail"],
    config: {
        "model": "Inventory.model.InventoryCountDetail",
        "storeId": "BufferedInventoryCountDetail",
        "pageSize": 200,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "create": "./inventory/api/inventorycountdetail/post",
                "read": "./inventory/api/inventorycount/getinventorycountdetails",
                "update": "./inventory/api/inventorycountdetail/updatedetail"
            }
        }
    }
});