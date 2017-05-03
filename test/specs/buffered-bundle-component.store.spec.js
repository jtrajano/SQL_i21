UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedBundleComponent',
    alias: "store.icbufferedbundlecomponent",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.BundleComponent"],
    config: {
        "model": "Inventory.model.BundleComponent",
        "storeId": "BufferedBundleComponent",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/Item/SearchBundleComponents"
            }
        }
    }
});