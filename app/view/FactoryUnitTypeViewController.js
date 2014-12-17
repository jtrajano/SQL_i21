/*
 * File: app/view/FactoryUnitTypeViewController.js
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

Ext.define('Inventory.view.FactoryUnitTypeViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.icfactoryunittype',

    config: {
        searchConfig: {
            title:  'Search Storage Unit Type',
            type: 'Inventory.FactoryUnitType',
            api: {
                read: '../Inventory/api/StorageUnitType/SearchStorageUnitTypes'
            },
            columns: [
                {dataIndex: 'intStorageUnitTypeId',text: "Storage Unit Type Id", flex: 1, defaultSort:true, dataType: 'numeric', key: true, hidden: true},
                {dataIndex: 'strStorageUnitType', text: 'Storage Unit Type', flex: 1,  dataType: 'string'},
                {dataIndex: 'strDescription', text: 'Description', flex: 1,  dataType: 'string'}
            ]
        },
        binding: {
            txtName: '{current.strStorageUnitType}',
            txtDescription: '{current.strDescription}',
            cboInternalCode: {
                value: '{current.strInternalCode}',
                store: '{internalCodes}'
            },
            cboCapacityUom: {
                value: '{current.intCapacityUnitMeasureId}',
                store: '{capacityUOM}'
            },

            txtMaxWeight : '{current.dblMaxWeight}',
            chkAllowsPicking : '{current.ysnAllowPick}',
            cboDimensionUom : {
                value: '{current.intDimensionUnitMeasureId}',
                store: '{dimensionUOM}'
            },
            txtHeight : '{current.dblHeight}',
            txtDepth : '{current.dblDepth}',
            txtWidth : '{current.dblWidth}',
            txtPalletStack : '{current.intPalletStack}',
            txtPalletColumns : '{current.intPalletColumn}',
            txtPalletRows : '{current.intPalletRow}'
        }
    },

    setupContext : function(options){
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.FactoryUnitType', { pageSize: 1 });

        win.context = Ext.create('iRely.mvvm.Engine', {
            window : win,
            store  : store,
            createRecord : me.createRecord,
            binding: me.config.binding
        });

        var filter = [{ dataIndex: 'strUnitType', value: 'Area', condition: 'eq', conjunction: 'and' },
            { dataIndex: 'strUnitType', value: 'Length', condition: 'eq' }];
        var cboDimensionUom = win.down('#cboDimensionUom');
        cboDimensionUom.defaultFilters = filter;

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
                        column: 'intStorageUnitTypeId',
                        value: config.id
                    }];
                }
                context.data.load({
                    filters: config.filters
                });
            }
        }
    }
});
