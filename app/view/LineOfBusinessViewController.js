/*
 * File: app/view/LineOfBusinessViewController.js
 *
 * This file was generated by Sencha Architect version 3.1.0.
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

Ext.define('Inventory.view.LineOfBusinessViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.lineofbusiness',

    setupContext : function(){
        "use strict";
        var win = this.getView();
        win.context = Ext.create('iRely.mvvm.Engine', {
            window : win,
            store  : Ext.create('Inventory.store.LineOfBusiness'),
            singleGridMgr: Ext.create('iRely.mvvm.grid.Manager', {
                grid:  win.down('grid'),
                title: 'Line Of Business',
                columns: [
                    {
                        itemId: 'colLineOfBusiness',
                        dataIndex: 'strLineOfBusiness',
                        text: 'Line Of Business',
                        flex: 1,
                        editor: {
                            xtype: 'textfield'
                        }
                    }
                ]
            })
        });
        return win.context;
    },

    show : function() {
        "use strict";
        var me = this;
        me.getView().show();
        var context = me.setupContext();
        context.data.load();
    }
});
