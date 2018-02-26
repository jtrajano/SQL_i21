/**
 * Created by LZabala on 10/27/2014.
 */
Ext.define('Inventory.model.ItemKitDetail', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemKitDetailId',

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
                            direction: 'DESC',
                            property: 'intSort'
                        }
                    }
                }
            }},
        { name: 'intItemId', type: 'int', allowNull: true },
        { name: 'dblQuantity', type: 'float' },
        { name: 'intItemUnitMeasureId', type: 'int', allowNull: true },
        { name: 'dblPrice', type: 'float' },
        { name: 'ysnSelected', type: 'int', allowNull: true },
        { name: 'inSort', type: 'int', allowNull: true },

        { name: 'strItemNo', type: 'string', auditKey: true},
        { name: 'strDescription', type: 'string'},
        { name: 'strUnitMeasure', type: 'string'}
    ],

    validators: [
        {type: 'presence', field: 'strItemNo'},
        {type: 'presence', field: 'strUnitMeasure'}
    ]
});