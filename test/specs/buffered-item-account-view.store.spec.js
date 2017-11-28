UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedItemAccountView',
    alias: "store.icbuffereditemaccountview",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.ItemAccountView"],
    config: {
        "model": "Inventory.model.ItemAccountView",
        "storeId": "BufferedItemAccountView",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/item/searchitemaccounts"
            }
        }
    }
});