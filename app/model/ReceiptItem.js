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
                            direction: 'DESC',
                            property: 'intSort'
                        }
                    }
                }
            }
        },
        { name: 'intLineNo', type: 'int'},
        { name: 'intSourceId', type: 'int', allowNull: true},
        { name: 'strSourceId', type: 'string'},
        { name: 'dtmSourceDate', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d'},
        { name: 'intItemId', type: 'int', allowNull: true },
        { name: 'intSubLocationId', type: 'int', allowNull: true },
        { name: 'dblOrderQty', type: 'float'},
        { name: 'dblOpenReceive', type: 'float'},
        { name: 'dblReceived', type: 'float'},
        { name: 'intUnitMeasureId', type: 'int', allowNull: true },
        { name: 'intWeightUOMId', type: 'int', allowNull: true },
        { name: 'dblUnitCost', type: 'float'},
        { name: 'dblUnitRetail', type: 'float'},
        { name: 'dblLineTotal', type: 'float'},
        { name: 'dblGrossMargin', type: 'float'},
        { name: 'intSort', type: 'int'},

        { name: 'strItemNo', type: 'string'},
        { name: 'strItemDescription', type: 'string'},
        { name: 'strLotTracking', type: 'string'},
        { name: 'strUnitMeasure', type: 'string'},
        { name: 'strWeightUOM', type: 'string'},
        { name: 'strSubLocationName', type: 'string'}

    ],

    validators: [
        {type: 'presence', field: 'strItemNo'},
        {type: 'presence', field: 'strUnitMeasure'},
        {type: 'presence', field: 'dblOpenReceive'}
    ]

});