Ext.define('Inventory.view.InventoryTransferViewModel', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.icinventorytransfer',

    requires: [
        'i21.store.CompanyLocationBuffered',
        'i21.store.CompanyLocationSubLocationBuffered',
        'i21.store.TaxCodeBuffered',
        'i21.store.UserListBuffered',
        'i21.store.ShipViaBuffered',
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
            type: 'icbuffereditemstockuomview'
        },
        lot: {
            type: 'icbufferedlot'
        },
        fromSubLocation: {
            type: 'smcompanylocationsublocationbuffered'
        },
        fromStorageLocation: {
            type: 'icbufferedstoragelocation'
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
        }
    }

});