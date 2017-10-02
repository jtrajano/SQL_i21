UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedInventoryCountDetail',
    alias: "store.icbufferedinventorycountdetail",
    base: 'Ext.data.Store',
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
                "create": "./Inventory/api/InventoryCountDetail/Post",
                "read": "./Inventory/api/InventoryCount/GetInventoryCountDetails",
                "update": "./Inventory/api/InventoryCountDetail/UpdateDetail"
            }
        }
    }
});