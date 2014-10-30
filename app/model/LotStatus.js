/**
 * Created by LZabala on 10/30/2014.
 */
Ext.define('Inventory.model.LotStatus', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intLotStatusId',

    fields: [
        { name: 'intLotStatusId', type: 'int'},
        { name: 'strSecondaryStatus', type: 'string'},
        { name: 'strDescription', type: 'string'},
        { name: 'strPrimaryStatus', type: 'string'},
        { name: 'intSort', type: 'int'},
    ]
});