UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedContainerType',
    alias: "store.icbufferedcontainertype",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.ContainerType"],
    config: {
        "model": "Inventory.model.ContainerType",
        "storeId": "BufferedContainerType",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/ContainerType/Search"
            }
        }
    }
});