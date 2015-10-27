Ext.define('Inventory.view.InventoryCountViewModel', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.icinventorycount',

    requires: [
        'Inventory.store.BufferedCategory',
        'Inventory.store.BufferedCommodity',
        'Inventory.store.BufferedCountGroup',
        'Inventory.store.BufferedStorageLocation',
        'Inventory.store.BufferedItemUnitMeasure',
        'Inventory.store.ItemStockUOMView',
        'i21.store.CompanyLocationBuffered',
        'i21.store.CompanyLocationSubLocationBuffered'
    ],

    stores: {
        location: {
            type: 'companylocationbuffered'
        },
        category: {
            type: 'icbufferedcategory'
        },
        commodity: {
            type: 'icbufferedcommodity'
        },
        countGroup: {
            type: 'icbufferedcountgroup'
        },
        subLocation: {
            type: 'smcompanylocationsublocationbuffered'
        },
        storageLocation: {
            type: 'icbufferedstoragelocation'
        },
        itemUOM: {
            type: 'icbuffereditemunitmeasure'
        },
        status: {
            autoLoad: true,
            data: [
                {
                    strStatus: 'Open',
                    intStatus: 1
                },
                {
                    strStatus: 'Count Sheet Printed',
                    intStatus: 2
                },
                {
                    strStatus: 'Inventory Locked',
                    intStatus: 3
                },
                {
                    strStatus: 'Closed',
                    intStatus: 4
                }
            ],
            fields: [
                {
                    name: 'strStatus'
                },
                {
                    name: 'intStatus'
                }
            ]
        },
        itemList: {
            type: 'icitemstockuomview'
        }
    },

    formulas: {
        checkPrintCountSheet: function (get) {
            if (get('current.intStatus') !== 1) {
                return true;
            }
            else return false;
        },
        checkPrintVariance: function (get) {
            if (get('current.intStatus') !== 3) {
                return true;
            }
            else return false;
        },
        checkLockInventory: function (get) {
            if (get('current.intStatus') !== 2) {
                return true;
            }
            else return false;
        },
        checkPost: function (get) {
            if (get('current.intStatus') !== 3) {
                return true;
            }
            else return false;
        },
        checkRecount: function (get) {
            if (get('current.intStatus') !== 4) {
                return true;
            }
            else return false;
        },
        hasCountGroup: function (get) {
            if (iRely.Functions.isEmpty(get('current.intCountGroupId'))) {
                return false;
            }
            else return true;
        },


    }

});