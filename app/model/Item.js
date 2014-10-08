/**
 * Created by LZabala on 9/11/2014.
 */
Ext.define('Inventory.model.Item', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Inventory.model.ItemUOM',
        'Inventory.model.ItemLocationStore',
        'Inventory.model.ItemUPC',
        'Inventory.model.ItemVendorXref',
        'Inventory.model.ItemCustomerXref',
        'Inventory.model.ItemContract',
        'Inventory.model.ItemCertification',
        'Inventory.model.ItemPOSSLA',
        'Inventory.model.ItemPOSCategory',
        'Inventory.model.ItemManufacturingUOM',
        'Ext.data.Field'
    ],

    idProperty: 'intItemId',

    fields: [
        { name: 'intItemId', type: 'int'},
        { name: 'strItemNo', type: 'string'},
        { name: 'strType', type: 'string'},
        { name: 'strDescription', type: 'string'},
        { name: 'intManufacturerId', type: 'int', allowNull: true},
        { name: 'intBrandId', type: 'int', allowNull: true},
        { name: 'strStatus', type: 'string'},
        { name: 'strModelNo', type: 'string'},
        { name: 'intTrackingId', type: 'int', allowNull: true},
        { name: 'strLotTracking', type: 'string'},
        { name: 'ysnRequireCustomerApproval', type: 'boolean'},
        { name: 'intRecipeId', type: 'int', allowNull: true},
        { name: 'ysnSanitationRequired', type: 'boolean'},
        { name: 'intLifeTime', type: 'int'},
        { name: 'strLifeTimeType', type: 'string'},
        { name: 'intReceiveLife', type: 'int'},
        { name: 'strGTIN', type: 'string'},
        { name: 'strRotationType', type: 'string'},
        { name: 'intNMFCId', type: 'int', allowNull: true},
        { name: 'ysnStrictFIFO', type: 'boolean'},
        { name: 'intDimensionUOMId', type: 'int', allowNull: true},
        { name: 'dblHeight', type: 'float'},
        { name: 'dblWidth', type: 'float'},
        { name: 'dblDepth', type: 'float'},
        { name: 'intWeightUOMId', type: 'int', allowNull: true},
        { name: 'dblWeight', type: 'float'},
        { name: 'intMaterialPackTypeId', type: 'int', allowNull: true},
        { name: 'strMaterialSizeCode', type: 'string'},
        { name: 'intInnerUnits', type: 'int'},
        { name: 'intLayerPerPallet', type: 'int'},
        { name: 'intUnitPerLayer', type: 'int'},
        { name: 'dblStandardPalletRatio', type: 'float'},
        { name: 'strMask1', type: 'string'},
        { name: 'strMask2', type: 'string'},
        { name: 'strMask3', type: 'string'},
        { name: 'intPatronageCategoryId', type: 'int', allowNull: true},
        { name: 'intTaxClassId', type: 'int', allowNull: true},
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
        { name: 'intRINFuelTypeId', type: 'int', allowNull: true},
        { name: 'dblDenaturantPercent', type: 'float'},
        { name: 'ysnTonnageTax', type: 'boolean'},
        { name: 'ysnLoadTracking', type: 'boolean'},
        { name: 'dblMixOrder', type: 'float'},
        { name: 'ysnHandAddIngredient', type: 'boolean'},
        { name: 'intMedicationTag', type: 'int', allowNull: true},
        { name: 'intIngredientTag', type: 'int', allowNull: true},
        { name: 'strVolumeRebateGroup', type: 'string'},
        { name: 'intPhysicalItem', type: 'int', allowNull: true},
        { name: 'ysnExtendPickTicket', type: 'boolean'},
        { name: 'ysnExportEDI', type: 'boolean'},
        { name: 'ysnHazardMaterial', type: 'boolean'},
        { name: 'ysnMaterialFee', type: 'boolean'},
        { name: 'strUPCNo', type: 'string'},
        { name: 'intCaseUOM', type: 'int', allowNull: true},
        { name: 'strNACSCategory', type: 'string'},
        { name: 'strWICCode', type: 'string'},
        { name: 'intAGCategory', type: 'int', allowNull: true},
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
        { name: 'strSpecialCommission', type: 'string'}
    ],

    hasMany: [{
            model: 'Inventory.model.ItemUOM',
            name: 'tblICItemUOMs',
            foreignKey: 'intItemId',
            primaryKey: 'intItemId',
            storeConfig: {
                sortOnLoad: true,
                sorters: {
                    direction: 'ASC',
                    property: 'intSort'
                }
            }
        },{
            model: 'Inventory.model.ItemLocationStore',
            name: 'tblICItemLocationStores',
            foreignKey: 'intItemId',
            primaryKey: 'intItemId',
            storeConfig: {
                sortOnLoad: true,
                sorters: {
                    direction: 'ASC',
                    property: 'intSort'
                }
            }
        },{
            model: 'Inventory.model.ItemUPC',
            name: 'tblICItemUPCs',
            foreignKey: 'intItemId',
            primaryKey: 'intItemId',
            storeConfig: {
                sortOnLoad: true,
                sorters: {
                    direction: 'ASC',
                    property: 'intSort'
                }
            }
        },{
            model: 'Inventory.model.ItemVendorXref',
            name: 'tblICItemVendorXrefs',
            foreignKey: 'intItemId',
            primaryKey: 'intItemId',
            storeConfig: {
                sortOnLoad: true,
                sorters: {
                    direction: 'ASC',
                    property: 'intSort'
                }
            }
        },{
            model: 'Inventory.model.ItemCustomerXref',
            name: 'tblICItemCustomerXrefs',
            foreignKey: 'intItemId',
            primaryKey: 'intItemId',
            storeConfig: {
                sortOnLoad: true,
                sorters: {
                    direction: 'ASC',
                    property: 'intSort'
                }
            }
        },{
            model: 'Inventory.model.ItemContract',
            name: 'tblICItemContracts',
            foreignKey: 'intItemId',
            primaryKey: 'intItemId',
            storeConfig: {
                sortOnLoad: true,
                sorters: {
                    direction: 'ASC',
                    property: 'intSort'
                }
            }
        },{
            model: 'Inventory.model.ItemCertification',
            name: 'tblICItemCertifications',
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
        {
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
        },{
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
        },{
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
    ],

    validators: [
        {type: 'presence', field: 'strItemNo'}
    ]
});