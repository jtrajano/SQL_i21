/**
 * Created by LZabala on 9/17/2014.
 */
Ext.define('Inventory.model.ItemUOM', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
        //'AccountsPayable.common.validators.NotZero'
    ],

    idProperty: 'intItemUOMId',

    fields: [
        { name: 'intItemUOMId', type: 'int'},
        { name: 'intItemId',
            type: 'int',
            reference: {
                type: 'Inventory.model.Item',
                inverse: {
                    role: 'tblICItemUOMs',
                    storeConfig: {
                        remoteFilter: true,
                        complete: true,
                        proxy: {
                            extraParams: { include: 'tblICUnitMeasure, WeightUOM, DimensionUOM, VolumeUOM, tblICUnitMeasure.vyuICGetUOMConversions' },
                            type: 'rest',
                            api: {
                                read: './inventory/api/itemuom/get'
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
                            property: 'intItemUOMId'
                        }
                    }
                }
            }
        },
        { name: 'intUnitMeasureId', type: 'int', allowNull: true },
        { name: 'dblUnitQty', type: 'float' },
        { name: 'dblSellQty', type: 'float' },
        { name: 'strDescription', type: 'string' },
        { 
            name: 'strUpcCode', 
            type: 'string', 
            allowNull: true, 
            convert: function (value, record){
                if (Ext.isString(value) && value.length > 0){
                    return value;
                } 
                return null;                
            }
        },
        {
            name: 'strLongUPCCode', 
            type: 'string', 
            allowNull: true,
            convert: function (value, record){
                if (Ext.isString(value) && value.length > 0){
                    return value;
                } 
                return null;                
            }            
        },
        { name: 'ysnStockUnit', type: 'boolean' },
        { name: 'ysnStockUOM', type: 'boolean' },
        { name: 'ysnAllowPurchase', type: 'boolean' },
        { name: 'ysnAllowSale', type: 'boolean' },
        { name: 'dblLength', type: 'float' },
        { name: 'dblWidth', type: 'float' },
        { name: 'dblHeight', type: 'float' },
        //{ name: 'intDimensionUOMId', type: 'int', allowNull: true },
        { name: 'dblVolume', type: 'float' },
        //{ name: 'intVolumeUOMId', type: 'int', allowNull: true },
        { name: 'dblMaxQty', type: 'float' },
        { name: 'intSort', type: 'int', allowNull: true },
        { name: 'strUnitMeasure', type: 'string', auditKey: true}
    ],

    validators: [
        {type: 'presence', field: 'strUnitMeasure'}
        //{type: 'notzero', field: 'dblUnitQty'}
    ], 

    validate: function(options){
        var errors = this.callParent(arguments);
        var dblUnitQty = this.get('dblUnitQty');
        dblUnitQty = Ext.isNumeric(dblUnitQty) ? dblUnitQty : 0;
        if(dblUnitQty == 0)
        {
            errors.add({
                field: 'dblUnitQty',
                message: 'Zero is not allowed.' 
            });
        }
        return errors;        
    }
});