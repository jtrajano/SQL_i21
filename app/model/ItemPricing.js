/**
 * Created by LZabala on 10/24/2014.
 */
Ext.define('Inventory.model.ItemPricing', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemPricingId',

    fields: [
        { name: 'intItemPricingId', type: 'int'},
        { name: 'intItemId', type: 'int',
            reference: {
                type: 'Inventory.model.Item',
                inverse: {
                    role: 'tblICItemPricings',
                    storeConfig: {
                        remoteFilter: true,
                        proxy: {
                            extraParams: { include: 'tblICItemLocation.tblSMCompanyLocation' },
                            type: 'rest',
                            api: {
                                read: '../Inventory/api/ItemPricing/Get'
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
        { name: 'dblAmountPercent', type: 'float' },
        { name: 'dblSalePrice', type: 'float' },
        { name: 'dblMSRPPrice', type: 'float' },
        { name: 'strPricingMethod', type: 'string' },
        { name: 'dblLastCost', type: 'float' },
        { name: 'dblStandardCost', type: 'float' },
        { name: 'dblAverageCost', type: 'float' },
        { name: 'dblEndMonthCost', type: 'float' },
        { name: 'intSort', type: 'int', allowNull: true },
        { name: 'strLocationName', type: 'string'}
    ],

    validators: [
        {type: 'presence', field: 'strLocationName'},
        {type: 'presence', field: 'dblStandardCost'},
        {type: 'presence', field: 'strPricingMethod'},
        {type: 'presence', field: 'dblSalePrice'}
    ],

    validate: function(options) {
        var errors = this.callParent(arguments);
        if (this.get('strPricingMethod') === 'Percent of Margin') {
            if (this.get('dblAmountPercent') <= 100) {
                errors.add({
                    field: 'dblAmountPercent',
                    message: 'Percent of Margin cannot be greater than or equal to 100.'
                })
            }
        }
        return errors;
    }
});