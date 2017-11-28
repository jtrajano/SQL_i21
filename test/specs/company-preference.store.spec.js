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
                "read": "./inventory/api/companypreference/get",
                "update": "./inventory/api/companypreference/put",
                "create": "./inventory/api/companypreference/post"
            }
        }
    }
});