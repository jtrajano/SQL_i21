/**
 * Created by LZabala on 2/19/2015.
 */
Ext.define('Inventory.model.StockReservation', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intStockReservationId',

    fields: [
        { name: 'intStockReservationId', type: 'int', allowNull: true },
        { name: 'intItemId', type: 'int', allowNull: true },
        { name: 'intItemLocationId', type: 'int', allowNull: true },
        { name: 'intItemUOMId', type: 'int', allowNull: true },
        { name: 'dblQuantity', type: 'float' },
        { name: 'intTransactionId', type: 'int', allowNull: true },
        { name: 'strTransactionId', type: 'string' },
        { name: 'intSort', type: 'int', allowNull: true }
    ]
});