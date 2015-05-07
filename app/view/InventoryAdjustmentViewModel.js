Ext.define('Inventory.view.InventoryAdjustmentViewModel', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.icinventoryadjustment',

    requires: [
        'i21.store.CompanyLocationBuffered',
        'i21.store.CompanyLocationSubLocationBuffered',
        'GeneralLedger.store.BufAccountId',
        'GeneralLedger.store.BufAccountCategoryGroup',
        'Inventory.store.BufferedItemStockView',
        'Inventory.store.BufferedStorageLocation',
        'Inventory.store.BufferedLot',
        'Inventory.store.BufferedPostedLot',
        'Inventory.store.BufferedItemUnitMeasure',
        'Inventory.store.BufferedItemWeightUOM',
        'Inventory.store.BufferedLotStatus'
    ],

    stores: {
        location: {
            type: 'companylocationbuffered'
        },
        adjustmentTypes: {
            data: [
                {
                    intAdjustmentTypeId : '1',
                    strDescription: 'Quantity Change'
                },{
                    intAdjustmentTypeId : '2',
                    strDescription: 'UOM Change'
                },{
                    intAdjustmentTypeId : '3',
                    strDescription: 'Item Change'
                },{
                    intAdjustmentTypeId : '4',
                    strDescription: 'Lot Status Change'
                },{
                    intAdjustmentTypeId : '5',
                    strDescription: 'Split Lot'
                },{
                    intAdjustmentTypeId : '6',
                    strDescription: 'Expiry Date Change'
                }
            ],
            fields: [
                {
                    type: 'int',
                    name: 'intAdjustmentTypeId'
                },
                {
                    name: 'strDescription'
                }
            ]
        },

        item: {
            type: 'icbuffereditemstockview'
        },
        subLocation: {
            type: 'smcompanylocationsublocationbuffered'
        },
        storageLocation: {
            type: 'icbufferedstoragelocation'
        },
        lot: {
            type: 'icbufferedpostedlot'
        },
        newLot: {
            type: 'icbufferedlot'
        },
        newItemUOM: {
            type: 'icbuffereditemunitmeasure'
        },
        weightUOM: {
            type: 'icbuffereditemweightuom'
        },
        newWeightUOM: {
            type: 'icbuffereditemweightuom'
        },
        newItem: {
            type: 'icbuffereditemstockview'
        },
        newLotStatus: {
            type: 'icbufferedlotstatus'
        },
        newLocation: {
            type: 'companylocationbuffered'
        },
        newSubLocation: {
            type: 'smcompanylocationsublocationbuffered'
        },
        newStorageLocation: {
            type: 'icbufferedstoragelocation'
        }
    },

    formulas: {
        formulaShowLotNumberEditor: function(get){
            var hide = true
                ,show = false;

            var posted = get('current.ysnPosted');
            if (posted){
                return hide;
            }
            else {
                var itemId = get('grdInventoryAdjustment.selection.intItemId');
                if (!Ext.isNumeric(itemId))
                    return hide;

                var lotTracking = get('grdInventoryAdjustment.selection.strLotTracking');
                if (lotTracking == 'No'){
                    return hide;
                }
                else {
                    return show;
                }
            }
        }
    }

});