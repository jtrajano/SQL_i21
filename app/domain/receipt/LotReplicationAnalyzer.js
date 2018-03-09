Ext.define("Inventory.domain.receipt.LotReplicationAnalyzer", {
    constructor: function (config) {
        this.initConfig(config);
    },
    
    config: {
        receipt: null,
        receiptItem: null,
        lot: null,
        totalConvertedLotQty: null,
        replicationLimit: 500,
        
        qtyReplicationLimit: null,
        replications: null,
        baseReplications: null,
        excessReplications: null,
        lotQtyToReplicate: null,
        totalQty: null,
        totalConvertedQty: null,
        excessLotQtyToReplicate: null,

        // Gross computations
        lotGrossQtyToReplicate: null,
        excessLotGrossQtyToReplicate: null,
        lotTareWgtQtyToReplicate: null
    },

    analyze: function () {
        if (!this.getLot()) throw "Please select a lot to replicate.";
        if (!this.getReceiptItem()) return;

        var receiptItemQuantity = this.getReceiptItem().get('dblOpenReceive');
        var receiptItemConversionFactor = this.getReceiptItem().get('dblItemUOMConvFactor');
        var lotQuantity = this.getLot().get('dblQuantity');
        var lotConversionFactor = this.getLot().get('dblLotUOMConvFactor');

        if (receiptItemQuantity <= 0) throw "Cannot replicate zero Receipt Qty.";
        if (lotQuantity <= 0) throw "Cannot replicate zero Lot Quantity.";

        // Automatically calculate the total lot qty that is converted to the lot unit
        if(!this.getTotalConvertedLotQty()) {
            var lots = _.filter(this.getReceiptItem().tblICInventoryReceiptItemLots().data.items, function(x) { return !x.dummy; });
            var qty = Inventory.domain.receipt.LotReplicationAnalyzer.getTotalLotQty(lots, this.getReceiptItem());
            this.setTotalConvertedLotQty(Inventory.Utils.nullOrDefault(qty, 0));
        }

        // 1. Get the total item qty and convert to lot unit
        this.setTotalQty(Inventory.Utils.Uom.convertQtyBetweenUOM(receiptItemConversionFactor, lotConversionFactor, receiptItemQuantity));
        // 2. Get the total lot qty in item unit
        this.setTotalConvertedQty(Inventory.Utils.Uom.convertQtyBetweenUOM(lotConversionFactor, receiptItemConversionFactor, this.getTotalQty()));
        // 3. Get the limit that the replication can fill in
        this.setQtyReplicationLimit(this.getTotalConvertedQty() - this.getTotalConvertedLotQty());
        // 4. Calculate the no. of replications by converting the total qty from item unit to lot unit
        this.setLotQtyToReplicate(lotQuantity);
        this.setReplications(Inventory.Utils.Uom.convertQtyBetweenUOM(receiptItemConversionFactor, lotConversionFactor, this.getQtyReplicationLimit()) / lotQuantity);
        this.setBaseReplications(Inventory.Utils.Math.truncate(this.getReplications()));
        // 5. Calculate the excess qty to replicate
        this.setExcessReplications(this.getReplications() - this.getBaseReplications());
        this.setExcessLotQtyToReplicate(this.getExcessReplications() * lotQuantity);

        // Gross & tare qty calculations
        var receiptItemGrossConversionFactor = this.getReceiptItem().get('dblWeightUOMConvFactor');
        var receiptItemGrossQty = this.getReceiptItem().get('dblGross');
        if(receiptItemGrossQty) {
            // 6. Calculate lot gross qty
            var lotGrossQtyToReplicate = Inventory.Utils.Uom.convertQtyBetweenUOM(lotConversionFactor, receiptItemGrossConversionFactor, lotQuantity);
            this.setLotGrossQtyToReplicate(lotGrossQtyToReplicate);

            // 7. Calculate excess lot gross qty
            var excessLotGrossQtyToReplicate = Inventory.Utils.Uom.convertQtyBetweenUOM(lotConversionFactor, receiptItemGrossConversionFactor, this.getExcessLotQtyToReplicate());
            this.setExcessLotGrossQtyToReplicate(excessLotGrossQtyToReplicate);

            // 8. Calculate tare qty
            var lotTareWgtQtyToReplicate = this.getLot().get('dblTareWeight');
            this.setLotTareWgtQtyToReplicate(lotTareWgtQtyToReplicate);
        }
    },

    getSuggestedLotQtyToReplicate: function() {
        return Inventory.Utils.Math.roundWithPrecision(this.getReplications() / this.getReplicationLimit() * this.getLotQtyToReplicate(), 0);
    },

    /*  
        Item: 100 Ton
        Lots:
            > 3 Ton
            > 5 Kg
        Quantity computations
        1. Get total item qty converted to lot unit
            > 100 * 1,000 = 100,000 Kg
        2. Get total lot qty in Tons
            > (5/1,000 + 3) = 3.005 Tons
        3. Get the limit
            > 100 - 3.005 = 96.995 Tons
        4. Get the lot's qty based on it's unit
            > 5 Kg
        5. Calculate the no. of replications by converting the total qty from tons to kg
            > 96.995 * 1,000 = 96,995 Kg
            > 96,995 / 5 = 19,399 replications
        6. The qty per replicated lot qty is 5 Kg
        Gross computations
        1. Get item gross qty
    */

    /**
     * The number of replications is huge! This will result to a memory overhead.
     */
    excessive: function() {
        return (this.getBaseReplications() >= (this.getReplicationLimit()));
    },

    /**
     * Throws an exception when surplus() is true.
     */
    throwIfExcessive: function(message) {
        if(this.excessive())
            throw message ? message : "Excessive replication detected.";
    },

    statics: {
        getTotalLotQty: function (lots, receiptItem) {
            var qty = 0;
            _.each(lots, function(rec) {
                var factor = receiptItem.get('dblItemUOMConvFactor');
                qty += Inventory.Utils.Uom.convertQtyBetweenUOM(rec.get('dblLotUOMConvFactor'), factor, rec.get('dblQuantity'));
            });

            return qty;
        }
    }
});