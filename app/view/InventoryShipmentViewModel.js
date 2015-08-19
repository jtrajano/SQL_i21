Ext.define('Inventory.view.InventoryShipmentViewModel', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.icinventoryshipment',

    requires: [
        'Inventory.store.BufferedItemStockDetailView',
        'Inventory.store.BufferedItemUnitMeasure',
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
        'ContractManagement.store.ContractHeaderViewBuffered'
    ],

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
        shipVia: {
            type: 'emshipviabuffered'
        },
        soDetails: {
            type: 'salesorderdetailcompactbuffered'
        },
        salesContract: {
            type: 'ctcontractdetailviewbuffered'
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
            type: 'icbuffereditemunitmeasure'
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
        }
    },

    formulas: {
        getShipButtonText: function(get) {
            if (get('current.ysnPosted')) {
                return 'UnShip';
            }
            else {
                return 'Ship';
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
                    return true;
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
        }
    }

});