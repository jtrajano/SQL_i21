UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedItemMotorFuelTax',
    alias: "store.icbuffereditemmotorfueltax",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.BufferedItemMotorFuelTax"],
    config: {
        "model": "Inventory.model.ItemMotorFuelTax",
        "storeId": "BufferedItemMotorFuelTax",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/Item/GetItemMotorFuelTax"
            }
        }
    }
});