/**
 * Created by LZabala on 11/13/2014.
 */
describe("Category View Model", function() {
    "use strict";

    var store;

    describe("Check if Unit Measure store", function() {
        store = Ext.create('Inventory.store.BufferedUnitMeasure');
        var storeAlias = store.alias[0];

        it("is available", function() {
            store.should.exist;
        });

        it("and alias is " + storeAlias, function() {
            storeAlias.should.equal('store.inventorybuffereduom');
        });
    });

    describe("Check if Item store", function() {
        store = Ext.create('Inventory.store.BufferedCompactItem');
        var storeAlias = store.alias[0];

        it("is available", function() {
            store.should.exist;
        });

        it("and alias is " + storeAlias, function() {
            storeAlias.should.equal('store.inventorybufferedcompactitem');
        });
    });

    describe("Check if Class store", function() {
        store = Ext.create('Inventory.store.Class');
        var storeAlias = store.alias[0];

        it("is available", function() {
            store.should.exist;
        });

        it("and alias is " + storeAlias, function() {
            storeAlias.should.equal('store.storeclass');
        });
    });

    describe("Check if Family store", function() {
        store = Ext.create('Inventory.store.Family');
        var storeAlias = store.alias[0];

        it("is available", function() {
            store.should.exist;
        });

        it("and alias is " + storeAlias, function() {
            storeAlias.should.equal('store.storefamily');
        });
    });

    describe("Check if Location store", function() {
        store = Ext.create('i21.store.CompanyLocationBuffered');
        var storeAlias = store.alias[0];

        it("is available", function() {
            store.should.exist;
        });

        it("and alias is " + storeAlias, function() {
            storeAlias.should.equal('store.companylocationbuffered');
        });
    });

    describe("Check if Vendor store", function() {
        store = Ext.create('AccountsPayable.store.VendorBuffered');
        var storeAlias = store.alias[0];

        it("is available", function() {
            store.should.exist;
        });

        it("and alias is " + storeAlias, function() {
            storeAlias.should.equal('store.vendorbuffered');
        });
    });

    describe("Check if Customer store", function() {
        store = Ext.create('GeneralLedger.store.BufAccountId');
        var storeAlias = store.alias[0];

        it("is available", function() {
            store.should.exist;
        });

        it("and alias is " + storeAlias, function() {
            storeAlias.should.equal('store.bufAccountid');
        });
    });

    describe("View Model can be instantiated", function() {
        var viewModel = store = Ext.create('Inventory.view.CategoryViewModel');
        viewModel.should.exist;

        describe("with the following stores ", function() {
            it("Line Of Business", function() {
                viewModel.storeInfo.linesOfBusiness.should.exist;
            });
            it("Costing Methods", function() {
                viewModel.storeInfo.costingMethods.should.exist;
            });
            it("Material Fees", function() {
                viewModel.storeInfo.materialFees.should.exist;
            });
            it("Account Descriptions", function() {
                viewModel.storeInfo.accountDescriptions.should.exist;
            });
            it("Inventory Trackings", function() {
                viewModel.storeInfo.inventoryTrackings.should.exist;
            });
            it("Unit of Measures", function() {
                viewModel.storeInfo.unitMeasures.should.exist;
            });
            it("Material Items", function() {
                viewModel.storeInfo.materialItem.should.exist;
            });
            it("Freight Items", function() {
                viewModel.storeInfo.freightItem.should.exist;
            });
            it("GL Accounts", function() {
                viewModel.storeInfo.glAccount.should.exist;
            });
            it("Locations", function() {
                viewModel.storeInfo.location.should.exist;
            });
            it("Vendor Sell Class", function() {
                viewModel.storeInfo.vendorSellClass.should.exist;
            });
            it("Vendor Order Class", function() {
                viewModel.storeInfo.vendorOrderClass.should.exist;
            });
            it("Vendor Family", function() {
                viewModel.storeInfo.vendorFamily.should.exist;
            });
            it("Vendor", function() {
                viewModel.storeInfo.vendor.should.exist;
            });
        });
    });

});