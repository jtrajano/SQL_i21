/**
 * Created by LZabala on 10/23/2014.
 */
Ext.define('Inventory.model.CountGroup', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intCountGroupId',

    fields: [
        { name: 'intCountGroupId', type: 'int' },
        { name: 'strCountGroup', type: 'string', auditKey: true },
        { name: 'intCountsPerYear', type: 'int' },
        { name: 'ysnIncludeOnHand', type: 'boolean' },
        { name: 'ysnScannedCountEntry', type: 'boolean' },
        { name: 'ysnCountByLots', type: 'boolean' },
        { name: 'ysnCountByPallets', type: 'boolean' },
        { name: 'ysnRecountMismatch', type: 'boolean' },
        { name: 'ysnExternal', type: 'boolean' },
        { name: 'intSort', type: 'int', allowNull: true }
    ],

    validators: [
        {type: 'presence', field: 'strCountGroup'}
    ]
});