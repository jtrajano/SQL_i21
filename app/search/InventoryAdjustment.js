Ext.define('Inventory.search.InventoryAdjustment', {
    alias: 'search.icinventoryadjustment',
    singleton: true,

    searchConfigs: [
        {
            title: 'Search Inventory Adjustment',
            type: 'Inventory.InventoryAdjustment',
            api: {
                read: '../Inventory/api/InventoryAdjustment/Search'
            },
            columns: [
                { dataIndex: 'intInventoryAdjustmentId', text: 'Inventory Adjustment Id', flex: 1, defaultSort: true, sortOrder: 'DESC', dataType: 'numeric', key: true, hidden: true },
                { dataIndex: 'intLocationId', text: 'Location Id', flex: 1, dataType: 'numeric', hidden: true },
                { dataIndex: 'strLocationName', text: 'Location Name', flex: 1, dataType: 'string', drillDownText: 'View Location', drillDownClick: 'onViewLocation' },
                { dataIndex: 'dtmAdjustmentDate', text: 'Adjustment Date', flex: 1, dataType: 'date', xtype: 'datecolumn' },
                { dataIndex: 'intAdjustmentType', text: 'Adjustment Type', flex: 1, dataType: 'numeric', hidden: true },
                { dataIndex: 'strAdjustmentType', text: 'Adjustment Type', flex: 1, dataType: 'string' },
                { dataIndex: 'strAdjustmentNo', text: 'Adjustment No', flex: 1, dataType: 'string', drillDownText: 'View Adjustment', drillDownClick: 'onViewAdjustment' },
                { dataIndex: 'strDescription', text: 'Description', flex: 1, dataType: 'string' },
                { dataIndex: 'ysnPosted', text: 'Posted', flex: 1, dataType: 'boolean', xtype: 'checkcolumn' },
                { dataIndex: 'intEntityId', text: 'Entity Id', flex: 1, dataType: 'numeric', hidden: true },
                { dataIndex: 'strUser', text: 'User', flex: 1, dataType: 'string', hidden: true },
                { dataIndex: 'dtmPostedDate', text: 'Posted Date', flex: 1, dataType: 'date', xtype: 'datecolumn', hidden: true },
                { dataIndex: 'dtmUnpostedDate', text: 'Unposted Date', flex: 1, dataType: 'date', xtype: 'datecolumn', hidden: true },
                { dataIndex: 'intSourceId', text: 'Source Id', flex: 1, dataType: 'numeric', hidden: true },
                { dataIndex: 'intSourceTransactionTypeId', text: 'Source Transaction Type Id', flex: 1, dataType: 'numeric', hidden: true }
            ]
        },
        {
            title: 'Details',
            api: {
                read: '../Inventory/api/InventoryAdjustment/SearchAdjustmentDetails'
            },
            columns: [
                { dataIndex: 'intInventoryAdjustmentDetailId', text: 'Inventory Adjustment Detail Id', width: 100, defaultSort: true, sortOrder: 'DESC', dataType: 'numeric', hidden: true },
                { dataIndex: 'intInventoryAdjustmentId', text: 'Inventory Adjustment Id', width: 100, key: true, dataType: 'numeric', hidden: true },
                { dataIndex: 'intLocationId', text: 'Location Id', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strLocationName', text: 'Location Name', width: 100, dataType: 'string', hidden: true },
                { dataIndex: 'dtmAdjustmentDate', text: 'Adjustment Date', width: 100, dataType: 'date', xtype: 'datecolumn', hidden: true },
                { dataIndex: 'intAdjustmentType', text: 'Adjustment Type', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strAdjustmentType', text: 'Adjustment Type', width: 100, dataType: 'string', hidden: true },
                { dataIndex: 'strAdjustmentNo', text: 'Adjustment No', width: 100, dataType: 'string', drillDownText: 'View Adjustment', drillDownClick: 'onViewAdjustment' },
                { dataIndex: 'strDescription', text: 'Description', width: 100, dataType: 'string', hidden: true },
                { dataIndex: 'ysnPosted', text: 'Posted', width: 100, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                { dataIndex: 'intEntityId', text: 'Entity Id', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strUser', text: 'User', width: 100, dataType: 'string', hidden: true },
                { dataIndex: 'dtmPostedDate', text: 'Posted Date', width: 100, dataType: 'date', xtype: 'datecolumn', hidden: true },
                { dataIndex: 'dtmUnpostedDate', text: 'Unposted Date', width: 100, dataType: 'date', xtype: 'datecolumn', hidden: true },
                { dataIndex: 'intSubLocationId', text: 'SubLocation Id', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strSubLocationName', text: 'SubLocation Name', width: 100, dataType: 'string' },
                { dataIndex: 'intStorageLocationId', text: 'Storage Location Id', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strStorageLocationName', text: 'Storage Location Name', width: 100, dataType: 'string', drillDownText: 'View Storage Location', drillDownClick: 'onViewStorageLocation' },
                { dataIndex: 'intItemId', text: 'Item Id', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strItemNo', text: 'Item No', width: 100, dataType: 'string', drillDownText: 'View Item', drillDownClick: 'onViewItem' },
                { dataIndex: 'strItemDescription', text: 'Item Description', width: 100, dataType: 'string' },
                { dataIndex: 'strLotTracking', text: 'Lot Tracking', width: 100, dataType: 'string', hidden: true },
                { dataIndex: 'intNewItemId', text: 'New Item Id', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strNewItemNo', text: 'New Item No', width: 100, dataType: 'string', drillDownText: 'View Item', drillDownClick: 'onViewItem' },
                { dataIndex: 'strNewItemDescription', text: 'New Item Description', width: 100, dataType: 'string' },
                { dataIndex: 'strNewLotTracking', text: 'New Lot Tracking', width: 100, dataType: 'string', hidden: true },
                { dataIndex: 'intLotId', text: 'Lot Id', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strLotNumber', text: 'Lot Number', width: 100, dataType: 'string' },
                { dataIndex: 'dblLotQty', text: 'Lot Qty', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                { dataIndex: 'dblLotUnitCost', text: 'Lot Unit Cost', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                { dataIndex: 'dblLotWeightPerQty', text: 'Lot Weight Per Qty', width: 100, dataType: 'float', xtype: 'numbercolumn', hidden: true },
                { dataIndex: 'intNewLotId', text: 'New Lot Id', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strNewLotNumber', text: 'New Lot Number', width: 100, dataType: 'string' },
                { dataIndex: 'dblQuantity', text: 'Available Qty', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                { dataIndex: 'dblNewQuantity', text: 'New Quantity', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                { dataIndex: 'dblNewSplitLotQuantity', text: 'New Split Lot Quantity', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                { dataIndex: 'dblAdjustByQuantity', text: 'Adjust By Quantity', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                { dataIndex: 'intItemUOMId', text: 'Item UOM Id', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strItemUOM', text: 'Item UOM', width: 100, dataType: 'string', drillDownText: 'View Inventory UOM', drillDownClick: 'onViewUOM' },
                { dataIndex: 'dblItemUOMUnitQty', text: 'Item UOM Unit Qty', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                { dataIndex: 'intNewItemUOMId', text: 'New Item UOM Id', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strNewItemUOM', text: 'New Item UOM', width: 100, dataType: 'string', drillDownText: 'View Inventory UOM', drillDownClick: 'onViewUOM' },
                { dataIndex: 'dblNewItemUOMUnitQty', text: 'New Item UOM Unit Qty', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                { dataIndex: 'intWeightUOMId', text: 'Weight UOM Id', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strWeightUOM', text: 'Weight UOM', width: 100, dataType: 'string', drillDownText: 'View Inventory UOM', drillDownClick: 'onViewUOM' },
                { dataIndex: 'intNewWeightUOMId', text: 'New Weight UOM Id', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strNewWeightUOM', text: 'New Weight UOM', width: 100, dataType: 'string', drillDownText: 'View Inventory UOM', drillDownClick: 'onViewUOM' },
                { dataIndex: 'dblWeight', text: 'Weight', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                { dataIndex: 'dblNewWeight', text: 'New Weight', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                { dataIndex: 'dblWeightPerQty', text: 'Weight Per Qty', width: 100, dataType: 'float', xtype: 'numbercolumn', hidden: true },
                { dataIndex: 'dblNewWeightPerQty', text: 'New Weight Per Qty', width: 100, dataType: 'float', xtype: 'numbercolumn', hidden: true },
                { dataIndex: 'dtmExpiryDate', text: 'Expiry Date', width: 100, dataType: 'date', xtype: 'datecolumn' },
                { dataIndex: 'dtmNewExpiryDate', text: 'New Expiry Date', width: 100, dataType: 'date', xtype: 'datecolumn' },
                { dataIndex: 'intLotStatusId', text: 'Lot Status Id', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strLotStatus', text: 'Lot Status', width: 100, dataType: 'string', drillDownText: 'View Lot Status', drillDownClick: 'onViewLotStatus' },
                { dataIndex: 'intNewLotStatusId', text: 'New Lot Status Id', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strNewLotStatus', text: 'New Lot Status', width: 100, dataType: 'string', drillDownText: 'View Lot Status', drillDownClick: 'onViewLotStatus' },
                { dataIndex: 'dblCost', text: 'Cost', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                { dataIndex: 'dblNewCost', text: 'New Cost', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                { dataIndex: 'intNewLocationId', text: 'New Location Id', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strNewLocationName', text: 'New Location Name', width: 100, dataType: 'string', drillDownText: 'View Location', drillDownClick: 'onViewLocation' },
                { dataIndex: 'intNewSubLocationId', text: 'New SubLocation Id', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strNewSubLocationName', text: 'New SubLocation Name', width: 100, dataType: 'string' },
                { dataIndex: 'intNewStorageLocationId', text: 'New Storage Location Id', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strNewStorageLocationName', text: 'New Storage Location Name', width: 100, dataType: 'string', drillDownText: 'View Storage Location', drillDownClick: 'onViewStorageLocation' },
                { dataIndex: 'dblLineTotal', text: 'LineTotal', width: 100, dataType: 'float', xtype: 'numbercolumn' }
            ]
        }
    ],

    buttons: [
        {
            text: 'Items',
            itemId: 'btnItem',
            clickHandler: 'onItemClick',
            width: 80
        },
        {
            text: 'Categories',
            itemId: 'btnCategory',
            clickHandler: 'onCategoryClick',
            width: 100
        },
        {
            text: 'Commodities',
            itemId: 'btnCommodity',
            clickHandler: 'onCommodityClick',
            width: 100
        },
        {
            text: 'Locations',
            itemId: 'btnLocation',
            clickHandler: 'onLocationClick',
            width: 100
        },
        {
            text: 'Storage Locations',
            itemId: 'btnStorageLocation',
            clickHandler: 'onStorageLocationClick',
            width: 110
        }
    ],

    onItemClick: function () {
        iRely.Functions.openScreen('Inventory.view.Item', { action: 'new', viewConfig: { modal: true } });
    },

    onCategoryClick: function () {
        iRely.Functions.openScreen('Inventory.view.Category', { action: 'new', viewConfig: { modal: true } });
    },

    onCommodityClick: function () {
        iRely.Functions.openScreen('Inventory.view.Commodity', { action: 'new', viewConfig: { modal: true } });
    },

    onLocationClick: function () {
        iRely.Functions.openScreen('i21.view.CompanyLocation', { action: 'new', viewConfig: { modal: true } });
    },

    onStorageLocationClick: function () {
        iRely.Functions.openScreen('Inventory.view.StorageUnit', { action: 'new', viewConfig: { modal: true } });
    },

    /* Drilldown Handlers */
    onViewLocation: function (value, record) {
        i21.ModuleMgr.Inventory.showScreen(value, 'LocationName');
    },

    onViewAdjustment: function (value, record) {
        i21.ModuleMgr.Inventory.showScreen(value, 'AdjustmentNo');
    },

    onViewStorageLocation: function (value, record) {
        i21.ModuleMgr.Inventory.showScreen(value, 'StorageLocation');
    },

    onViewItem: function (value, record) {
        i21.ModuleMgr.Inventory.showScreen(value, 'ItemNo');
    },

    onViewUOM: function (value, record) {
        i21.ModuleMgr.Inventory.showScreen(value, 'UOM');
    },

    onViewLotStatus: function (value, record) {
        i21.ModuleMgr.Inventory.showScreen(value, 'LotStatus');
    }
});