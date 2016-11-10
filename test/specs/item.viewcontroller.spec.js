UnitTestEngine.testViewController({
    name: 'Inventory.view.ItemViewController',
    alias: 'controller.icitem',
    base: 'Ext.app.ViewController',
    dependencies: [],
    init: function (controller) {
        describe('sale price', function () {
            describe('pricing method is None', function () {
                // Sale Price = Cost
                it('should be equal to cost of 100.5', function () {
                    var config = { cost: 100.5, amount: 30.5, pricingMethod: "None" };
                    var salePrice = controller.getSalePrice(config, function () { });
                    salePrice.should.be.equal(100.5);
                });
            });

            describe('pricing method is Fixed Dollar Amount', function () {
                // Sale Price = Cost + Amount
                it('should be equal to 131', function () {
                    var config = { cost: 100.5, amount: 30.5, pricingMethod: "Fixed Dollar Amount" };
                    var salePrice = controller.getSalePrice(config, function () { });
                    salePrice.should.be.equal(131);
                });
            });

            describe('pricing method is Markup Standard Cost', function () {
                // Sale Price = (Cost * (Amount/100)) + Cost
                it('should be equal to 131.1525', function () {
                    var config = { cost: 100.5, amount: 30.5, pricingMethod: "Markup Standard Cost" };
                    var salePrice = controller.getSalePrice(config, function () { });
                    salePrice.should.be.equal(131.1525);
                });
            });

            describe('pricing method is Percent of Margin', function () {
                describe("amount < 100", function() {
                    // Sale Price = Cost / (1 - (Amount / 100)
                    it('should be equal to 144.604317', function () {
                        var config = { cost: 100.5, amount: 30.5, pricingMethod: "Percent of Margin" };
                        var salePrice = (controller.getSalePrice(config, function () { })).toFixed(6);
                        salePrice.should.be.equal(144.604317.toFixed(6));
                    });
                });

                describe("amount >= 100", function() {
                    it('should be equal to 131.1525', function () {
                        var config = { cost: 100.5, amount: 130.5, pricingMethod: "Percent of Margin" };
                        var salePrice = controller.getSalePrice(config, function () { });
                        should.not.exist(salePrice);
                    });
                });
            });
        });
    }
});