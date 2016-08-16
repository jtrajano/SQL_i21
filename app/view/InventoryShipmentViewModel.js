Ext.define('Inventory.view.InventoryShipmentViewModel', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.icinventoryshipment',

    requires: [
        'Inventory.store.BufferedItemStockDetailView',
        'Inventory.store.BufferedItemUnitMeasure',
        'Inventory.store.BufferedItemPricingView',
        'Inventory.store.BufferedItemWeightUOM',
        'Inventory.store.BufferedLot',
        'Inventory.store.BufferedGradeAttribute',
        'Inventory.store.BufferedStorageLocation',
        'Inventory.store.BufferedOtherCharges',
        'i21.store.CompanyLocationBuffered',
        'i21.store.CompanyLocationSubLocationBuffered',
        'i21.store.FreightTermsBuffered',
        'EntityManagement.store.ShipViaBuffered',
        'EntityManagement.store.CustomerBuffered',
        'EntityManagement.store.LocationBuffered',
        'EntityManagement.store.VendorBuffered',
        'AccountsReceivable.store.SalesOrderDetailCompactBuffered',
        'ContractManagement.store.ContractDetailViewBuffered',
        'ContractManagement.store.ContractDetailView',
        'ContractManagement.store.ContractHeaderViewBuffered',
        'i21.store.CurrencyBuffered',
        'Logistics.store.PickedLots'
    ],

    data: {
        triggerAddRemoveLineItem: false
    },

    stores: {
        orderTypes: {
            autoLoad: true,
            data: [
                {
                    intOrderType: 1,
                    strOrderType: 'Sales Contract'
                },{
                    intOrderType: 2,
                    strOrderType: 'Sales Order'
                },{
                    intOrderType: 3,
                    strOrderType: 'Transfer Order'
                },{
                    intOrderType: 4,
                    strOrderType: 'Direct'
                }
            ],
            fields: {
                name: 'intOrderType',
                name: 'strOrderType'
            }
        },
        sourceTypes: {
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
                    strSourceType: 'Pick Lot'
                }
            ],
            fields: {
                name: 'intSourceType',
                name: 'strSourceType'
            }
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
        freightTerm: {
            type: 'FreightTermsBuffered'
        },
        customer: {
            type: 'customerbuffered'
        },
        shipFromLocation: {
            type: 'companylocationbuffered'
        },
        shipToLocation: {
            type: 'emlocationbuffered'
        },
        shipToCompanyLocation: {
            type: 'companylocationbuffered'
        },
        shipVia: {
            type: 'emshipviabuffered'
        },
        soDetails: {
            type: 'salesorderdetailcompactbuffered'
        },
        salesContract: {
            type: 'ctcontractdetailviewbuffered'
        },
        salesContractList: {
            type: 'ctcontractdetailview'
        },
        items: {
            type: 'icbuffereditemstockdetailview'
        },
        subLocation: {
            type: 'smcompanylocationsublocationbuffered'
        },
        storageLocation: {
            type: 'icbufferedstoragelocation'
        },
        grade: {
            type: 'icbufferedgradeattribute'
        },
        itemUOM: {
            type: 'icbuffereditempricingview'
        },
        weightUOM: {
            type: 'icbuffereditemweightuom'
        },
        lot: {
            type: 'icbufferedlot'
        },
        contract: {
            type: 'ctcontractheaderviewbuffered'
        },
        otherCharges: {
            type: 'icbufferedothercharges'
        },
        costUOM: {
            type: 'icbuffereditemunitmeasure'
        },
        vendor: {
            type: 'emvendorbuffered'
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
        allocateBy: {
            autoLoad: true,
            data: [
                {
                    strAllocatePriceBy: 'Unit'
                },
                {
                    strAllocatePriceBy: 'Stock Unit'
                },
                {
                    strAllocatePriceBy: 'Price'
                },
                {
                    strAllocatePriceBy: ''
                }
            ],
            fields: [
                {
                    name: 'strAllocatePriceBy'
                }
            ]
        },
        chargeCurrency: {
            type: 'currencybuffered'
        },
        pickedLotList: {
            type: 'lgpickedlots'
        }
    },

    formulas: {
        getShipButtonText: function(get) {
            if (get('current.ysnPosted')) {
                return 'Unpost';
            }
            else {
                return 'Post';
            }
        },
        getShipButtonIcon: function(get) {
            if (get('current.ysnPosted')) {
                return 'large-unpost';
            }
            else {
                return 'large-ship-via';
            }
        },
        checkHideOrderNo: function(get) {
            if (get('current.intOrderType') === 4) {
                return true;
            }
            else {
                return false;
            }
        },
        checkHideOwnershipType: function(get) {
            if (get('current.intOrderType') === 4) {
                return false;
            }
            else {
                return true;
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
        readOnlyItemDropdown: function (get) {
            var orderType = get('current.intOrderType');
            switch (orderType) {
                case 4:
                    return false;
                    break;
                default:
                    if (iRely.Functions.isEmpty(get('grdInventoryShipment.selection.strOrderNumber'))) {
                        return false;
                    }
                    else {
                        return true;
                    }
                    break;
            };
        },
        hasItemCommodity: function (get) {
            if (get('grdInventoryShipment.selection.intCommodityId')) {
                return false;
            }
            else {
                return true;
            }
        },
        hideContractColumn: function(get) {
            var orderType = get('current.intOrderType');
            switch (orderType) {
                case 1:
                    return false;
                    break;
                default:
                    return true;
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
        readOnlyOnPickLots: function (get) {
            if (get('current.ysnPosted')) {
                return true;
            }
            else {
                var sourceType = get('current.intSourceType');
                var win = this.getView();
                var grid = win.down('#grdInventoryShipment');
                switch (sourceType) {
                    case 3:
                        grid.gridMgr.newRow.disable();
                        return true;
                        break;
                    default:
                        grid.gridMgr.newRow.enable();
                        return false;
                        break;
                };
            }
        },
        filterSourceByType: function (get) {
            switch (get('current.intOrderType')) {
                case 1:
                    return [];
                    break;
                default:
                    return [{
                        column: 'intSourceType',
                        value: 3,
                        condition: 'noteq'
                    }];
                    break;
            }
        },
        checkReadOnlyWithLineItem: function (get) {
            get('triggerAddRemoveLineItem');

            if (get('current.ysnPosted') === true) {
                return true
            }
            else {
                if (get('current.tblICInventoryShipmentItems').data.items.length > 0) {
                    var current = get('current.tblICInventoryShipmentItems').data.items[0];
                    if (current.dummy) {
                        return false;
                    }
                    else {
                        return true;
                    }
                }
                else {
                    return false;
                }
            }
        },
        checkHiddenAddOrders: function(get) {
            var isHidden = false;
            if (get('current.ysnPosted')) {
                isHidden = true;
            }
            else {
                switch (get('current.intOrderType')) {
                    case 1:
                        switch (get('current.intSourceType')) {
                            case 0:
                            case 2:
                                if (iRely.Functions.isEmpty(get('current.intEntityCustomerId'))) {
                                    isHidden = true;
                                }
                                else {
                                    isHidden = false;
                                }
                                break;
                            case 3:
                                isHidden = false;
                                break;
                            default:
                                isHidden = true;
                                break;

                        }
                        break;
                    case 2:
                        if (iRely.Functions.isEmpty(get('current.intEntityCustomerId'))) {
                            isHidden = true;
                        }
                        else {
                            isHidden = false;
                        }
                        break;
                    case 3:
                        isHidden = true;
                        break;
                    default :
                        isHidden = true;
                        break;
                }
            }

            return isHidden;
        },
        hideShipToLocation: function(get) {
            if (get('current.intOrderType') === 3) {
                return true;
            }
            else {
                return false;
            }
        },
        hideShipToCompanyLocation: function(get) {
            if (get('current.intOrderType') === 3) {
                return false;
            }
            else {
                return true;
            }
        },
        checkInventoryPrice: function (get) {
            if (get('grdCharges.selection.ysnPrice')) {
                return false;
            }
            else
                return true;
        },
    }

});