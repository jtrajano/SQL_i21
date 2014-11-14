/**
 * Created by LZabala on 11/14/2014.
 */
Ext.define('Inventory.model.PromotionSalesList', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intPromoSalesListId',

    fields: [
        { name: 'intPromoSalesListId', type: 'int'},
        { name: 'strPromoType', type: 'boolean'},
        { name: 'strDescription', type: 'boolean'},
        { name: 'intPromoCode', type: 'int'},
        { name: 'intPromoUnits', type: 'int'},
        { name: 'dblPromoPrice', type: 'float'}
    ]
});