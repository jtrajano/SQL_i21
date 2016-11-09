UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedItemLocation',
    alias: "store.icbuffereditemlocation",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.ItemLocation"],
    config: {
        "model": "Inventory.model.ItemLocation",
        "storeId": "BufferedItemLocation",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/ItemLocation/Search"
            }
        }
    }
});