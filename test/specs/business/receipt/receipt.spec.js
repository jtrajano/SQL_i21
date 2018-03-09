describe('Receipt Lot Replication', function () {
    var controller;
    var receipt;
    var receiptItem;
    var lot;
    var lots;
    var $replicator;

    beforeEach(function() {
        controller = Ext.create('Inventory.view.InventoryReceiptViewController');
        receipt = getReceipt();
        receiptItem = getReceiptItem();
        lot = getReceiptItemLot();
        lots = [];
        $replicator = controller
            .getReplicator(receipt, receiptItem, lot)
            .createReplicator();
    });

    it('should instantiate classes', function() {
        should.exist(controller);
        should.exist(receipt);
        should.exist(receiptItem);
        should.exist(lot);
    });

    it('should replicate via controller', function() {
        $replicator
            .subscribe(function(x) {
                lots.push(x.replicatedLot);
            }, function(error) {
                
            }, function() {
                should.equal(17, lots.length);
            });
    });
});