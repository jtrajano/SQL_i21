/**
 * Created by LZabala on 9/29/2014.
 */
Ext.define('Inventory.model.ItemCertification', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemCertificationId',

    fields: [
        { name: 'intItemCertificationId', type: 'int'},
        { name: 'intItemId', type: 'int'},
        { name: 'intCertificationId', type: 'int'},
        { name: 'intSort', type: 'int'}
    ]
});