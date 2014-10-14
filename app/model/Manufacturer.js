/**
 * Created by kkarthick on 17-09-2014.
 */
Ext.define('Inventory.model.Manufacturer', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intManufacturerId',

    fields: [
        { name: 'intManufacturerId', type: 'int'},
        { name: 'strManufacturer', type: 'string'},
        { name: 'strContact', type: 'string'},
        { name: 'strAddress', type: 'string'},
        { name: 'strZipCode ', type: 'string'},
        { name: 'strCity', type: 'string'},
        { name: 'strState', type: 'string'},
        { name: 'strCountry', type: 'string'},
        { name: 'strPhone', type: 'string'},
        { name: 'strFax', type: 'string'},
        { name: 'strWebsite', type: 'string'},
        { name: 'strEmail', type: 'string'},
        { name: 'strNotes', type: 'string'}
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

    validators: [
        {type: 'presence', field: 'strManufacturer'}
    ]
});