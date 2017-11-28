UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedSearchLot',
    alias: "store.icbufferedsearchlot",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.Lot"],
    config: {
        "model": "Inventory.model.Lot",
        "storeId": "BufferedSearchLot",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/lot/searchlots"
            }
        }
    }
});