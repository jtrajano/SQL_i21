/**
 * Created by LZabala on 10/24/2014.
 */
Ext.define('Inventory.model.ItemSpecialPricing', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemSpecialPricingId',

    fields: [
        { name: 'intItemSpecialPricingId', type: 'int' },
        {
            name: 'intItemId', type: 'int',
            reference: {
                type: 'Inventory.model.Item',
                inverse: {
                    role: 'tblICItemSpecialPricings',
                    storeConfig: {
                        remoteFilter: true,
                        proxy: {
                            type: 'rest',
                            api: {
                                read: './inventory/api/itemspecialpricing/getitemspecialpricing'
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
        { name: 'strPromotionType', type: 'string' },
        { name: 'dtmBeginDate', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d' },
        { name: 'dtmEndDate', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d' },
        { name: 'intItemUnitMeasureId', type: 'int', allowNull: true },
        { name: 'dblUnit', type: 'float' },
        { name: 'strDiscountBy', type: 'string' },
        { name: 'dblDiscount', type: 'float' },
        { name: 'dblUnitAfterDiscount', type: 'float' },
        { name: 'dblDiscountThruQty', type: 'float' },
        { name: 'dblDiscountThruAmount', type: 'float' },
        { name: 'dblAccumulatedQty', type: 'float' },
        { name: 'dblAccumulatedAmount', type: 'float' },
        { name: 'intSort', type: 'int', allowNull: true },

        { name: 'strLocationName', type: 'string' },
        { name: 'strUnitMeasure', type: 'string' },
        { name: 'strUPC', type: 'string' },
        { name: 'intCurrencyId', type: 'int', allowNull: true },
        { name: 'strCurrency', type: 'string'}
    ],

    validators: [
        { type: 'presence', field: 'strLocationName' },
        { type: 'presence', field: 'strPromotionType' },
        { type: 'presence', field: 'strUnitMeasure' },
        { type: 'presence', field: 'dblUnit' },
        { type: 'presence', field: 'dblDiscount' },
        { type: 'presence', field: 'dblUnitAfterDiscount' },
        { type: 'presence', field: 'dtmBeginDate' }
    ],
    validate: function (options) {
        var errors = this.callParent(arguments);
        if (this.get('dtmBeginDate') > this.get('dtmEndDate')) {
            errors.add({
                field: 'dtmEndDate',
                message: 'End Date should be after or the same to Begin Date.'
            });
        }

        return errors;
    }
});