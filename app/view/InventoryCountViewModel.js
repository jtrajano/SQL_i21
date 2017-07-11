Ext.define('Inventory.view.InventoryCountViewModel', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.icinventorycount',

    requires: [
        'Inventory.store.BufferedCategory',
        'Inventory.store.BufferedCommodity',
        'Inventory.store.BufferedCountGroup',
        'Inventory.store.BufferedStorageLocation',
        'Inventory.store.BufferedItemUnitMeasure',
        'Inventory.store.ItemStockSummary',
        'Inventory.store.ItemStockSummaryByLot',
        'Inventory.store.BufferedItemStockView',
        'Inventory.store.BufferedItemStockUOMView',
        'Inventory.store.BufferedLot',
        'i21.store.CompanyLocationBuffered',
        'i21.store.CompanyLocationSubLocationBuffered',
        'Inventory.store.BufferedItemStockUOMForAdjustmentView'
    ],

    data: {
        pageSize: 200
    },

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
            //type: 'icbuffereditemunitmeasure'
             type: 'icbuffereditemstockuomforadjustmentview'
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
            type: 'icitemstocksummary'
        },
        itemListByLot: {
            type: 'icitemstocksummarybylot'
        },
        itemStock: {
            type: 'icbuffereditemstockview'
        },
        fromSubLocation: {
            type: 'icbuffereditemstockuomview'
        },
        fromStorageLocation: {
            type: 'icbuffereditemstockuomview'
        },
        lot: {
            type: 'icbufferedlot'
        },
        pagesize: {
            autoLoad: true,
            data: [
                {
                    strRows: '50',
                },
                {
                    strRows: '100',
                },
                {
                    strRows: '200',
                },
                {
                    strRows: '500',
                }
            ],
            fields: [
                {
                    name: 'strRows'
                }
            ]    
        }
    },

    formulas: {
        intCurrencyId: function(get) {
            return get('current.intCurrencyId');
        },
        
        checkPrintCountSheet: function (get) {
            if (get('current.intStatus') == 4 || get('hasCountGroup')) {
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
            if (get('current.intStatus') === 2 || get('current.intStatus') === 3) {
                return false;
            }
            else return true;
        },
        hidePostButton: function(get) {
            var posted = get('current.ysnPosted');
            if (get('current.intStatus') === 3 || get('current.intStatus') === 4 || get('current.ysnCountByGroup')) {
                return true;
            }
            else return posted;
        },
        hideUnpostButton: function (get) {
            var posted = get('current.ysnPosted');
            if (get('current.intStatus') === 4 && !get('current.ysnCountByGroup')) {
                return false;
            }
            else return true;
        },
        checkRecount: function (get) {
            if (get('current.intStatus') !== 4) {
                return true;
            }
            else return false;
        },
        
        getLockInventoryText: function (get) {
            if (get('current.intStatus') === 3) {
                return 'Unlock Inventory';
            }
            else return 'Lock Inventory';
        },
        getPostText: function (get) {
            if (get('current.ysnPosted')) {
                return 'Unpost';
            }
            else return 'Post';
        },
        disableCountGridFields: function (get) {
            if((iRely.Functions.isEmpty(get('grdPhysicalCount.selection.strItemNo')) && !get('current.ysnCountByGroup')) || get('current.ysnPosted')) {
                return true;
            }
            else {
                return false;
            }
        },
        disableBtnDelete: function (get) {
            if(get('current.ysnPosted') || get('current.intStatus') === 3 )
                return true;
            else
                return false;
        },
        hasCountGroup: function (get) {
            return get('current.ysnCountByGroup');
        },
        countByGroup: {
            get: function(get) {
                return get('current.ysnCountByGroup');
            },

            set: function(value) {
                if(value) {
                    this.set('current.ysnCountByLots', false);
                    this.set('current.ysnExternal', false);
                    this.set('current.ysnRecountMismatch', false);
                    this.set('current.ysnRecount', false);
                    this.set('current.ysnCountByPallets', false);
                    this.set('current.ysnIncludeZeroOnHand', false);
                    this.set('current.ysnIncludeOnHand', false);
                }
                this.set('current.ysnCountByGroup', value);
            }
        },
        getFetchText: function(get) {
            //return (get('hasCountGroup')) ? "Refresh" : "Fetch";
            return "Fetch";
        },
        getFetchIconCls: function(get) {
            //return (get('hasCountGroup')) ? "small-refresh-small" : "small-transfer";
            return "small-transfer";
        },
    }

});