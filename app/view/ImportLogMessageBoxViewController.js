/*
 * File: app/view/ImportLogMessageBoxViewController.js
 *
 * This file was generated by Sencha Architect version 3.2.0.
 * http://www.sencha.com/products/architect/
 *
 * This file requires use of the Ext JS 5.0.x library, under independent license.
 * License of Sencha Architect does not include license for Ext JS 5.0.x. For more
 * details see http://www.sencha.com/license or contact license@sencha.com.
 *
 * This file will be auto-generated each and everytime you save your project.
 *
 * Do NOT hand edit this file.
 */

Ext.define('Inventory.view.ImportLogMessageBoxViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.icimportlogmessagebox',
    formParams: null,

    onBtnCloseClick: function(button, e, eOpts) {
        "use strict";
        var win = button.up('window');
        win.close(function() {
            console.log(arguments);
        });
    },

    setupContext : function(options){
        "use strict";
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.FuelType', { pageSize: 1 });

        win.context = Ext.create('iRely.Engine', {
            window : win,
            store  : store,
            binding: me.config.binding
        });

        return win.context;
    },

    show: function(cfg) {
        var me = this;
        me.formParams = cfg.param;
        var win = me.getView();
        var grid = win.down('#gridLogs');
        var store = Ext.create('Ext.data.ArrayStore', {
            extend: 'Ext.data.ArrayStore',
            data: me.formParams.data,
            fields: ["Message", "Column", "Row", "Type", "Status"],
            autoLoad: true,
            groupField: 'Row'
        });
        grid.reconfigure(store);
        store.loadData(me.formParams.data.messages);

        var colType = win.down('#colType');
        var colMessage = win.down('#colMessage');
        var colColumn = win.down('#colColumn');
        var colStatus = win.down('#colStatus');
        colMessage.renderer = this.fieldRenderer;
        colType.renderer = this.fieldRenderer;
        colColumn.renderer = this.fieldRenderer;
        colStatus.renderer = this.fieldRenderer;
        win.show();
        var context = me.setupContext( {window : win} );
    },

    fieldRenderer: function(value, metaData, record, rowIndex, colIndex, store, view) {
        if(value == null)
            return value;
        var type = record.get("Type");
        if (type == "Error")
            return '<span style="color:' + "#FF0000" + ';">' + value + '</span>';
        else if (type == "Warning")
            return '<span style="color:' + "#296AA3" + ';"><i>' + value + '</i></span>';
        else if (type == "Info")
            return '<span style="color:' + "#0E7500" + ';">' + value + '</span>';
        return value;
    },

    init: function() {
        "use strict";

        this.control({
           "icimportlogmessagebox #btnClose": {
               click: this.onBtnCloseClick
           }
        });
    }
});
