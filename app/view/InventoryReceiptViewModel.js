Ext.define('Inventory.view.InventoryReceiptViewModel', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.icinventoryreceipt',

    requires: [
        'Inventory.store.BufferedEquipmentLength',
        'Inventory.store.BufferedQAProperty',
        'Inventory.store.BufferedItemStockView',
        'Inventory.store.BufferedItemUnitMeasure',
        'Inventory.store.BufferedPackType',
        'AccountsPayable.store.VendorBuffered',
        'i21.store.CompanyLocationBuffered',
        'i21.store.CountryBuffered',
        'i21.store.CurrencyBuffered',
        'i21.store.FreightTermsBuffered'
    ],

    stores: {
        receiptTypes: {
            autoLoad: true,
            data: [
                {
                    strDescription: 'Contract'
                },{
                    strDescription: 'Purchase Order'
                },{
                    strDescription: 'Transfer Order'
                },{
                    strDescription: 'Direct'
                }
            ],
            fields: {
                name: 'strDescription'
            }
        },
        allocateFreights: {
            autoLoad: true,
            data: [
                {
                    strDescription: 'Weight'
                },{
                    strDescription: 'Cost'
                },{
                    strDescription: 'No'
                }
            ],
            fields: {
                name: 'strDescription'
            }
        },
        freightBilledBys: {
            autoLoad: true,
            data: [
                {
                    strDescription: 'Vendor'
                },{
                    strDescription: 'Outside Carrier'
                },{
                    strDescription: 'No'
                }
            ],
            fields: {
                name: 'strDescription'
            }
        },
        calculationBasis: {
            autoLoad: true,
            data: [
                {
                    strDescription: 'Per Unit'
                },{
                    strDescription: 'Per Ton'
                },{
                    strDescription: 'Per Miles'
                },{
                    strDescription: 'Flat Rate'
                }
            ],
            fields: {
                name: 'strDescription'
            }
        },
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
            type: 'icbuffereditemstockview'
        },
        itemUOM: {
            type: 'icbuffereditemunitmeasure'
        },
        itemPackType: {
            type: 'icbufferedpacktype'
        },
        vendor: {
            type: 'vendorbuffered'
        },
        location: {
            type: 'companylocationbuffered'
        },
        currency: {
            type: 'currencybuffered'
        },
        country: {
            type: 'countrybuffered'
        },
        freightTerm: {
            type: 'FreightTermsBuffered'
        },
        equipmentLength: {
            type: 'icbufferedequipmentlength'
        },
        qaProperty: {
            type: 'icbufferedqaproperty'
        }
    },

    formulas: {
        getInvoicePaidEnabled: function(get){
            if (get('ysnPosted') !== false){
                return true;
            }
            else {
                if ((get('ysnInvoicePaid') !== false)){
                    return true;
                }
                else{
                    return false;
                }

            }
        },
        getReceiveButtonText: function(get){
            if (get('ysnPosted') !== false){
                return 'Receive';
            }
            else {
                return 'UnReceive';
            }
        }
    }

});