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
        { name: 'strItemNo', type: 'string', auditKey: true },
        { name: 'strStorageLocationName', type: 'string' },
        { name: 'strSubLocationName', type: 'string' },
        { name: 'dblEffectiveDepth', type: 'float' },
        { name: 'strUnitMeasure', type: 'string' },
        { name: 'dblUnitPerFoot', type: 'float', persist: true },
        { name: 'dblResidualUnit', type: 'float', persist: true },
        { 
            name: 'dblValue',
            type: 'float',
            persist: true,
            convert: function(value, record) {
                if(!record) return 0.00;
                var dblCashPrice = iRely.Functions.isEmpty(record.get('dblCashPrice')) ? 0 : record.get('dblCashPrice');    
                var dblNewOnHand = iRely.Functions.isEmpty(record.get('dblNewOnHand')) ? 0 : record.get('dblNewOnHand');    
                return dblCashPrice * dblNewOnHand;
            },
            depends: [ 'dblCashPrice', 'dblNewOnHand' ]
        },
        { 
            name: 'dblGainLoss',
            type: 'float',
            persist: true,
            convert: function(value, record) {
                if(!record) return 0.00;
                var dblCashPrice = iRely.Functions.isEmpty(record.get('dblCashPrice')) ? 0 : record.get('dblCashPrice');    
                var dblVariance = iRely.Functions.isEmpty(record.get('dblVariance')) ? 0 : record.get('dblVariance');    
                return dblCashPrice * dblVariance;
            },
            depends: [ 'dblVariance', 'dblCashPrice' ]
        },
        { name: 'dblOnHand', type: 'float' },
        { 
            name: 'dblNewOnHand', 
            type: 'float', 
            persist: true,
            convert: function(value, record) {
                if(!record) return 0.00;
                var dblAirSpaceReading = iRely.Functions.isEmpty(record.get('dblAirSpaceReading')) ? 0 : record.get('dblAirSpaceReading');
                var dblEffectiveDepth = iRely.Functions.isEmpty(record.get('dblEffectiveDepth')) ? 0 : record.get('dblEffectiveDepth');
                var dblUnitPerFoot = iRely.Functions.isEmpty(record.get('dblUnitPerFoot')) ? 0 : record.get('dblUnitPerFoot');
                var dblResidualUnit = iRely.Functions.isEmpty(record.get('dblResidualUnit')) ? 0 : record.get('dblResidualUnit');

                if(dblEffectiveDepth === 0)
                    return (dblAirSpaceReading * dblUnitPerFoot);
                else if (dblEffectiveDepth > 0)
                    return ((dblEffectiveDepth - dblAirSpaceReading) * dblUnitPerFoot);
                
                 //return ((dblEffectiveDepth - dblAirSpaceReading) * dblUnitPerFoot) + dblResidualUnit;
            },
            depends: [ 'dblEffectiveDepth', 'dblAirSpaceReading' ]
        },
        {
            name: 'dblVariance',
            type: 'float',
            persist: true,
            convert: function(value, record) {
                if(!record) return 0.00;
                var dblNewOnHand = iRely.Functions.isEmpty(record.get('dblNewOnHand')) ? 0 : record.get('dblNewOnHand');
                var dblOnHand = iRely.Functions.isEmpty(record.get('dblOnHand')) ? 0 : record.get('dblOnHand');

                return dblNewOnHand - dblOnHand;
            },
            depends: [ 'dblOnHand', 'dblNewOnHand' ]
        }
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
                message: 'Reading in Foot must be greater than zero(0).'
            })
        }

        return errors;
    }
});