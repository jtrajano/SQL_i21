Ext.define('Inventory.view.InventoryTransferViewModel', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.icinventorytransfer',

    requires: [
        'i21.store.CompanyLocationBuffered',
        'i21.store.CompanyLocationSubLocationBuffered',
        'i21.store.TaxCodeBuffered',
        'i21.store.UserListBuffered',
        'i21.store.ShipViaBuffered',
        'GeneralLedger.store.BufAccountId',
        'GeneralLedger.store.BufAccountCategoryGroup',
        'Inventory.store.BufferedItemStockView',
        'Inventory.store.BufferedStorageLocation',
        'Inventory.store.BufferedLot',
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
                },{
                    strDescription: 'Location to External'
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
        accountCategory: {
            type: 'glbufaccountcategorygroup'
        },
        shipVia: {
            type: 'shipviabuffered'
        },
        glAccount: {
            type: 'glbufaccountid'
        },


        item: {
            type: 'icbuffereditemstockview'
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
        creditGLAccount: {
            type: 'glbufaccountid'
        },
        debitGLAccount: {
            type: 'glbufaccountid'
        },
        taxCode: {
            type: 'smtaxcodebuffered'
        }
    },

    formulas: {

    }

});