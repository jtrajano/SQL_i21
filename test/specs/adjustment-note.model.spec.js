/**
 * Created by WEstrada on 8/18/2016.
 */
describe('Adjustment Note Model', function() {
    var model = Ext.create('Inventory.model.AdjustmentNote');

    it('should exists', function() {
        should.exist(model, "Adjustment Note model is not initialized.");
    });

    it('should have idProperty', function() {
        model.should.have.property('idProperty');
        model.idProperty.should.equal('intInventoryAdjustmentNoteId');
    });

    it('should have fields', function() {
        model.should.have.property('fields');
        describe('Adjustment Note Model Fields', function() {
            var fields = model.fields;
            should.exist(fields, 'No fields');
            it('should have the following fields', function() {
                _.isEmpty(fields).should.be.false;

                should.exist(_.findWhere(fields, {name: 'intInventoryAdjustmentNoteId', type: 'int'}), 'intInventoryAdjustmentNoteId does not exists');
                should.exist(_.findWhere(fields, {name: 'intInventoryAdjustmentId', type: 'int'}), 'intInventoryAdjustmentqId does not exists');
                should.exist(_.findWhere(fields, {name: 'strDescription', type: 'string'}), 'strDescription does not exists');
                should.exist(_.findWhere(fields, {name: 'strNotes', type: 'string'}), 'strNotes does not exists');
                should.exist(_.findWhere(fields, {name: 'intSort', type: 'int'}), 'intSort does not exists');
            });
        });
    });
});