UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedLotStatus',
    alias: "store.icbufferedlotstatus",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.LotStatus"],
    config: {
        "model": "Inventory.model.LotStatus",
        "storeId": "BufferedLotStatus",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/LotStatus/Search"
            }
        }
    }
});