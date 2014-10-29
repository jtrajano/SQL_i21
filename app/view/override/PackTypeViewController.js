Ext.define('Inventory.view.override.PackTypeViewController', {
    override: 'Inventory.view.PackTypeViewController',

    config: {
        searchConfig: {
            title:  'Search Pack Types',
            type: 'Inventory.PackType',
            api: {
                read: '../Inventory/api/PackType/SearchPackTypes'
            },
            columns: [
                {dataIndex: 'intPackTypeId',text: "Pack Type Id", flex: 1, defaultSort:true, dataType: 'numeric', key: true, hidden: true},
                {dataIndex: 'strPackName', text: 'Pack Type Name', flex: 2,  dataType: 'string'},
                {dataIndex: 'strDescription', text: 'Description', flex: 1,  dataType: 'string'}
            ]
        },
        binding: {
            txtPackTypeName: '{current.strPackName}',
            txtDescription: '{current.strDescription}',

            colSourceUOM: 'strSourceUnitMeasure',
            colTargetUOM: 'strTargetUnitMeasure',
            colConversionFactor: 'dblConversionFactor'
        }
    },

    setupContext : function(options){
        "use strict";
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.PackType', { pageSize: 1 });

        var grdPackType = win.down('#grdPackType');

        win.context = Ext.create('iRely.mvvm.Engine', {
            binding: me.config.binding,
            window : win,
            store  : store,
            details: [
                {
                    key: 'tblICPackTypeDetails',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: grdPackType,
                        deleteButton : grdPackType.down('#btnDeletePackType')
                    })
                }
            ]
        });

        var colSourceUOM = grdPackType.columns[0];
        var cboSourceUOM = colSourceUOM.getEditor();
        cboSourceUOM.on('select', me.onUOMSelect);

        var colTargetUOM = grdPackType.columns[1];
        var cboTargetUOM = colTargetUOM.getEditor();
        cboTargetUOM.on('select', me.onUOMSelect);
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
                        column: 'intPackTypeId',
                        value: config.id
                    }];
                }
                context.data.load({
                    filters: config.filters
                });
            }
        }
    },

    SourceUOMRenderer: function (value, metadata, record) {
        var unitmeasure = record.get('strSourceUnitMeasure');
        return unitmeasure;
    },

    TargetUOMRenderer: function (value, metadata, record) {
        var unitmeasure = record.get('strTargetUnitMeasure');
        return unitmeasure;
    },

    onGridUOMEdit: function(editor, e, eOpts){
        var me = this;
        var record = e.record
        var column = e.column;

        var grid = column.up('grid');
        var view = grid.view;

        if (column.itemId === 'colSourceUOM')
        {
            var cboSourceUOM = column.getEditor();
            if (cboSourceUOM.getSelectedRecord())
            {
                var strUnitMeasure = cboSourceUOM.getSelectedRecord().get('strUnitMeasure');
                record.set('strSourceUnitMeasure', strUnitMeasure);
                view.refresh();
            }
        }
        else if (column.itemId === 'colTargetUOM')
        {
            var cboTargetUOM = column.getEditor();
            if (cboTargetUOM.getSelectedRecord())
            {
                var strUnitMeasure = cboTargetUOM.getSelectedRecord().get('strUnitMeasure');
                record.set('strTargetUnitMeasure', strUnitMeasure);
                view.refresh();
            }
        }
    },

    onUOMSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepPackType');
        var current = plugin.getActiveRecord();

        if (combo.column.itemId === 'colSourceUOM')
        {
            current.set('intSourceUnitMeasureId', records[0].get('intUnitMeasureId'));
        }
        else if (combo.column.itemId === 'colTargetUOM')
        {
            current.set('intTargetUnitMeasureId', records[0].get('intUnitMeasureId'));
        }
    }


});