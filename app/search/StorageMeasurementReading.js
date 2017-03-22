Ext.define('Inventory.search.StorageMeasurementReading', {
    alias: 'search.storagemeasurementreading',
    singleton: true,

    searchConfigs: [
        {
            title: 'Search Storage Measurement Reading',
            type: 'Inventory.StorageMeasurementReading',
            api: {
                read: '../Inventory/api/StorageMeasurementReading/Search'
            },
            columns: [
                { dataIndex: 'intLocationId', text: 'Location', flex: 1, dataType: 'numeric', key: true, hidden: true },
                { dataIndex: 'strLocationName', text: 'Location', flex: 1, dataType: 'string' },
                { dataIndex: 'dtmDate', text: 'Date', flex: 1, dataType: 'datetime', xtype: 'datecolumn' },
                { dataIndex: 'strReadingNo', text: 'Reading No', flex: 1, dataType: 'string' },
                { dataIndex: 'intStorageMeasurementReadingId', key: true, text: 'Reading Id', flex: 1, defaultSort: true, sortOrder: 'DESC', dataType: 'numeric', hidden: true }
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
    }
});