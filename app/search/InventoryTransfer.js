Ext.define('Inventory.search.InventoryTransfer', {
    alias: 'search.icinventorytransfer',
    singleton: true,

    searchConfigs: [
        {
            title: 'Search Inventory Transfer',
            type: 'Inventory.InventoryTransfer',
            api: {
                read: '../Inventory/api/InventoryTransfer/Search'
            },
            columns: [

                { dataIndex: 'intInventoryTransferId', text: 'Inventory Transfer Id', flex: 1, dataType: 'numeric', defaultSort: true, sortOrder: 'DESC', key: true, hidden: true },
                { dataIndex: 'strTransferNo', text: 'Transfer No', flex: 1, dataType: 'string', drillDownText: 'View Transfer', drillDownClick: 'onViewTransfer' },
                { dataIndex: 'dtmTransferDate', text: 'Transfer Date', flex: 1, dataType: 'date', xtype: 'datecolumn' },
                { dataIndex: 'strTransferType', text: 'Transfer Type', flex: 1, dataType: 'string' },
                { dataIndex: 'strSourceType', text: 'Source Type', flex: 1, dataType: 'string', hidden: true },
                { dataIndex: 'strTransferredBy', text: 'Transferred By', flex: 1, dataType: 'string', hidden: true },
                { dataIndex: 'strDescription', text: 'Description', flex: 1, dataType: 'string' },
                { dataIndex: 'strFromLocation', text: 'From Location', flex: 1, dataType: 'string', drillDownText: 'View Location', drillDownClick: 'onViewLocation' },
                { dataIndex: 'strToLocation', text: 'To Location', flex: 1, dataType: 'string', drillDownText: 'View Location', drillDownClick: 'onViewLocation' },
                { dataIndex: 'ysnShipmentRequired', text: 'Shipment Required', flex: 1, dataType: 'boolean', xtype: 'checkcolumn', hidden: true },
                { dataIndex: 'strStatus', text: 'Status', flex: 1, dataType: 'string' },
                { dataIndex: 'ysnPosted', text: 'Posted', flex: 1, dataType: 'boolean', xtype: 'checkcolumn' },
                { dataIndex: 'strName', text: 'User', flex: 1, dataType: 'string', hidden: true },
                { dataIndex: 'intSort', text: 'Sort', flex: 1, dataType: 'numeric', hidden: true }
            ]
        },
        {
            title: 'Details',
            api: {
                read: '../Inventory/api/InventoryTransfer/SearchTransferDetails'
            },
            columns: [
                { dataIndex: 'intInventoryTransferId', text: 'InventoryTransferId', width: 100, defaultSort: true, sortOrder: 'DESC', dataType: 'numeric', key: true, hidden: true },
                { dataIndex: 'intInventoryTransferDetailId', text: 'InventoryTransferDetailId', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'intFromLocationId', text: 'FromLocationId', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'intToLocationId', text: 'ToLocationId', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strTransferNo', text: 'TransferNo', width: 100, dataType: 'string', drillDownText: 'View Transfer', drillDownClick: 'onViewTransfer' },
                { dataIndex: 'intSourceId', text: 'SourceId', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strSourceNumber', text: 'SourceNumber', width: 100, dataType: 'string' },
                { dataIndex: 'intItemId', text: 'ItemId', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strItemNo', text: 'ItemNo', width: 100, dataType: 'string', drillDownText: 'View Item', drillDownClick: 'onViewItem' },
                { dataIndex: 'strItemDescription', text: 'ItemDescription', width: 100, dataType: 'string', drillDownText: 'View Item', drillDownClick: 'onViewItem' },
                { dataIndex: 'strLotTracking', text: 'LotTracking', width: 100, dataType: 'string' },
                { dataIndex: 'intCommodityId', text: 'CommodityId', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strLotNumber', text: 'LotNumber', width: 100, dataType: 'string' },
                { dataIndex: 'intLifeTime', text: 'LifeTime', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strLifeTimeType', text: 'LifeTimeType', width: 100, dataType: 'string' },
                { dataIndex: 'intFromSubLocationId', text: 'FromSubLocationId', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strFromSubLocationName', text: 'FromSubLocationName', width: 100, dataType: 'string' },
                { dataIndex: 'intToSubLocationId', text: 'ToSubLocationId', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strToSubLocationName', text: 'ToSubLocationName', width: 100, dataType: 'string' },
                { dataIndex: 'intFromStorageLocationId', text: 'FromStorageLocationId', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strFromStorageLocationName', text: 'FromStorageLocationName', width: 100, dataType: 'string', drillDownText: 'View Storage Location', drillDownClick: 'onViewStorageLocation' },
                { dataIndex: 'intToStorageLocationId', text: 'ToStorageLocationId', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strToStorageLocationName', text: 'ToStorageLocationName', width: 100, dataType: 'string', drillDownText: 'View Storage Location', drillDownClick: 'onViewStorageLocation' },
                { dataIndex: 'intItemUOMId', text: 'ItemUOMId', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strUnitMeasure', text: 'UnitMeasure', width: 100, dataType: 'string', drillDownText: 'View Inventory UOM', drillDownClick: 'onViewUOM' },
                { dataIndex: 'dblItemUOMCF', text: 'ItemUOMCF', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                { dataIndex: 'intWeightUOMId', text: 'WeightUOMId', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strWeightUOM', text: 'WeightUOM', width: 100, dataType: 'string', drillDownText: 'View Inventory UOM', drillDownClick: 'onViewUOM' },
                { dataIndex: 'dblWeightUOMCF', text: 'WeightUOMCF', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                { dataIndex: 'strAvailableUOM', text: 'AvailableUOM', width: 100, dataType: 'string', drillDownText: 'View Inventory UOM', drillDownClick: 'onViewUOM' },
                { dataIndex: 'dblLastCost', text: 'LastCost', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                { dataIndex: 'dblOnHand', text: 'OnHand', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                { dataIndex: 'dblOnOrder', text: 'OnOrder', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                { dataIndex: 'dblReservedQty', text: 'ReservedQty', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                { dataIndex: 'dblAvailableQty', text: 'AvailableQty', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                { dataIndex: 'dblQuantity', text: 'Quantity', width: 100, dataType: 'float', xtype: 'numbercolumn' },
                { dataIndex: 'intOwnershipType', text: 'OwnershipType', width: 100, dataType: 'numeric', hidden: true },
                { dataIndex: 'strOwnershipType', text: 'OwnershipType', width: 100, dataType: 'string' },
                { dataIndex: 'ysnPosted', text: 'Posted', width: 100, dataType: 'boolean', xtype: 'checkcolumn' }
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
    onViewTransfer: function (value, record) {
        i21.ModuleMgr.Inventory.showScreen(value, 'TransferNo');
    },

    onViewItem: function (value, record) {
        var ItemId = record.get('intItemId');
        i21.ModuleMgr.Inventory.showScreen(ItemId, 'ItemId');
    },

    onViewLocation: function (value, record) {
        i21.ModuleMgr.Inventory.showScreen(value, 'LocationName');
    },

    onViewStorageLocation: function (value, record) {
        i21.ModuleMgr.Inventory.showScreen(value, 'StorageLocation');
    },

    onViewUOM: function (value, record) {
        i21.ModuleMgr.Inventory.showScreen(value, 'UOM');
    }
});