Ext.define('Inventory.view.override.BrandViewController', {
    override: 'Inventory.view.BrandViewController',

    config: {
        binding: {
            colBrandCode : 'strBrandCode',
            colBrandName : 'strBrandName',
            colManufacturer: {
                value: 'intManufacturerId',
                store: '{Manufacturers}'
            }
        }
    },

    setupContext : function(options){
        "use strict";
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.Brand', { pageSize: 1 }),
            grdBrand = win.down('#grdBrand');

        win.context = Ext.create('iRely.mvvm.Engine', {
            binding: me.config.binding,
            window : win,
            store  : store,
            singleGridMgr: Ext.create('iRely.mvvm.grid.Manager', {
                grid: grdBrand,
                deleteButton: grdBrand.down('#btnDeleteBrand')
            })
        });

        var colManufacturer = grdBrand.columns[2];
        colManufacturer.renderer = me.ManufacturerRenderer;

        //-----------------------------------------------//
        // Use old approach becuase the new one doesnt work
        //-----------------------------------------------//
        var manufacturer = Ext.create('Inventory.store.Manufacturer');
        var cboManufacturer = colManufacturer.getEditor();
        cboManufacturer.bindStore(manufacturer);
        //-----------------------------------------------//


        var cepBrand = grdBrand.getPlugin('cepBrand');
        cepBrand.on({
            edit: me.onGridManufacturerEdit,
            scope: me
        });

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
                        column: 'intBrandId',
                        value: config.id
                    }];
                }
                context.data.load({
                    filters: config.filters
                });
            }
        }
    },

    ManufacturerRenderer: function (value, metadata, record) {
        var manufacturer = record.get('strManufacturer');
        return manufacturer;
    },

    onGridManufacturerEdit: function(editor, e, eOpts){
        var me = this;
        var record = e.record
        var column = e.column;

        if (column.itemId !== 'colManufacturer')
            return;

        var grid = column.up('grid');
        var view = grid.view;

        var cboManufacturer = column.getEditor();
        if (cboManufacturer.getSelectedRecord())
        {
            var strManufacturer = cboManufacturer.getSelectedRecord().get('strManufacturer');
            var intManufacturerId = cboManufacturer.getSelectedRecord().get('intManufacturerId');
            record.set('strManufacturer', strManufacturer);
            record.set('intManufacturerId', intManufacturerId);
            view.refresh();
        }
    }
});