Ext.define('Inventory.view.LotDetail', {
    extend: 'GlobalComponentEngine.view.GridTemplate',
    alias: 'widget.iclotdetail',

    requires: [
        'GlobalComponentEngine.view.GridTemplate',
        'Inventory.view.LotDetailViewModel',
        'Inventory.view.LotDetailViewController'
    ]
});