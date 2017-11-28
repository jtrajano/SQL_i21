UnitTestEngine.testViewModel({
    name: 'Inventory.view.CategoryViewModel',
    alias: 'viewmodel.iccategory',
    base: 'Ext.app.ViewModel',
    dependencies: ["Inventory.store.BufferedUnitMeasure", "Inventory.store.BufferedCompactItem", "Inventory.store.BufferedCategoryLocation", "Inventory.store.BufferedCategoryUOM", "EntityManagement.store.VendorBuffered", "i21.store.CompanyLocationBuffered", "i21.store.TaxClassBuffered", "Store.store.SubCategoryBuffered", "GeneralLedger.store.BufAccountCategoryGroup", "i21.store.LineOfBusinessBuffered"]
});