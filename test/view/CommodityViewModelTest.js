/**
 * Created by LZabala on 11/13/2014.
 */
describe("Commodity View Model", function() {
    "use strict";

    var store;

    describe("Check if Patronage Category store", function() {
        store = Ext.create('Inventory.store.BufferedPatronageCategory');
        var storeAlias = store.alias[0];

        it("is available", function() {
            store.should.exist;
        });

        it("and alias is " + storeAlias, function() {
            storeAlias.should.equal('store.inventorybufferedpatronagecategory');
        });
    });

    describe("Check if Unit of Measure store", function() {
        store = Ext.create('Inventory.store.BufferedUnitMeasure');
        var storeAlias = store.alias[0];

        it("is available", function() {
            store.should.exist;
        });

        it("and alias is " + storeAlias, function() {
            storeAlias.should.equal('store.inventorybuffereduom');
        });
    });

    describe("Check if Storage Type store", function() {
        store = Ext.create('Inventory.store.BufferedStorageType');
        var storeAlias = store.alias[0];

        it("is available", function() {
            store.should.exist;
        });

        it("and alias is " + storeAlias, function() {
            storeAlias.should.equal('store.inventorybufferedstoragetype');
        });
    });

    describe("Check if GL Account store", function() {
        store = Ext.create('GeneralLedger.store.BufAccountId');
        var storeAlias = store.alias[0];

        it("is available", function() {
            store.should.exist;
        });

        it("and alias is " + storeAlias, function() {
            storeAlias.should.equal('store.bufAccountid');
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

    describe("View Model can be instantiated", function() {
        var viewModel = store = Ext.create('Inventory.view.CommodityViewModel');
        viewModel.should.exist;

        describe("with the following stores ", function() {
            it("States", function() {
                viewModel.storeInfo.states.should.exist;
            });
            it("Account Description", function() {
                viewModel.storeInfo.accountDescriptions.should.exist;
            });
            it("Patronage Category", function() {
                viewModel.storeInfo.patronageCategory.should.exist;
            });
            it("Direct Patronage Category", function() {
                viewModel.storeInfo.directPatronageCategory.should.exist;
            });
            it("Unit of Measure", function() {
                viewModel.storeInfo.unitMeasure.should.exist;
            });
            it("GL Account", function() {
                viewModel.storeInfo.glAccount.should.exist;
            });
            it("Location", function() {
                viewModel.storeInfo.location.should.exist;
            });
            it("Auto Scale Dist", function() {
                viewModel.storeInfo.autoScaleDist.should.exist;
            });
        });
    });

});