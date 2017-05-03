UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedItemWeightVolumeUOM',
    alias: "store.icbuffereditemweightvolumeuom",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.ItemUOM"],
    config: {
        "model": "Inventory.model.ItemUOM",
        "storeId": "BufferedItemWeightVolumeUOM",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/ItemUOM/SearchWeightVolumeUOMs"
            }
        }
    }
});