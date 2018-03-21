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
                "read": "./inventory/api/manufacturingcell/getmanufacturingcells",
                "update": "./inventory/api/manufacturingcell/putmanufacturingcells",
                "create": "./inventory/api/manufacturingcell/postmanufacturingcells"
            }
        }
    }
});