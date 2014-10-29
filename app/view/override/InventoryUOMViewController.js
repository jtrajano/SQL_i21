Ext.define('Inventory.view.override.InventoryUOMViewController', {
    override: 'Inventory.view.InventoryUOMViewController',

    config: {
        searchConfig: {
            title:  'Search Inventory UOMs',
            type: 'Inventory.InventoryUOM',
            api: {
                read: '../Inventory/api/UnitMeasure/SearchUnitMeasures'
            },
            columns: [
                {dataIndex: 'intUnitMeasureId',text: "UOM Id", flex: 1, defaultSort:true, dataType: 'numeric', key: true, hidden: true},
                {dataIndex: 'strUnitMeasure', text: 'UOM Name', flex: 2,  dataType: 'string'},
                {dataIndex: 'strSymbol', text: 'Symbol', flex: 1,  dataType: 'string'},
                {dataIndex: 'strUnitType', text: 'Unit Type', flex: 2,  dataType: 'string'},
                {dataIndex: 'ysnDefault', text: 'Default', flex: 1,  dataType: 'boolean', xtype: 'checkcolumn'}
            ]
        },
        binding: {
            txtUnitMeasure: '{current.strUnitMeasure}',
            txtSymbol: '{current.strSymbol}',
            cboUnitType: {
                value: '{current.strUnitType}',
                store: '{UnitTypes}'
            },
            chkDefault: '{current.ysnDefault}',

            colConversionStockUOM: 'intStockUnitMeasureId',
            colConversionToStockUOM: 'dblConversionToStock',
            colConversionFromStockUOM: 'dblConversionFromStock'
        }
    },

    setupContext : function(options){
        "use strict";
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.UnitMeasure', { pageSize: 1 });

        var grdConversion = win.down('#grdConversion');

        win.context = Ext.create('iRely.mvvm.Engine', {
            binding: me.config.binding,
            window : win,
            store  : store,
            details: [
                {
                    key: 'tblICUnitMeasureConversions',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: grdConversion,
                        deleteButton : grdConversion.down('#btnDeleteConversion')
                    })
                }
            ]
        });

        var colUOM = grdConversion.columns[0];
        colUOM.renderer = me.UOMRenderer;
        var cepConversion = grdConversion.getPlugin('cepConversion');
        cepConversion.on({
            edit: me.onGridUOMEdit,
            scope: me
        });

        win.context.data.on({ currentrecordchanged: me.onCurrentRecordChanged, scope: me })

        return win.context;
    },

    show : function(config) {
        "use strict";

        var me = this,
            win = this.getView();

        if (config) {
            win.show();

            var context = me.setupContext( {window : win} );

            if (config.action === 'new') {
                context.data.addRecord();
            } else {
                if (config.id) {
                    config.filters = [{
                        column: 'intUnitMeasureId',
                        value: config.id
                    }];
                }
                context.data.load({
                    filters: config.filters
                });
            }
        }
    },

    UOMRenderer: function (value, metadata, record) {
        var unitmeasure = record.get('strUnitMeasure');
        return unitmeasure;
    },

    onGridUOMEdit: function(editor, e, eOpts){
        var me = this;
        var record = e.record
        var column = e.column;

        if (column.itemId !== 'colConversionStockUOM')
            return;

        var grid = column.up('grid');
        var view = grid.view;

        var cboUOM = column.getEditor();
        if (cboUOM.getSelectedRecord())
        {
            var strUnitMeasure = cboUOM.getSelectedRecord().get('strUnitMeasure');
            record.set('strUnitMeasure', strUnitMeasure);
            view.refresh();
        }
    },

    onCurrentRecordChanged: function (record, store) {
        var me = this;
        var win = me.getView();
        var grd = win.down('#grdConversion');
        var col = grd.columns[0];
        var cboUOM = col.getEditor();
        cboUOM.defaultFilters =
            [{ dataIndex: 'intUnitMeasureId', value: record.get('intUnitMeasureId'), condition: 'noteq' }
                , { dataIndex: 'strUnitType', value: record.get('strUnitType'), condition: 'eq', conjunction: 'and'}];
    }
});