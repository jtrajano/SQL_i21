UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedMaterialNMFC',
    alias: "store.icbufferedmaterialnmfc",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.MaterialNMFC"],
    config: {
        "model": "Inventory.model.MaterialNMFC",
        "storeId": "BufferedMaterialNMFC",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/MaterialNMFC/Search"
            }
        }
    }
});