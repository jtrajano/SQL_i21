/*
 * File: app/view/BrandViewController.js
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

Ext.define('Inventory.view.BrandViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.icbrand',

    setupContext: function () {
        "use strict";
        var win = this.getView();
        win.context = Ext.create('iRely.mvvm.Engine', {
            window: win,
            store: Ext.create('Inventory.store.Brand'),
            singleGridMgr: Ext.create('iRely.mvvm.grid.Manager', {
                grid: win.down('grid'),
                title: 'Brand',
                columns: [
                    {
                        itemId: 'colBrandCode',
                        dataIndex: 'strBrandCode',
                        text: 'Brand Code',
                        flex: 1,
                        editor: {
                            xtype: 'textfield'
                        }
                    },
                    {
                        itemId: 'colBrandName',
                        dataIndex: 'strBrandName',
                        text: 'Brand Name',
                        flex: 1,
                        editor: {
                            xtype: 'textfield'
                        }
                    }
                    ,
                    {
                        itemId: 'colManufacturer',
                        dataIndex: 'strManufacturer',
                        text: 'Manufacturer',
                        flex: 1,
                        editor: {
                            xtype: 'gridcombobox',
                            columns: [
                                {
                                    dataIndex: 'intManufacturerId',
                                    dataType: 'numeric',
                                    text: 'Manufacturer ID',
                                    hidden: true
                                },
                                {
                                    dataIndex: 'strManufacturer',
                                    dataType: 'string',
                                    text: 'Manufacturer',
                                    flex: 1
                                }
                            ],
                            itemId: 'cboManufacturer',
                            displayField: 'strManufacturer',
                            valueField: 'strManufacturer',
                            bind: {
                                store: '{manufacturer}'
                            },
                            listeners: {
                                select: 'onCboManufacturerSelect'
                            }
                        }
                    }
                ]
            })
        });
        return win.context;
    },

    show: function () {
        "use strict";
        var me = this;
        me.getView().show();
        var context = me.setupContext();
        context.data.load();
    },

    onCboManufacturerSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var grid = combo.up('grid');
        var plugin = grid.plugins[0];
        var current = plugin.getActiveRecord();

        if (combo.column.itemId === 'colManufacturer' && current) {
            current.set('intManufacturerId', records[0].get('intManufacturerId'));
        }
    }

});
