UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedM2MComputation',
    alias: "store.icbufferedm2mcomputation",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.M2MComputation"],
    config: {
        "model": "Inventory.model.M2MComputation",
        "storeId": "BufferedM2MComputation",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/M2MComputation/Search"
            }
        }
    }
});