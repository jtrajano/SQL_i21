/**
 * Created by WEstrada on 10/6/2016.
 */
var fields = [
    { name: 'intInventoryAdjustmentId', type: 'int' },
    { name: 'intLocationId', type: 'int', allowNull: true },
    { name: 'dtmAdjustmentDate', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d' },
    { name: 'intAdjustmentType', type: 'int', allowNull: true },
    { name: 'strAdjustmentNo', type: 'string' },
    { name: 'strDescription', type: 'string' },
    { name: 'ysnPosted', type: 'boolean'},
    { name: 'intSort', type: 'int', allowNull: true }
];

Inventory.TestUtils.testModel({
    model: 'Inventory.model.Adjustment',
    idProperty: 'intInventoryAdjustmentId',
    checkFields: true,
    fields: fields
});