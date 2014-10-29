/**
 * Created by LZabala on 10/29/2014.
 */
Ext.define('Inventory.model.ManufacturingCellPackType', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intManufacturingCellId',

    fields: [
        { name: 'intManufacturingCellPackTypeId', type: 'int'},
        { name: 'intManufacturingCellId', type: 'int',
            reference: {
                type: 'Inventory.model.ManufacturingCell',
                inverse: {
                    role: 'tblICManufacturingCellPackTypes',
                    storeConfig: {
                        sortOnLoad: true,
                        sorters: {
                            direction: 'ASC',
                            property: 'intSort'
                        }
                    }
                }
            }},
        { name: 'intPackTypeId', type: 'int', allowNull: true },
        { name: 'dblLineCapacity', type: 'float'},
        { name: 'intLineCapacityUnitMeasureId', type: 'int', allowNull: true },
        { name: 'intLineCapacityRateUnitMeasureId', type: 'int', allowNull: true },
        { name: 'dblLineEfficiencyRate', type: 'float'},
        { name: 'intSort', type: 'int'}
    ],

    validators: [
        {type: 'presence', field: 'intPackTypeId'}
    ]
});