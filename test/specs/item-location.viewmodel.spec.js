UnitTestEngine.testViewModel({
    name: 'Inventory.view.ItemLocationViewModel',
    alias: 'viewmodel.icitemlocation',
    base: 'Ext.app.ViewModel',
    dependencies: ["i21.store.CompanyLocationBuffered", "i21.store.FreightTermsBuffered", "i21.store.CompanyLocationSubLocationBuffered", "EntityManagement.store.VendorBuffered", "EntityManagement.store.ShipViaBuffered", "Inventory.store.BufferedItemUnitMeasure", "Inventory.store.BufferedCountGroup", "Inventory.store.BufferedStorageLocation", "Inventory.store.BufferedItemUPC", "Store.store.SubCategoryBuffered", "Store.store.SubcategoryRegProdBuffered", "Store.store.PromotionSalesBuffered", "Store.store.RadiantItemTypeCodeBuffered"]
});