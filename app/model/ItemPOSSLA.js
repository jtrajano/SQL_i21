/**
 * Created by LZabala on 9/24/2014.
 */
Ext.define('Inventory.model.ItemPOSSLA', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemPOSSLAId',

    fields: [
        { name: 'intItemPOSSLAId', type: 'int'},
        { name: 'intItemPOSId', type: 'int'},
        { name: 'strSLAContract', type: 'string'},
        { name: 'dblContractPrice', type: 'float'},
        { name: 'ysnServiceWarranty', type: 'boolean'}
    ]
});