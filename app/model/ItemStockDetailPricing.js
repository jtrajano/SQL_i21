/**
 * Created by LZabala on 1/5/2015.
 */
Ext.define('Inventory.model.ItemStockDetailPricing', {
    extend: 'Ext.data.Model',

    requires: [
        'Ext.data.Field'
    ],

    fields: [
        { name: 'intItemPricingId', type: 'int'},
        { name: 'intItemId', type: 'int',
            reference: {
                type: 'Inventory.model.ItemStockDetailView',
                inverse: {
                    role: 'tblICItemPricings',
                    storeConfig: {
                        complete: true,
                        remoteFilter: true,
                        sortOnLoad: true,
                        sorters: {
                            direction: 'DESC',
                            property: 'intSort'
                        }
                    }
                }
            }
        },
        { name: 'strDescription', type: 'string' },
        { name: 'strUpcCode', type: 'string' },
        { name: 'intItemPricingId', type: 'int', allowNull: true },
        { name: 'intItemId', type: 'int', allowNull: true },
        { name: 'intLocationId', type: 'int', allowNull: true },
        { name: 'intItemLocationId', type: 'int', allowNull: true },
        { name: 'strLocationName', type: 'string' },
        { name: 'strLocationType', type: 'string' },
        { name: 'intItemUnitMeasureId', type: 'int', allowNull: true },
        { name: 'intUnitMeasureId', type: 'int', allowNull: true },
        { name: 'strUnitMeasure', type: 'string' },
        { name: 'strUnitType', type: 'string' },
        { name: 'ysnStockUnit', type: 'boolean' },
        { name: 'ysnAllowPurchase', type: 'boolean' },
        { name: 'ysnAllowSale', type: 'boolean' },
        { name: 'dblUnitQty', type: 'float' },
        { name: 'dblAmountPercent', type: 'float' },
        { name: 'dblSalePrice', type: 'float' },
        { name: 'dblMSRPPrice', type: 'float' },
        { name: 'strPricingMethod', type: 'string' },
        { name: 'dblLastCost', type: 'float' },
        { name: 'dblStandardCost', type: 'float' },
        { name: 'dblAverageCost', type: 'float' },
        { name: 'dblEndMonthCost', type: 'float' },
        { name: 'intSort', type: 'int', allowNull: true }
    ]
});