/**
 * Created by LZabala on 9/17/2014.
 */
Ext.define('Inventory.model.ItemUOM', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemUOMId',

    fields: [
        { name: 'intItemUOMId', type: 'int'},
        { name: 'intItemId',
            type: 'int',
            reference: {
                type: 'Inventory.model.Item',
                inverse: {
                    role: 'tblICItemUOMs',
                    storeConfig: {
                        sortOnLoad: true,
                        sorters: {
                            direction: 'ASC',
                            property: 'intSort'
                        }
                    }
                }
            }
        },
        { name: 'intUnitMeasureId', type: 'int', allowNull: true},
        { name: 'dblUnitQty', type: 'float'},
        { name: 'dblSellQty', type: 'float'},
        { name: 'dblWeight', type: 'float'},
        { name: 'strDescription', type: 'string'},
        { name: 'dblLength', type: 'float'},
        { name: 'dblWidth', type: 'float'},
        { name: 'dblHeight', type: 'float'},
        { name: 'dblVolume', type: 'float'},
        { name: 'dblMaxQty', type: 'float'}
    ],

    validators: [
        {type: 'presence', field: 'intUnitMeasureId'}
    ]
});