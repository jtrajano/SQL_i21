Ext.define('Inventory.model.RepostInventory', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intId',

    fields: [
        { name: 'intId', type: 'int' },
        { name: 'dtmDate', type: 'date' },
        { name: 'strPostOrder', type: 'string' },
        { name: 'intItemId', type: 'int', allowNull: true },
        { name: 'intMonth', type: 'int' },
        { name: 'strMonth', type: 'string' }
    ],

    validators: [
        { type: 'presence', field: 'dtmDate' },
        { type: 'presence', field: 'strPostOrder' },
        { type: 'presence', field: 'intMonth' }
    ]
});