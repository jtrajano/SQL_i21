Ext.define('Inventory.view.InventoryShipmentViewModel', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.icinventoryshipment',

    requires: [
        'Inventory.store.BufferedCompactItem',
        'Inventory.store.BufferedItemUnitMeasure',
        'i21.store.CompanyLocationBuffered',
        'i21.store.FreightTermsBuffered',
        'i21.store.ShipViaBuffered',
        'AccountsReceivable.store.CustomerBuffered'
    ],

    stores: {
        orderTypes: {
            autoLoad: true,
            data: [
                {
                    intOrderType: 1,
                    strDescription: 'Sales Contract'
                },{
                    intOrderType: 2,
                    strDescription: 'Sales Order'
                },{
                    intOrderType: 3,
                    strDescription: 'Transfer Order'
                }
            ],
            fields: {
                name: 'intOrderType',
                name: 'strDescription'
            }
        },
        freightTerm: {
            type: 'FreightTermsBuffered'
        },
        customer: {
            type: 'customerbuffered'
        },
        location: {
            type: 'companylocationbuffered'
        },
        shipVia: {
            type: 'shipviabuffered'
        },
        items: {
            type: 'icbufferedcompactitem'
        },
        itemUOM: {
            type: 'icbuffereditemunitmeasure'
        },
        weightUOM: {
            type: 'icbuffereditemunitmeasure'
        }

    }

});