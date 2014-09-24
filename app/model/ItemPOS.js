/**
 * Created by LZabala on 9/24/2014.
 */
Ext.define('Inventory.model.ItemPOS', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Inventory.model.ItemPOSCategory',
        'Inventory.model.ItemPOSSLA',
        'Ext.data.Field'
    ],

    idProperty: 'intItemId',

    fields: [
        { name: 'intItemId', type: 'int'},
        { name: 'strUPCNo', type: 'string'},
        { name: 'intCaseUOM', type: 'int'},
        { name: 'strNACSCategory', type: 'string'},
        { name: 'strWICCode', type: 'string'},
        { name: 'intAGCategory', type: 'int'},
        { name: 'ysnReceiptCommentRequired', type: 'boolean'},
        { name: 'strCountCode', type: 'string'},
        { name: 'ysnLandedCost', type: 'boolean'},
        { name: 'strLeadTime', type: 'string'},
        { name: 'ysnTaxable', type: 'boolean'},
        { name: 'strKeywords', type: 'string'},
        { name: 'dblCaseQty', type: 'float'},
        { name: 'dtmDateShip', type: 'date'},
        { name: 'dblTaxExempt', type: 'float'},
        { name: 'ysnDropShip', type: 'boolean'},
        { name: 'ysnCommisionable', type: 'boolean'},
        { name: 'strSpecialCommission', type: 'string'},
    ],

    hasMany: {
        model: 'Inventory.model.ItemPOSCategory',
        name: 'tblICItemPOSCategories',
        foreignKey: 'intItemId',
        primaryKey: 'intItemId',
        storeConfig: {
            sortOnLoad: true,
            sorters: {
                direction: 'ASC',
                property: 'intSort'
            }
        }
    },

    hasMany: {
        model: 'Inventory.model.ItemPOSSLA',
        name: 'tblICItemPOSSLAs',
        foreignKey: 'intItemId',
        primaryKey: 'intItemId',
        storeConfig: {
            sortOnLoad: true,
            sorters: {
                direction: 'ASC',
                property: 'intSort'
            }
        }
    }
});