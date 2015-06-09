Ext.define('Inventory.view.InventoryShipmentViewModel', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.icinventoryshipment',

    requires: [
        'Inventory.store.BufferedCompactItem',
        'Inventory.store.BufferedItemUnitMeasure',
        'Inventory.store.BufferedItemWeightUOM',
        'Inventory.store.BufferedLot',
        'i21.store.CompanyLocationBuffered',
        'i21.store.CompanyLocationSubLocationBuffered',
        'i21.store.FreightTermsBuffered',
        'i21.store.ShipViaBuffered',
        'EntityManagement.store.CustomerBuffered',
        'EntityManagement.store.LocationBuffered',
        'AccountsReceivable.store.SalesOrderDetailCompactBuffered'
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
            type: 'shipviabuffered'
        },
        soDetails: {
            type: 'salesorderdetailcompactbuffered'
        },
        items: {
            type: 'icbufferedcompactitem'
        },
        subLocation: {
            type: 'smcompanylocationsublocationbuffered'
        },
        itemUOM: {
            type: 'icbuffereditemunitmeasure'
        },
        weightUOM: {
            type: 'icbuffereditemweightuom'
        },
        lot: {
            type: 'icbufferedlot'
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
        }
    }

});