Ext.define('Inventory.search.InventoryCount', {
    alias: 'search.icinventorycount',
    singleton: true,

    searchConfigs: [
        {
            title: 'Search Inventory Count',
            type: 'Inventory.InventoryCount',
            api: {
                read: './inventory/api/inventorycount/search'
            },
            columns: [
                { dataIndex: 'intInventoryCountId', text: "Count Id", flex: 1, defaultSort: true, sortOrder: 'DESC', dataType: 'numeric', key: true, hidden: true },
                { dataIndex: 'strCountNo', text: 'Count No', flex: 1, dataType: 'string' },
                { dataIndex: 'strLocationName', text: 'Location', flex: 1, dataType: 'string' },
                { dataIndex: 'strCategory', text: 'Category', flex: 1, dataType: 'string' },
                { dataIndex: 'strCommodity', text: 'Commodity', flex: 1, dataType: 'string' },
                { dataIndex: 'strCountBy', text: 'Count By', dataType: 'string' },
                { dataIndex: 'strShiftNo', text: 'Shift No', dataType: 'string' },
                { dataIndex: 'strCountGroup', text: 'Count Group', flex: 1, dataType: 'string' },
                { dataIndex: 'dtmCountDate', text: 'Count Date', flex: 1, dataType: 'date', xtype: 'datecolumn' },
                { dataIndex: 'strSubLocationName', text: 'Storage Location', flex: 1, dataType: 'string' },
                { dataIndex: 'strStorageLocationName', text: 'Storage Unit', flex: 1, dataType: 'string' },
                { dataIndex: 'strStatus', text: 'Status', flex: 1, dataType: 'string' },
                { dataIndex: 'ysnCountByLots', text: 'Count By Lots', flex: 1, dataType: 'boolean', xtype: 'checkcolumn' },
                { dataIndex: 'ysnCountByPallets', text: 'Count By Pallets', flex: 1, dataType: 'boolean', xtype: 'checkcolumn' },
                { dataIndex: 'ysnRecount', text: 'Recount', flex: 1, dataType: 'boolean', xtype: 'checkcolumn' },
                { dataIndex: 'ysnExternal', text: 'External', flex: 1, dataType: 'boolean', xtype: 'checkcolumn' },
                { dataIndex: 'ysnRecountMismatch', text: 'Recount Mismatch', flex: 1, dataType: 'boolean', xtype: 'checkcolumn' },
                { dataIndex: 'ysnScannedCountEntry', text: 'Scanned Count Entry', flex: 1, dataType: 'boolean', xtype: 'checkcolumn' },
                { dataIndex: 'ysnIncludeOnHand', text: 'Include On Hand', flex: 1, dataType: 'boolean', xtype: 'checkcolumn' },
                { dataIndex: 'ysnIncludeZeroOnHand', text: 'Include Zero On Hand', flex: 1, dataType: 'boolean', xtype: 'checkcolumn' },
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
                    text: 'Storage Unit',
                    itemId: 'btnStorageLocation',
                    clickHandler: 'onStorageLocationClick',
                    width: 110
                }
            ],
        },
        {
            title: 'Search Count Group',
            type: 'Inventory.Item',
            api: {
                read: './Inventory/api/CountGroup/Search'
            },
            columns: [
                { dataIndex: 'intCountGroupId', text: 'Count Group Id', flex: 1, defaultSort: true, sortOrder: 'ASC', dataType: 'numeric', key: true, hidden: true },
                { dataIndex: 'strCountGroup', text: 'Count Group', flex: 1, dataType: 'string' },
                { dataIndex: 'intCountsPerYear', text: 'Counts Per Year', flex: 1, dataType: 'numeric' },
                { dataIndex: 'ysnIncludeOnHand', text: 'Include on Hand', flex: 1, xtype: 'checkcolumn', dataType: 'boolean' },
                { dataIndex: 'ysnScannedCountEntry', text: 'Scanned Count Entry', flex: 1, xtype: 'checkcolumn', dataType: 'boolean' },
                { dataIndex: 'ysnCountByLots', text: 'Count By Lots', flex: 1, xtype: 'checkcolumn', dataType: 'boolean' },
                { dataIndex: 'ysnCountByPallets', text: 'Count By Pallets', flex: 1, xtype: 'checkcolumn', dataType: 'boolean' },
                { dataIndex: 'ysnRecountMismatch', text: 'Recount Mismatch', flex: 1, xtype: 'checkcolumn', dataType: 'boolean' },
                { dataIndex: 'ysnExternal', text: 'External', flex: 1, xtype: 'checkcolumn', dataType: 'boolean' }
            ],
            showNew: false,
            showOpenSelected: false,
            enableDblClick: false,
            buttons: [
                {
                    text: 'New',
                    itemId: 'btnNewCountGroup',
                    clickHandler: 'onNewCountGroupClick',
                    width: 80
                },
                {
                    text: 'Open',
                    itemId: 'btnOpenCountGroup',
                    clickHandler: 'onOpenCountGroupClick',
                    width: 80
                }
            ]
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

    onOpenCountGroupClick: function(e) {
        var grid = e.up('panel');
        grid = _.filter(grid, { url: './Inventory/api/CountGroup/Search' });
        if(grid && grid.length > 0) {
            grid = grid[0];
            var selection = grid.getSelectionModel().selected;
            var filters = _.map(selection.items, function(x) {
                return {
                    column: 'intCountGroupId',
                    value: x.get('intCountGroupId')
                };
            });

            iRely.Functions.openScreen('Inventory.view.InventoryCountGroup', { action: 'edit', 
                filters: filters,
                viewConfig: {
                    modal: true, 
                    listeners: { 
                        close: function(control) { 
                            grid.getStore().reload();
                        }
                    }
                }
            });   
        }   
    },

    onNewCountGroupClick: function (e) {
        iRely.Functions.openScreen('Inventory.view.InventoryCountGroup', { action: 'new', 
            viewConfig: { 
                modal: true, 
                listeners: { 
                    close: function() { 
                        var panel = e.up('panel');
                        var grid = panel ? panel.query('#grdSearch') : null;
                        grid = _.filter(grid, { url: './Inventory/api/CountGroup/Search' });
                        if(grid && grid.length > 0) {
                            grid = grid[0];
                            if(grid) {
                                grid.getStore().reload();
                            }
                        }
                    }
                }
            }
        });
    }
});