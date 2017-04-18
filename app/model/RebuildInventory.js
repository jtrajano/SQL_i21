Ext.define('Inventory.model.RebuildInventory', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intId',

    fields: [
        { name: 'intId', type: 'int' },
        { name: 'dtmDate', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d' },
        { name: 'strPostOrder', type: 'string' },
        { name: 'intItemId', type: 'int', allowNull: true },
        { name: 'intMonth', type: 'int' },
        { name: 'strMonth', type: 'string' },
        { name: 'strItemNo', type: 'string', allowNull: true}
    ],

    validators: [
        { type: 'presence', field: 'dtmDate' },
        { type: 'presence', field: 'strPostOrder' },
        { type: 'presence', field: 'intMonth' }
    ]
});