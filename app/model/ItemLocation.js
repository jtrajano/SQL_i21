/**
 * Created by LZabala on 9/18/2014.
 */
Ext.define('Inventory.model.ItemLocation', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemLocationId',

    fields: [
        { name: 'intItemLocationId', type: 'int'},
        { name: 'intItemId', type: 'int',
            reference: {
                type: 'Inventory.model.Item',
                inverse: {
                    role: 'tblICItemLocations',
                    storeConfig: {
                        complete: true,
                        remoteFilter: true,
                        proxy: {
                            type: 'rest',
                            api: {
                                read: '../Inventory/api/ItemLocation/GetItemLocations'
                            },
                            reader: {
                                type: 'json',
                                rootProperty: 'data',
                                messageProperty: 'message'
                            }
                        },
                        sortOnLoad: true,
                        sorters: {
                            direction: 'DESC',
                            property: 'intSort'
                        }
                    }
                }
            }
        },
        { name: 'intLocationId', type: 'int', allowNull: true},
        { name: 'intVendorId', type: 'int', allowNull: true},
        { name: 'strDescription', type: 'string'},
        { name: 'intCostingMethod', type: 'int', allowNull: true },
        { name: 'intCategoryId', type: 'int', allowNull: true},
        { name: 'strRow', type: 'string'},
        { name: 'strBin', type: 'string'},
        { name: 'intDefaultUOMId', type: 'int', allowNull: true},
        { name: 'intIssueUOMId', type: 'int', allowNull: true},
        { name: 'intReceiveUOMId', type: 'int', allowNull: true},
        { name: 'intFamilyId', type: 'int', allowNull: true},
        { name: 'intClassId', type: 'int', allowNull: true},
        { name: 'intProductCodeId', type: 'int', allowNull: true},
        { name: 'strPassportFuelId1', type: 'string'},
        { name: 'strPassportFuelId2', type: 'string'},
        { name: 'strPassportFuelId3', type: 'string'},
        { name: 'ysnTaxFlag1', type: 'boolean'},
        { name: 'ysnTaxFlag2', type: 'boolean'},
        { name: 'ysnTaxFlag3', type: 'boolean'},
        { name: 'ysnTaxFlag4', type: 'boolean'},
        { name: 'ysnPromotionalItem', type: 'boolean'},
        { name: 'intMixMatchId', type: 'int', allowNull: true},
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
        { name: 'intItemTypeCode', type: 'int', allowNull: true},
        { name: 'intItemTypeSubCode', type: 'int', allowNull: true},
        { name: 'ysnAutoCalculateFreight', type: 'boolean'},
        { name: 'intFreightMethodId', type: 'int', allowNull: true},
        { name: 'dblFreightRate', type: 'float'},
        { name: 'intFreightVendorId', type: 'int', allowNull: true},
        { name: 'intNegativeInventory', type: 'int', allowNull: true},
        { name: 'dblReorderPoint', type: 'float'},
        { name: 'dblMinOrder', type: 'float'},
        { name: 'dblSuggestedQty', type: 'float'},
        { name: 'dblLeadTime', type: 'float'},
        { name: 'strCounted', type: 'string'},
        { name: 'intCountGroupId', type: 'int', allowNull: true},
        { name: 'ysnCountedDaily', type: 'boolean'},
        { name: 'intSort', type: 'int'},

        { name: 'strLocationName', type: 'string'},
        { name: 'strVendorId', type: 'string'},
        { name: 'strCategory', type: 'string'},
        { name: 'strUnitMeasure', type: 'string'}
    ],

    validators: [
        {type: 'presence', field: 'intLocationId'}
    ]
});