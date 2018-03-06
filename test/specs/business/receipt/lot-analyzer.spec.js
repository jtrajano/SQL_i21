
describe("Lot Analyzer", function() {
    var receipt;
    var receiptItem;
    var lot;
    var analyzer;
    var lots;

    beforeEach(function() {
        receipt = getReceipt();
        receiptItem = getReceiptItem();
        lot = getReceiptItemLot();
        
        var lots = _.filter(getLots(), function(x) { return !x.dummy; });
        var totalConvertedLotQty = Inventory.domain.receipt.LotReplicationAnalyzer.getTotalLotQty(lots, receiptItem);

        analyzer = Ext.create('Inventory.domain.receipt.LotReplicationAnalyzer', {
            receipt: receipt,
            receiptItem: receiptItem,
            lot: lot,
            totalConvertedLotQty: totalConvertedLotQty,
            replicationLimit: 1000
        });
        analyzer.analyze();
    });

    it('should have a limit of 1000', function () {        
        should.equal(1000, analyzer.getReplicationLimit());
    });

    it('total quantity should be 5000', function() {
        should.equal(5000, analyzer.getTotalQty());
    });

    it('total converted quantity should be 5000', function() {
        should.equal(5000, analyzer.getTotalConvertedQty());
    });

    it('should have a total lot quantity of 1300', function() {
        should.equal(1300, analyzer.getTotalConvertedLotQty());
    });

    it('should have a lot quantity of 300', function() {
        should.equal(300, analyzer.getLotQtyToReplicate());
    });

    it('should produce 12.333333333333334 replications', function() {
        should.equal(12.333333333333334, analyzer.getReplications());
    });

    it('should have 12 base replications ', function() {
        should.equal(12, analyzer.getBaseReplications());
    });
    
    it('should have 0.3333333333333339 excess replications', function() {
        should.equal(0.3333333333333339, analyzer.getExcessReplications());
    });

    it('should have 100.00000000000017 excess lot quantity replications', function() {
        should.equal(100.00000000000017, analyzer.getExcessLotQtyToReplicate());
    });

    it('should have 300 lot quantity to replicate', function() {
        should.equal(300, analyzer.getLotQtyToReplicate());
    });

    it('should limit replication quantity to 3700', function() {
        should.equal(3700, analyzer.getQtyReplicationLimit());
    });

    it('should validate when replication reaches the limit of 10', function() {
        var r = getReceipt();
        var ri = getReceiptItem();
        var ls = getLotsSmall();
        var l = ls[1];

        var lots = _.filter(ls, function(x) { return !x.dummy; });
        var totalConvertedLotQty = Inventory.domain.receipt.LotReplicationAnalyzer.getTotalLotQty(lots, receiptItem);

        var anz = Ext.create('Inventory.domain.receipt.LotReplicationAnalyzer', {
            receipt: receipt,
            receiptItem: receiptItem,
            lot: lot,
            totalConvertedLotQty: totalConvertedLotQty,
            replicationLimit: 10
        });
        anz.analyze();
        should.equal(true, anz.excessive());
    });

    it('should output a suggested lot qty of', function() {
        var r = getReceipt();
        var ri = getReceiptItem();
        var ls = getLotsSmall();
        var l = ls[1];

        var lots = _.filter(ls, function(x) { return !x.dummy; });
        var totalConvertedLotQty = Inventory.domain.receipt.LotReplicationAnalyzer.getTotalLotQty(lots, receiptItem);

        var anz = Ext.create('Inventory.domain.receipt.LotReplicationAnalyzer', {
            receipt: receipt,
            receiptItem: receiptItem,
            lot: lot,
            totalConvertedLotQty: totalConvertedLotQty,
            replicationLimit: 1000
        });
        anz.analyze();
        should.equal(4, anz.getSuggestedLotQtyToReplicate());
    });

    //region Setters
    it('should be able to set limit to 100', function () { 
        analyzer.setReplicationLimit(100);       
        should.equal(100, analyzer.getReplicationLimit());
    });
    //endregion
})