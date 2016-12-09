UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedFuelType',
    alias: "store.icbufferedfueltype",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.FuelType"],
    config: {
        "model": "Inventory.model.FuelType",
        "storeId": "BufferedFuelType",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/FuelType/Search"
            }
        }
    }
});