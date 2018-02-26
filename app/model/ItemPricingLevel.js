/**
 * Created by LZabala on 10/24/2014.
 */
Ext.define('Inventory.model.ItemPricingLevel', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemPricingLevelId',

    fields: [
        { name: 'intItemPricingLevelId', type: 'int'},
        { name: 'intItemId', type: 'int',
            reference: {
                type: 'Inventory.model.Item',
                inverse: {
                    role: 'tblICItemPricingLevels',
                    storeConfig: {
                        remoteFilter: true,
                        complete: true, 
                        proxy: {
                            type: 'rest',
                            api: {
                                read: './inventory/api/itempricinglevel/getitempricinglevel'
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
            }
        },
        { name: 'intItemLocationId', type: 'int', allowNull: true },
        { name: 'strPriceLevel', type: 'string' },
        { name: 'intItemUnitMeasureId', type: 'int', allowNull: true },
        { name: 'dblUnit', type: 'float' },
        { name: 'dblMin', type: 'float' },
        { name: 'dblMax', type: 'float' },
        { name: 'strPricingMethod', type: 'string' },
        { name: 'dblAmountRate', type: 'float' },
        { name: 'dblUnitPrice', type: 'float' },
        { name: 'dtmEffectiveDate', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d' },
        { name: 'strCommissionOn', type: 'string' },
        { name: 'dblCommissionRate', type: 'float' },
        { name: 'intSort', type: 'int', allowNull: true },

        { name: 'strLocationName', type: 'string', auditKey: true},
        { name: 'strUnitMeasure', type: 'string'},
        { name: 'strUPC', type: 'string'},
        { name: 'intCurrencyId', type: 'int', allowNull: true },
        { name: 'strCurrency', type: 'string'}
    ],

    validators: [
        {type: 'presence', field: 'strLocationName'},
        {type: 'presence', field: 'strPriceLevel'},
        {type: 'presence', field: 'strUnitMeasure'},
        {type: 'presence', field: 'dblUnit'},
        {type: 'presence', field: 'strPricingMethod'},
        {type: 'presence', field: 'dblUnitPrice'}
    ],

    validate: function(options){
        var errors = this.callParent(arguments);
        if (this.get('strPricingMethod') !== 'None' && iRely.Functions.isEmpty(this.get('strPricingMethod')) !== true) {
            if (this.get('dblAmountRate') <= 0) {
                errors.add({
                    field: 'dblAmountRate',
                    message: 'Amount/Rate must be greater than zero(0).'
                })
            }
        }

        if(this.get('dblUnitPrice') <= 0){
            errors.add({
                field:'dblUnitPrice',
                message: 'Retail Price cannot be zero for Pricing Level'
            });
        }
        
        return errors;
    }
});