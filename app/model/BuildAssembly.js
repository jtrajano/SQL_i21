/**
 * Created by LZabala on 4/15/2015.
 */
Ext.define('Inventory.model.BuildAssembly', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Inventory.model.BuildAssemblyDetail',
        'Ext.data.Field'
    ],

    idProperty: 'intBuildAssemblyId',

    fields: [
        { name: 'intBuildAssemblyId', type: 'int', allowNull: true },
        { name: 'dtmBuildDate', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d' },
        { name: 'intItemId', type: 'int', allowNull: true },
        { name: 'strBuildNo', type: 'string' },
        { name: 'intLocationId', type: 'int', allowNull: true },
        { name: 'dblBuildQuantity', type: 'float' },
        { name: 'dblCost', type: 'float' },
        { name: 'intSubLocationId', type: 'int', allowNull: true },
        { name: 'intItemUOMId', type: 'int', allowNull: true },
        { name: 'strDescription', type: 'string' },
        { name: 'intSort', type: 'int', allowNull: true }
    ],

    validators: [
        { type: 'presence', field: 'dtmBuildDate' },
        { type: 'presence', field: 'intItemId' },
        { type: 'presence', field: 'intLocationId' },
        { type: 'presence', field: 'intItemUOMId' }
    ]
});