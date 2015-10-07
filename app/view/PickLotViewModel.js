Ext.define('Inventory.view.PickLotViewModel', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.icpicklot',

    requires: [
        'i21.store.CompanyLocationBuffered',
        'Inventory.store.BufferedCommodity',
        'Inventory.store.BufferedItemStockView',
        'Inventory.store.BufferedStorageLocation'
    ],

    stores: {
        location: {
            type: 'companylocationbuffered'
        },
        commodity: {
            type: 'icbufferedcommodity'
        },
        item: {
            type: 'icbuffereditemstockview'
        },
        storageLocation: {
            type: 'icbufferedstoragelocation'
        }
    }

});