UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedAssemblyItem',
    alias: "store.icbufferedassemblyitem",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.CompactItem"],
    config: {
        "model": "Inventory.model.CompactItem",
        "storeId": "BufferedAssemblyItem",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/Item/SearchAssemblyItems"
            }
        }
    }
});