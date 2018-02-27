UnitTestEngine.testStore({
    name: 'Inventory.store.StorageMeasurementReading',
    alias: "store.icstoragemeasurementreading",
    base: 'GlobalComponentEngine.store.MultiCompanyBaseStore',
    dependencies: ["Inventory.model.StorageMeasurementReading"],
    config: {
        "model": "Inventory.model.StorageMeasurementReading",
        "storeId": "StorageMeasurementReading",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/storagemeasurementreading/get",
                "update": "./inventory/api/storagemeasurementreading/put",
                "create": "./inventory/api/storagemeasurementreading/post"
            }
        }
    }
});