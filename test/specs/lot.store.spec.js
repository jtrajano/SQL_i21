UnitTestEngine.testStore({
    name: 'Inventory.store.Lot',
    alias: "store.iclot",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.Lot"],
    config: {
        "model": "Inventory.model.Lot",
        "storeId": "Lot",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/Lot/Get"
            }
        }
    }
});