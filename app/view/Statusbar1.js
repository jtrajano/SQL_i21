/*
 * File: app/view/Statusbar1.js
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

Ext.define('Inventory.view.Statusbar1', {
    extend: 'Ext.toolbar.Toolbar',
    alias: 'widget.statusbar1',

    requires: [
        'Inventory.view.Statusbar1ViewModel',
        'Ext.button.Button',
        'Ext.toolbar.Separator',
        'Ext.form.Label',
        'Ext.toolbar.Fill'
    ],

    viewModel: {
        type: 'statusbar1'
    },
    itemId: 'tlbStatusbar',
    width: 1265,

    layout: {
        type: 'hbox',
        padding: '0 0 0 1'
    },
    items: [
        {
            xtype: 'button',
            tabIndex: -1,
            itemId: 'btnHelp',
            iconCls: 'small-help',
            tooltip: 'Click to get help on this screen'
        },
        {
            xtype: 'button',
            tabIndex: -1,
            itemId: 'btnSupport',
            iconCls: 'small-support',
            tooltip: 'Click for support on this screen'
        },
        {
            xtype: 'button',
            tabIndex: -1,
            itemId: 'btnFieldName',
            iconCls: 'small-light-bulb-off',
            tooltip: 'Click to display table/field name tooltips'
        },
        {
            xtype: 'tbseparator'
        },
        {
            xtype: 'label',
            itemId: 'lblReady',
            margin: '0 5',
            text: 'Ready'
        },
        {
            xtype: 'tbfill'
        }
    ]

});