/**
 * Created by LZabala on 11/19/2014.
 */
Ext.define('Inventory.model.StorageLocationMeasurement', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intStorageLocationMeasurementId',

    fields: [
        { name: 'intStorageLocationMeasurementId', type: 'int'},
        { name: 'intStorageLocationId', type: 'int',
            reference: {
                type: 'Inventory.model.StorageLocation',
                inverse: {
                    role: 'tblICStorageLocationMeasurements',
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
        { name: 'intMeasurementId', type: 'int', allowNull: true },
        { name: 'intReadingPointId', type: 'int', allowNull: true },
        { name: 'ysnActive', type: 'boolean'},
        { name: 'intSort', type: 'int'}
    ],

    validators: [
        {type: 'presence', field: 'intMeasurementId'}
    ]
});