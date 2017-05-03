UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedPostedLot',
    alias: "store.icbufferedpostedlot",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.Lot"],
    config: {
        "model": "Inventory.model.Lot",
        "storeId": "BufferedPostedLot",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/InventoryAdjustment/SearchPostedLots"
            }
        }
    }
});