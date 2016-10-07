/**
 * Created by WEstrada on 10/7/2016.
 */
describe('Inventory.view.CategoryViewController', function() {
    var vc;

    beforeEach(function () {
        vc = Ext.create('Inventory.view.CategoryViewController');
    });

    afterEach(function () {
        vc.destroy();
    });

    it('should exist', function() {
        should.exist(vc);
    });

    it('should have a config', function() {
        should.exist(vc.config);

        describe("config", function() {
           it('should have a search config', function () {
               //var searchConfig = vc.config.searchConfig;


           })
        });
    })
});