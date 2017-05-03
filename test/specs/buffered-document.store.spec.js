UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedDocument',
    alias: "store.icbuffereddocument",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.Document"],
    config: {
        "model": "Inventory.model.Document",
        "storeId": "BufferedDocument",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/Document/Search"
            }
        }
    }
});