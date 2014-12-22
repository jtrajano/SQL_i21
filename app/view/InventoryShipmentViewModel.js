Ext.define('Inventory.view.InventoryShipmentViewModel', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.icinventoryshipment',

    requires: [
        'Inventory.store.BufferedCompactItem',
        'Inventory.store.BufferedItemUnitMeasure',
        'i21.store.CompanyLocationBuffered',
        'i21.store.FreightTermsBuffered',
    ],

    stores: {
        sealStatuses: {
            autoLoad: true,
            data: [
                {
                    strDescription: '01 - Intact'
                },{
                    strDescription: '02 - Broken'
                },{
                    strDescription: '03 - Missing'
                },{
                    strDescription: '04 - Replaced'
                }
            ],
            fields: {
                name: 'strDescription'
            }
        },
        items: {
            type: 'icbufferedcompactitem'
        },
        itemUOM: {
            type: 'icbuffereditemunitmeasure'
        },
        location: {
            type: 'companylocationbuffered'
        },
        freightTerm: {
            type: 'FreightTermsBuffered'
        }
    }

});