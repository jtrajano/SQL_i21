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
        'Inventory.store.BufferedLotStatus',
        'Inventory.store.BufferedItemStockUOMForAdjustmentView',
        'Inventory.store.BufferedItemOwner',
        'Inventory.store.BufferedItemStockUOMView'
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
                },{
                    intAdjustmentTypeId : '7',
                    strDescription: 'Lot Merge'
                },{
                    intAdjustmentTypeId : '8',
                    strDescription: 'Lot Move'
                },{
                    intAdjustmentTypeId : '9',
                    strDescription: 'Lot Owner Change'
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
            //type: 'icbuffereditemunitmeasure'
            type: 'icbuffereditemstockuomforadjustmentview'
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
        },
        newOwner: {
            type: 'icbuffereditemowner'
        },
        fromSubLocation: {
            type: 'icbuffereditemstockuomview'
        },    
        fromStorageLocation: {
            type: 'icbuffereditemstockuomview'
        }
    },

    adjustmentTypes: {
        QuantityChange: 1,
        UOMChange: 2,
        ItemChange: 3,
        LotStatusChange: 4,
        SplitLot: 5,
        ExpiryDateChange: 6,
        LotMerge: 7,
        LotMove: 8,
        LotOwnerChange: 9
    },

    hide: true,
    show: false,
    readOnly: true,
    editable: false,

    formulas: {
        getOnHandFilterValue: function(get) {
            if(get('current.intAdjustmentType') === 1)
                return -1;
            return 0;
        },

        intCurrencyId: function(get) {
            return get('current.intCurrencyId');
        },
        
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
                case me.adjustmentTypes.LotOwnerChange:
                    return me.hide;
                    break;
                case me.adjustmentTypes.SplitLot:
                case me.adjustmentTypes.LotMerge:
                case me.adjustmentTypes.LotMove:
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
                case me.adjustmentTypes.LotOwnerChange:
                    return me.hide;
                    break;
                case me.adjustmentTypes.QuantityChange:
                case me.adjustmentTypes.SplitLot:
                case me.adjustmentTypes.LotMerge:
                case me.adjustmentTypes.LotMove:
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
                case me.adjustmentTypes.LotOwnerChange:
                    return me.hide;
                    break;

                case me.adjustmentTypes.QuantityChange:
                case me.adjustmentTypes.SplitLot:
                case me.adjustmentTypes.LotMerge:
                case me.adjustmentTypes.LotMove:
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
                case me.adjustmentTypes.LotOwnerChange:
                    return me.hide;
                    break;
                case me.adjustmentTypes.QuantityChange:
                case me.adjustmentTypes.SplitLot:
                case me.adjustmentTypes.LotMerge:
                case me.adjustmentTypes.LotMove:
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
                case me.adjustmentTypes.LotOwnerChange:
                    return me.hide;
                    break;

                case me.adjustmentTypes.SplitLot:
                case me.adjustmentTypes.LotMerge:
                case me.adjustmentTypes.LotMove:
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
                case me.adjustmentTypes.LotOwnerChange:
                    return me.hide;
                    break;

                case me.adjustmentTypes.QuantityChange:
                case me.adjustmentTypes.SplitLot:
                case me.adjustmentTypes.LotMerge:
                case me.adjustmentTypes.LotMove:
                case me.adjustmentTypes.UOMChange:
                case me.adjustmentTypes.ItemChange:
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
                case me.adjustmentTypes.LotOwnerChange:
                    return me.hide;
                    break;
                case me.adjustmentTypes.SplitLot:
                case me.adjustmentTypes.LotMerge:
                case me.adjustmentTypes.LotMove:
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
                case me.adjustmentTypes.LotOwnerChange:
                    return me.hide;
                    break;
                case me.adjustmentTypes.SplitLot:
                case me.adjustmentTypes.LotMerge:
                case me.adjustmentTypes.LotMove:
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
                case me.adjustmentTypes.LotOwnerChange:
                    return me.hide;
                    break;
                case me.adjustmentTypes.SplitLot:
                case me.adjustmentTypes.LotMerge:
                case me.adjustmentTypes.LotMove:
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
                case me.adjustmentTypes.LotOwnerChange:
                    return me.hide;
                    break;
                case me.adjustmentTypes.SplitLot:
                case me.adjustmentTypes.LotMerge:
                case me.adjustmentTypes.LotMove:
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
                case me.adjustmentTypes.LotOwnerChange:
                    return me.hide;
                    break;
                case me.adjustmentTypes.SplitLot:
                case me.adjustmentTypes.LotMerge:
                case me.adjustmentTypes.LotMove:
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
                case me.adjustmentTypes.LotMerge:
                case me.adjustmentTypes.LotMove:
                case me.adjustmentTypes.LotOwnerChange:
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
                case me.adjustmentTypes.LotMerge:
                case me.adjustmentTypes.LotMove:
                case me.adjustmentTypes.LotOwnerChange:
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
                case me.adjustmentTypes.LotOwnerChange:
                    return me.hide;
                    break;

                case me.adjustmentTypes.QuantityChange:
                case me.adjustmentTypes.SplitLot:
                case me.adjustmentTypes.LotMerge:
                case me.adjustmentTypes.LotMove:
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
                case me.adjustmentTypes.LotOwnerChange:
                    return me.hide;
                    break;

                case me.adjustmentTypes.QuantityChange:
                case me.adjustmentTypes.SplitLot:
                case me.adjustmentTypes.LotMerge:
                case me.adjustmentTypes.LotMove:
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
                case me.adjustmentTypes.LotMerge:
                case me.adjustmentTypes.LotMove:
                case me.adjustmentTypes.LotStatusChange:
                case me.adjustmentTypes.ExpiryDateChange:
                case me.adjustmentTypes.UOMChange:
                case me.adjustmentTypes.LotOwnerChange:
                    return me.hide;
                    break;
                case me.adjustmentTypes.ItemChange:
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
                case me.adjustmentTypes.LotMerge:
                case me.adjustmentTypes.LotMove:
                case me.adjustmentTypes.LotStatusChange:
                case me.adjustmentTypes.ExpiryDateChange:
                case me.adjustmentTypes.UOMChange:
                case me.adjustmentTypes.LotOwnerChange:                
                    return me.hide;
                    break;
                case me.adjustmentTypes.ItemChange:
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
                case me.adjustmentTypes.LotMerge:
                case me.adjustmentTypes.LotMove:
                case me.adjustmentTypes.LotStatusChange:
                case me.adjustmentTypes.ItemChange:
                case me.adjustmentTypes.UOMChange:
                case me.adjustmentTypes.LotOwnerChange:
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
                case me.adjustmentTypes.LotMerge:
                case me.adjustmentTypes.LotMove:
                case me.adjustmentTypes.LotStatusChange:
                case me.adjustmentTypes.ItemChange:
                case me.adjustmentTypes.UOMChange:
                case me.adjustmentTypes.LotOwnerChange:
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
                case me.adjustmentTypes.LotMerge:
                case me.adjustmentTypes.LotMove:
                case me.adjustmentTypes.ItemChange:
                case me.adjustmentTypes.UOMChange:
                case me.adjustmentTypes.ExpiryDateChange:
                case me.adjustmentTypes.LotOwnerChange:
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
                case me.adjustmentTypes.LotMerge:
                case me.adjustmentTypes.LotMove:
                case me.adjustmentTypes.ItemChange:
                case me.adjustmentTypes.UOMChange:
                case me.adjustmentTypes.ExpiryDateChange:
                case me.adjustmentTypes.LotOwnerChange:
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
                case me.adjustmentTypes.LotMerge:
                case me.adjustmentTypes.LotMove:
                case me.adjustmentTypes.ItemChange:
                case me.adjustmentTypes.UOMChange:
                case me.adjustmentTypes.ExpiryDateChange:
                case me.adjustmentTypes.LotStatusChange:
                case me.adjustmentTypes.LotOwnerChange:
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
                case me.adjustmentTypes.LotOwnerChange:
                    return me.hide;
                    break;
                case me.adjustmentTypes.SplitLot:
                case me.adjustmentTypes.LotMerge:
                case me.adjustmentTypes.LotMove:
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
                case me.adjustmentTypes.LotOwnerChange:
                    return me.hide;
                    break;
                case me.adjustmentTypes.SplitLot:
                case me.adjustmentTypes.LotMerge:
                case me.adjustmentTypes.LotMove:
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
                case me.adjustmentTypes.LotOwnerChange:
                    return me.hide;
                    break;
                case me.adjustmentTypes.SplitLot:
                case me.adjustmentTypes.LotMerge:
                case me.adjustmentTypes.LotMove:
                default:
                    return me.show;
            }
        },

        formulaShowNewCostEditor: function(get){
            var me = this;
            var posted = get('current.ysnPosted');
            if (posted){
                return me.readOnly;
            }
            else {
                var newQuantity = get('grdInventoryAdjustment.selection.dblNewQuantity')
                    ,currentQuantity = get('grdInventoryAdjustment.selection.dblQuantity');

                if (!Ext.isNumeric(newQuantity))
                    return me.readOnly;

                // Check if new quantity will increase the stock. If yes, allow edit.
                currentQuantity = Ext.isNumeric(currentQuantity) ? currentQuantity : 0.00;
                if (newQuantity > currentQuantity){
                    return me.editable;
                }
                else {
                    return me.readOnly;
                }
            }
        },

        formulaHideColumn_colOwner: function(get){
            var me = this;
            var intAdjustmentTypeId = get('current.intAdjustmentType');

            switch (intAdjustmentTypeId) {
                case me.adjustmentTypes.QuantityChange:
                case me.adjustmentTypes.SplitLot:
                case me.adjustmentTypes.LotMerge:
                case me.adjustmentTypes.LotMove:
                case me.adjustmentTypes.ItemChange:
                case me.adjustmentTypes.UOMChange:
                case me.adjustmentTypes.ExpiryDateChange:
                case me.adjustmentTypes.LotStatusChange:
                    return me.hide;
                    break;                
                case me.adjustmentTypes.LotOwnerChange:
                default:
                    return me.show;
            }
        },

        formulaHideColumn_colNewOwner: function(get){
            var me = this;
            var intAdjustmentTypeId = get('current.intAdjustmentType');

            switch (intAdjustmentTypeId) {
                case me.adjustmentTypes.QuantityChange:
                case me.adjustmentTypes.SplitLot:
                case me.adjustmentTypes.LotMerge:
                case me.adjustmentTypes.LotMove:
                case me.adjustmentTypes.ItemChange:
                case me.adjustmentTypes.UOMChange:
                case me.adjustmentTypes.ExpiryDateChange:
                case me.adjustmentTypes.LotStatusChange:
                    return me.hide;
                    break;
                case me.adjustmentTypes.LotOwnerChange:
                default:
                    return me.show;
            }
        },

        setAdjustByQuantityLabel: function(get) {
            var win = this.getView();
            var grdInventoryAdjustment = win.down('#grdInventoryAdjustment');
            var gridColumns = grdInventoryAdjustment.headerCt.getGridColumns();

            if (get('current.intAdjustmentType') == 1) {
                for (var i = 0; i < gridColumns.length; i++) {
                    if (gridColumns[i].itemId == 'colAdjustByQuantity') {
                        grdInventoryAdjustment.columnManager.columns[i].setText('Adjust Qty By <span style="color:red">*</span>');
                    }
                }
            }
            else {
                for (var i = 0; i < gridColumns.length; i++) {
                    if (gridColumns[i].itemId == 'colAdjustByQuantity') {
                        grdInventoryAdjustment.columnManager.columns[i].setText('Adjust Qty By');
                    }
                }
            }
        },

        setNewQuantityLabel: function(get) {
            var win = this.getView();
            var grdInventoryAdjustment = win.down('#grdInventoryAdjustment');
            var gridColumns = grdInventoryAdjustment.headerCt.getGridColumns();

            if (get('current.intAdjustmentType') == 1) {
                for (var i = 0; i < gridColumns.length; i++) {
                    if (gridColumns[i].itemId == 'colNewQuantity') {
                        grdInventoryAdjustment.columnManager.columns[i].setText('New Quantity <span style="color:red">*</span>');
                    }
                }
            }
            else {
                for (var i = 0; i < gridColumns.length; i++) {
                    if (gridColumns[i].itemId == 'colNewQuantity') {
                        grdInventoryAdjustment.columnManager.columns[i].setText('New Quantity');
                    }
                }
            }
        },

        setNewItemNumberLabel: function(get) {
            var win = this.getView();
            var grdInventoryAdjustment = win.down('#grdInventoryAdjustment');
            var gridColumns = grdInventoryAdjustment.headerCt.getGridColumns();

            if (get('current.intAdjustmentType') == 3) {
                for (var i = 0; i < gridColumns.length; i++) {
                    if (gridColumns[i].itemId == 'colNewItemNumber') {
                        grdInventoryAdjustment.columnManager.columns[i].setText('New Item No. <span style="color:red">*</span>');
                    }
                }
            }
            else {
                for (var i = 0; i < gridColumns.length; i++) {
                    if (gridColumns[i].itemId == 'colNewItemNumber') {
                        grdInventoryAdjustment.columnManager.columns[i].setText('New Item No.');
                    }
                }
            }
        },

        setSubLocationLabel: function(get) {
            var win = this.getView();
            var grdInventoryAdjustment = win.down('#grdInventoryAdjustment');
            var gridColumns = grdInventoryAdjustment.headerCt.getGridColumns();

            if (get('current.intAdjustmentType') == 4) {
                for (var i = 0; i < gridColumns.length; i++) {
                    if (gridColumns[i].itemId == 'colSubLocation') {
                        grdInventoryAdjustment.columnManager.columns[i].setText('Sub Location <span style="color:red">*</span>');
                    }
                }
            }
            else {
                for (var i = 0; i < gridColumns.length; i++) {
                    if (gridColumns[i].itemId == 'colSubLocation') {
                        grdInventoryAdjustment.columnManager.columns[i].setText('Sub Location');
                    }
                }
            }
        },

        setStorageLocationLabel: function(get) {
            var win = this.getView();
            var grdInventoryAdjustment = win.down('#grdInventoryAdjustment');
            var gridColumns = grdInventoryAdjustment.headerCt.getGridColumns();

            if (get('current.intAdjustmentType') == 4) {
                for (var i = 0; i < gridColumns.length; i++) {
                    if (gridColumns[i].itemId == 'colStorageLocation') {
                        grdInventoryAdjustment.columnManager.columns[i].setText('Storage Location <span style="color:red">*</span>');
                    }
                }
            }
            else {
                for (var i = 0; i < gridColumns.length; i++) {
                    if (gridColumns[i].itemId == 'colStorageLocation') {
                        grdInventoryAdjustment.columnManager.columns[i].setText('Storage Location');
                    }
                }
            }
        },

        setLotNumberLabel: function(get) {
            var win = this.getView();
            var grdInventoryAdjustment = win.down('#grdInventoryAdjustment');
            var gridColumns = grdInventoryAdjustment.headerCt.getGridColumns();

            if (get('current.intAdjustmentType') == 4 || get('current.intAdjustmentType') == 5) {
                for (var i = 0; i < gridColumns.length; i++) {
                    if (gridColumns[i].itemId == 'colLotNumber') {
                        grdInventoryAdjustment.columnManager.columns[i].setText('Lot ID <span style="color:red">*</span>');
                    }
                }
            }
            else {
                for (var i = 0; i < gridColumns.length; i++) {
                    if (gridColumns[i].itemId == 'colLotNumber') {
                        grdInventoryAdjustment.columnManager.columns[i].setText('Lot ID');
                    }
                }
            }
        },

        setNewLotStatusLabel: function(get) {
            var win = this.getView();
            var grdInventoryAdjustment = win.down('#grdInventoryAdjustment');
            var gridColumns = grdInventoryAdjustment.headerCt.getGridColumns();

            if (get('current.intAdjustmentType') == 4) {
                for (var i = 0; i < gridColumns.length; i++) {
                    if (gridColumns[i].itemId == 'colNewLotStatus') {
                        grdInventoryAdjustment.columnManager.columns[i].setText('New Lot Status <span style="color:red">*</span>');
                    }
                }
            }
            else {
                for (var i = 0; i < gridColumns.length; i++) {
                    if (gridColumns[i].itemId == 'colNewLotStatus') {
                        grdInventoryAdjustment.columnManager.columns[i].setText('New Lot Status');
                    }
                }
            }
        },

        setNewLotNumberLabel: function(get) {
            var win = this.getView();
            var grdInventoryAdjustment = win.down('#grdInventoryAdjustment');
            var gridColumns = grdInventoryAdjustment.headerCt.getGridColumns();

            if (get('current.intAdjustmentType') == 5) {
                for (var i = 0; i < gridColumns.length; i++) {
                    if (gridColumns[i].itemId == 'colNewLotNumber') {
                        grdInventoryAdjustment.columnManager.columns[i].setText('New Lot ID <span style="color:red">*</span>');
                    }
                }
            }
            else {
                for (var i = 0; i < gridColumns.length; i++) {
                    if (gridColumns[i].itemId == 'colNewLotNumber') {
                        grdInventoryAdjustment.columnManager.columns[i].setText('New Lot ID');
                    }
                }
            }
        },

        setNewUOMLabel: function(get) {
            var win = this.getView();
            var grdInventoryAdjustment = win.down('#grdInventoryAdjustment');
            var gridColumns = grdInventoryAdjustment.headerCt.getGridColumns();

            if (get('current.intAdjustmentType') == 5) {
                for (var i = 0; i < gridColumns.length; i++) {
                    if (gridColumns[i].itemId == 'colNewUOM') {
                        grdInventoryAdjustment.columnManager.columns[i].setText('New Split Lot UOM <span style="color:red">*</span>');
                    }
                }
            }
            else {
                for (var i = 0; i < gridColumns.length; i++) {
                    if (gridColumns[i].itemId == 'colNewUOM') {
                        grdInventoryAdjustment.columnManager.columns[i].setText('New Split Lot UOM');
                    }
                }
            }
        },

        setNewSplitLotQuantityLabel: function(get) {
            var win = this.getView();
            var grdInventoryAdjustment = win.down('#grdInventoryAdjustment');
            var gridColumns = grdInventoryAdjustment.headerCt.getGridColumns();

            if (get('current.intAdjustmentType') == 5) {
                for (var i = 0; i < gridColumns.length; i++) {
                    if (gridColumns[i].itemId == 'colNewSplitLotQuantity') {
                        grdInventoryAdjustment.columnManager.columns[i].setText('New Split Lot Qty <span style="color:red">*</span>');
                    }
                }
            }
            else {
                for (var i = 0; i < gridColumns.length; i++) {
                    if (gridColumns[i].itemId == 'colNewSplitLotQuantity') {
                        grdInventoryAdjustment.columnManager.columns[i].setText('New Split Lot Qty');
                    }
                }
            }
        },

        setNewLocationLabel: function(get) {
            var win = this.getView();
            var grdInventoryAdjustment = win.down('#grdInventoryAdjustment');
            var gridColumns = grdInventoryAdjustment.headerCt.getGridColumns();

            if (get('current.intAdjustmentType') == 5) {
                for (var i = 0; i < gridColumns.length; i++) {
                    if (gridColumns[i].itemId == 'colNewLocation') {
                        grdInventoryAdjustment.columnManager.columns[i].setText('New Location <span style="color:red">*</span>');
                    }
                }
            }
            else {
                for (var i = 0; i < gridColumns.length; i++) {
                    if (gridColumns[i].itemId == 'colNewLocation') {
                        grdInventoryAdjustment.columnManager.columns[i].setText('New Location');
                    }
                }
            }
        },

        setNewSubLocationLabel: function(get) {
            var win = this.getView();
            var grdInventoryAdjustment = win.down('#grdInventoryAdjustment');
            var gridColumns = grdInventoryAdjustment.headerCt.getGridColumns();

            if (get('current.intAdjustmentType') == 5) {
                for (var i = 0; i < gridColumns.length; i++) {
                    if (gridColumns[i].itemId == 'colNewSubLocation') {
                        grdInventoryAdjustment.columnManager.columns[i].setText('New Sub Location <span style="color:red">*</span>');
                    }
                }
            }
            else {
                for (var i = 0; i < gridColumns.length; i++) {
                    if (gridColumns[i].itemId == 'colNewSubLocation') {
                        grdInventoryAdjustment.columnManager.columns[i].setText('New Sub Location');
                    }
                }
            }
        },

        setNewStorageLocationLabel: function(get) {
            var win = this.getView();
            var grdInventoryAdjustment = win.down('#grdInventoryAdjustment');
            var gridColumns = grdInventoryAdjustment.headerCt.getGridColumns();

            if (get('current.intAdjustmentType') == 5) {
                for (var i = 0; i < gridColumns.length; i++) {
                    if (gridColumns[i].itemId == 'colNewStorageLocation') {
                        grdInventoryAdjustment.columnManager.columns[i].setText('New Storage Location <span style="color:red">*</span>');
                    }
                }
            }
            else {
                for (var i = 0; i < gridColumns.length; i++) {
                    if (gridColumns[i].itemId == 'colNewStorageLocation') {
                        grdInventoryAdjustment.columnManager.columns[i].setText('New Storage Location');
                    }
                }
            }
        }              
    }

});