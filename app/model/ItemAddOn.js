Ext.define('Inventory.model.ItemAddOn', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemAddOnId',

    fields: [
        { name: 'intItemAddOnId', type: 'int'},
        { name: 'intItemId', type: 'int',
            reference: {
                type: 'Inventory.model.Item',
                inverse: {
                    role: 'tblICItemAddOns',
                    storeConfig: {
                        remoteFilter: true,
                        complete: true, 
                        proxy: {
                            type: 'rest',
                            api: {
                                read: './inventory/api/item/searchaddons'
                            },
                            reader: {
                                type: 'json',
                                rootProperty: 'data',
                                messageProperty: 'message'
                            }
                        },
                        sortOnLoad: true
                    }
                }
            }},
        { name: 'intAddOnItemId', type: 'int' },
        { name: 'dblQuantity', type: 'float', defaultValue: 1.00 },
        { name: 'intItemUOMId', type: 'int', allowNull: true },
        { name: 'strAddOnItemNo', type: 'string', auditKey: true },
        { name: 'strUnitMeasure', type: 'string' },
        { name: 'strDescription', type: 'string' }
    ],

    validators: [
        {type: 'presence', field: 'strAddOnItemNo'},
        {type: 'presence', field: 'strUnitMeasure'}
    ]
});