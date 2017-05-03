UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedItemUnitMeasure',
    alias: "store.icbuffereditemunitmeasure",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.ItemUOM"],
    config: {
        "model": "Inventory.model.ItemUOM",
        "storeId": "BufferedItemUnitMeasure",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/ItemUOM/Search"
            }
        }
    }
});