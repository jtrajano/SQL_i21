Ext.define('Inventory.view.StorageMeasurementReadingViewModel', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.icstoragemeasurementreading',

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