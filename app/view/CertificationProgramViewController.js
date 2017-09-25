/*
 * File: app/view/CertificationProgramViewController.js
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

Ext.define('Inventory.view.CertificationProgramViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.iccertificationprogram',

    config: {
        searchConfig: {
            title:  'Search Certification Programs',
            type: 'Inventory.CertificationProgram',
            api: {
                read: '../inventory/api/certification/search'
            },
            columns: [
                {dataIndex: 'intCertificationId',text: "Certification Id", flex: 1, defaultSort:true, dataType: 'numeric', key: true, hidden: true},
                {dataIndex: 'strCertificationName', text: 'Certification Name', flex: 1,  dataType: 'string'},
                {dataIndex: 'strIssuingOrganization', text: 'Issuing Organization', flex: 1,  dataType: 'string'}
            ]
        },
        binding: {
            bind: {
                title: 'Certification Program - {current.strCertificationName}'
            },
            txtCertificationProgram: '{current.strCertificationName}',
            txtIssuingOrganization: '{current.strIssuingOrganization}',
            txtCertificationID: '{current.strCertificationIdName}',
            chkGlobalCertification: '{current.ysnGlobalCertification}',
            cboSpecificCountry: {
                value: '{current.intCountryId}',
                store: '{country}'
            },
            txtCertificationCode: '{current.strCertificationCode}',

            grdCertificationProgram: {
                colCommodity: {
                    dataIndex: 'strCommodityCode',
                    editor: {
                        store: '{commodity}'
                    }
                },
                colCurrency: {
                    dataIndex: 'strCurrency',
                    editor: {
                        store: '{currency}'
                    }
                },
                colPremium: 'dblCertificationPremium',
                colPerUOM: {
                    dataIndex: 'strUnitMeasure',
                    editor: {
                        store: '{perUOM}'
                    }
                },
                colEffectiveFrom: 'dtmDateEffective'
            }
        }
    },

    setupContext : function(options){
        "use strict";
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.Certification', { pageSize: 1 });

        win.context = Ext.create('iRely.Engine', {
            window : win,
            store  : store,
            include: 'tblICCertificationCommodities.tblICCommodity, ' +
                'tblICCertificationCommodities.tblSMCurrency, ' +
                'tblICCertificationCommodities.tblICUnitMeasure',
            binding: me.config.binding,
            details: [
                {
                    key: 'tblICCertificationCommodities',
                    component: Ext.create('iRely.grid.Manager', {
                        grid: win.down('#grdCertificationProgram'),
                        deleteButton : win.down('#btnDeleteCertificationProgram')
                    })
                }
            ]
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
                        column: 'intCertificationId',
                        value: config.id
                    }];
                }
                context.data.load({
                    filters: config.filters
                });
            }
        }
    },

    onCommoditySelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var grid = combo.up('grid');
        var plugin = grid.getPlugin('cepCommodity');
        var current = plugin.getActiveRecord();

        if (combo.itemId === 'cboCommodity')
        {
            current.set('intCommodityId', records[0].get('intCommodityId'));
        }
        else if (combo.itemId === 'cboCurrency')
        {
            current.set('intCurrencyId', records[0].get('intCurrencyID'));
        }
        else if (combo.itemId === 'cboPerUnitMeasure')
        {
            current.set('intUnitMeasureId', records[0].get('intUnitMeasureId'));
        }
    },

    init: function(application) {
        this.control({
            "#cboCommodity": {
                select: this.onCommoditySelect
            },
            "#cboCurrency": {
                select: this.onCommoditySelect
            },
            "#cboPerUnitMeasure": {
                select: this.onCommoditySelect
            }
        });
    }

});
