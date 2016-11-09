UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedManufacturingCell',
    alias: "store.icbufferedmanufacturingcell",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.ManufacturingCell"],
    config: {
        "model": "Inventory.model.ManufacturingCell",
        "storeId": "BufferedManufacturingCell",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/ManufacturingCell/Search"
            }
        }
    }
});