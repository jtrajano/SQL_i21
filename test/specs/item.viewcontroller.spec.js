UnitTestEngine.testViewController({
    name: 'Inventory.view.ItemViewController',
    alias: 'controller.icitem',
    base: 'Inventory.view.InventoryBaseViewController',
    dependencies: [],
    init: function (controller) {
        describe('sale/retail price', function () {
            describe('pricing method is None', function () {
                // Sale Price = Cost
                it('should be equal to cost of 0', function () {
                    var config = { standardCost: 100.5, amount: 30.5, pricingMethod: "None" };
                    var salePrice = controller.getSalePrice(config, function () { });
                    salePrice.should.be.equal(0);
                });
            });

            describe('pricing method is Fixed Dollar Amount', function () {
                // Sale Price = Cost + Amount
                it('should be equal to 131', function () {
                    var config = { standardCost: 100.5, amount: 30.5, pricingMethod: "Fixed Dollar Amount" };
                    var salePrice = controller.getSalePrice(config, function () { });
                    salePrice.should.be.equal(131);
                });
            });

            describe('pricing method is Markup Standard Cost', function () {
                // Sale Price = (Cost * (Amount/100)) + Cost
                it('should be equal to 131.1525', function () {
                    var config = { standardCost: 100.5, amount: 30.5, pricingMethod: "Markup Standard Cost" };
                    var salePrice = controller.getSalePrice(config, function () { });
                    salePrice.should.be.equal(131.1525);
                });
            });

            describe('pricing method is Percent of Margin', function () {
                describe("amount < 100", function() {
                    // Sale Price = Cost / (1 - (Amount / 100)
                    it('should be equal to 144.604317', function () {
                        var config = { standardCost: 100.5, amount: 30.5, pricingMethod: "Percent of Margin" };
                        var salePrice = (controller.getSalePrice(config, function () { })).toFixed(6);
                        salePrice.should.be.equal(144.604317.toFixed(6));
                    });
                });

                describe("amount >= 100", function() {
                    it('should be undefined', function () {
                        var config = { standardCost: 100.5, amount: 130.5, pricingMethod: "Percent of Margin" };
                        var salePrice = controller.getSalePrice(config, function () { });
                        should.not.exist(salePrice);
                    });
                });
            });
        });

        describe('pricing level unit price', function () {
            describe('pricing method is None', function () {
                it('should be equal to cost of 0', function () {
                    var config = { salePrice: 67.625899, msrpPrice: 6,
                        standardCost: 47, amount: 25.30, qty: 3, 
                        pricingMethod: "None" };
                    var salePrice = controller.getPricingLevelUnitPrice(config);
                    salePrice.should.be.equal(0);
                });
            });

            describe('pricing method is MSRP Discount', function () {
                it('should be equal to 5.88', function () {
                    var config = { salePrice: 67.625899, msrpPrice: 6,
                        standardCost: 47, amount: 2, qty: 1, 
                        pricingMethod: "MSRP Discount" };
                    var salePrice = controller.getPricingLevelUnitPrice(config);
                    salePrice.should.be.equal(5.88);
                });
            });

            describe('pricing method is Percent of Margin (MSRP)', function () {
                it('should be equal to 46.18', function () {
                    var config = { salePrice: 67.625899, msrpPrice: 6,
                        standardCost: 47, amount: 2, qty: 1,
                        pricingMethod: "Percent of Margin (MSRP)" };
                    var salePrice = controller.getPricingLevelUnitPrice(config);
                    salePrice.should.be.equal(46.18);
                });
            });

            describe('pricing method is Fixed Dollar Amount', function () {
                it('should be equal to 49', function () {
                    var config = { salePrice: 67.625899, msrpPrice: 6,
                        standardCost: 47, amount: 2, qty: 1,
                        pricingMethod: "Fixed Dollar Amount" };
                    var salePrice = controller.getPricingLevelUnitPrice(config);
                    salePrice.should.be.equal(49);
                });
            });

            describe('pricing method is Markup Standard Cost', function () {
                it('should be equal to 47.94', function () {
                    var config = { salePrice: 67.625899, msrpPrice: 6,
                        standardCost: 47, amount: 2, qty: 1,
                        pricingMethod: "Markup Standard Cost" };
                    var salePrice = controller.getPricingLevelUnitPrice(config);
                    salePrice.should.be.equal(47.94);
                });
            });

            describe('pricing method is Percent of Margin', function () {
                it('should be equal to 47.96', function () {
                    var config = { salePrice: 67.625899, msrpPrice: 6,
                        standardCost: 47, amount: 2, qty: 1,
                        pricingMethod: "Percent of Margin" };
                    var salePrice = controller.getPricingLevelUnitPrice(config).toFixed(2);
                    salePrice.should.be.equal(47.96.toFixed(2));
                });
            });
        });
    }
});