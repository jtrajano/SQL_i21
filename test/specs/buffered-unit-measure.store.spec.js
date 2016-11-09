UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedUnitMeasure',
    alias: "store.icbuffereduom",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.UnitMeasure"],
    config: {
        "model": "Inventory.model.UnitMeasure",
        "storeId": "BufferedUnitMeasure",
        "pageSize": 50,
        "remoteFilter": true,
        "proxy": {
            "extraParams": [{
                "name": "include",
                "value": "\"tblICUnitMeasureConversions.StockUnitMeasure, vyuICGetUOMConversions\""
            }],
            "type": "rest",
            "api": {
                "read": "../Inventory/api/UnitMeasure/Search"
            }
        }
    }
});