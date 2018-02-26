/**
 * Created by LZabala on 10/9/2014.
 */
Ext.define('Inventory.model.Brand', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intBrandId',

    fields: [
        { name: 'intBrandId', type: 'int'},
        { name: 'strBrandCode', type: 'string', auditKey: true},
        { name: 'strBrandName', type: 'string'},
        { name: 'intManufacturerId', type: 'int', allowNull: true,
            reference: {
                type: 'Inventory.model.Manufacturer',
                role: 'tblICManufacturer',
                inverse: {
                    role: 'tblICBrands',
                    storeConfig: {
                        complete: true
                    }
                }
            }
        },
        { name: 'intSort', type: 'int'},
        { name: 'strManufacturer', type: 'string'}
    ],

    validators: [
        {type: 'presence', field: 'strBrandCode'}
    ]
});