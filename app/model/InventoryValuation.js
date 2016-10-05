/**
 * Created by LZabala on 9/18/2015.
 */
Ext.define('Inventory.model.InventoryValuation', {
    extend: 'Ext.data.Model',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemId',

    fields: [
        { name: 'intInventoryValuationKeyId', type: 'int' },
        { name: 'intInventoryTransactionId', type: 'int' },
        { name: 'intItemId', type: 'int' },
        { name: 'strItemNo', type: 'string' },
        { name: 'strItemDescription', type: 'string' },
        { name: 'intCategoryId', type: 'int', allowNull: true },
        { name: 'strCategroy', type: 'string' },
        { name: 'intItemLocationId', type: 'int', allowNull: true },
        { name: 'strLocationName', type: 'string' },
        { name: 'intSubLocationId', type: 'int', allowNull: true },
        { name: 'strSubLocationName', type: 'string' },
        { name: 'intStorageLocationId', type: 'int', allowNull: true },
        { name: 'strStorageLocationName', type: 'string' },
        { name: 'dtmDate', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d' },
        { name: 'strTransactionForm', type: 'string' },
        { name: 'strTransactionId', type: 'string' },
        { name: 'dblQuantity', type: 'float' },
        { name: 'dblCost', type: 'float' },
        { name: 'dblBeginningBalance', type: 'float' },
        { name: 'dblValue', type: 'float' },
        { name: 'dblRunningBalance', type: 'float' },
        { name: 'strBatchId', type: 'string' }
    ]
});