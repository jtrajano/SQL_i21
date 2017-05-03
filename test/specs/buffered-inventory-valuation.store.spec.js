UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedInventoryValuation',
    alias: "store.icbufferedinventoryvaluation",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.InventoryValuation"],
    config: {
        "model": "Inventory.model.InventoryValuation",
        "storeId": "BufferedInventoryValuation",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/Item/SearchInventoryValuation"
            }
        }
    }
});