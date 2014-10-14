/**
 * Created by marahman on 19-09-2014.
 */
Ext.define('Inventory.model.ProcessCode', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intRinProcessId',

    fields: [
        { name: 'intRinProcessId', type: 'int'},
        { name: 'strRinProcessCode', type: 'string'},
        { name: 'strDescription', type: 'string'},
        { name: 'intSort', type: 'int'}
    ],

    validators: [
        {type: 'presence', field: 'strRinProcessCode'}
    ]
});
