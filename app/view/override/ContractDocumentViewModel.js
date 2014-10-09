Ext.define('Inventory.view.override.ContractDocumentViewModel', {
    override: 'Inventory.view.ContractDocumentViewModel',

    requires: [
        'Inventory.store.Commodity'
    ],

    stores: {
        Commodity: {
            type: 'inventorycommodity'
        }
    }
    
});