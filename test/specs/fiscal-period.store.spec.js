UnitTestEngine.testStore({
    name: 'Inventory.store.FiscalPeriod',
    alias: "store.icfiscalperiod",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.FiscalPeriod"],
    config: {
        "model": "Inventory.model.FiscalPeriod",
        "storeId": "FiscalPeriod",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/inventoryvaluation/getfiscalmonths"
            }
        }
    }
});