UnitTestEngine.testViewController({
    name: 'Inventory.view.InventoryReceiptViewController',
    alias: 'controller.icinventoryreceipt',
    base: 'Inventory.view.InventoryBaseViewController',
    dependencies: ["CashManagement.common.Text", "CashManagement.common.BusinessRules"],
    init: function(controller) {
        describe("Weight/Loss Percentage", function() {
            it('should compute weight/loss percentage', function() {

                var receipt = Ext.create('Inventory.view.InventoryReceiptViewController');
                var percentage = receipt.getWeightLossPercentage();
                (percentage).should.equal(0);
            });
        });
    }
});