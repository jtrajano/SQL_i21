/**
 * Created by LZabala on 9/29/2014.
 */
Ext.define('Inventory.model.ItemVendorXref', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemVendorXrefId',

    fields: [
        { name: 'intItemVendorXrefId', type: 'int'},
        { name: 'intItemId', type: 'int',
            reference: {
                type: 'Inventory.model.Item',
                inverse: {
                    role: 'tblICItemVendorXrefs',
                    storeConfig: {
                        remoteFilter: true,
                        proxy: {
                            type: 'rest',
                            api: {
                                read: '../Inventory/api/ItemXref/GetItemVendorXrefs'
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
        { name: 'intItemLocationId', type: 'int', allowNull: true },
        { name: 'intVendorId', type: 'int', allowNull: true },
        { name: 'strVendorProduct', type: 'string' },
        { name: 'strProductDescription', type: 'string' },
        { name: 'dblConversionFactor', type: 'float' },
        { name: 'intItemUnitMeasureId', type: 'int', allowNull: true },
        { name: 'intSort', type: 'int', allowNull: true },

        { name: 'strLocationName', type: 'string'},
        { name: 'strVendorId', type: 'string'},
        { name: 'strUnitMeasure', type: 'string'}
    ],

    validators: [
        {type: 'presence', field: 'strLocationName'},
        {type: 'presence', field: 'strVendorId'},
        {type: 'presence', field: 'strVendorProduct'},
        {type: 'presence', field: 'strProductDescription'}
    ]
});