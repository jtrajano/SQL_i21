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
        { name: 'strLotTracking', type: 'string'}
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
        }
    ],

//    hasOne: {
//        model: 'Inventory.model.ItemPOS',
//        name: 'tblICItemPOS',
//        foreignKey: 'intItemId',
//        primaryKey: 'intItemId',
//        storeConfig: {
//            sortOnLoad: true,
//            sorters: {
//                direction: 'ASC',
//                property: 'intSort'
//            }
//        }
//    },
//
//    hasOne: {
//        model: 'Inventory.model.ItemSales',
//        name: 'tblICItemSales',
//        foreignKey: 'intItemId',
//        primaryKey: 'intItemId',
//        storeConfig: {
//            sortOnLoad: true,
//            sorters: {
//                direction: 'ASC',
//                property: 'intSort'
//            }
//        }
//    },
//
//    hasOne: {
//        model: 'Inventory.model.ItemManufacturing',
//        name: 'tblICItemManufacturing',
//        foreignKey: 'intItemId',
//        primaryKey: 'intItemId',
//        storeConfig: {
//            sortOnLoad: true,
//            sorters: {
//                direction: 'ASC',
//                property: 'intSort'
//            }
//        }
//    },

    validators: [
        {type: 'presence', field: 'strItemNo'}
    ]
});