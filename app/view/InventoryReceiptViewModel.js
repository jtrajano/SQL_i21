Ext.define('Inventory.view.InventoryReceiptViewModel', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.icinventoryreceipt',

    requires: [
        'Inventory.store.BufferedEquipmentLength',
        'Inventory.store.BufferedQAProperty',
        'Inventory.store.BufferedItemStockDetailView',
        'Inventory.store.BufferedItemPricingView',
        'Inventory.store.BufferedItemUnitMeasure',
        'Inventory.store.BufferedItemWeightVolumeUOM',
        'Inventory.store.BufferedPackedUOM',
        'Inventory.store.BufferedUnitMeasure',
        'Inventory.store.BufferedLot',
        'Inventory.store.BufferedOtherCharges',
        'Inventory.store.BufferedStorageLocation',
        'Inventory.store.BufferedGradeAttribute',
        'EntityManagement.store.VendorBuffered',
        'AccountsPayable.store.PurchaseOrderDetail',
        'EntityManagement.store.LocationBuffered',
        'EntityManagement.store.ShipViaBuffered',
        'i21.store.CompanyLocationBuffered',
        'i21.store.CurrencyBuffered',
        'i21.store.FreightTermsBuffered',
        'i21.store.UserListBuffered',
        'i21.store.CompanyLocationSubLocationBuffered',
        'i21.store.CountryBuffered',
        'i21.store.TaxGroupBuffered',
        'ContractManagement.store.ContractDetailViewBuffered',
        'ContractManagement.store.ContractHeaderViewBuffered',
        'Logistics.store.BufferedShipmentReceiptContracts',
        'AccountsPayable.common.extensions.GridExtension'
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
            autoFilter: true,
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
                },
                {
                    intSourceType: 3,
                    strSourceType: 'Transport'
                }
            ],
            filters: '{filterSourceByType}',
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
        taxGroup: {
            type: 'smtaxgroupbuffered'
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
        purchaseContract: {
            type: 'ctcontractdetailviewbuffered'
        },
        inboundShipment: {
            type: 'lgbufferedshipmentreceiptcontracts'
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
            type: 'emshipviabuffered'
        },
        freightTerm: {
            type: 'FreightTermsBuffered'
        },

        contract: {
            type: 'ctcontractheaderviewbuffered'
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
        grade: {
            type: 'icbufferedgradeattribute'
        },
        lotGrade: {
            type: 'icbufferedgradeattribute'
        },
        vendorLocation: {
            type: 'emlocationbuffered'
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
            type: 'icbuffereditemweightvolumeuom'
        },
        lotUOM: {
            type: 'icbuffereditemunitmeasure'
        },
        storageLocation: {
            type: 'icbufferedstoragelocation'
        },
        lotStorageLocation: {
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
            if (get('current.ysnPosted')) {
                isEnabled = true;
            }
            else {
                if (get('current.ysnInvoicePaid')) {
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
            if (get('current.ysnPosted') === true) {
                return true
            }
            else {
                var isDirect = (get('current.strReceiptType') === 'Direct')
                return isDirect;
            }
        },
        checkReadOnlyWithOrder: function (get) {
            if (get('current.ysnPosted') === true) {
                return true
            }
            else {
                if (get('current.strReceiptType') !== 'Direct') {
                    if (get('current.tblICInventoryReceiptItems').data.items.length > 0) {
                        var current = get('current.tblICInventoryReceiptItems').data.items[0];
                        if (current.get('intOrderId') !== null) {
                            return true;
                        }
                        else {
                            return false;
                        }
                    }
                    else {
                        return false;
                    }
                }
                else {
                    return false;
                }
            }
        },
        getReceiveButtonText: function (get) {
            if (get('current.ysnPosted')) {
                return 'UnReceive';
            }
            else {
                return 'Receive';
            }
        },
        checkHideOrderNo: function (get) {
            if (get('current.strReceiptType') === 'Direct') {
                return true;
            }
            else {
                return false;
            }
        },
        checkHideSourceNo: function (get) {
            if (get('current.intSourceType') === 0) {
                return true;
            }
            else {
                return false;
            }
        },
        checkHideOwnershipType: function(get) {
            if (get('current.strReceiptType') === 'Direct') {
                return false;
            }
            else {
                return true;
            }
        },
        checkInventoryCost: function (get) {
            if (get('grdCharges.selection.ysnInventoryCost')) {
                return false;
            }
            else
                return true;
        },
        hasItemSelection: function (get) {
            if (get('grdInventoryReceipt.selection')) {
                if (get('grdInventoryReceipt.selection').dummy === true) {
                    if (iRely.Functions.isEmpty(get('grdInventoryReceipt.selection.strLotTracking'))) {
                        return true
                    }
                    else {
                        if (get('grdInventoryReceipt.selection.strLotTracking') === 'No') {
                            return true
                        }
                        else {
                            return false;
                        }
                    }
                }
                else {
                    if (get('grdInventoryReceipt.selection.strLotTracking') === 'No') {
                        return true
                    }
                    else {
                        return false;
                    }
                }
            }
            else
                return true;
        },
        hasItemCommodity: function (get) {
            if (iRely.Functions.isEmpty(get('grdInventoryReceipt.selection.intCommodityId'))) {
                return true;
            }
            else {
                return false;
            }
        },
        hasStorageLocation: function (get) {
            if (iRely.Functions.isEmpty(get('grdInventoryReceipt.selection.intStorageLocationId'))) {
                return false;
            }
            else {
                return true;
            }
        },
        disableSourceType: function (get) {
            if (get('current.ysnPosted') === true) {
                return true;
            }
            else {
                switch (get('current.strReceiptType')) {
                    case 'Purchase Contract':
                        return false;
                        break;
                    default:
                        return true;
                        break;
                }
            }
        },
        filterSourceByType: function (get) {
            switch (get('current.strReceiptType')) {
                case 'Purchase Contract':
                    return {
                        property: 'intSourceType',
                        value: '1',
                        operator: '!='
                    };
                    break;
                default:
                    return {};
                    break;
            }
        },
        readOnlyReceiptItemGrid: function (get) {
            if (get('current.ysnPosted')) {
                return true;
            }
            else if (iRely.Functions.isEmpty(get('current.intEntityVendorId')) || iRely.Functions.isEmpty(get('current.intLocationId'))) {
                return true;
            }
            else {
                return false;
            }

        },
        readOnlyItemDropdown: function (get) {
            var receiptType = get('current.strReceiptType');
            switch (receiptType) {
                case 'Direct' :
                    return false;
                    break;
                default:
                    return true;
                    break;
            };
        },
        readOnlyWeightDropdown: function (get) {
            if (get('grdInventoryReceipt.selection.strLotTracking') === 'No') {
                return true;
            }
            else return false;
        },
        readOnlyOrderNumberDropdown: function (get) {
            var receiptType = get('current.strReceiptType');
            switch (receiptType) {
                case 'Direct' :
                    return true;
                    break;
                default:
                    if (iRely.Functions.isEmpty(get('grdInventoryReceipt.selection.strOrderNumber'))) {
                        return false;
                    }
                    else {
                        return true;
                    }
                    break;
            };
        },
        readOnlySourceNumberDropdown: function (get) {
            var receiptType = get('current.strReceiptType');
            switch (receiptType) {
                case 'Direct' :
                    return true;
                    break;
                default:
                    if (iRely.Functions.isEmpty(get('grdInventoryReceipt.selection.strSourceNumber'))) {
                        return false;
                    }
                    else {
                        return true;
                    }
                    break;
            };
        },
        readOnlyCostMethod: function (get) {
            if (iRely.Functions.isEmpty(get('grdCharges.selection.strOnCostType'))) {
                return false;
            }
            else {
                return true;
            }
        },
        hideContainerColumn: function(get) {
            var sourceType = get('current.intSourceType');
            switch (sourceType) {
                case 2 :
                    return false;
                    break;
                default:
                    return true;
                    break;
            }
        },
        hideContractColumn: function(get) {
            var receiptType = get('current.strReceiptType');
            switch (receiptType) {
                case 'Purchase Contract' :
                    return false;
                    break;
                default:
                    return true;
                    break;
            }
        },
        readOnlyAccrue: function (get) {
            switch (get('grdCharges.selection.ysnAccrue')) {
                case false:
                    return true;
                    break;
                default:
                    return false;
                    break;
            }
        },
        readOnlyUnitCost: function (get) {
            switch (get('current.strReceiptType')) {
                case 'Purchase Contract':
                    return true;
                    break;
                default:
                    return false;
                    break;
            }
        },
        readOnlyNoGrossNetUOM: function (get) {
            if (iRely.Functions.isEmpty(get('grdInventoryReceipt.selection.intWeightUOMId'))) {
                return true;
            }
            else {
                return false;
            }
        }
    }

});