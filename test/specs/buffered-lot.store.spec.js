UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedLot',
    alias: "store.icbufferedlot",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.Lot"],
    config: {
        "model": "Inventory.model.Lot",
        "storeId": "BufferedLot",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/Lot/Search"
            }
        }
    }
});