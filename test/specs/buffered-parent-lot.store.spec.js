UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedParentLot',
    alias: "store.icbufferedparentlot",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.ParentLot"],
    config: {
        "model": "Inventory.model.ParentLot",
        "storeId": "BufferedParentLot",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/ParentLot/Search"
            }
        }
    }
});