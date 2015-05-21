/*
 * File: app/view/Filter1.js
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

Ext.define('Inventory.view.Filter1', {
    extend: 'Ext.container.Container',
    alias: 'widget.filter1',

    requires: [
        'Ext.form.field.Text',
        'Ext.form.trigger.Trigger',
        'Ext.form.Label'
    ],

    height: 23,
    hidden: true,
    hideMode: 'offsets',
    width: 199,

    items: [
        {
            xtype: 'textfield',
            tabIndex: -1,
            hidden: true,
            itemId: 'txtFitlerGrid',
            margin: '0 0 0 5',
            width: 189,
            fieldLabel: 'Filter',
            labelWidth: 35,
            triggers: {
                mytrigger: {
                    cls: 'x-form-clear-trigger'
                }
            }
        },
        {
            xtype: 'label',
            itemId: 'lblTotalRecords',
            padding: 3,
            text: ''
        }
    ]

});