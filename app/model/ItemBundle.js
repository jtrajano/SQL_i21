/**
 * Created by LZabala on 10/27/2014.
 */
Ext.define('Inventory.model.ItemBundle', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemBundleId',

    fields: [
        { name: 'intItemBundleId', type: 'int'},
        { name: 'intItemId', type: 'int',
            reference: {
                type: 'Inventory.model.Item',
                inverse: {
                    role: 'tblICItemBundles',
                    storeConfig: {
                        complete: true,
                        sortOnLoad: true,
                        sorters: {
                            direction: 'ASC',
                            property: 'intSort'
                        }
                    }
                }
            }},
        { name: 'intBundleItemId', type: 'int', allowNull: true },
        { name: 'strDescription', type: 'string'},
        { name: 'dblQuantity', type: 'float'},
        { name: 'intUnitMeasureId', type: 'int', allowNull: true },
        { name: 'dblUnit', type: 'float'},
        { name: 'dblPrice', type: 'float'},
        { name: 'intSort', type: 'int'},

        { name: 'strItemNo', type: 'string'},
        { name: 'strUnitMeasure', type: 'string'}
    ],

    validators: [
        {type: 'presence', field: 'intBundleItemId'},
        {type: 'presence', field: 'intUnitMeasureId'}
    ]
});