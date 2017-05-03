UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedItemFactoryManufacturingCell',
    alias: "store.icbuffereditemfactorymanufacturingcell",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.CompactItemFactoryManufacturingCell"],
    config: {
        "model": "Inventory.model.CompactItemFactoryManufacturingCell",
        "storeId": "BufferedItemFactoryManufacturingCell",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/ItemFactory/SearchItemFactoryManufacturingCells"
            }
        }
    }
});