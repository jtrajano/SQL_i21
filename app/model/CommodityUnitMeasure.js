/**
 * Created by LZabala on 10/3/2014.
 */
Ext.define('Inventory.model.CommodityUnitMeasure', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intCommodityUnitMeasureId',

    fields: [
        { name: 'intCommodityUnitMeasureId', type: 'int'},
        { name: 'intCommodityId', type: 'int',
            reference: {
                type: 'Inventory.model.Commodity',
                inverse: {
                    role: 'tblICCommodityUnitMeasures',
                    storeConfig: {
                        complete: true,
                        sortOnLoad: true,
                        sorters: {
                            direction: 'DESC',
                            property: 'intSort'
                        }
                    }
                }
            }},
        { name: 'intUnitMeasureId', type: 'int', allowNull: true },
        { name: 'dblUnitQty', type: 'float' },
        { name: 'ysnStockUnit', type: 'boolean' },
        { name: 'ysnDefault', type: 'boolean' },
        { name: 'ysnStockUOM', type: 'boolean', allowNull: true  },
        { name: 'intSort', type: 'int', allowNull: true },

        { name: 'strUnitMeasure', type: 'string'}
    ],

    validators: [
        {type: 'presence', field: 'strUnitMeasure'}
    ]
});