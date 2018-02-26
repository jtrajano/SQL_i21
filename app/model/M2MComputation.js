Ext.define('Inventory.model.M2MComputation', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intM2MComputationId',
    
    fields: [
        { name: 'intM2MComputationId', type: 'int' },
        { name: 'strM2MComputationId', type: 'string', auditKey: true }
    ]
});