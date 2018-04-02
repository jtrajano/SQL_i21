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
        'Inventory.store.BufferedParentLot',
        'i21.store.CompanyLocationBuffered',
        'i21.store.CompanyLocationSubLocationBuffered',
        'Inventory.store.BufferedItemStockUOMForAdjustmentView',
        'GeneralLedger.controls.RecapTab',
        'GeneralLedger.controls.PostHistory',
        'Inventory.store.BufferedItemSubLocationsLookup',
        'Inventory.store.BufferedItemStorageLocationsLookup'
    ],

    data: {
        pageSize: 200,
        forceSelection: false
    },

    stores: {
        parentLots: {
            type: 'icbufferedparentlot'
        },
        lockTypes: {
            fields: [
                { name: 'intId' },
                { name: 'strType' }
            ],
            data: [
                { intId: 1, strType: 'Company Location' },
                { intId: 4, strType: 'Sub Location'},
                { intId: 3, strType: 'Storage Location' },
                { intId: 2, strType: 'Lot' }
            ],
            autoLoad: true
        },
        countBy: {
            fields: [{ name: 'strName' }],
            autoLoad: true,
            data: [
                {
                    strName: 'Item'
                },
                {
                    strName: 'Pack'
                }
            ]
        },
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
            type: 'icitemstocksummary'
        },
        itemListByLot: {
            type: 'icitemstocksummarybylot'
        },
        itemStock: {
            type: 'icbuffereditemstockview'
        },
        fromSubLocation: {
            type: 'icbuffereditemsublocationslookup'
        },
        fromStorageLocation: {
            type: 'icbuffereditemstoragelocationslookup'
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
        pgePreviewTitle: function(get) {
            var posted = get('current.ysnPosted');
            if (posted)
                return 'Unpost Preview';            
            else 
                return 'Post Preview';
        },
        intCurrencyId: function(get) {
            return get('current.intCurrencyId');
        },

        strTransactionId: function(get) {
            return get('current.strCountNo');
        },                
        
        checkPrintCountSheet: function (get) {
            if (get('current.intStatus') == 4 || get('hasCountGroup') || get('current.intStatus') == 3) {
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
            // if (get('current.intStatus') === 3 || get('current.intStatus') === 4 || get('current.strCountBy') === 'Pack') {
            //     return true;
            // }
            // else return posted;
            return posted;
        },
        hideUnpostButton: function (get) {
            var posted = get('current.ysnPosted');
            // if (get('current.intStatus') === 4 && get('current.strCountBy') !== 'Pack') {
            //     return true;
            // }
            // else return !posted;
            return !posted;
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
            if((iRely.Functions.isEmpty(get('grdPhysicalCount.selection.strItemNo')) && get('current.strCountBy') !== 'Pack') || get('current.ysnPosted')) {
                return true;
            }
            else {
                return false;
            }
        },

        hasSelection: function(get) {
            return !get('grdPhysicalCount.selection');
        },

        readOnly: function(get) { return true; },
        
        disablePhysicalCount: function(get) {
            return get('grdPhysicalCount.selection.dblPallets') > 0 && get('grdPhysicalCount.selection.dblQtyPerPallet') > 0;
        },

        disableCountUOM: function(get) {
            var readOnly = false;
            if(get('grdPhysicalCount.selection.strItemNo') || get('current.ysnPosted')) {
                readOnly = true;
            }
            else {
                readOnly = false;
            }
            readOnly = !get('grdPhysicalCount.selection.intLotId') || !get('grdPhysicalCount.selection.intLotId') === 0;
            return readOnly;
        },

        isAutoLot: function(get) {
            if(iRely.Functions.isEmpty(get('grdPhysicalCount.selection.intLotId')) && !iRely.Functions.isEmpty(get('grdPhysicalCount.selection.strLotNo'))) {
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
            return get('current.strCountBy') === 'Pack';
        },
        countByGroup: {
            get: function(get) {
                return get('current.strCountBy');
            },

            set: function(value) {
                if(value === 'Pack') {
                    this.set('current.ysnCountByLots', false);
                    this.set('current.ysnExternal', false);
                    this.set('current.ysnRecountMismatch', false);
                    this.set('current.ysnRecount', false);
                    this.set('current.ysnCountByPallets', false);
                    this.set('current.ysnIncludeZeroOnHand', false);
                    this.set('current.ysnIncludeOnHand', false);
                }
                this.set('current.strCountBy', value);
            }
        },
        isCountByGroupOrNotLotted: function(get) {
            return get('current.strCountBy') === 'Pack' || !get('current.ysnCountByLots');
        },
        hidePalletFields: function(get) {
            var hidden = get('current.strCountBy') === 'Pack' || !get('current.ysnCountByLots');
            return hidden || (get('current.ysnCountByLots') && !get('current.ysnCountByPallets'));            
        },
        isPack: function(get) {
            return get('current.strCountBy') === 'Pack';
        },
        getFetchText: function(get) {
            //return (get('hasCountGroup')) ? "Refresh" : "Fetch";
            //return "Fetch";
            return 'Load';
        },
        getFetchIconCls: function(get) {
            //return (get('hasCountGroup')) ? "small-refresh-small" : "small-transfer";
            //return "small-transfer";
            return 'small-refresh-small';
        },
    }

});