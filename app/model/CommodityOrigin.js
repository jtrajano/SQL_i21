/**
 * Created by LZabala on 11/6/2014.
 */
Ext.define('Inventory.model.CommodityOrigin', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intCommodityAttributeId',

    fields: [
        { name: 'intCommodityAttributeId', type: 'int'},
        { name: 'intCommodityId', type: 'int',
            reference: {
                type: 'Inventory.model.Commodity',
                inverse: {
                    role: 'tblICCommodityOrigins',
                    storeConfig: {
                        complete: true,
                        sortOnLoad: true,
                        sorters: {
                            direction: 'DESC',
                            property: 'intSort'
                        }
                    }
                }
            }
        },
        { name: 'strDescription', type: 'string'},
        { name: 'intSort', type: 'int'},
        { name: 'intDefaultPackingUOMId', type: 'int' },
        { name: 'strDefaultPackingUOM', type: 'string' },
        { name: 'intPurchasingGroupId', type: 'int' },
        { name: 'strPurchasingGroup', type: 'string' },
        { name: 'intCountryID', type: 'int' }
    ],

    validators: [
        {type: 'presence', field: 'strDescription'}
    ]
});