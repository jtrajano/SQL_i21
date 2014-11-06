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
                        complete: true,
                        sortOnLoad: true,
                        sorters: {
                            direction: 'ASC',
                            property: 'intSort'
                        }
                    }
                }
            }
        },
        { name: 'intLocationId', type: 'int'},
        { name: 'strStoreName', type: 'string'},
        { name: 'intVendorId', type: 'int'},
        { name: 'strVendorProduct', type: 'string'},
        { name: 'strProductDescription', type: 'string'},
        { name: 'dblConversionFactor', type: 'float'},
        { name: 'intUnitMeasureId', type: 'int'},
        { name: 'intSort', type: 'int'},

        { name: 'strLocationName', type: 'string'},
        { name: 'strVendorId', type: 'string'},
        { name: 'strUnitMeasure', type: 'string'}
    ],

    validators: [
        {type: 'presence', field: 'intLocationId'}
    ]
});