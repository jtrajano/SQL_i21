/**
 * Created by LZabala on 11/11/2015.
 */
Ext.define('Inventory.model.CategoryTax', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intCategoryTaxId',

    fields: [
        { name: 'intCategoryTaxId', type: 'int'},
        { name: 'intCategoryId', type: 'int',
            reference: {
                type: 'Inventory.model.Category',
                inverse: {
                    role: 'tblICCategoryTaxes',
                    storeConfig: {
                        // complete: true,
                        // sortOnLoad: true,
                        // sorters: {
                        //     direction: 'DESC',
                        //     property: 'intSort'
                        // }
                        remoteFilter: true,
                        complete: true,                        
                        proxy: {
                            extraParams: { include: 'vyuICGetCategoryTax' },
                            type: 'rest',
                            api: {
                                read: './inventory/api/categorytax/get'
                            },
                            reader: {
                                type: 'json',
                                rootProperty: 'data',
                                messageProperty: 'message'
                            }
                        },
                        sortOnLoad: true,
                        sorters: {
                            direction: 'ASC',
                            property: 'intSort'
                        }                         
                    }
                }
            }},
        { name: 'intTaxClassId', type: 'int', allowNull: true },

        { name: 'strTaxClass', type: 'string' }
    ]
});