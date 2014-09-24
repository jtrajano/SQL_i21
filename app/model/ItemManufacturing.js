/**
 * Created by LZabala on 9/24/2014.
 */
Ext.define('Inventory.model.ItemManufacturing', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Inventory.model.ItemManufacturingUOM',
        'Ext.data.Field'
    ],

    idProperty: 'intItemId',

    fields: [
        { name: 'intItemId', type: 'int'},
        { name: 'ysnRequireCustomerApproval', type: 'boolean'},
        { name: 'intRecipeId', type: 'int'},
        { name: 'ysnSanitationRequired', type: 'boolean'},
        { name: 'intLifeTime', type: 'int'},
        { name: 'strLifeTimeType', type: 'string'},
        { name: 'intReceiveLife', type: 'int'},
        { name: 'strGTIN', type: 'string'},
        { name: 'strRotationType', type: 'string'},
        { name: 'intNMFCId', type: 'int'},
        { name: 'ysnStrictFIFO', type: 'boolean'},
        { name: 'intDimensionUOMId', type: 'int'},
        { name: 'dblHeight', type: 'float'},
        { name: 'dblWidth', type: 'float'},
        { name: 'dblDepth', type: 'float'},
        { name: 'intWeightUOMId', type: 'int'},
        { name: 'dblWeight', type: 'float'},
        { name: 'strMaterialSizeCode', type: 'string'},
        { name: 'intInnerUnits', type: 'int'},
        { name: 'intLayerPerPallet', type: 'int'},
        { name: 'intUnitPerLayer', type: 'int'},
        { name: 'dblStandardPalletRatio', type: 'float'},
        { name: 'strMask1', type: 'string'},
        { name: 'strMask2', type: 'string'},
        { name: 'strMask3', type: 'string'}
    ],

    hasMany: {
        model: 'Inventory.model.ItemManufacturingUOM',
        name: 'tblICItemManufacturingUOMs',
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