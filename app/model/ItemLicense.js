Ext.define('Inventory.model.ItemLicense', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemLicenseId',

    fields: [
        { name: 'intItemLicenseId', type: 'int'},
        { 
            name: 'intItemId', 
            type: 'int',
            reference: {
                type: 'Inventory.model.Item',
                role: 'tblICItem',
                inverse: {
                    role: 'tblICItemLicenses',
                    storeConfig: {
                        proxy: {
                            type: 'rest',
                            api: {
                                read: './inventory/api/itemlicense/getitemlicense'
                            },
                            reader: {
                                type: 'json',
                                rootProperty: 'data',
                                messageProperty: 'message'
                            }
                        }
                    }
                }
            }
        },
        { name: 'intLicenseTypeId', type: 'int' }
    ]
});