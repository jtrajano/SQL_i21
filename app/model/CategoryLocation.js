/**
 * Created by LZabala on 11/3/2014.
 */
Ext.define('Inventory.model.CategoryLocation', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intCategoryLocationId',

    fields: [
        { name: 'intCategoryLocationId', type: 'int'},
        { name: 'intCategoryId', type: 'int',
            reference: {
                type: 'Inventory.model.Category',
                inverse: {
                    role: 'tblICCategoryLocations',
                    storeConfig: {
                        complete: true,
                        remoteFilter: true,                        
                        proxy: {
                            extraParams: { include: 'tblSMCompanyLocation' },
                            type: 'rest',
                            api: {
                                read: './inventory/api/categorylocation/get'
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
            }},
        { name: 'intLocationId', type: 'int' },
        { name: 'intRegisterDepartmentId', type: 'int', allowNull: true },
        { name: 'ysnUpdatePrices', type: 'boolean' },
        { name: 'ysnUseTaxFlag1', type: 'boolean' },
        { name: 'ysnUseTaxFlag2', type: 'boolean' },
        { name: 'ysnUseTaxFlag3', type: 'boolean' },
        { name: 'ysnUseTaxFlag4', type: 'boolean' },
        { name: 'ysnBlueLaw1', type: 'boolean' },
        { name: 'ysnBlueLaw2', type: 'boolean' },
        { name: 'intNucleusGroupId', type: 'int', allowNull: true },
        { name: 'dblTargetGrossProfit', type: 'float' },
        { name: 'dblTargetInventoryCost', type: 'float' },
        { name: 'dblCostInventoryBOM', type: 'float' },
        { name: 'dblLowGrossMarginAlert', type: 'float' },
        { name: 'dblHighGrossMarginAlert', type: 'float' },
        { name: 'dtmLastInventoryLevelEntry', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d' },
        { name: 'ysnNonRetailUseDepartment', type: 'boolean' },
        { name: 'ysnReportNetGross', type: 'boolean' },
        { name: 'ysnDepartmentForPumps', type: 'boolean' },
        { name: 'intConvertPaidOutId', type: 'int', allowNull: true },
        { name: 'ysnDeleteFromRegister', type: 'boolean' },
        { name: 'ysnDeptKeyTaxed', type: 'boolean' },
        { name: 'intProductCodeId', type: 'int', allowNull: true },
        { name: 'intFamilyId', type: 'int', allowNull: true },
        { name: 'intClassId', type: 'int', allowNull: true },
        { name: 'ysnFoodStampable', type: 'boolean' },
        { name: 'ysnReturnable', type: 'boolean' },
        { name: 'ysnSaleable', type: 'boolean' },
        { name: 'ysnPrePriced', type: 'boolean' },
        { name: 'ysnIdRequiredLiquor', type: 'boolean' },
        { name: 'ysnIdRequiredCigarette', type: 'boolean' },
        { name: 'intMinimumAge', type: 'int', allowNull: true },
        { name: 'intSort', type: 'int', allowNull: true },
        { name: 'strLocationName', type: 'string', auditKey: true},
        { name: 'intCompanyLocationId', type: 'int', allowNull: true },
        { name: 'strProductCodeId', type: 'string'},
        { name: 'strFamilyId', type: 'string'},
        { name: 'strClassId', type: 'string'}
    ],

    validators: [
        {type: 'presence', field: 'intLocationId'}
    ]
});