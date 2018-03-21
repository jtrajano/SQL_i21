UnitTestEngine.testStore({
    name: 'Inventory.store.Shipment',
    alias: "store.icshipment",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.Shipment"],
    config: {
        "model": "Inventory.model.Shipment",
        "storeId": "Shipment",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "./inventory/api/inventoryshipment/get",
                "update": "./inventory/api/inventoryshipment/put",
                "create": "./inventory/api/inventoryshipment/post"
            }
        }
    }
});