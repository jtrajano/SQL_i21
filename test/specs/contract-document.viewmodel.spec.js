UnitTestEngine.testViewModel({
    name: 'Inventory.view.ContractDocumentViewModel',
    alias: 'viewmodel.iccontractdocument',
    base: 'Ext.app.ViewModel',
    dependencies: ["Inventory.store.BufferedCommodity", "Inventory.store.BufferedCertification"]
});