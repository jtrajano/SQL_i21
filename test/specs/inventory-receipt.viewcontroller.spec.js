UnitTestEngine.testViewController({
    name: 'Inventory.view.InventoryReceiptViewController',
    alias: 'controller.icinventoryreceipt',
    base: 'Inventory.view.InventoryBaseViewController',
    dependencies: ["CashManagement.common.Text", "CashManagement.common.BusinessRules"],
    init: function(controller) {
        describe('Inventory Receipt', function() {
            describe('view', function() {
                beforeEach(function() {
                    this.view = controller.getView();
                });

                it('should have a view', function() {
                    var view = Ext.create('Inventory.view.InventoryReceiptViewModel');
                });
            })
        })
    }
});