UnitTestEngine.testViewModel({
    name: 'Inventory.view.ManufacturingCellViewModel',
    alias: 'viewmodel.icmanufacturingcell',
    base: 'Ext.app.ViewModel',
    dependencies: ["i21.store.CompanyLocationBuffered", "Inventory.store.BufferedUnitMeasure", "Inventory.store.BufferedPackType"]
});