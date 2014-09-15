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
        { name: 'intItemTypeId', type: 'int'},
        { name: 'intVendorId', type: 'int'},
        { name: 'strDescription', type: 'string'},
        { name: 'strPOSDescription', type: 'string'},
        { name: 'intClassId', type: 'int'},
        { name: 'intManufacturerId', type: 'int'},
        { name: 'intBrandId', type: 'int'},
        { name: 'intStatusId', type: 'int'},
        { name: 'strModelNo', type: 'string'},
        { name: 'intCostingMethodId', type: 'int'},
        { name: 'intCategoryId', type: 'int'},
        { name: 'intPatronageId', type: 'int'},
        { name: 'intTaxClassId', type: 'int'},
        { name: 'ysnStockedItem', type: 'boolean'},
        { name: 'ysnDyedFuel', type: 'boolean'},
        { name: 'strBarCodeIndicator', type: 'string'},
        { name: 'ysnMSDSRequired', type: 'boolean'},
        { name: 'strEPANumber', type: 'string'},
        { name: 'ysnInboundTax', type: 'boolean'},
        { name: 'ysnOutboundTax', type: 'boolean'},
        { name: 'ysnRestrictedChemical', type: 'boolean'},
        { name: 'ysnTMTankRequired', type: 'boolean'},
        { name: 'ysnTMAvailable', type: 'boolean'},
        { name: 'dblTMPercentFull', type: 'double'},
        { name: 'strRINFuelInspectFee', type: 'string'},
        { name: 'strRINRequired', type: 'string'},
        { name: 'intRINFuelType', type: 'int'},
        { name: 'dblRINDenaturantPercentage', type: 'double'},
        { name: 'ysnFeedTonnageTax', type: 'boolean'},
        { name: 'strFeedLotTracking', type: 'string'},
        { name: 'ysnFeedLoadTracking', type: 'boolean'},
        { name: 'intFeedMixOrder', type: 'int'},
        { name: 'ysnFeedHandAddIngredients', type: 'boolean'},
        { name: 'intFeedMedicationTag', type: 'int'},
        { name: 'intFeedIngredientTag', type: 'int'},
        { name: 'strFeedRebateGroup', type: 'string'},
        { name: 'intPhysicalItem', type: 'int'},
        { name: 'ysnExtendOnPickTicket', type: 'boolean'},
        { name: 'ysnExportEDI', type: 'boolean'},
        { name: 'ysnHazardMaterial', type: 'boolean'},
        { name: 'ysnMaterialFee', type: 'boolean'},
        { name: 'ysnAutoCalculateFreight', type: 'boolean'},
        { name: 'intFreightMethodId', type: 'int'},
        { name: 'dblFreightRate', type: 'double'},
        { name: 'intFreightVendorId', type: 'int'}
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