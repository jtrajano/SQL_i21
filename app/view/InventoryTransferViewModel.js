Ext.define('Inventory.view.InventoryTransferViewModel', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.icinventorytransfer',

    requires: [
        'i21.store.CompanyLocationBuffered',
        'i21.store.CompanyLocationSubLocationBuffered',
        'i21.store.TaxCodeBuffered',
        'i21.store.UserListBuffered',
        'EntityManagement.store.ShipViaBuffered',
        'Inventory.store.BufferedItemStockView',
        'Inventory.store.BufferedItemStockUOMView',
        'Inventory.store.BufferedStorageLocation',
        'Inventory.store.BufferedLot',
        'Inventory.store.BufferedStatus',
        'Inventory.store.BufferedItemUnitMeasure',
        'Inventory.store.BufferedItemWeightUOM',
        'Inventory.store.BufferedUnitMeasure',
        'Inventory.store.BufferedItemStockUOMViewTotals',
        'GeneralLedger.controls.RecapTab'        
    ],

    stores: {

        transferTypes: {
            data: [
                {
                    strDescription: 'Location to Location'
                },{
                    strDescription: 'Storage to Storage'
                }
            ],
            fields: [
                {
                    name: 'strDescription'
                }
            ]
        },
        sourceTypes: {
            autoLoad: true,
            data: [
                {
                    intSourceType: 0,
                    strSourceType: 'None'
                },
                {
                    intSourceType: 1,
                    strSourceType: 'Scale'
                },
                {
                    intSourceType: 2,
                    strSourceType: 'Inbound Shipment'
                },
                {
                    intSourceType: 3,
                    strSourceType: 'Transports'
                }
            ],
            fields: {
                name: 'intSourceType',
                name: 'strSourceType'
            }
        },
        userList: {
            type: 'userlistbuffered'
        },

        fromLocation: {
            type: 'companylocationbuffered'
        },
        toLocation: {
            type: 'companylocationbuffered'
        },
        uom: {
            type: 'icbuffereduom'
        },
        shipVia: {
            type: 'emshipviabuffered'
        },
        status: {
            type: 'icbufferedstatus'
        },

        itemStock: {
            autoLoad: true,
            type: 'icbuffereditemstockuomview'
        },
        item: {
            type: 'icbuffereditemstockview'
        },
        lot: {
            type: 'icbufferedlot'
        },
        fromSubLocation: {
            type: 'icbuffereditemstockuomviewtotals'
        },
        fromStorageLocation: {
            type: 'icbuffereditemstockuomviewtotals'
        },
        toSubLocation: {
            type: 'smcompanylocationsublocationbuffered'
        },
        toStorageLocation: {
            type: 'icbufferedstoragelocation'
        },
        itemUOM: {
            type: 'icbuffereditemunitmeasure'
        },
        weightUOM: {
            type: 'icbuffereditemweightuom'
        },
        newLot: {
            type: 'icbufferedlot'
        },
        taxCode: {
            type: 'smtaxcodebuffered'
        },
        ownershipTypes: {
            autoLoad: true,
            data: [
                {
                    intOwnershipType: 1,
                    strOwnershipType: 'Own'
                },
                {
                    intOwnershipType: 2,
                    strOwnershipType: 'Storage'
                },
                {
                    intOwnershipType: 3,
                    strOwnershipType: 'Consigned Purchase'
                }
            ],
            fields: {
                name: 'intOwnershipType',
                name: 'strOwnershipType'
            }
        }
    },

    formulas: {
        intCurrencyId: function(get) {
            //Since transfer does not have a currency, return the functional currency. 
            return i21.ModuleMgr.SystemManager.getCompanyPreference('intDefaultCurrencyId');
        },
        
        destinationWeightsDisabled: function(get) {
            if(!(get('current.ysnShipmentRequired') && get('current.strTransferType') === 'Location to Location') || get('current.ysnPosted') || get('current.intSourceType') === 1) {
                return true;
            }
            return false;
        },
        hidePostButton: function(get) {
            var posted = get('current.ysnPosted');

            if (get('current.intSourceType') === 3) {
                return true;
            }
            else {
                return posted;
            }
        },
        hideUnpostButton: function(get) {
            var posted = get('current.ysnPosted');

            if (get('current.intSourceType') === 3) {
                return true;
            }
            else {
                return !posted;
            }
        },
        hideOnLocationToLocation: function(get) {
            if (get('current.strTransferType') === 'Location to Location') {
                return true;
            }
            else {
                return false;
            }
        },
        hideOnStorageToStorage: function(get) {
            if (get('current.strTransferType') === 'Storage to Storage') {
                return true;
            }
            else {
                return false;
            }
        },
        getPostButtonText: function(get) {
            if (get('current.ysnPosted')) {
                return 'UnPost';
            }
            else {
                return 'Post';
            }
        },
        getPostButtonIcon: function(get) {
            if (get('current.ysnPosted')) {
                return 'large-unpost';
            }
            else {
                return 'large-post';
            }
        },
        checkHideSourceNo: function(get) {
            if (get('current.intSourceType') === 0) {
                return true;
            }
            else {
                return false;
            }
        },
        checkLotExists: function(get) {
            if (iRely.Functions.isEmpty(get('grdInventoryTransfer.selection.intLotId'))) {
                return false;
            }
            else {
                return true;
            }
        },
        getAvailableQty: function(get) {
            var intOwnershipType = iRely.Functions.isEmpty(get('grdInventoryTransfer.selection.intOwnershipType'));
            switch (intOwnershipType) {
                case 1:
                    return get('grdInventoryTransfer.selection.dblOriginalAvailableQty');
                    break;
                case 2:
                    return get('grdInventoryTransfer.selection.dblOriginalStorageQty');
                    break;
                default:
                    return get('grdInventoryTransfer.selection.dblOriginalStorageQty');
            }
        },
        readOnlyInventoryTransferField: function(get) {
            if (get('grdInventoryTransfer.selection.intItemId') !== null)
                {
                    return false;
                }
            else
                {
                    return true;
                }
        }
    }

});