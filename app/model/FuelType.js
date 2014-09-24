/**
 * Created by marahman on 22-09-2014.
 */
Ext.define('Inventory.model.FuelType', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intFuelTypeId',

    fields: [
        { name: 'intFuelTypeId', type: 'int'},
        { name: 'intRinFuelTypeId', type: 'int'},
        { name: 'intRinFeedStockId', type: 'int'},
        { name: 'intBatchNumber', type: 'int'},
        { name: 'intEndingRinGallons', type: 'int'},
        { name: 'intEquivalenceValue', type: 'int'},
        { name: 'intRinFuelId', type: 'int'},
        { name: 'intRinProcessId', type: 'int'},
        { name: 'intRinFeedStockUOMId', type: 'int'},
        { name: 'dblFeedStockFactor', type: 'float'},
        { name: 'dblPercentDenaturant', type: 'float'},
        { name: 'ysnRenewableBiomass', type: 'boolean'},
        { name: 'ysnDeductDenaturant', type: 'boolean'},

        {name: 'strRinFuelTypeCodeId', type: 'string'},
        {name: 'strRinFeedStockId', type: 'string'},
        {name: 'strRinFuelId', type: 'string'},
        {name: 'strRinProcessId', type: 'string'},
        {name: 'strRinFeedStockUOMId', type: 'string'}
    ],

    validations: [
        {type: 'presence', field: 'intFuelTypeId'}
    ]
});
