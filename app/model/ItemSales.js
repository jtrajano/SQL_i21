/**
 * Created by LZabala on 9/24/2014.
 */
Ext.define('Inventory.model.ItemSales', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemId',

    fields: [
        { name: 'intItemId', type: 'int'},
        { name: 'intPatronageCategoryId', type: 'int'},
        { name: 'intTaxClassId', type: 'int'},
        { name: 'ysnStockedItem', type: 'boolean'},
        { name: 'ysnDyedFuel', type: 'boolean'},
        { name: 'strBarcodePrint', type: 'string'},
        { name: 'ysnMSDSRequired', type: 'boolean'},
        { name: 'strEPANumber', type: 'string'},
        { name: 'ysnInboundTax', type: 'boolean'},
        { name: 'ysnOutboundTax', type: 'boolean'},
        { name: 'ysnRestrictedChemical', type: 'boolean'},
        { name: 'ysnTankRequired', type: 'boolean'},
        { name: 'ysnAvailableTM', type: 'boolean'},
        { name: 'dblDefaultFull', type: 'float'},
        { name: 'strFuelInspectFee', type: 'string'},
        { name: 'strRINRequired', type: 'string'},
        { name: 'intRINFuelTypeId', type: 'int'},
        { name: 'dblDenaturantPercent', type: 'float'},
        { name: 'ysnTonnageTax', type: 'boolean'},
        { name: 'ysnLoadTracking', type: 'boolean'},
        { name: 'dblMixOrder', type: 'float'},
        { name: 'ysnHandAddIngredient', type: 'boolean'},
        { name: 'intMedicationTag', type: 'int'},
        { name: 'intIngredientTag', type: 'int'},
        { name: 'strVolumeRebateGroup', type: 'string'},
        { name: 'intPhysicalItem', type: 'int'},
        { name: 'ysnExtendPickTicket', type: 'boolean'},
        { name: 'ysnExportEDI', type: 'boolean'},
        { name: 'ysnHazardMaterial', type: 'boolean'},
        { name: 'ysnMaterialFee', type: 'boolean'},
        { name: 'intConcurrencyId', type: 'int'},
    ]
});