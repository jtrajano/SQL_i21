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
                        remoteFilter: true,
                        proxy: {
                            extraParams: { include: 'BundleItem, tblICItemUOM.tblICUnitMeasure' },
                            type: 'rest',
                            api: {
                                read: '../Inventory/api/ItemBundle/Get'
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
            }},
        { name: 'intBundleItemId', type: 'int', allowNull: true },
        { name: 'strDescription', type: 'string' },
        { name: 'dblQuantity', type: 'float' },
        { name: 'intItemUnitMeasureId', type: 'int', allowNull: true },
        { name: 'dblUnit', type: 'float' },
        { name: 'dblPrice', type: 'float' },
        { name: 'intSort', type: 'int', allowNull: true },

        { name: 'strItemNo', type: 'string'},
        { name: 'strUnitMeasure', type: 'string'}
    ],

    validators: [
        {type: 'presence', field: 'strItemNo'},
        {type: 'presence', field: 'strUnitMeasure'}
    ]
});