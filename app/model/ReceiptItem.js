/**
 * Created by LZabala on 10/10/2014.
 */
Ext.define('Inventory.model.ReceiptItem', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Inventory.model.ReceiptItemLot',
        'Inventory.model.ReceiptItemTax',
        'Ext.data.Field'
    ],

    idProperty: 'intInventoryReceiptItemId',

    fields: [
        { name: 'intInventoryReceiptItemId', type: 'int'},
        { name: 'intInventoryReceiptId', type: 'int',
            reference: {
                type: 'Inventory.model.Receipt',
                inverse: {
                    role: 'tblICInventoryReceiptItems',
                    storeConfig: {
                        complete: true,
                        sortOnLoad: true,
                        sorters: {
                            direction: 'ASC',
                            property: 'intSort'
                        }
                    }
                }
            }
        },
        { name: 'intLineNo', type: 'int'},
        { name: 'intItemId', type: 'int', allowNull: true },
        { name: 'dblOrderQty', type: 'float'},
        { name: 'dblOpenReceive', type: 'float'},
        { name: 'dblReceived', type: 'float'},
        { name: 'intUnitMeasureId', type: 'int', allowNull: true },
        { name: 'intNoPackages', type: 'int'},
        { name: 'intPackTypeId', type: 'int', allowNull: true },
        { name: 'dblExpPackageWeight', type: 'float'},
        { name: 'dblUnitCost', type: 'float'},
        { name: 'dblUnitRetail', type: 'float'},
        { name: 'dblLineTotal', type: 'float'},
        { name: 'dblGrossMargin', type: 'float'},
        { name: 'intSort', type: 'int'},

        { name: 'strItemNo', type: 'string'},
        { name: 'strUnitMeasure', type: 'string'}
    ],

    validators: [
        {type: 'presence', field: 'strItemNo'},
        {type: 'presence', field: 'strUnitMeasure'}
    ]

});