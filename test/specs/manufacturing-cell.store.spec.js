UnitTestEngine.testStore({
    name: 'Inventory.store.ManufacturingCell',
    alias: "store.icmanufacturingcell",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.ManufacturingCell"],
    config: {
        "model": "Inventory.model.ManufacturingCell",
        "storeId": "ManufacturingCell",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/ManufacturingCell/GetManufacturingCells",
                "update": "../Inventory/api/ManufacturingCell/PutManufacturingCells",
                "create": "../Inventory/api/ManufacturingCell/PostManufacturingCells"
            }
        }
    }
});