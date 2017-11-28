UnitTestEngine.testViewModel({
    name: 'Inventory.view.CategoryLocationViewModel',
    alias: 'viewmodel.iccategorylocation',
    base: 'Ext.app.ViewModel',
    dependencies: ["i21.store.CompanyLocationBuffered", "Store.store.SubCategoryBuffered", "Store.store.SubcategoryRegProdBuffered"]
});