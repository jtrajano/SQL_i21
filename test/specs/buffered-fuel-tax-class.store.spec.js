UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedFuelTaxClass',
    alias: "store.icbufferedfueltaxclass",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.FuelTaxClass"],
    config: {
        "model": "Inventory.model.FuelTaxClass",
        "storeId": "BufferedFuelTaxClass",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/FuelTaxClass/Search"
            }
        }
    }
});