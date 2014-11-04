/**
 * Created by LZabala on 11/4/2014.
 */
Ext.define('Inventory.model.Catalog', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intBrandId',

    fields: [
        { name: 'intCatalogId', type: 'int'},
        { name: 'intParentCatalogId', type: 'int',
            reference: {
                type: 'Inventory.model.Catalog',
                role: 'ParentCatalog',
                inverse: 'children'
            }
        },
        { name: 'strCatalogName', type: 'string'},
        { name: 'strDescription', type: 'string'},
        { name: 'intSort', type: 'int'},
        { name: 'ysnLeaf', type: 'boolean'}
    ]
});