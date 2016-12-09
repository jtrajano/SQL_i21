UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedBrand',
    alias: "store.icbufferedbrand",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.Brand"],
    config: {
        "model": "Inventory.model.Brand",
        "storeId": "BufferedBrand",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/Brand/Search"
            }
        }
    }
});