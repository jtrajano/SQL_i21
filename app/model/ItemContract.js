/**
 * Created by LZabala on 9/29/2014.
 */
Ext.define('Inventory.model.ItemContract', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Inventory.model.ItemContractDocument',
        'Ext.data.Field'
    ],

    idProperty: 'intItemContractId',

    fields: [
        { name: 'intItemContractId', type: 'int'},
        { name: 'intItemId', type: 'int'},
        { name: 'intLocationId', type: 'int'},
        { name: 'strStoreName', type: 'string'},
        { name: 'strContractItemName', type: 'string'},
        { name: 'intCountryId', type: 'int'},
        { name: 'strGrade', type: 'string'},
        { name: 'strGradeType', type: 'string'},
        { name: 'strGarden', type: 'string'},
        { name: 'dblYieldPercent', type: 'float'},
        { name: 'dblTolerancePercent', type: 'float'},
        { name: 'dblFranchisePercent', type: 'float'},
        { name: 'intSort', type: 'int'},

        { name: 'strLocationName', type: 'string'},
        { name: 'strCountry', type: 'string'}
    ],

    hasMany: {
        model: 'Inventory.model.ItemContractDocument',
        name: 'tblICItemContractDocuments',
        foreignKey: 'intItemContractId',
        primaryKey: 'intItemContractId',
        storeConfig: {
            sortOnLoad: true,
            sorters: {
                direction: 'ASC',
                property: 'intSort'
            }
        }
    }
});