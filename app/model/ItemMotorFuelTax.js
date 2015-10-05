/**
 * Created by LZabala on 10/2/2015.
 */
Ext.define('Inventory.model.ItemMotorFuelTax', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemMotorFuelTaxId',

    fields: [
        { name: 'intItemMotorFuelTaxId', type: 'int'},
        { name: 'intItemId', type: 'int',
            reference: {
                type: 'Inventory.model.Item',
                inverse: {
                    role: 'tblICItemMotorFuelTaxes',
                    storeConfig: {
                        remoteFilter: true,
                        proxy: {
                            extraParams: { include: 'vyuICGetItemMotorFuelTax' },
                            type: 'rest',
                            api: {
                                read: '../Inventory/api/ItemMotorFuelTax/Get'
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
        { name: 'intTaxAuthorityId', type: 'int', allowNull: true },
        { name: 'intProductCodeId', type: 'int', allowNull: true },
        { name: 'intSort', type: 'int', allowNull: true },

        { name: 'strTaxAuthorityCode', type: 'string'},
        { name: 'strProductCode', type: 'string'}
    ],

    validators: [
        {type: 'presence', field: 'strTaxAuthorityCode'},
        {type: 'presence', field: 'strProductCode'}
    ]
});