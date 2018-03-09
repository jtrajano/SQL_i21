describe("Lot Replicator", function () {
    var receipt;
    var receiptItem;
    var lot;
    var analyzer;
    var $replicator;
    var clones = [];

    beforeEach(function () {
        receipt = getReceipt();
        receiptItem = getReceiptItem();
        lot = getReceiptItemLot();
        var lots = _.filter(getLots(), function (x) { return !x.dummy; });
        var totalConvertedLotQty = Inventory.domain.receipt.LotReplicationAnalyzer.getTotalLotQty(lots, receiptItem);

        analyzer = Ext.create('Inventory.domain.receipt.LotReplicationAnalyzer', {
            receipt: receipt,
            receiptItem: receiptItem,
            lot: lot,
            totalConvertedLotQty: totalConvertedLotQty,
            replicationLimit: 1000
        });

        $replicator = Ext.create('Inventory.domain.receipt.LotReplicator', {
            analyzer: analyzer,
            notifyExcessiveReplication: true,
        })
        .createReplicator();
    });

    it('should replicate successfully', function(done) {
        $replicator.subscribe(function (val) {
            clones.push(val.replicatedLot);
        }, function (err) {
            done();
        }, function () {
            should.exist(clones);
            clones.length.should.be.above(0);
            done();
        });
    });

    it('should replicate 13 lots', function () {
        clones.length.should.equal(13);   
    });

    it('replicated lots should have a total lot quantity of 3700', function () {
        var qty = 0.00;
        _.each(clones, function(data) {
            qty += data.get('dblQuantity');
        });
        qty.should.be.equal(3700);
    });

    it('replicated lots should have a total gross quantity of 3700', function () {
        var qty = 0.00;
        _.each(clones, function(data) {
            qty += data.get('dblGrossWeight');
        });
        qty.should.be.equal(3700);
    });
});