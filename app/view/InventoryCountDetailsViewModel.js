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
        'Inventory.store.BufferedParentLot',
        'Inventory.store.BufferedLot',
        'i21.store.CompanyLocationBuffered',
        'i21.store.CompanyLocationSubLocationBuffered',
        'Inventory.store.BufferedItemStockUOMForAdjustmentView',
        'Inventory.store.BufferedInventoryCountStockItem',
        'Inventory.store.BufferedItemSubLocationsLookup',
        'Inventory.store.BufferedItemStorageLocationsLookup'
    ],

    data: {
        inventoryCount: null,
        forceSelection: false,
        isLotted: false,
        selectedLot: null
    },
    formulas: {
        isCountByGroup: function(get) {
            var count = get('inventoryCount');
            return count && count.get('strCountBy') === 'Pack';
        },
        isCountByGroupOrNotLotted: function(get) {
            var count = get('inventoryCount');
            return count && (count.get('strCountBy') === 'Pack' || !count.get('ysnCountByLots'));
        },
        lotAliasReadOnly: function(get) {
            return get('current.intLotId');
        },
        disablePhysicalCount: function(get) {
            return get('current.dblPallets') > 0 && get('current.dblQtyPerPallet') > 0;
        },
        disableCountUOM: function(get) {
            return get('current.intLotId') || get('current.intLotId') === 0;
        },
        disableGrossUOM: function(get) {
            return get('current.ysnLotWeightsRequired') === false && get('current.strLotTracking') !== 'No';
        },
        hidePalletFields: function(get) {
            var count = get('inventoryCount');
            var hidden = count && (count.get('strCountBy') === 'Pack' || !count.get('ysnCountByLots'));
            return hidden || (!get('isLotted') || (get('isLotted') && !get('inventoryCount.ysnCountByPallets')));            
        },
        setWeightUOMFieldLabel: function(get) {
            var win = this.getView();
            var cboWeightUOM = win.down('#cboWeightUOM');
        
            if(get('current.ysnLotWeightsRequired') && ((get('current.intWeightUOMId') === null) || (get('current.dblWeightQty') === 0 && get('current.dblNetQty') === 0))) {
                cboWeightUOM.setFieldLabel('Gross/Net UOM');
            } else {
                cboWeightUOM.setFieldLabel('Gross/Net UOM ' + '<span style="color:red">*</span>');
            }
        }
    },
    stores: {
        parentLots: {
            type: 'icbufferedparentlot'
        },
        countGroup: {
            type: 'icbufferedcountgroup'
        },
        items: {
            type: 'icbuffereditemstockview'
        },
        storageLocations: {
            type: 'icbuffereditemsublocationslookup'
        },
        storageUnits: {
            type: 'icbuffereditemstoragelocationslookup'
        },
        lots: {
            type: 'icbufferedlot'
        },
        itemUOMs: {
            type: "icbuffereditemunitmeasure"
        }
    }
});