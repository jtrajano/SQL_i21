UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedItemUOMByType',
    alias: "store.icbuffereditemuombytype",
    base: 'Ext.data.BufferedStore',
    dependencies: [],
    config: {
        "storeId": "BufferedItemUOMByType",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/item/getitemuomsbytype"
            }
        }
    }
});