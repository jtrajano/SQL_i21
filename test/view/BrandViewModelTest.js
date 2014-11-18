/**
 * Created by LZabala on 11/13/2014.
 */
describe("Brand View Model", function() {
    "use strict";

    var store;

    describe("Check if Manufacturer store", function() {
        store = Ext.create('Inventory.store.BufferedManufacturer');
        var storeAlias = store.alias[0];

        it("is available", function() {
            store.should.exist;
        });

        it("and alias is " + storeAlias, function() {
            storeAlias.should.equal('store.inventorybufferedmanufacturer');
        });
    });

    describe("View Model can be instantiated", function() {
        var viewModel = store = Ext.create('Inventory.view.BrandViewModel');
        viewModel.should.exist;

        describe("with the following stores ", function() {
            it("Manufacturer", function() {
                viewModel.storeInfo.manufacturer.should.exist;
            });
        });
    });

});