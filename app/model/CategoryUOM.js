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
        { name: 'dblSellQty', type: 'float' },
        { name: 'dblWeight', type: 'float' },
        { name: 'intWeightUOMId', type: 'int', allowNull: true },
        { name: 'strDescription', type: 'string' },
        { name: 'strUpcCode', type: 'string' },
        { name: 'ysnStockUnit', type: 'boolean' },
        { name: 'ysnAllowPurchase', type: 'boolean' },
        { name: 'ysnAllowSale', type: 'boolean' },
        { name: 'dblLength', type: 'float' },
        { name: 'dblWidth', type: 'float' },
        { name: 'dblHeight', type: 'float' },
        { name: 'intDimensionUOMId', type: 'int', allowNull: true },
        { name: 'dblVolume', type: 'float' },
        { name: 'intVolumeUOMId', type: 'int', allowNull: true },
        { name: 'dblMaxQty', type: 'float' },
        { name: 'intSort', type: 'int', allowNull: true }
    ],

    validators: [
        {type: 'presence', field: 'strUnitMeasure'}
    ]
});