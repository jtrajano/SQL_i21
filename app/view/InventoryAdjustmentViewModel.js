Ext.define('Inventory.view.InventoryAdjustmentViewModel', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.icinventoryadjustment',

    requires: [
        'i21.store.CompanyLocationBuffered',
        'i21.store.CompanyLocationSubLocationBuffered',
        'GeneralLedger.store.BufAccountId',
        'GeneralLedger.store.BufAccountCategoryGroup',
        'Inventory.store.BufferedItemStockView',
        'Inventory.store.BufferedStorageLocation',
        'Inventory.store.BufferedLot',
        'Inventory.store.BufferedItemUnitMeasure',
        'Inventory.store.BufferedItemWeightUOM',
        'Inventory.store.BufferedLotStatus'
    ],

    stores: {
        location: {
            type: 'companylocationbuffered'
        },
        adjustmentTypes: {
            data: [
                {
                    intAdjustmentTypeId : '1',
                    strDescription: 'Quantity Change'
                },{
                    intAdjustmentTypeId : '2',
                    strDescription: 'UOM Change'
                },{
                    intAdjustmentTypeId : '3',
                    strDescription: 'Item Change'
                },{
                    intAdjustmentTypeId : '4',
                    strDescription: 'Lot Status Change'
                },{
                    intAdjustmentTypeId : '5',
                    strDescription: 'Lot Id Change'
                },{
                    intAdjustmentTypeId : '6',
                    strDescription: 'Expiry Date Change'
                }
            ],
            fields: [
                {
                    type: 'int',
                    name: 'intAdjustmentTypeId'
                },
                {
                    name: 'strDescription'
                }
            ]
        },

        item: {
            autoLoad: true,
            type: 'icbuffereditemstockview'
        },
        subLocation: {
            autoLoad: true,
            type: 'smcompanylocationsublocationbuffered'
        },
        storageLocation: {
            autoLoad: true,
            type: 'icbufferedstoragelocation'
        },
        lot: {
            autoLoad: true,
            type: 'icbufferedlot'
        },
        newLot: {
            autoLoad: true,
            type: 'icbufferedlot'
        },
        newItemUOM: {
            autoLoad: true,
            type: 'icbuffereditemunitmeasure'
        },
        weightUOM: {
            autoLoad: true,
            type: 'icbuffereditemweightuom'
        },
        newItem: {
            autoLoad: true,
            type: 'icbuffereditemstockview'
        },
        newLotStatus: {
            autoLoad: true,
            type: 'icbufferedlotstatus'
        },
        accountCategory: {
            autoLoad: true,
            type: 'glbufaccountcategorygroup'
        },
        creditGLAccount: {
            autoLoad: true,
            type: 'glbufaccountid'
        },
        debitGLAccount: {
            autoLoad: true,
            type: 'glbufaccountid'
        }
    },

    formulas: {

    }

});