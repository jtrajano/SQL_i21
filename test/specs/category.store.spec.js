/**
 * Created by WEstrada on 10/7/2016.
 */
describe("Inventory.store.Category", function () {
    var store = Ext.create('Inventory.store.Category');
    it('should exist', function () {
        should.exist(store);
    });
    it('should load data', function() {
        store.load();
    })
});