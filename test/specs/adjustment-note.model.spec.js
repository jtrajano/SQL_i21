/**
 * Created by WEstrada on 8/18/2016.
 */

var fields = [
    { name: 'intInventoryAdjustmentNoteId', type: 'int' },
    { name: 'intInventoryAdjustmentId', type: 'int' },
    { name: 'strDescription', type: 'string' },
    { name: 'strNotes', type: 'string' },
    { name: 'intSort', type: 'int' }
];
var references = [
    { name: 'intInventoryAdjustmentId', type: 'Inventory.model.Adjustment', role: 'tblICInventoryAdjustmentNotes' }
];

Inventory.TestUtils.testModel({
    model: 'Inventory.model.AdjustmentNote',
    idProperty: 'intInventoryAdjustmentNoteId',
    fields: fields,
    references: references
});