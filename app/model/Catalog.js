/**
 * Created by LZabala on 11/4/2014.
 */
Ext.define('Inventory.model.Catalog', {
    extend: 'Ext.data.TreeModel',

    requires: [
        'Ext.data.Field'
    ],

    fields: [
        { name: 'intCatalogId', type: 'int'},
        { name: 'intParentCatalogId', type: 'int',
            reference: {
                type: 'i21.model.Catalog',
                role: 'ParentCatalog',
                inverse: 'children'
            }},
        { name: 'strCatalogName', type: 'string'},
        { name: 'strDescription', type: 'string'},
        { name: 'intSort', type: 'int'},
        { name: 'ysnLeaf', type: 'boolean'}
    ],

    validators: [
        {type: 'presence', field: 'strCatalogName'}
    ]
});