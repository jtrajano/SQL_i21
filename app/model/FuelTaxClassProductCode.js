/**
 * Created by LZabala on 10/21/2014.
 */
Ext.define('Inventory.model.FuelTaxClassProductCode', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intFuelTaxClassProductCodeId',

    fields: [
        { name: 'intFuelTaxClassProductCodeId', type: 'int'},
        { name: 'intFuelTaxClassId', type: 'int',
            reference: {
                type: 'Inventory.model.FuelTaxClass',
                inverse: {
                    role: 'tblICFuelTaxClassProductCodes',
                    storeConfig: {
                        complete: true,
                        sortOnLoad: true,
                        sorters: {
                            direction: 'DESC',
                            property: 'intSort'
                        }
                    }
                }
            }
        },
        { name: 'strState', type: 'string', allowNull: true },
        { name: 'strProductCode', type: 'string', auditKey: true},
        { name: 'intSort', type: 'int'}
    ],

    validators: [
        { type: 'presence', field: 'strState' }
    ]
});