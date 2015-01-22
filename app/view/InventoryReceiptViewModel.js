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
        'AccountsPayable.store.PurchaseOrder',
        'AccountsPayable.store.VendorLocation',
        'i21.store.CompanyLocationBuffered',
        'i21.store.CurrencyBuffered',
        'i21.store.FreightTermsBuffered',
        'i21.store.ShipViaBuffered',
        'i21.store.UserListBuffered'
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
                    strDescription: 'Transfer Receipt'
                },{
                    strDescription: 'Direct Transfer'
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
        shipTo: {
            type: 'companylocationbuffered'
        },
        poSource: {
            type: 'purchaseorder'
        },
        shipFrom: {
            type: 'apentitylocation'
        },
        shipTo: {
            type: 'companylocationbuffered'
        },
        transferor: {
            type: 'companylocationbuffered'
        },
        users: {
            type: 'userlistbuffered'
        },
        currency: {
            type: 'currencybuffered'
        },
        shipvia: {
            type: 'shipviabuffered'
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
        checkHiddenInInvoicePaid: function (get) {
            var isEnabled = false;
            if (get('ysnPosted')){
                isEnabled = true;
            }
            else {
                if (get('ysnInvoicePaid')){
                    isEnabled = true;
                }
                else {
                    isEnabled = false;
                }
            }

            return isEnabled;
        },
        checkHiddenInTransferReceipt: function (get) {
            var isTransferReceipt = (get('current.strReceiptType') === 'Transfer Receipt')
            return isTransferReceipt;
        },
        checkHiddenIfNotTransferReceipt: function (get) {
            var isTransferReceipt = (get('current.strReceiptType') !== 'Transfer Receipt')
            return isTransferReceipt;
        }
    }

});