UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedManufacturer',
    alias: "store.icbufferedmanufacturer",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.Manufacturer"],
    config: {
        "model": "Inventory.model.Manufacturer",
        "storeId": "BufferedManufacturer",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/Manufacturer/Search"
            }
        }
    }
});