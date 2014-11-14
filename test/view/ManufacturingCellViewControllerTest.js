/**
 * Created by LZabala on 10/8/2014.
 */
describe("Manufacturing Cell View Controller", function() {
    "use strict";

    var controller;
    var view;

    beforeEach(function() {
        view = Ext.create('Inventory.view.ManufacturingCell', { controller : 'manufacturingcell' });
        controller = view.getController();
    });

    afterEach(function() {
        controller = null;
        view = null;
    });

    it("can be instantiated", function() {
        view.should.exist;
    });

    it("View Controller exists", function() {
        controller.should.exist;
    });

    describe("Standard Methods", function(){
        it("has a show function", function() {
            controller.show.should.exist;
        });
        it("has a setupContext function", function() {
            controller.setupContext.should.exist;
        });
        it("has a config property", function() {
            controller.config.should.exist;
        });


    });

});