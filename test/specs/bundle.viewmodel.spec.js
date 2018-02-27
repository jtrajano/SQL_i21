UnitTestEngine.testViewModel({
    name: 'Inventory.view.BundleViewModel',
    alias: 'viewmodel.icbundle',
    base: 'Ext.app.ViewModel',
    dependencies: ["Inventory.store.BufferedCompactItem", "Inventory.store.BufferedManufacturer", "Inventory.store.BufferedCategory", "Inventory.store.BufferedItemUnitMeasure", "Inventory.store.BufferedUnitMeasure", "Inventory.store.BufferedBrand", "Inventory.store.BufferedCommodity", "Inventory.store.BufferedCategory", "Inventory.store.BufferedItemLocation", "Inventory.store.BufferedCommodity", "i21.store.CompanyLocationSubLocationBuffered", "i21.store.CompanyLocationPricingLevelBuffered", "i21.store.CurrencyBuffered", "GeneralLedger.store.BufAccountCategoryGroup"]
});