/**
 * Created by LZabala on 9/11/2014.
 */
Ext.define('Inventory.model.Item', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemId',

    fields: [
        { name: 'intItemId', type: 'int'},
        { name: 'strItemNo', type: 'string'},
        { name: 'strType', type: 'string'},
        { name: 'strDescription', type: 'string'},
        { name: 'intManufacturerId', type: 'int'},
        { name: 'intBrandId', type: 'int'},
        { name: 'strStatus', type: 'string'},
        { name: 'strModelNo', type: 'string'},
        { name: 'intTrackingId', type: 'int'},
        { name: 'strLotTracking', type: 'string'}
    ],

//    hasMany: {
//        model: 'GlobalComponentEngine.model.CustomFieldDetail',
//        name: 'tblSMCustomFieldDetails',
//        foreignKey: 'intCustomFieldId',
//        primaryKey: 'intCustomFieldId',
//        storeConfig: {
//            sortOnLoad: true,
//            sorters: {
//                direction: 'ASC',
//                property: 'intSort'
//            }
//        }
//    },

    validations: [
        {type: 'presence', field: 'strItemNo'}
    ]
});