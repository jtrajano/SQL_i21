UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedProductionProcess',
    alias: "store.icbufferedproductionprocess",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.ProductionProcess"],
    config: {
        "model": "Inventory.model.ProductionProcess",
        "storeId": "BufferedProductionProcess",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/processcode/search"
            }
        }
    }
});