UnitTestEngine.testStore({
    name: 'Inventory.store.CompanyPreference',
    alias: "store.iccompanypreference",
    base: 'Ext.data.Store',
    dependencies: ["Inventory.model.CompanyPreference"],
    config: {
        "model": "Inventory.model.CompanyPreference",
        "storeId": "CompanyPreference",
        "pageSize": 50,
        "proxy": {
            "type": "rest",
            "api": {
                "read": "../Inventory/api/CompanyPreference/Get",
                "update": "../Inventory/api/CompanyPreference/Put",
                "create": "../Inventory/api/CompanyPreference/Post"
            }
        }
    }
});