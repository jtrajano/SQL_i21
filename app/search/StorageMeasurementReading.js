Ext.define('Inventory.search.StorageMeasurementReading', {
    alias: 'search.icstoragemeasurementreading',
    singleton: true,

    searchConfigs: [
        {
            title: 'Search Storage Measurement Reading',
            type: 'Inventory.StorageMeasurementReading',
            api: {
                read: '../inventory/api/storagemeasurementreading/search'
            },
            columns: [
                { dataIndex: 'intLocationId', text: 'Location', flex: 1, dataType: 'numeric', key: true, hidden: true },
                { dataIndex: 'strLocationName', text: 'Location', flex: 1, dataType: 'string' },
                { dataIndex: 'dtmDate', text: 'Date', flex: 1, dataType: 'datetime', xtype: 'datecolumn' },
                { dataIndex: 'strReadingNo', text: 'Reading No', flex: 1, dataType: 'string' },
                { dataIndex: 'intStorageMeasurementReadingId', key: true, text: 'Reading Id', flex: 1, defaultSort: true, sortOrder: 'DESC', dataType: 'numeric', hidden: true }
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
                    text: 'Storage Units',
                    itemId: 'btnStorageLocation',
                    clickHandler: 'onStorageLocationClick',
                    width: 110
                }
            ]
        },
        {
            title: 'Search Reading Details',
            type: 'Inventory.StorageMeasurementReading',
            api: {
                read: '../inventory/api/storagemeasurementreading/searchstoragemeasurementreadingconversion'
            },
            columns: [
                { dataIndex: 'intStorageMeasurementReadingConversionId', key: true, dataType: 'numeric', text: "Storage Measurement Reading Conversion Id", hidden: true, flex: 1 },
                { dataIndex: 'intStorageMeasurementReadingId', dataType: 'numeric', text: "Storage Measurement Reading Id", hidden: true, flex: 1 },
                { dataIndex: 'strReadingNo', dataType: 'string', text: "Reading No", hidden: false, flex: 1 },
                { dataIndex: 'dtmDate', dataType: 'datetime', text: "Date", hidden: false, flex: 1, xtype: 'datecolumn' },
                { dataIndex: 'intCommodityId', dataType: 'numeric', text: "Commodity Id", hidden: true, flex: 1 },
                { dataIndex: 'strCommodity', dataType: 'string', text: "Commodity", hidden: false, flex: 1 },
                { dataIndex: 'intItemId', dataType: 'numeric', text: "Item Id", hidden: true, flex: 1 },
                { dataIndex: 'strItemNo', dataType: 'string', text: "Item No", hidden: false, flex: 1 },
                { dataIndex: 'intStorageLocationId', dataType: 'numeric', text: "Storage Unit Id", hidden: true, flex: 1 },
                { dataIndex: 'strStorageLocationName', dataType: 'string', text: "Storage Unit", hidden: false, flex: 1 },
                { dataIndex: 'dblEffectiveDepth', dataType: 'float', text: "Effective Depth", hidden: false, flex: 1 },
                { dataIndex: 'intSubLocationId', dataType: 'numeric', text: "Storage Location Id", hidden: true, flex: 1 },
                { dataIndex: 'strSubLocationName', dataType: 'string', text: "Storage Location", hidden: false, flex: 1 },
                { dataIndex: 'dblUnitPerFoot', dataType: 'float', text: "Units per Foot", hidden: false, flex: 1 },
                { dataIndex: 'dblAirSpaceReading', dataType: 'float', text: "Reading in Foot", hidden: false, flex: 1 },
                { dataIndex: 'dblCashPrice', dataType: 'float', text: "Cash Price", hidden: false, flex: 1 },
                { dataIndex: 'intDiscountSchedule', dataType: 'numeric', text: "Discount Schedule Id", hidden: true, flex: 1 },
                { dataIndex: 'strDiscountSchedule', dataType: 'string', text: "Discount Schedule", hidden: false, flex: 1 },
                { dataIndex: 'strUnitMeasure', dataType: 'string', text: "Stock UOM", hidden: false, flex: 1 },
                { dataIndex: 'intUnitMeasureId', dataType: 'numeric', text: "Unit Measure Id", hidden: true, flex: 1 },
                { dataIndex: 'dblOnHand', dataType: 'float', text: "Current Stock", hidden: false, flex: 1 },
                { dataIndex: 'dblNewOnHand', dataType: 'float', text: "New Stock", hidden: false, flex: 1 },
                { dataIndex: 'dblValue', dataType: 'float', text: "Value", hidden: false, flex: 1 },
                { dataIndex: 'dblVariance', dataType: 'float', text: "Variance", hidden: false, flex: 1 },
                { dataIndex: 'dblGainLoss', dataType: 'float', text: "Gain/Loss", hidden: false, flex: 1 },
            ],
            showNew: false,
            showOpenSelected: false,
            enableDblClick: false
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