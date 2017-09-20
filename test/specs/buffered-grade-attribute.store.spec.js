UnitTestEngine.testStore({
    name: 'Inventory.store.BufferedGradeAttribute',
    alias: "store.icbufferedgradeattribute",
    base: 'Ext.data.BufferedStore',
    dependencies: ["Inventory.model.CommodityGradeView"],
    config: {
        "model": "Inventory.model.CommodityGradeView",
        "storeId": "BufferedGradeAttribute",
        "pageSize": 50,
        "remoteFilter": true,
        "remoteSort": true,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/CommodityAttribute/SearchGradeAttributes"
            }
        }
    }
});