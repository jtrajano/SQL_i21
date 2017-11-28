UnitTestEngine.testViewModel({
    name: 'Inventory.view.CertificationProgramViewModel',
    alias: 'viewmodel.iccertificationprogram',
    base: 'Ext.app.ViewModel',
    dependencies: ["i21.store.CountryBuffered", "Inventory.store.BufferedCommodity", "Inventory.store.BufferedUnitMeasure", "i21.store.CurrencyBuffered"]
});