/**
 * Created by LZabala on 10/1/2015.
 */
Ext.define('Inventory.model.StorageMeasurementReadingConversion', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intStorageMeasurementReadingConversionId',

    fields: [
        { name: 'intStorageMeasurementReadingConversionId', type: 'int' },
        { name: 'intStorageMeasurementReadingId', type: 'int',
            reference: {
                type: 'Inventory.model.StorageMeasurementReading',
                inverse: {
                    role: 'tblICStorageMeasurementReadingConversions',
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
        { name: 'intCommodityId', type: 'int', allowNull: true },
        { name: 'intItemId', type: 'int', allowNull: true },
        { name: 'intStorageLocationId', type: 'int', allowNull: true },
        { name: 'intSubLocationId', type: 'int', allowNull: true },
        { name: 'dblAirSpaceReading', type: 'float' },
        { name: 'dblCashPrice', type: 'float' },
        { name: 'intSort', type: 'int', allowNull: true },

        { name: 'strCommodity', type: 'string' },
        { name: 'strItemNo', type: 'string' },
        { name: 'strStorageLocationName', type: 'string' },
        { name: 'strSubLocationName', type: 'string' },
        { name: 'dblEffectiveDepth', type: 'float' }
    ],

    validators: [
        {type: 'presence', field: 'strItemNo'},
        {type: 'presence', field: 'strStorageLocationName'}
    ],

    validate: function(options) {
        var errors = this.callParent(arguments);

        if (this.get('dblAirSpaceReading') <= 0) {
            errors.add({
                field: 'dblAirSpaceReading',
                message: 'Air Space Reading must be greater than zero(0).'
            })
        }

        return errors;
    }
});