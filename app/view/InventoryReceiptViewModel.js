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
        'Inventory.store.BufferedParentLot',
        'Inventory.store.BufferedOtherCharges',
        'Inventory.store.BufferedStorageLocation',
        'Inventory.store.BufferedGradeAttribute',
        'EntityManagement.store.VendorBuffered',
        'AccountsPayable.store.PurchaseOrderDetailBuffered',
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
        'ContractManagement.store.ContractDetailView',
        'ContractManagement.store.ContractHeaderViewBuffered',
        'Logistics.store.BufferedShipmentReceiptContracts',
        'Inventory.store.BufferedReceiptItemView',
        'i21.store.CurrencyExchangeRateTypeBuffered',
        'GeneralLedger.controls.RecapTab'
    ],

    data: {
        forceSelection: false,
        weightLoss: 0,
        modifiedOnPosted: undefined,
        locationFromTransferOrder: null
    },

    stores: {
        receiptItemView: {
            type: 'icbufferedreceiptitemview'
        },
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
                } // Note: cboReceiptType is set to forceSelection: false. This means 'Inventory Return' will show in the combo box despite not included as an inline data. 
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
                },
                {
                    intSourceType: 3,
                    strSourceType: 'Transport'
                },
                {
                    intSourceType: 4,
                    strSourceType: 'Settle Storage'
                }
            ],
            fields: {
                name: 'intSourceType',
                name: 'strSourceType'
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
            type: 'purchaseorderdetailbuffered'
        },
        purchaseContract: {
            type: 'ctcontractdetailviewbuffered'
        },
        purchaseContractList: {
            type: 'ctcontractdetailview'
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
        //itemCurrency: {
        //    type: 'currencybuffered'
        //},
        chargeCurrency: {
            type: 'currencybuffered'
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
            type: 'icbuffereditempricingview'
        },
        chargeUOM: {
            type: 'icbuffereditempricingview'
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
            type: 'icbufferedparentlot'
        },
        weightUOM: {
            type: 'icbuffereditemweightvolumeuom'
        },
        costtUOM: {
            type: 'icbuffereditemunitmeasure'
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
                },
                {
                    strDescription: 'Clean Wgt'
                }
            ],
            fields: {
                name: 'strDescription'
            }
        },
        forexRateType: {
            type: 'smcurrencyexchangeratetypebuffered'
        },
        chargeForexRateType: {
            type: 'smcurrencyexchangeratetypebuffered'
        }        
    },

    formulas: {
        intCurrencyId: function(get) {
            return get('current.intCurrencyId');
        },

        receiptTitle: function(get) {
            var screenTitle = 'Inventory Receipt - ';
            if (get('current.strReceiptType') === 'Inventory Return'){
                screenTitle = 'Inventory Return - '
            }

            screenTitle += get('current.strReceiptNumber');
            
            if(get('current.ysnOrigin')) {
                screenTitle += ' (Origin)';
            }
            
            return screenTitle;
        },
        hidePostButton: function(get) {
            var posted = get('current.ysnPosted');
            var hide = true;
            switch (get('current.intSourceType')) {
                case 1: // Scale  
                case 3: // Transport Load
                case 4: // Settle Storage 
                    return true;
                default:  
                    return posted;
            }
        },
        pgePreviewTitle: function(get) {
            var posted = get('current.ysnPosted');
            if (posted){
                return 'Unpost Preview';
            }
            else 
                return 'Post Preview';
        },
        hideUnpostButton: function(get) {
            var posted = get('current.ysnPosted');
            switch (get('current.intSourceType')) {
                case 1: // Scale  
                case 3: // Transport Load
                case 4: // Settle Storage 
                    return true;
                default:  
                    return !posted;
            }
        },

        checkHiddenAddOrders: function(get) {
            var isHidden = false;
            if (get('current.ysnPosted')) {
                isHidden = true;
            }
            else {
                switch (get('current.strReceiptType')) {
                    case 'Purchase Contract':
                        switch (get('current.intSourceType')) {
                            case 0:
                            case 2:
                                if (iRely.Functions.isEmpty(get('current.intEntityVendorId'))) {
                                    isHidden = true;
                                }
                                else {
                                    isHidden = false;
                                }
                                break;
                            default:
                                isHidden = true;
                                break;
                        }
                        break;
                    case 'Purchase Order':
                        if (iRely.Functions.isEmpty(get('current.intEntityVendorId'))) {
                            isHidden = true;
                        }
                        else {
                            isHidden = false;
                        }
                        break;
                    case 'Transfer Order':
                        if (iRely.Functions.isEmpty(get('current.intTransferorId'))) {
                            isHidden = true;
                        }
                        else {
                            isHidden = false;
                        }
                        break;
                    default :
                        isHidden = true;
                        break;
                }
            }

            return isHidden;
        },
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
        checkHiddenInTransferOrder: function (get) {
            var isTransferOrder = (get('current.strReceiptType') === 'Transfer Order')
            return isTransferOrder;
        },
        checkHiddenIfNotTransferOrder: function (get) {
            var isTransferOrder = (get('current.strReceiptType') !== 'Transfer Order')
            return isTransferOrder;
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
        locationCheckReadOnlyWithOrder: function (get) {
            if (get('current.ysnPosted') === true) {
                return true;
            }
            else {
                if (get('current.strReceiptType') === 'Inventory Return') {
                    return true; 
                }
                else if (get('current.strReceiptType') !== 'Direct' && get('current.strReceiptType') !== 'Transfer Order') {
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
        checkReadOnlyWithOrder: function (get) {
            if (get('current.ysnPosted') === true) {
                return true;
            }
            else {
                if (get('current.strReceiptType') === 'Inventory Return') {
                    return true; 
                }
                else if (get('current.strReceiptType') !== 'Direct') {
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
                return 'Unpost';
            }
            else {
                return 'Post';
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
        checkShowContractOnly: function (get) {
            if (get('current.strReceiptType') === 'Purchase Contract') {
                return false;
            }
            else {
                return true;
            }
        },
        checkHideLoadContract: function (get) {
            if (get('current.strReceiptType') === 'Purchase Contract' || get('current.strReceiptType') === 'Purchase Order') {
                if (get('grdInventoryReceipt.selection.ysnLoad') !== true) {
                    return false;
                }
                else {
                    return true;
                }
            }
            else {
                return true;
            }
        },
        checkShowLoadContractOnly: function (get) {
            if (get('grdInventoryReceipt.selection.ysnLoad') !== true) {
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
        checkInventoryCostAndPrice: function (get) {
            if (
                get('grdCharges.selection.ysnInventoryCost') ||
                get('grdCharges.selection.ysnPrice')
            ) {
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
            if (get('current.strReceiptType') == 'Inventory Return'){
                return true;
            }
            else if (iRely.Functions.isEmpty(get('grdInventoryReceipt.selection.intStorageLocationId'))) {
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
                    if (this.getData().current) {
                        if (this.getData().current.phantom) {
                            return {
                                column: 'intSourceType',
                                value: 1,
                                condition: 'noteq'
                            };
                        }
                    }
                    return [];
                    break;
                default:
                    return [];
                    break;
            }
        },

        isOriginOrPosted: function(get){
            return  get('current.ysnOrigin') || get('current.ysnPosted');
        },

        isReceiptReadonly: function(get) {
            return  get('current.ysnOrigin') || get('current.ysnPosted') || get('current.strReceiptType') === 'Inventory Return';
        },

        isOriginOrInventoryReturn: function(get){
            return  get('current.ysnOrigin') || get('current.strReceiptType') === 'Inventory Return';
        },

        readOnlyReceiptItemGrid: function (get) {
            if (get('current.ysnPosted') || get('current.ysnOrigin')) {
                return true;
            }
            else if ((iRely.Functions.isEmpty(get('current.intEntityVendorId')) && get('current.strReceiptType') !== 'Transfer Order') || iRely.Functions.isEmpty(get('current.intLocationId'))) {
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
                case 'Inventory Return': 
                    return true;
                    break;
                default:
                    // Commenting this out. User should be able to enter the lots even if the IR is a purchase contract. 
                    // if (iRely.Functions.isEmpty(get('grdInventoryReceipt.selection.strOrderNumber'))) {
                    //     return false;
                    // }
                    // else {
                    //     return true;
                    // }
                    return false;
                    break;
            };
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
                case true:
                    return false;
                    break;
                default:
                    return true;
                    break;
            }
        },
        readOnlyUnitCost: function (get) {
            if (iRely.Functions.isEmpty(get('grdInventoryReceipt.selection.strItemNo'))) {
               return true;
            }
            else {
                switch (get('current.strReceiptType')) {       
                    case 'Purchase Contract':
                        if (iRely.Functions.isEmpty(get('grdInventoryReceipt.selection.strOrderNumber')) || get('grdInventoryReceipt.selection.strPricingType') === 'Unit') {
                            return false;
                        }
                        else {
                            return true;
                        }
                        break; 
                    case 'Inventory Return': 
                        return true; 
                        break;
                    default:
                        return false;
                }
            }
        },
        readOnlyNetUOM: function (get) {
            if (get('current.strReceiptType') === 'Inventory Return') {
                return false; 
            }
            else if (iRely.Functions.isEmpty(get('grdInventoryReceipt.selection.intWeightUOMId'))) {
                return true;
            }
            else {
                return false;
            }
        },
        readOnlyGrossTareUOM: function (get) {
            if (iRely.Functions.isEmpty(get('grdInventoryReceipt.selection.intWeightUOMId'))) {
                return true;
            }
            else if (get('current.strReceiptType') === 'Inventory Return') {
                return false; 
            }
            else {
                return false;
            }
        },        
        getWeightLossText: function (get) {
            var weight = get('weightLoss');
            if (Ext.isNumeric(weight) && weight !== 0) {
                return 'Wgt or Vol Gain/Loss: ';
            }
            else {
                return 'Wgt or Vol Gain/Loss: 0.00';  
            }
        },
       /* getWeightLossValueText: function (get) {
            var weight = get('weightLoss');
            if (Ext.isNumeric(weight) && weight !== 0) {
                return Ext.util.Format.number(weight, '0,000.00');
            }
            else {
                 return '0.00';  
            }
        },*/
        hidelblWeightLossMsgValue: function(get) {
             var weight = get('weightLoss');
            if (Ext.isNumeric(weight) && weight !== 0) {
                return false;
            }
            else {
                 return true; 
            }
        },
        readOnlyChargeCurrency: function (get) {
            switch (get('grdCharges.selection.ysnSubCurrency')) {
                case true:
                    return true;
                    break;
                default:
                    return false;
                    break;

            }
        },
        disableAmount: function (get) {
             switch (get('grdCharges.selection.strCostMethod')) {
                  case 'Per Unit':
                      return true;
                      break;
                  case 'Percentage':
                      return true;
                      break;
                  default:
                      return false;
                      break;
              }
        },
    
        disableQtyInReceiptGrid: function (get){
            if (iRely.Functions.isEmpty(get('grdInventoryReceipt.selection.strItemNo'))) {
                return true;
            }
            else {
                return false; 
            }
            // else {
            //     switch (get('current.strReceiptType')) {       
            //         case 'Inventory Return': 
            //             return false; 
            //             break;
            //         default:
            //             return false;
            //     }
            // }
        },

       disableFieldInReceiptGrid: function (get) {
            if (iRely.Functions.isEmpty(get('grdInventoryReceipt.selection.strItemNo'))) {
                return true;
            }
            else {
                switch (get('current.strReceiptType')) {       
                    case 'Inventory Return': 
                        return true; 
                        break;
                    default:
                        return false;
                }
            }
       },
       readyOnlyChargeTaxGroup: function(get) {
           if(get('grdCharges.selection.intEntityVendorId') || (get('grdCharges.selection.intEntityVendorId') == get('current.intEntityVendorId'))) {
              return false;
            }
           else {
                return true;
           }
       },
       checkHideReturnButton: function (get){
           if (get('current.strReceiptType') !== 'Inventory Return' && get('current.ysnPosted')){
                return false; 
           }
           return true; 
       },
       changeQtyToReceiveText: function (get){
            if (get('current.strReceiptType') == 'Inventory Return'){
                return 'Qty to Return';
           }
           return 'Receipt Qty';
       },
       hideVoucherButton: function(get) {
            if (get('current.strReceiptType') == 'Inventory Return') {
                return true; 
            }

            var posted = get('current.ysnPosted');
            return !posted; 
       },
       hideDebitMemoButton: function(get) {
            if (get('current.strReceiptType') != 'Inventory Return') 
            {
                return true; 
            }

            var posted = get('current.ysnPosted');
            return !posted; 
       }
    }
});