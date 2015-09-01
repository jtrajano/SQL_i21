/**
 * Created by LZabala on 2/17/2015.
 */
Ext.define('Inventory.model.CategoryUOM', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intCategoryUOMId',

    fields: [
        { name: 'intCategoryUOMId', type: 'int'},
        { name: 'intCategoryId', type: 'int',
            reference: {
                type: 'Inventory.model.Category',
                inverse: {
                    role: 'tblICCategoryUOMs',
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
        { name: 'ysnAllowPurchase', type: 'boolean' },
        { name: 'ysnAllowSale', type: 'boolean' },
        { name: 'ysnDefault', type: 'boolean' },
        { name: 'intSort', type: 'int', allowNull: true }
    ],

    validators: [
        {type: 'presence', field: 'strUnitMeasure'}
    ]
});