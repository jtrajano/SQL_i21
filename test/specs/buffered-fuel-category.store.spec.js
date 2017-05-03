UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedFuelCategory',
    alias: "store.icbufferedfuelcategory",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.FuelCategory"],
    config: {
        "model": "Inventory.model.FuelCategory",
        "storeId": "BufferedFuelCategory",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/FuelCategory/Search"
            }
        }
    }
});