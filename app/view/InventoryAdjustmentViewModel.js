Ext.define('Inventory.view.InventoryAdjustmentViewModel', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.icinventoryadjustment',

    requires: [
        'i21.store.CompanyLocationBuffered',
        'i21.store.CompanyLocationSubLocationBuffered',
        'GeneralLedger.store.BufAccountId',
        'GeneralLedger.store.BufAccountCategoryGroup',
        'Inventory.store.BufferedItemStockView',
        'Inventory.store.BufferedStockTrackingItemView',
        'Inventory.store.BufferedStorageLocation',
        'Inventory.store.BufferedLot',
        'Inventory.store.BufferedPostedLot',
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
                    strDescription: 'Split Lot'
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
            type: 'icbufferedstocktrackingitemview'
        },
        subLocation: {
            type: 'smcompanylocationsublocationbuffered'
        },
        storageLocation: {
            type: 'icbufferedstoragelocation'
        },
        lot: {
            type: 'icbufferedpostedlot'
        },
        newLot: {
            type: 'icbufferedlot'
        },
        itemUOM: {
            type: 'icbuffereditemunitmeasure'
        },
        newItemUOM: {
            type: 'icbuffereditemunitmeasure'
        },
        weightUOM: {
            type: 'icbuffereditemweightuom'
        },
        newWeightUOM: {
            type: 'icbuffereditemweightuom'
        },
        newItem: {
            type: 'icbuffereditemstockview'
        },
        newLotStatus: {
            type: 'icbufferedlotstatus'
        },
        newLocation: {
            type: 'companylocationbuffered'
        },
        newSubLocation: {
            type: 'smcompanylocationsublocationbuffered'
        },
        newStorageLocation: {
            type: 'icbufferedstoragelocation'
        }
    },

    adjustmentTypes: {
        QuantityChange: 1,
        UOMChange: 2,
        ItemChange: 3,
        LotStatusChange: 4,
        SplitLot: 5,
        ExpiryDateChange: 6
    },

    hide: true,
    show: false,

    formulas: {
        formulaShowLotNumberEditor: function(get){
            var me = this;
            var posted = get('current.ysnPosted');
            if (posted){
                return me.hide;
            }
            else {
                var itemId = get('grdInventoryAdjustment.selection.intItemId');
                if (!Ext.isNumeric(itemId))
                    return me.hide;

                var lotTracking = get('grdInventoryAdjustment.selection.strLotTracking');
                if (lotTracking == 'No'){
                    return me.hide;
                }
                else {
                    return me.show;
                }
            }
        },

        formulaShowItemUOMEditor: function(get){
            var me = this;
            var posted = get('current.ysnPosted');
            if (posted){
                return me.hide;
            }
            else {
                var itemId = get('grdInventoryAdjustment.selection.intItemId');
                if (!Ext.isNumeric(itemId))
                    return me.hide;

                var lotTracking = get('grdInventoryAdjustment.selection.strLotTracking');
                if (lotTracking == 'No'){
                    return me.show;
                }
                else {
                    return me.hide;
                }
            }
        },

        formulaHideColumn_colNewLotNumber: function(get){
            var me = this;
            var intAdjustmentTypeId = get('current.intAdjustmentType');

            switch (intAdjustmentTypeId) {
                case me.adjustmentTypes.QuantityChange:
                case me.adjustmentTypes.LotStatusChange:
                case me.adjustmentTypes.UOMChange:
                case me.adjustmentTypes.ItemChange:
                case me.adjustmentTypes.ExpiryDateChange:
                    return me.hide;
                    break;
                case me.adjustmentTypes.SplitLot:
                default:
                    return me.show;
            }
        },

        formulaHideColumn_colQuantity: function(get){
            var me = this;
            var intAdjustmentTypeId = get('current.intAdjustmentType');

            switch (intAdjustmentTypeId) {

                case me.adjustmentTypes.LotStatusChange:
                case me.adjustmentTypes.ExpiryDateChange:
                    return me.hide;
                    break;
                case me.adjustmentTypes.QuantityChange:
                case me.adjustmentTypes.SplitLot:
                case me.adjustmentTypes.UOMChange:
                case me.adjustmentTypes.ItemChange:
                default:
                    return me.show;
            }
        },

        formulaHideColumn_colNewQuantity: function(get){
            var me = this;
            var intAdjustmentTypeId = get('current.intAdjustmentType');

            switch (intAdjustmentTypeId) {
                case me.adjustmentTypes.LotStatusChange:
                case me.adjustmentTypes.ExpiryDateChange:
                    return me.hide;
                    break;

                case me.adjustmentTypes.QuantityChange:
                case me.adjustmentTypes.SplitLot:
                case me.adjustmentTypes.UOMChange:
                case me.adjustmentTypes.ItemChange:
                default:
                    return me.show;
            }
        },

        formulaHideColumn_colAdjustByQuantity: function(get){
            var me = this;
            var intAdjustmentTypeId = get('current.intAdjustmentType');

            switch (intAdjustmentTypeId) {
                case me.adjustmentTypes.LotStatusChange:
                case me.adjustmentTypes.ExpiryDateChange:
                    return me.hide;
                    break;
                case me.adjustmentTypes.QuantityChange:
                case me.adjustmentTypes.SplitLot:
                case me.adjustmentTypes.UOMChange:
                case me.adjustmentTypes.ItemChange:
                default:
                    return me.show;
            }
        },

        formulaHideColumn_colNewSplitLotQuantity: function(get){
            var me = this;
            var intAdjustmentTypeId = get('current.intAdjustmentType');

            switch (intAdjustmentTypeId) {
                case me.adjustmentTypes.QuantityChange:
                case me.adjustmentTypes.LotStatusChange:
                case me.adjustmentTypes.ExpiryDateChange:
                case me.adjustmentTypes.UOMChange:
                case me.adjustmentTypes.ItemChange:
                    return me.hide;
                    break;

                case me.adjustmentTypes.SplitLot:
                default:
                    return me.show;
            }
        },

        formulaHideColumn_colUOM: function(get){
            var me = this;
            var intAdjustmentTypeId = get('current.intAdjustmentType');

            switch (intAdjustmentTypeId) {
                case me.adjustmentTypes.LotStatusChange:
                case me.adjustmentTypes.ExpiryDateChange:
                case me.adjustmentTypes.ItemChange:
                    return me.hide;
                    break;

                case me.adjustmentTypes.QuantityChange:
                case me.adjustmentTypes.SplitLot:
                case me.adjustmentTypes.UOMChange:
                default:
                    return me.show;
            }
        },

        formulaHideColumn_colNewUOM: function(get){
            var me = this;
            var intAdjustmentTypeId = get('current.intAdjustmentType');

            switch (intAdjustmentTypeId) {
                case me.adjustmentTypes.QuantityChange:
                case me.adjustmentTypes.LotStatusChange:
                case me.adjustmentTypes.ExpiryDateChange:
                case me.adjustmentTypes.ItemChange:
                    return me.hide;
                    break;
                case me.adjustmentTypes.SplitLot:
                case me.adjustmentTypes.UOMChange:
                default:
                    return me.show;
            }
        },

        formulaHideColumn_colNetWeight: function(get){
            var me = this;
            var intAdjustmentTypeId = get('current.intAdjustmentType');

            switch (intAdjustmentTypeId) {
                case me.adjustmentTypes.QuantityChange:
                case me.adjustmentTypes.LotStatusChange:
                case me.adjustmentTypes.ExpiryDateChange:
                case me.adjustmentTypes.ItemChange:
                case me.adjustmentTypes.UOMChange:
                    return me.hide;
                    break;
                case me.adjustmentTypes.SplitLot:
                default:
                    return me.show;
            }
        },

        formulaHideColumn_colNewNetWeight: function(get){
            var me = this;
            var intAdjustmentTypeId = get('current.intAdjustmentType');

            switch (intAdjustmentTypeId) {
                case me.adjustmentTypes.QuantityChange:
                case me.adjustmentTypes.LotStatusChange:
                case me.adjustmentTypes.ExpiryDateChange:
                case me.adjustmentTypes.ItemChange:
                case me.adjustmentTypes.UOMChange:
                    return me.hide;
                    break;
                case me.adjustmentTypes.SplitLot:
                default:
                    return me.show;
            }
        },

        formulaHideColumn_colWeightUOM: function(get){
            var me = this;
            var intAdjustmentTypeId = get('current.intAdjustmentType');

            switch (intAdjustmentTypeId) {
                case me.adjustmentTypes.QuantityChange:
                case me.adjustmentTypes.LotStatusChange:
                case me.adjustmentTypes.ExpiryDateChange:
                case me.adjustmentTypes.ItemChange:
                case me.adjustmentTypes.UOMChange:
                    return me.hide;
                    break;
                case me.adjustmentTypes.SplitLot:
                default:
                    return me.show;
            }
        },

        formulaHideColumn_colNewWeightUOM: function(get){
            var me = this;
            var intAdjustmentTypeId = get('current.intAdjustmentType');

            switch (intAdjustmentTypeId) {
                case me.adjustmentTypes.QuantityChange:
                case me.adjustmentTypes.LotStatusChange:
                case me.adjustmentTypes.ExpiryDateChange:
                case me.adjustmentTypes.ItemChange:
                case me.adjustmentTypes.UOMChange:
                    return me.hide;
                    break;
                case me.adjustmentTypes.SplitLot:
                default:
                    return me.show;
            }
        },

        formulaHideColumn_colWeightPerQty: function(get){
            var me = this;
            var intAdjustmentTypeId = get('current.intAdjustmentType');

            switch (intAdjustmentTypeId) {
                case me.adjustmentTypes.QuantityChange:
                case me.adjustmentTypes.LotStatusChange:
                case me.adjustmentTypes.ExpiryDateChange:
                case me.adjustmentTypes.ItemChange:
                case me.adjustmentTypes.UOMChange:
                case me.adjustmentTypes.SplitLot:
                    return me.hide;
                    break;
                default:
                    return me.show;
            }
        },

        formulaHideColumn_colNewWeightPerQty: function(get){
            var me = this;
            var intAdjustmentTypeId = get('current.intAdjustmentType');

            switch (intAdjustmentTypeId) {
                case me.adjustmentTypes.QuantityChange:
                case me.adjustmentTypes.LotStatusChange:
                case me.adjustmentTypes.ExpiryDateChange:
                case me.adjustmentTypes.ItemChange:
                case me.adjustmentTypes.UOMChange:
                case me.adjustmentTypes.SplitLot:
                    return me.hide;
                    break;
                default:
                    return me.show;
            }
        },

        formulaHideColumn_colUnitCost: function(get){
            var me = this;
            var intAdjustmentTypeId = get('current.intAdjustmentType');

            switch (intAdjustmentTypeId) {
                case me.adjustmentTypes.LotStatusChange:
                case me.adjustmentTypes.ExpiryDateChange:
                case me.adjustmentTypes.ItemChange:
                case me.adjustmentTypes.UOMChange:
                    return me.hide;
                    break;

                case me.adjustmentTypes.QuantityChange:
                case me.adjustmentTypes.SplitLot:
                default:
                    return me.show;
            }
        },

        formulaHideColumn_colNewUnitCost: function(get){
            var me = this;
            var intAdjustmentTypeId = get('current.intAdjustmentType');

            switch (intAdjustmentTypeId) {
                case me.adjustmentTypes.LotStatusChange:
                case me.adjustmentTypes.ExpiryDateChange:
                case me.adjustmentTypes.ItemChange:
                case me.adjustmentTypes.UOMChange:
                    return me.hide;
                    break;

                case me.adjustmentTypes.QuantityChange:
                case me.adjustmentTypes.SplitLot:
                default:
                    return me.show;
            }
        },

        formulaHideColumn_colNewItemNumber: function(get){
            var me = this;
            var intAdjustmentTypeId = get('current.intAdjustmentType');

            switch (intAdjustmentTypeId) {
                case me.adjustmentTypes.QuantityChange:
                case me.adjustmentTypes.SplitLot:
                case me.adjustmentTypes.LotStatusChange:
                case me.adjustmentTypes.ExpiryDateChange:
                case me.adjustmentTypes.ItemChange:
                case me.adjustmentTypes.UOMChange:
                    return me.hide;
                    break;
                default:
                    return me.show;
            }
        },

        formulaHideColumn_colNewItemDescription: function(get){
            var me = this;
            var intAdjustmentTypeId = get('current.intAdjustmentType');

            switch (intAdjustmentTypeId) {
                case me.adjustmentTypes.QuantityChange:
                case me.adjustmentTypes.SplitLot:
                case me.adjustmentTypes.LotStatusChange:
                case me.adjustmentTypes.ExpiryDateChange:
                case me.adjustmentTypes.ItemChange:
                case me.adjustmentTypes.UOMChange:
                    return me.hide;
                    break;
                default:
                    return me.show;
            }
        },

        formulaHideColumn_colExpiryDate: function(get){
            var me = this;
            var intAdjustmentTypeId = get('current.intAdjustmentType');

            switch (intAdjustmentTypeId) {
                case me.adjustmentTypes.QuantityChange:
                case me.adjustmentTypes.SplitLot:
                case me.adjustmentTypes.LotStatusChange:
                case me.adjustmentTypes.ItemChange:
                case me.adjustmentTypes.UOMChange:
                    return me.hide;
                    break;
                case me.adjustmentTypes.ExpiryDateChange:
                default:
                    return me.show;
            }
        },

        formulaHideColumn_colNewExpiryDate: function(get){
            var me = this;
            var intAdjustmentTypeId = get('current.intAdjustmentType');

            switch (intAdjustmentTypeId) {
                case me.adjustmentTypes.QuantityChange:
                case me.adjustmentTypes.SplitLot:
                case me.adjustmentTypes.LotStatusChange:
                case me.adjustmentTypes.ItemChange:
                case me.adjustmentTypes.UOMChange:
                    return me.hide;
                    break;
                case me.adjustmentTypes.ExpiryDateChange:
                default:
                    return me.show;
            }
        },

        formulaHideColumn_colLotStatus: function(get){
            var me = this;
            var intAdjustmentTypeId = get('current.intAdjustmentType');

            switch (intAdjustmentTypeId) {
                case me.adjustmentTypes.QuantityChange:
                case me.adjustmentTypes.SplitLot:
                case me.adjustmentTypes.ItemChange:
                case me.adjustmentTypes.UOMChange:
                case me.adjustmentTypes.ExpiryDateChange:
                    return me.hide;
                    break;
                case me.adjustmentTypes.LotStatusChange:
                default:
                    return me.show;
            }
        },

        formulaHideColumn_colNewLotStatus: function(get){
            var me = this;
            var intAdjustmentTypeId = get('current.intAdjustmentType');

            switch (intAdjustmentTypeId) {
                case me.adjustmentTypes.QuantityChange:
                case me.adjustmentTypes.SplitLot:
                case me.adjustmentTypes.ItemChange:
                case me.adjustmentTypes.UOMChange:
                case me.adjustmentTypes.ExpiryDateChange:
                    return me.hide;
                    break;
                case me.adjustmentTypes.LotStatusChange:
                default:
                    return me.show;
            }
        },

        formulaHideColumn_colLineTotal: function(get){
            var me = this;
            var intAdjustmentTypeId = get('current.intAdjustmentType');

            switch (intAdjustmentTypeId) {
                case me.adjustmentTypes.QuantityChange:
                case me.adjustmentTypes.SplitLot:
                case me.adjustmentTypes.ItemChange:
                case me.adjustmentTypes.UOMChange:
                case me.adjustmentTypes.ExpiryDateChange:
                case me.adjustmentTypes.LotStatusChange:
                    // Todo: Hide Line total for now.
                    return me.hide;
                    break;
                default:
                    return me.show;
            }
        },

        formulaHideColumn_colNewLocation: function(get){
            var me = this;
            var intAdjustmentTypeId = get('current.intAdjustmentType');

            switch (intAdjustmentTypeId) {
                case me.adjustmentTypes.QuantityChange:
                case me.adjustmentTypes.ItemChange:
                case me.adjustmentTypes.UOMChange:
                case me.adjustmentTypes.ExpiryDateChange:
                case me.adjustmentTypes.LotStatusChange:
                    return me.hide;
                    break;
                case me.adjustmentTypes.SplitLot:
                default:
                    return me.show;
            }
        },

        formulaHideColumn_colNewSubLocation: function(get){
            var me = this;
            var intAdjustmentTypeId = get('current.intAdjustmentType');

            switch (intAdjustmentTypeId) {
                case me.adjustmentTypes.QuantityChange:
                case me.adjustmentTypes.ItemChange:
                case me.adjustmentTypes.UOMChange:
                case me.adjustmentTypes.ExpiryDateChange:
                case me.adjustmentTypes.LotStatusChange:
                    return me.hide;
                    break;
                case me.adjustmentTypes.SplitLot:
                default:
                    return me.show;
            }
        },

        formulaHideColumn_colNewStorageLocation: function(get){
            var me = this;
            var intAdjustmentTypeId = get('current.intAdjustmentType');

            switch (intAdjustmentTypeId) {
                case me.adjustmentTypes.QuantityChange:
                case me.adjustmentTypes.ItemChange:
                case me.adjustmentTypes.UOMChange:
                case me.adjustmentTypes.ExpiryDateChange:
                case me.adjustmentTypes.LotStatusChange:
                    return me.hide;
                    break;
                case me.adjustmentTypes.SplitLot:
                default:
                    return me.show;
            }
        }


    }

});