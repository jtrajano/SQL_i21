UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedEquipmentLength',
    alias: "store.icbufferedequipmentlength",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.EquipmentLength"],
    config: {
        "model": "Inventory.model.EquipmentLength",
        "storeId": "BufferedEquipmentLength",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/EquipmentLength/Search"
            }
        }
    }
});