/**
 * Created by LZabala on 10/27/2014.
 */
Ext.define('Inventory.model.ItemBundle', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemBundleId',

    fields: [
        { name: 'intItemBundleId', type: 'int'},
        { name: 'intItemId', type: 'int',
            reference: {
                type: 'Inventory.model.Item',
                inverse: {
                    role: 'tblICItemBundles',
                    storeConfig: {
                        remoteFilter: true,
                        complete: true, 
                        proxy: {
                            type: 'rest',
                            api: {
                                read: './inventory/api/item/searchbundlecomponents'
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
        { name: 'intBundleItemId', type: 'int' },
        { name: 'strDescription', type: 'string' },
        { name: 'dblQuantity', type: 'float', defaultValue: 1.00 },
        { 
            name: 'intItemUnitMeasureId', 
            type: 'int', 
            allowNull: true
        },
        { name: 'dblMarkUpOrDown', type: 'float' },
        { name: 'dtmBeginDate', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d'},
        { name: 'dtmEndDate', type: 'date', dateFormat: 'c', dateWriteFormat: 'Y-m-d' },
        { name: 'strComponentItemNo', type: 'string', auditKey: true },
        { name: 'strUnitMeasure', type: 'string' }
    ],

    validators: [
        {type: 'presence', field: 'strComponentItemNo'}
    ],

    validate: function(options){
        var errors = this.callParent(arguments),
            current = this.getAssociatedData();
        
        if(current && current.intItem.strBundleType == 'Kit' && iRely.Functions.isEmpty(this.get('strUnitMeasure'))){
            errors.add({
                field: 'strUnitMeasure',
                message: 'Must be present.'
            });
        }

        return errors;

    }
});