UnitTestEngine.testViewModel({
    name: 'Inventory.view.CommodityViewModel',
    alias: 'viewmodel.iccommodity',
    base: 'Ext.app.ViewModel',
    dependencies: ["Inventory.store.BufferedUnitMeasure", "Inventory.store.BufferedStorageType", "GeneralLedger.store.BufAccountId", "GeneralLedger.store.BufAccountCategoryGroup", "i21.store.CompanyLocationBuffered", "RiskManagement.store.FutureMarketBuffered", "Grain.store.BufferedStorageSchedule", "Grain.store.BufferedUniqueDiscountId", "Grain.store.BufferedDistributions", "Grain.store.BufferedUniqueStorageSchedule", "i21.store.CountryBufferedStore", "i21.store.PurchasingGroupBuffered"]
});