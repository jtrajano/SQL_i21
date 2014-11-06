/**
 * Created by LZabala on 10/27/2014.
 */
Ext.define('Inventory.model.ItemKitDetail', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemKitId',

    fields: [
        { name: 'intItemKitDetailId', type: 'int'},
        { name: 'intItemKitId', type: 'int',
            reference: {
                type: 'Inventory.model.ItemKit',
                inverse: {
                    role: 'tblICItemKitDetails',
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
        { name: 'intItemId', type: 'int', allowNull: true },
        { name: 'dblQuantity', type: 'float'},
        { name: 'intUnitMeasureId', type: 'int', allowNull: true },
        { name: 'dblPrice', type: 'float'},
        { name: 'ysnSelected', type: 'int'},
        { name: 'inSort', type: 'int'},

        { name: 'strItemNo', type: 'string'},
        { name: 'strUnitMeasure', type: 'string'}
    ],

    validators: [
        {type: 'presence', field: 'intItemId'},
        {type: 'intUnitMeasureId', field: 'intItemId'},
    ]
});