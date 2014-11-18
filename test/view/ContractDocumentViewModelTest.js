/**
 * Created by LZabala on 11/13/2014.
 */
describe("Contract Document View Model", function() {
    "use strict";

    var store;

    describe("Check if Commodity store", function() {
        store = Ext.create('Inventory.store.BufferedCommodity');
        var storeAlias = store.alias[0];

        it("is available", function() {
            store.should.exist;
        });

        it("and alias is " + storeAlias, function() {
            storeAlias.should.equal('store.inventorybufferedcommodity');
        });
    });

    describe("View Model can be instantiated", function() {
        var viewModel = store = Ext.create('Inventory.view.ContractDocumentViewModel');
        viewModel.should.exist;

        describe("with the following stores ", function() {
            it("Commodity", function() {
                viewModel.storeInfo.commodity.should.exist;
            });
        });
    });

});