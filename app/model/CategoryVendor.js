/**
 * Created by LZabala on 10/1/2014.
 */
Ext.define('Inventory.model.CategoryVendor', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intCategoryVendorId',

    fields: [
        { name: 'intCategoryVendorId', type: 'int'},
        { name: 'intCategoryId', type: 'int',
            reference: {
                type: 'Inventory.model.Category',
                inverse: {
                    role: 'tblICCategoryVendors',
                    storeConfig: {
                        sortOnLoad: true,
                        sorters: {
                            direction: 'ASC',
                            property: 'intSort'
                        }
                    }
                }
            }},
        { name: 'intLocationId', type: 'int', allowNull: true },
        { name: 'intVendorId', type: 'int', allowNull: true },
        { name: 'strVendorDepartment', type: 'string'},
        { name: 'ysnAddOrderingUPC', type: 'boolean'},
        { name: 'ysnUpdateExistingRecords', type: 'boolean'},
        { name: 'ysnAddNewRecords', type: 'boolean'},
        { name: 'ysnUpdatePrice', type: 'boolean'},
        { name: 'intFamilyId', type: 'int', allowNull: true },
        { name: 'intSellClassId', type: 'int', allowNull: true },
        { name: 'intOrderClassId', type: 'int', allowNull: true },
        { name: 'strComments', type: 'string'},
    ],

    validators: [
        {type: 'presence', field: 'intLocationId'},
        {type: 'presence', field: 'intVendorId'}
    ]
});