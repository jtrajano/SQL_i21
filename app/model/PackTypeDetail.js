/**
 * Created by LZabala on 10/29/2014.
 */
Ext.define('Inventory.model.PackTypeDetail', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intPackTypeDetailId',

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
                            direction: 'DESC',
                            property: 'intSort'
                        }
                    }
                }
            }
        },
        { name: 'intSourceUnitMeasureId', type: 'int', allowNull: true },
        { name: 'intTargetUnitMeasureId', type: 'int', allowNull: true },
        { name: 'dblConversionFactor', type: 'float'},
        { name: 'intSort', type: 'int'},

        { name: 'strSourceUnitMeasure', type: 'string'},
        { name: 'strTargetUnitMeasure', type: 'string'}

    ],

    validators: [
        {type: 'presence', field: 'strSourceUnitMeasure'},
        {type: 'presence', field: 'strTargetUnitMeasure'}
    ]
});