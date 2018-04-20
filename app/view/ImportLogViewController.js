"use strict";

Ext.define('Inventory.view.ImportLogViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.icimportlog',

    config: {
        binding: {
            bind: {
                title: 'Import Log - {current.intImportLogId}'
            },
            lblLogId: '{current.intImportLogId}',
            lblImportType: '{current.strType}',
            lblMessage: {
                value: '{current.strDescription}',
                fieldStyle: '{messagestyle}'
            },
            lblImportDate: '{current.dtmDateImported}',
            lblFileType: '{current.strFileType}',
            lblTotalRows: '{current.intTotalRows}',
            lblRowsImported: '{current.intRowsImported}',
            lblRowsUpdated: '{current.intRowsUpdated}',
            lblTotalErrors: '{current.intTotalErrors}',
            lblTotalWarnings: '{current.intTotalWarnings}',
            lblDuration: '{duration}',
            lblDuplicates: {
                value: '{current.ysnAllowDuplicates}',
                fieldLabel: '{duplicatelabel}'
            },
            lblFileType: '{current.strFileType}',
            lblFilename: '{current.strFileName}',
            lblUsername: '{username}'
        }
    },

    show: function (config) {
        var me = this,
            win = this.getView();

        if (config) {
            win.show();

            var context = win.context ? win.context.initialize() : me.setupContext();

            if (config.id) {
                config.filters = [
                    {
                        column: 'intImportLogId',
                        value: config.id
                    }
                ];
            }
            context.data.load({
                filters: config.filters,
                callback: function() {
                    me.getViewModel().setData({ username: config.param.username});
                }
            });
        }
    },

    setupContext: function (options) {
        var me = this,
            win = me.getView(),
            store = Ext.create('Inventory.store.ImportLog', { pageSize: 1 }),
            grdLogDetails = win.down('#grdLogDetails');
        
        win.context = Ext.create('iRely.Engine', {
            window: win,
            store: store,
            binding: me.config.binding,
            details: [{
                key: 'tblICImportLogDetails',
                lazy: true,
                component: Ext.create('iRely.grid.Manager', {
                    grid: grdLogDetails
                })
            }]
        });

        return win.context;
    }
});
