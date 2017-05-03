UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedItemFactory',
    alias: "store.icbuffereditemfactory",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.CompactItemFactory"],
    config: {
        "model": "Inventory.model.CompactItemFactory",
        "storeId": "BufferedItemFactory",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/ItemFactory/Search"
            }
        }
    }
});