/**
 * Created by LZabala on 11/13/2014.
 */
describe("Category Location View Model", function() {
    "use strict";

    var store;

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

    describe("Check if Paid Out store", function() {
        store = Ext.create('Inventory.store.PaidOut');
        var storeAlias = store.alias[0];

        it("is available", function() {
            store.should.exist;
        });

        it("and alias is " + storeAlias, function() {
            storeAlias.should.equal('store.storepaidout');
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

    describe("Check if Product store", function() {
        store = Ext.create('Inventory.store.Product');
        var storeAlias = store.alias[0];

        it("is available", function() {
            store.should.exist;
        });

        it("and alias is " + storeAlias, function() {
            storeAlias.should.equal('store.storeproduct');
        });
    });

    describe("View Model can be instantiated", function() {
        var viewModel = store = Ext.create('Inventory.view.CategoryLocationViewModel');
        viewModel.should.exist;

        describe("with the following stores ", function() {
            it("Location", function() {
                viewModel.storeInfo.location.should.exist;
            });
            it("Paid Out", function() {
                viewModel.storeInfo.paidout.should.exist;
            });
            it("Class", function() {
                viewModel.storeInfo.class.should.exist;
            });
            it("Family", function() {
                viewModel.storeInfo.family.should.exist;
            });
            it("Product Code", function() {
                viewModel.storeInfo.product.should.exist;
            });
        });
    });

});