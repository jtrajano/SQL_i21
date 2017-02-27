/**
 * Created by FMontefrio on 12/27/2017.
 */
Ext.define('Inventory.model.ItemSubLocations', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intId',

    fields: [
        { name: 'intId', type: 'int'},
        { name: 'strItemNo', type: 'string'},
        { name: 'intItemId', type: 'int'},
        { name: 'intLocationId', type: 'int'},
        { name: 'intItemLocationId', type: 'int'},
        { name: 'intSubLocationId', type: 'int', allowNull: true},
        { name: 'strSubLocationName', type: 'string'},
        { name: 'intCountryId', type: 'int', allowNull: true}
    ]
});