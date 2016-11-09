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
                "read": "../Inventory/api/InventoryShipment/Get",
                "update": "../Inventory/api/InventoryShipment/Put",
                "create": "../Inventory/api/InventoryShipment/Post"
            }
        }
    }
});