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
        'Inventory.store.BufferedOtherCharges',
        'Inventory.store.BufferedStorageLocation',
        'EntityManagement.store.VendorBuffered',
        'AccountsPayable.store.PurchaseOrderDetail',
        'EntityManagement.store.LocationBuffered',
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
        sourceTypes: {
            autoLoad: true,
            data: [
                {
                    intSourceType: 0,
                    strSourceType: 'None'
                },
                {
                    intSourceType: 1,
                    strSourceType: 'Scale'
                },
                {
                    intSourceType: 2,
                    strSourceType: 'Inbound Shipment'
                }
            ],
            fields: {
                name: 'intSourceType',
                name: 'strSourceType'
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
        ownershipTypes: {
            autoLoad: true,
            data: [
                {
                    intOwnershipType: 1,
                    strOwnershipType: 'Own'
                },
                {
                    intOwnershipType: 2,
                    strOwnershipType: 'Storage'
                },
                {
                    intOwnershipType: 3,
                    strOwnershipType: 'Consigned Purchase'
                },
                {
                    intOwnershipType: 4,
                    strOwnershipType: 'Consigned Sale'
                }
            ],
            fields: {
                name: 'intOwnershipType',
                name: 'strOwnershipType'
            }
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
            type: 'emvendorbuffered'
        },
        location: {
            type: 'companylocationbuffered'
        },
        orderNumbers: {
            type: 'purchaseorderdetail'
        },
        shipFrom: {
            type: 'emlocationbuffered'
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

        otherCharges: {
            type: 'icbufferedothercharges'
        },
        costMethod: {
            autoLoad: true,
            data: [
                {
                    strDescription: 'Per Unit'
                },
                {
                    strDescription: 'Percentage'
                },
                {
                    strDescription: 'Amount'
                }
            ],
            fields: [
                {
                    name: 'strDescription'
                }
            ]
        },
        costUOM: {
            type: 'icbuffereditemunitmeasure'
        },
        vendor: {
            type: 'emvendorbuffered'
        },
        allocateBy: {
            autoLoad: true,
            data: [
                {
                    strDescription: 'Unit'
                },
                {
                    strDescription: 'Stock Unit'
                },
                {
                    strDescription: 'Cost'
                },
                {
                    strDescription: ''
                }
            ],
            fields: [
                {
                    name: 'strDescription'
                }
            ]
        },
        billedBy: {
            autoLoad: true,
            data: [
                {
                    strDescription: 'Vendor'
                },
                {
                    strDescription: 'Third Party'
                },
                {
                    strDescription: 'None'
                }
            ],
            fields: [
                {
                    name: 'strDescription'
                }
            ]
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
            if (get('current.ysnPosted')){
                isEnabled = true;
            }
            else {
                if (get('current.ysnInvoicePaid')){
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
        checkReadOnlyWithOrder: function(get) {
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
        },
        getReceiveButtonText: function(get) {
            if (get('current.ysnPosted')) {
                return 'UnReceive';
            }
            else {
                return 'Receive';
            }
        },
        checkHideOrderNo: function(get) {
            if (get('current.strReceiptType') === 'Direct') {
                return true;
            }
            else {
                return false;
            }
        },
        checkHideSourceNo: function(get) {
            if (get('current.intSourceType') === 0) {
                return true;
            }
            else {
                return false;
            }
        },
        checkInventoryCost: function(get){
            if (get('grdCharges.selection.ysnInventoryCost')) {
                return false;
            }
            else
                return true;
        },
        hasItemSelection: function(get){
            if (get('grdInventoryReceipt.selection')) {
                if (get('grdInventoryReceipt.selection').dummy === true) {
                    return true
                }
                else {
                    return false;
                }
            }
            else
                return true;
        }
    }

});