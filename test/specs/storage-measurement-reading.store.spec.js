UnitTestEngine.testStore({
    name: 'Inventory.store.StorageMeasurementReading',
    alias: "store.icstoragemeasurementreading",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.StorageMeasurementReading"],
    config: {
        "model": "Inventory.model.StorageMeasurementReading",
        "storeId": "StorageMeasurementReading",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/StorageMeasurementReading/Get",
                "update": "../Inventory/api/StorageMeasurementReading/Put",
                "create": "../Inventory/api/StorageMeasurementReading/Post"
            }
        }
    }
});