UnitTestEngine.testViewController({
    name: 'Inventory.view.InventoryReceiptViewController',
    alias: 'controller.icinventoryreceipt',
    base: 'Inventory.view.InventoryBaseViewController',
    dependencies: ["CashManagement.common.Text", "CashManagement.common.BusinessRules"],
    init: function(controller) {
        describe("Weight/Loss Percentage", function() {
            it('should compute weight/loss percentage', function() {

                var receipt = Ext.create('Inventory.view.InventoryReceiptViewController');
                var items = { data:[
                        {
                            dblNet: 10.50,
                            dblOrderQty: 2.10,
                            dblContainerWeightPerQty: 1.20
                        }
                    ] };
                
                var percentage = receipt.getWeightLoss(items, 2).dblWeightLossPercentage;
                percentage.should.equal(0.92);
            });
        });
    }
});