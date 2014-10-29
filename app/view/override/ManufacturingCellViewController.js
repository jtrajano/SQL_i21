Ext.define('Inventory.view.override.ManufacturingCellViewController', {
    override: 'Inventory.view.ManufacturingCellViewController',

    config: {
        searchConfig: {
            title:  'Search Manufacturing Cells',
            type: 'Inventory.ManufacturingCell',
            api: {
                read: '../Inventory/api/ManufacturingCell/SearchManufacturingCells'
            },
            columns: [
                {dataIndex: 'intManufacturingCellId',text: "Manufacturing Cell Id", flex: 1, defaultSort:true, dataType: 'numeric', key: true, hidden: true},
                {dataIndex: 'strCellName', text: 'Manufacturing Cell', flex: 2,  dataType: 'string'},
                {dataIndex: 'strDescription', text: 'Description', flex: 1,  dataType: 'string'}
            ]
        },
        binding: {
            txtName: '{current.strCellName}',
            txtDescription: '{current.strDescription}',
            cboLocationName: {
                value: '{current.intLocationId}',
                store: '{location}'
            },
//            cboStatus: '{current.strStatus}',
            txtStandardCapacity: '{current.dblStdCapacity}',
            cboStandardCapacityUom: {
                value: '{current.intStdUnitMeasureId}',
                store: '{capacityUOM}'
            },
            cboStandardCapacityRate: {
                value: '{current.intStdCapacityRateId}',
                store: '{capacityRateUOM}'
            },
            txtStandardLineEfficiency: '{current.dblStdLineEfficiency}',
            chkIncludeInScheduling: '{current.ysnIncludeSchedule}',

            colPackTypeName: 'strPackName',
            colPackTypeDescription: 'strDescription',
            colLineCapacity: 'dblLineCapacity',
            colLineCapacityUOM: 'strCapacityUnitMeasure',
            colLineCapacityRate: 'strCapacityRateUnitMeasure',
            colLineEfficiency: 'dblLineEfficiencyRate'
        }
    },

    setupContext : function(options){
        "use strict";
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.ManufacturingCell', { pageSize: 1 });

        var grdPackingType = win.down('#grdPackingType');

        win.context = Ext.create('iRely.mvvm.Engine', {
            binding: me.config.binding,
            window : win,
            store  : store,
            details: [
                {
                    key: 'tblICManufacturingCellPackTypes',
                    component: Ext.create('iRely.mvvm.grid.Manager', {
                        grid: grdPackingType,
                        deleteButton : grdPackingType.down('#btnDeletePackingType')
                    })
                }
            ]
        });

        var colPackType = grdPackingType.columns[0];
        var cboPackType = colPackType.editor;
        cboPackType.on('select', me.onPackTypeSelect);

        var colCapUOM = grdPackingType.columns[3];
        var cboCapUOM = colCapUOM.editor;
        cboCapUOM.on('select', me.onPackTypeSelect);

        var colCapRateUOM = grdPackingType.columns[4];
        var cboCapRateUOM = colCapRateUOM.getEditor();
        cboCapRateUOM.on('select', me.onPackTypeSelect);

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

    onPackTypeSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepPackType');
        var current = plugin.getActiveRecord();

        if (combo.column.itemId === 'colPackTypeName')
        {
            current.set('intSourceUnitMeasureId', records[0].get('intPackTypeId'));
            current.set('strDescription', records[0].get('strDescription'));
        }
        else if (combo.column.itemId === 'colLineCapacityUOM')
        {
            current.set('intLineCapacityUnitMeasureId', records[0].get('intUnitMeasureId'));
        }
        else if (combo.column.itemId === 'colLineCapacityRate')
        {
            current.set('intLineCapacityRateUnitMeasureId', records[0].get('intUnitMeasureId'));
        }
    }
    
});