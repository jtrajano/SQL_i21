/**
 * Created by LZabala on 11/24/2014.
 */
Ext.define('Inventory.model.Restriction', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intRestrictionId',

    fields: [
        { name: 'intRestrictionId', type: 'int'},
        { name: 'strInternalCode', type: 'string'},
        { name: 'strDisplayMember', type: 'string'},
        { name: 'ysnDefault', type: 'boolean'},
        { name: 'ysnLocked', type: 'boolean'},
        { name: 'strLastUpdateBy', type: 'string'},
        { name: 'dtmLastUpdateOn', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d'},
        { name: 'intSort', type: 'int'}
    ],

    validators: [
        {type: 'presence', field: 'strInternalCode'}
    ]
});