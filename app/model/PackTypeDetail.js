/**
 * Created by LZabala on 10/29/2014.
 */
Ext.define('Inventory.model.PackTypeDetail', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intPackTypeId',

    fields: [
        { name: 'intPackTypeDetailId', type: 'int'},
        { name: 'intPackTypeId', type: 'int',
            reference: {
                type: 'Inventory.model.PackType',
                inverse: {
                    role: 'tblICPackTypeDetails',
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
        { name: 'intSourceUnitMeasureId', type: 'int', allowNull: true },
        { name: 'intTargetUnitMeasureId', type: 'int', allowNull: true },
        { name: 'dblConversionFactor', type: 'float'},
        { name: 'intSort', type: 'int'}
    ],

    validators: [
        {type: 'presence', field: 'intSourceUnitMeasureId'},
        {type: 'presence', field: 'intTargetUnitMeasureId'}
    ]
});