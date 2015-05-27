/**
 * Created by LZabala on 10/27/2014.
 */
Ext.define('Inventory.model.ItemAssembly', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemAssemblyId',

    fields: [
        { name: 'intItemAssemblyId', type: 'int'},
        { name: 'intItemId', type: 'int',
            reference: {
                type: 'Inventory.model.Item',
                inverse: {
                    role: 'tblICItemAssemblies',
                    storeConfig: {
                        remoteFilter: true,
                        proxy: {
                            extraParams: { include: 'AssemblyItem, tblICItemUOM.tblICUnitMeasure' },
                            type: 'rest',
                            api: {
                                read: '../Inventory/api/ItemAssembly/Get'
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
        { name: 'intAssemblyItemId', type: 'int', allowNull: true },
        { name: 'strDescription', type: 'string' },
        { name: 'dblQuantity', type: 'float' },
        { name: 'intItemUnitMeasureId', type: 'int', allowNull: true },
        { name: 'dblUnit', type: 'float' },
        { name: 'dblCost', type: 'float' },
        { name: 'intSort', type: 'int', allowNull: true },

        { name: 'strItemNo', type: 'string'},
        { name: 'strUnitMeasure', type: 'string'}
    ],

    validators: [
        {type: 'presence', field: 'strItemNo'},
        {type: 'presence', field: 'strUnitMeasure'}
    ]


});