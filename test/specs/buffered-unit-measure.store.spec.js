Inventory.TestUtils.testStore({
    name: 'Inventory.store.BufferedUnitMeasure',
    alias: 'store.icbuffereduom',
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.UnitMeasure"],
    config: [{
        "model": "Inventory.model.UnitMeasure",
        "storeId": "BufferedUnitMeasure",
        "pageSize": 50,
        "remoteFilter": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/UnitMeasure/Search"
            }
        }
    }]
});