/**
 * Created by WEstrada on 8/18/2016.
 */
describe('adjustment model', function() {
    it('should exists', function() {
        var c = Ext.create('Inventory.store.Brand');
        var store = Ext.create('i21.store.CompanyLocationBuffered');
        var model = Ext.create('i21.model.CompanyLocation');
        should.exist(c, "Adjustment model is not initialized");
    });
});