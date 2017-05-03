UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedItemOwner',
    alias: "store.icbuffereditemowner",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.AdjustItemOwner"],
    config: {
        "model": "Inventory.model.AdjustItemOwner",
        "storeId": "BufferedItemOwner",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/Item/SearchItemOwner"
            }
        }
    }
});