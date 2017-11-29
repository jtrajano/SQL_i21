UnitTestEngine.testViewController({
    name: 'Inventory.view.InventoryReceiptViewController',
    alias: 'controller.icinventoryreceipt',
    base: 'Inventory.view.InventoryBaseViewController',
    dependencies: ["CashManagement.common.Text", "CashManagement.common.BusinessRules"],
    init: function(controller) {
        describe('Inventory Receipt', function() {
            describe('view model', function() {
                var vm, receipt;
                beforeEach(function() {
                    vm = Ext.create('Inventory.view.InventoryReceiptViewModel');
                    receipt = Ext.create('Inventory.model.Receipt', {
                        strReceiptNo: 'IR-0001'
                    });
                    vm.setData({ current: receipt });
                    vm.set('current.strReceiptType', 'Contract');
                });

                it('should be able to create view model', function() {
                    should.exist(vm);
                });

                it('should have a current data', function() {
                    var current = vm.get('current');
                    should.equal(current.get('strReceiptNo'), 'IR-0001');
                });

                it('should calculate line total', function() {
                    var total = controller.calculateLineTotal(receipt, null);
                    should.equal(total, undefined);
                })
            })
        })
    },
    fail: function(error) {
        describe("Initialize Receipt", function() {
            it('it should not fail', function() {
                should.fail(false, true, error);
            })
        })
    }
});