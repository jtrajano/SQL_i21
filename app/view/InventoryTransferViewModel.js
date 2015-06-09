Ext.define('Inventory.view.InventoryTransferViewModel', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.icinventorytransfer',

    requires: [
        'i21.store.CompanyLocationBuffered',
        'i21.store.CompanyLocationSubLocationBuffered',
        'i21.store.TaxCodeBuffered',
        'i21.store.UserListBuffered',
        'i21.store.ShipViaBuffered',
        'Inventory.store.BufferedItemStockView',
        'Inventory.store.BufferedItemStockUOMView',
        'Inventory.store.BufferedStorageLocation',
        'Inventory.store.BufferedLot',
        'Inventory.store.BufferedStatus',
        'Inventory.store.BufferedItemUnitMeasure',
        'Inventory.store.BufferedItemWeightUOM',
        'Inventory.store.BufferedUnitMeasure'
    ],

    stores: {

        transferTypes: {
            data: [
                {
                    strDescription: 'Location to Location'
                },{
                    strDescription: 'Storage to Storage'
                }
            ],
            fields: [
                {
                    name: 'strDescription'
                }
            ]
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
        userList: {
            type: 'userlistbuffered'
        },

        fromLocation: {
            type: 'companylocationbuffered'
        },
        toLocation: {
            type: 'companylocationbuffered'
        },
        uom: {
            type: 'icbuffereduom'
        },
        shipVia: {
            type: 'shipviabuffered'
        },
        status: {
            type: 'icbufferedstatus'
        },

        itemStock: {
            autoLoad: true,
            type: 'icbuffereditemstockuomview'
        },
        item: {
            type: 'icbuffereditemstockview'
        },
        lot: {
            type: 'icbufferedlot'
        },
        fromSubLocation: {
            type: 'icbuffereditemstockuomview'
        },
        fromStorageLocation: {
            type: 'icbuffereditemstockuomview'
        },
        toSubLocation: {
            type: 'smcompanylocationsublocationbuffered'
        },
        toStorageLocation: {
            type: 'icbufferedstoragelocation'
        },
        itemUOM: {
            type: 'icbuffereditemunitmeasure'
        },
        weightUOM: {
            type: 'icbuffereditemweightuom'
        },
        newLot: {
            type: 'icbufferedlot'
        },
        taxCode: {
            type: 'smtaxcodebuffered'
        }
    },

    formulas: {
        hideOnLocationToLocation: function(get) {
            if (get('current.strTransferType') === 'Location to Location') {
                return true;
            }
            else {
                return false;
            }
        },
        hideOnStorageToStorage: function(get) {
            if (get('current.strTransferType') === 'Storage to Storage') {
                return true;
            }
            else {
                return false;
            }
        },
        getPostButtonText: function(get) {
            if (get('current.ysnPosted')) {
                return 'UnPost';
            }
            else {
                return 'Post';
            }
        },
        getPostButtonIcon: function(get) {
            if (get('current.ysnPosted')) {
                return 'large-unpost';
            }
            else {
                return 'large-post';
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