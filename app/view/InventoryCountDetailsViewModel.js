Ext.define('Inventory.view.InventoryCountDetailsViewModel', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.icinventorycountdetails',
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
        'Inventory.store.BufferedItemStockUOMForAdjustmentView',
        'Inventory.store.BufferedInventoryCountStockItem'
    ],

    data: {
        inventoryCount: null,
        forceSelection: false
    },
    formulas: {
        lotAliasReadOnly: function(get) {
            return get('current.intLotId');
        }
    },
    stores: {
        countGroup: {
            type: 'icbufferedcountgroup'
        },
        items: {
            type: 'icbuffereditemstockview'
        },
        storageLocations: {
            type: 'icbufferedinventorycountstockitem'
        },
        storageUnits: {
            type: 'icbufferedinventorycountstockitem'
        },
        lots: {
            type: 'icbufferedlot'
        },
        itemUOMs: {
            type: "icbufferedinventorycountstockitem"
        }
    },

    formulas: {
        isCountByGroup: function(get) {
            var count = get('inventoryCount');
            return count && count.get('strCountBy') === 'Pack';
        }
    }
});