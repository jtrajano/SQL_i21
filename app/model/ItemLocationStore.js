/**
 * Created by LZabala on 9/18/2014.
 */
Ext.define('Inventory.model.ItemLocationStore', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemLocationStoreId',

    fields: [
        { name: 'intItemLocationStoreId', type: 'int'},
        { name: 'intItemId', type: 'int'},
        { name: 'intLocationId', type: 'int'},
        { name: 'intStoreId', type: 'int'},
        { name: 'intVendorId', type: 'int'},
        { name: 'strPOSDescription', type: 'string'},
        { name: 'strCostingMethod', type: 'string'},
        { name: 'intCategoryId', type: 'int'},
        { name: 'strRow', type: 'string'},
        { name: 'strBin', type: 'string'},
        { name: 'intDefaultUOMId', type: 'int'},
        { name: 'intIssueUOMId', type: 'int'},
        { name: 'intReceiveUOMId', type: 'int'},
        { name: 'intFamilyId', type: 'int'},
        { name: 'intClassId', type: 'int'},
        { name: 'intFuelTankId', type: 'int'},
        { name: 'strPassportFuelId1', type: 'string'},
        { name: 'strPassportFuelId2', type: 'string'},
        { name: 'strPassportFuelId3', type: 'string'},
        { name: 'ysnTaxFlag1', type: 'boolean'},
        { name: 'ysnTaxFlag2', type: 'boolean'},
        { name: 'ysnTaxFlag3', type: 'boolean'},
        { name: 'ysnTaxFlag4', type: 'boolean'},
        { name: 'ysnPromotionalItem', type: 'boolean'},
        { name: 'intMixMatchId', type: 'int'},
        { name: 'ysnDepositRequired', type: 'boolean'},
        { name: 'intBottleDepositNo', type: 'int'},
        { name: 'ysnSaleable', type: 'boolean'},
        { name: 'ysnQuantityRequired', type: 'boolean'},
        { name: 'ysnScaleItem', type: 'boolean'},
        { name: 'ysnFoodStampable', type: 'boolean'},
        { name: 'ysnReturnable', type: 'boolean'},
        { name: 'ysnPrePriced', type: 'boolean'},
        { name: 'ysnOpenPricePLU', type: 'boolean'},
        { name: 'ysnLinkedItem', type: 'boolean'},
        { name: 'strVendorCategory', type: 'string'},
        { name: 'ysnCountBySINo', type: 'boolean'},
        { name: 'strSerialNoBegin', type: 'string'},
        { name: 'strSerialNoEnd', type: 'string'},
        { name: 'ysnIdRequiredLiquor', type: 'boolean'},
        { name: 'ysnIdRequiredCigarette', type: 'boolean'},
        { name: 'intMinimumAge', type: 'int'},
        { name: 'ysnApplyBlueLaw1', type: 'boolean'},
        { name: 'ysnApplyBlueLaw2', type: 'boolean'},
        { name: 'intItemTypeCode', type: 'int'},
        { name: 'intItemTypeSubCode', type: 'int'},
        { name: 'ysnAutoCalculateFreight', type: 'boolean'},
        { name: 'intFreightMethodId', type: 'int'},
        { name: 'dblFreightRate', type: 'float'},
        { name: 'intFreightVendorId', type: 'int'}
    ]
});