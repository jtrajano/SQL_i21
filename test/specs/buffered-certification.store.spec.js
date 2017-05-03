UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedCertification',
    alias: "store.icbufferedcertification",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.Certification"],
    config: {
        "model": "Inventory.model.Certification",
        "storeId": "BufferedCertification",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/Certification/Search"
            }
        }
    }
});