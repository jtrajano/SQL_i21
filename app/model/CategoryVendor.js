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
        { name: 'intVendorId', type: 'int'},
        { name: 'strVendorDepartment', type: 'string'},
        { name: 'ysnAddOrderingUPC', type: 'boolean'},
        { name: 'ysnUpdateExistingRecords', type: 'boolean'},
        { name: 'ysnAddNewRecords', type: 'boolean'},
        { name: 'ysnUpdatePrice', type: 'boolean'},
        { name: 'intFamilyId', type: 'int'},
        { name: 'intSellClassId', type: 'int'},
        { name: 'intOrderClassId', type: 'int'},
        { name: 'strComments', type: 'string'},
    ],

    validators: [
        {type: 'presence', field: 'intVendorId'}
    ]
});