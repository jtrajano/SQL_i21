Ext.define('Inventory.view.InventoryReceiptViewModel', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.icinventoryreceipt',

    requires: [
        'Inventory.store.BufferedEquipmentLength',
        'Inventory.store.BufferedQAProperty',
        'Inventory.store.BufferedItemStockDetailView',
        'Inventory.store.BufferedItemPricingView',
        'Inventory.store.BufferedItemUnitMeasure',
        'Inventory.store.BufferedItemWeightUOM',
        'Inventory.store.BufferedPackedUOM',
        'Inventory.store.BufferedUnitMeasure',
        'Inventory.store.BufferedLot',
        'Inventory.store.BufferedStorageLocation',
        'AccountsPayable.store.VendorBuffered',
        'AccountsPayable.store.PurchaseOrderDetail',
        'AccountsPayable.store.VendorLocation',
        'i21.store.CompanyLocationBuffered',
        'i21.store.CurrencyBuffered',
        'i21.store.FreightTermsBuffered',
        'i21.store.ShipViaBuffered',
        'i21.store.UserListBuffered',
        'i21.store.CompanyLocationSubLocationBuffered',
        'i21.store.CountryBuffered'
    ],

    stores: {
        receiptTypes: {
            autoLoad: true,
            data: [
                {
                    strDescription: 'Purchase Contract'
                },
                {
                    strDescription: 'Purchase Order'
                },
                {
                    strDescription: 'Transfer Order'
                },
                {
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
                },
                {
                    strDescription: 'Cost'
                },
                {
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
                },
                {
                    strDescription: 'Per Ton'
                },
                {
                    strDescription: 'Per Miles'
                },
                {
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
                },
                {
                    strDescription: '02 - Broken'
                },
                {
                    strDescription: '03 - Missing'
                },
                {
                    strDescription: '04 - Replaced'
                }
            ],
            fields: {
                name: 'strDescription'
            }
        },

        subLocation: {
            type: 'smcompanylocationsublocationbuffered'
        },
        items: {
            type: 'icbuffereditemstockdetailview'
        },
        itemUOM: {
            type: 'icbuffereditempricingview'
        },
        packageType: {
            type: 'icbufferedpackeduom'
        },
        vendor: {
            type: 'vendorbuffered'
        },
        location: {
            type: 'companylocationbuffered'
        },
        poSource: {
            autoLoad: true,
            type: 'purchaseorderdetail'
        },
        shipFrom: {
            type: 'apentitylocation'
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
        },

        lots: {
            type: 'icbufferedlot'
        },
        parentLots: {
            type: 'icbufferedlot'
        },
        weightUOM: {
            type: 'icbuffereditemweightuom'
        },
        lotUOM: {
            type: 'icbuffereditemunitmeasure'
        },
        storageLocation: {
            type: 'icbufferedstoragelocation'
        },
        origin: {
            type: 'countrybuffered'
        },
        condition: {
            autoLoad: true,
            data: [
                {
                    strDescription: 'Sound/Full'
                },
                {
                    strDescription: 'Slack'
                },
                {
                    strDescription: 'Damaged'
                }
            ],
            fields: {
                name: 'strDescription'
            }
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
        },
        checkReadOnlyIfDirect: function (get) {
            if (get('current.ysnPosted') === true){
                return true
            }
            else {
                var isDirect = (get('current.strReceiptType') === 'Direct')
                return isDirect;
            }
        },
        checkReadOnlyWithSource: function(get) {
            if (get('current.ysnPosted') === true){
                return true
            }
            else {
                if (get('current.strReceiptType') !== 'Direct') {
                    if (get('current.tblICInventoryReceiptItems').data.items.length > 0){
                        var current = get('current.tblICInventoryReceiptItems').data.items[0];
                        if (current.get('intSourceId') !== null) {
                            return true;
                        }
                        else { return false; }
                    }
                    else { return false; }
                }
                else { return false; }
            }
        }
    }

});