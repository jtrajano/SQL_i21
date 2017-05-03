UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedFuelCode',
    alias: "store.icbufferedfuelcode",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.FuelCode"],
    config: {
        "model": "Inventory.model.FuelCode",
        "storeId": "BufferedFuelCode",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/FuelCode/Search"
            }
        }
    }
});