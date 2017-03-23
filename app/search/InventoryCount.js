Ext.define('Inventory.search.InventoryCount', {
    alias: 'search.icinventorycount',
    singleton: true,

    searchConfigs: [
        {
            title: 'Search Inventory Count',
            type: 'Inventory.InventoryCount',
            api: {
                read: '../Inventory/api/InventoryCount/Search'
            },
            columns: [
                { dataIndex: 'intInventoryCountId', text: "Count Id", flex: 1, defaultSort: true, sortOrder: 'DESC', dataType: 'numeric', key: true, hidden: true },
                { dataIndex: 'strCountNo', text: 'Count No', flex: 1, dataType: 'string' },
                { dataIndex: 'strLocationName', text: 'Location', flex: 1, dataType: 'string' },
                { dataIndex: 'strCategory', text: 'Category', flex: 1, dataType: 'string' },
                { dataIndex: 'strCommodity', text: 'Commodity', flex: 1, dataType: 'string' },
                { dataIndex: 'strCountGroup', text: 'Count Group', flex: 1, dataType: 'string' },
                { dataIndex: 'dtmCountDate', text: 'Count Date', flex: 1, dataType: 'date', xtype: 'datecolumn' },
                { dataIndex: 'strSubLocationName', text: 'Sub Location', flex: 1, dataType: 'string' },
                { dataIndex: 'strStorageLocationName', text: 'Storage Location', flex: 1, dataType: 'string' },
                { dataIndex: 'strStatus', text: 'Status', flex: 1, dataType: 'string' }
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
        },
        {
            text: 'Count Group',
            itemId: 'btnCountGroup',
            clickHandler: 'onCountGroupClick',
            width: 80
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

    onCountGroupClick: function () {
        iRely.Functions.openScreen('Inventory.view.InventoryCountGroup', { action: 'new', viewConfig: { modal: true } });
    }
});