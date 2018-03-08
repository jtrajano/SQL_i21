Ext.define('Inventory.domain.receipt.LotReplicator', {
    constructor: function(config) {
        this.initConfig(config);
    },

    config: {
        analyzer: null,
        progressHandler: null,
        notifyExcessiveReplication: true,
    },

    initializeProgress: function (min, max) {
        var ph = this.getProgressHandler();
        if (ph) {
            ph.setMin(min);
            ph.setMax(max);
        }
    },

    addProgress: function (value) {
        var ph = this.getProgressHandler();
        if (ph) {
            ph.step(value);
        }
    },

    createReplicator: function () {
        var me = this;
        var $replicator = Rx.Observable.create(function (observer) {
            var analyzer = me.getAnalyzer();
            if (!analyzer) {
                observer.onError("LotReplicationAnalyzer should be defined.");
                observer.onCompleted();
            }

            analyzer.analyze();

            if (me.getNotifyExcessiveReplication) {
                try {
                    analyzer.throwIfExcessive();
                } catch(e) {
                    observer.onError(e);
                    observer.onCompleted();
                    return $replicator;
                }
            }

            var lots = [];
            var totalReplicatedQty = 0.00;

            me.initializeProgress(0, analyzer.getReplications());

            // Add replicated lots with equally distributed quantity.
            for (var i = 0; i < analyzer.getBaseReplications(); i++) {
                me.addProgress(i + 1);
                if (analyzer.getLotQtyToReplicate() !== 0) {
                    var replicatedLot = me.createReceiptItemLot(analyzer.getLot(), analyzer.getLotQtyToReplicate(), analyzer.getLotGrossQtyToReplicate(), analyzer.getLotTareWgtQtyToReplicate());
                    lots.push(replicatedLot);
                    totalReplicatedQty += analyzer.getLotQtyToReplicate();
                    observer.next({ replicatedLot: replicatedLot, index: i });
                }
            }

            // Add the lot containing the excess replication quantity.
            if (Inventory.Utils.Math.roundWithPrecision(analyzer.getExcessLotQtyToReplicate(), 6) !== 0) {
                var replicatedLot = me.createReceiptItemLot(analyzer.getLot(), analyzer.getExcessLotQtyToReplicate(), analyzer.getExcessLotGrossQtyToReplicate(), analyzer.getLotTareWgtQtyToReplicate());
                lots.push(replicatedLot);
                totalReplicatedQty += analyzer.getExcessLotQtyToReplicate();
                observer.next({ replicatedLot: replicatedLot, index: lots.length - 1, isExcess: true });
            }

            if (lots.length === 0) {
                observer.onError("The lots for '" + analyzer.getReceiptItem().get('strItemNo') + "' are fully replicated.");
            }

            observer.onCompleted();
        });
        return $replicator;
    },

    createReceiptItemLot: function (lot, qty, grossWgt, tareWgt) {
        var newLot = Ext.create('Inventory.model.ReceiptItemLot', {
            strUnitMeasure: lot.get('strUnitMeasure'),
            intItemUnitMeasureId: lot.get('intItemUnitMeasureId'),
            dblNetWeight: grossWgt,
            dblStatedNetPerUnit: lot.get('dblStatedNetPerUnit'),
            dblPhyVsStated: lot.get('dblPhyVsStated'),
            strOrigin: lot.get('strOrigin'),
            intSubLocationId: lot.get('intSubLocationId'),
            intStorageLocationId: lot.get('intStorageLocationId'),
            dblQuantity: qty,
            dblGrossWeight: grossWgt,
            dblTareWeight: tareWgt,
            dblCost: lot.get('dblCost'),
            intUnitPallet: lot.get('intUnitPallet'),
            dblStatedGrossPerUnit: lot.get('dblStatedGrossPerUnit'),
            dblStatedTarePerUnit: lot.get('dblStatedTarePerUnit'),
            strContainerNo: lot.get('strContainerNo'),
            intEntityVendorId: lot.get('intEntityVendorId'),
            strGarden: lot.get('strGarden'),
            strMarkings: lot.get('strMarkings'),
            strGrade: lot.get('strGrade'),
            intOriginId: lot.get('intOriginId'),
            intSeasonCropYear: lot.get('intSeasonCropYear'),
            strVendorLotId: lot.get('strVendorLotId'),
            dtmManufacturedDate: lot.get('dtmManufacturedDate'),
            strRemarks: lot.get('strRemarks'),
            strCondition: lot.get('strCondition'),
            dtmCertified: lot.get('dtmCertified'),
            dtmExpiryDate: lot.get('dtmExpiryDate'),
            intSort: lot.get('intSort'),
            strWeightUOM: lot.get('strWeightUOM'),
            intParentLotId: lot.get('intParentLotId'),
            strParentLotNumber: lot.get('strParentLotNumber'),
            strParentLotAlias: lot.get('strParentLotAlias'),
            strStorageLocation: lot.get('strStorageLocation'),
            strSubLocationName: lot.get('strSubLocationName'),
            dblLotUOMConvFactor: lot.get('dblLotUOMConvFactor'),
            strLotAlias: lot.get('strLotAlias'),
            phantom: true
        });
        return newLot;
    }
})