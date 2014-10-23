/**
 * Created by LZabala on 10/23/2014.
 */
Ext.define('Inventory.model.MaterialNMFC', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intMaterialNMFCId',

    fields: [
        { name: 'intMaterialNMFCId', type: 'int'},
        { name: 'intExternalSystemId', type: 'int'},
        { name: 'strInternalCode', type: 'string'},
        { name: 'strDisplayMember', type: 'string'},
        { name: 'ysnDefault', type: 'boolean'},
        { name: 'ysnLocked', type: 'boolean'},
        { name: 'strLastUpdateBy', type: 'string'},
        { name: 'dtmLastUpdateOn', type: 'date'},
        { name: 'intSort', type: 'int'}
    ]
});