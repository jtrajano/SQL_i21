/**
 * Created by LZabala on 10/20/2014.
 */
Ext.define('Inventory.model.ItemStock', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemStockId',

    fields: [
        { name: 'intItemStockId', type: 'int'},
        { name: 'intItemId', type: 'int',
            reference: {
                type: 'Inventory.model.Item',
                inverse: {
                    role: 'tblICItemStocks',
                    storeConfig: {
                        remoteFilter: true,
                        proxy: {
                            //extraParams: { include: 'tblICItemLocation.vyuICGetItemLocation' },
                            type: 'rest',
                            api: {
                                read: '../Inventory/api/ItemStock/Get'
                            },
                            reader: {
                                type: 'json',
                                rootProperty: 'data',
                                messageProperty: 'message'
                            }
                        },
                        sortOnLoad: true,
                        sorters: {
                            direction: 'DESC',
                            property: 'intSort'
                        }
                    }
                }
            }
        },
        { name: 'intItemLocationId', type: 'int', allowNull: true },
        { name: 'dblOnOrder', type: 'float' },
        { name: 'dblInTransitInbound', type: 'float' },
        { name: 'dblUnitOnHand', type: 'float' },
        { name: 'dblInTransitOutbound', type: 'float' },
        { name: 'dblBackOrder', type: 'float' },
        { name: 'dblOrderCommitted', type: 'float' },
        { name: 'dblUnitStorage', type: 'float' },
        { name: 'dblConsignedPurchase', type: 'float' },
        { name: 'dblConsignedSale', type: 'float' },
        { name: 'dblUnitReserved', type: 'float' },
        { name: 'dblLastCountRetail', type: 'float' },
        { name: 'dblAvailable', type: 'float',
            persist: false,
            convert: function(value, record){
                var dblUnitOnHand = iRely.Functions.isEmpty(record.get('dblUnitOnHand')) ? 0 : record.get('dblUnitOnHand');
                var dblUnitReserved = iRely.Functions.isEmpty(record.get('dblUnitReserved')) ? 0 : record.get('dblUnitReserved');
                var dblInTransitOutbound = iRely.Functions.isEmpty(record.get('dblInTransitOutbound')) ? 0 : record.get('dblInTransitOutbound');
                var dblConsignedSale = iRely.Functions.isEmpty(record.get('dblConsignedSale')) ? 0 : record.get('dblConsignedSale');
                var dblAvailable = (dblUnitOnHand - (dblUnitReserved + dblConsignedSale));
                return dblAvailable;
            },
            depends: ['dblUnitOnHand', 'dblUnitReserved', 'dblInTransitOutbound', 'dblConsignedSale']
        },
        { name: 'intSort', type: 'int', allowNull: true },
        { name: 'dblCalculatedBackOrder', type: 'float',
            persist: false,
            convert: function(value, record){
                var dblAvailable = iRely.Functions.isEmpty(record.get('dblAvailable')) ? 0 : record.get('dblAvailable');
                var dblOrderCommitted = iRely.Functions.isEmpty(record.get('dblOrderCommitted')) ? 0 : record.get('dblOrderCommitted');
                var dblBackOrder = dblOrderCommitted > dblAvailable && dblAvailable > 0 ? Math.abs(dblOrderCommitted - dblAvailable) : 0;
                return dblBackOrder;
            },
            depends: ['dblAvailable', 'dblOrderCommitted']
        }

    ],

    validators: [
        {type: 'presence', field: 'strLocationName'}
    ]
});