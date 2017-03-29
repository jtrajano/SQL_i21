Ext.define('Inventory.view.BuildAssemblyBlendViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.icbuildassemblyblend',
    requires: [
        'CashManagement.common.Text',
        'CashManagement.common.BusinessRules'
    ],


    config: {
        searchConfig: {
            title: 'Search Build Assemblies',
            type: 'Inventory.BuildAssembly',
            api: {
                read: '../Inventory/api/BuildAssembly/Search'
            },
            columns: [
                {dataIndex: 'intBuildAssemblyId', text: "Build Assembly Id", flex: 1, defaultSort: true, dataType: 'numeric', key: true, hidden: true},
                {dataIndex: 'strBuildNo', text: 'Build No', flex: 1, dataType: 'string'},
                {dataIndex: 'dtmBuildDate', text: 'Build Date', flex: 1,  dataType: 'date', xtype: 'datecolumn'},
                {dataIndex: 'strItemNo', text: 'Item No', flex: 1, dataType: 'string'},
                {dataIndex: 'strLocationName', text: 'Location Name', flex: 1, dataType: 'string'},
                {dataIndex: 'strSubLocationName', text: 'Storage Location Name', flex: 1, dataType: 'string'},
                {dataIndex: 'strItemUOM', text: 'Item UOM', flex: 1, dataType: 'string'},
                {dataIndex: 'strDescription', text: 'Description', flex: 1, dataType: 'string'}
            ]
        },
        binding: {
            bind: {
                title: 'Build Assembly - {current.strBuildNo}'
            },
            btnSave: {
                disabled: '{current.ysnPosted}'
            },
            btnDelete: {
                disabled: '{current.ysnPosted}'
            },
            btnUndo: {
                disabled: '{current.ysnPosted}'
            },
            btnPost: {
                text: '{getPostButtonText}',
                iconCls: '{getPostButtonIcon}'
            },

            dtmBuildDate: {
                value: '{current.dtmBuildDate}',
                readOnly: '{current.ysnPosted}'
            },
            cboLocation: {
                value: '{current.intLocationId}',
                store: '{location}',
                readOnly: '{current.ysnPosted}'
            },
            cboSubLocation: {
                value: '{current.intSubLocationId}',
                store: '{subLocation}',
                defaultFilters: [{
                    column: 'intCompanyLocationId',
                    value: '{current.intLocationId}',
                    conjunction: 'and'
                }],
                readOnly: '{current.ysnPosted}'
            },
            cboItemNumber: {
                value: '{current.intItemId}',
                store: '{item}',
                defaultFilters: [{
                    column: 'intLocationId',
                    value: '{current.intLocationId}',
                    conjunction: 'and'
                }],
                readOnly: '{current.ysnPosted}'
            },
            txtBuildQuantity: {
                value: '{current.dblBuildQuantity}',
                readOnly: '{current.ysnPosted}'
            },
            cboUOM: {
                value: '{current.intItemUOMId}',
                store: '{itemUOM}',
                defaultFilters: [{
                    column: 'intItemId',
                    value: '{current.intItemId}',
                    conjunction: 'and'
                }],
                readOnly: '{current.ysnPosted}'
            },
            txtBuildNumber: '{current.strBuildNo}',
            txtCost: '{current.dblCost}',
            txtDescription: {
                value: '{current.strDescription}',
                readOnly: '{current.ysnPosted}'
            },

            grdBuildAssemblyBlend: {
                readOnly: '{current.ysnPosted}',
                colItemNo: 'strItemNo',
                colDescription: 'strItemDescription',
                colSubLocation: {
                    dataIndex: 'strSubLocationName',
                    editor: {
                        store: '{itemSubLocation}',
                        defaultFilters: [{
                            column: 'intCompanyLocationId',
                            value: '{current.intLocationId}',
                            conjunction: 'and'
                        }]
                    }
                },
                colStock: 'dblStock',
                colQuantity: 'dblQuantity',
                colUOM: 'strUnitMeasure',
                colCost: 'dblCost'
            }
        }
    },

    setupContext : function(options){
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.BuildAssembly', { pageSize: 1 });

        var grdBuildAssemblyBlend = win.down('#grdBuildAssemblyBlend');

        win.context = Ext.create('iRely.Engine', {
            window : win,
            store  : store,
            include: 'tblICBuildAssemblyDetails.tblICItem, ' +
                'tblICBuildAssemblyDetails.tblICItemUOM.tblICUnitMeasure, ' +
                'tblICBuildAssemblyDetails.tblSMCompanyLocationSubLocation',
            createRecord : me.createRecord,
            binding: me.config.binding,
            details: [
                {
                    key: 'tblICBuildAssemblyDetails',
                    component: Ext.create('iRely.grid.Manager', {
                        grid: grdBuildAssemblyBlend,
                        deleteButton : win.down('#btnRemove'),
                        position: 'none'
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
                win.controller.itemId = config.itemId;
                win.controller.itemSetup = config.itemSetup;
                context.data.addRecord();
            } else {
                if (config.id) {
                    config.filters = [{
                        column: 'intBuildAssemblyId',
                        value: config.id
                    }];
                }
                context.data.load({
                    filters: config.filters
                });
            }
        }
    },

    createRecord: function(config, action) {
        var today = new Date();
        var record = Ext.create('Inventory.model.BuildAssembly');
        if (app.DefaultLocation > 0)
            record.set('intLocationId', app.DefaultLocation);
        record.set('dtmBuildDate', today);
        if (config.controller.itemId)
            record.set('intItemId', config.controller.itemId);
        if (config.controller.itemSetup) {
            Ext.Array.each(config.controller.itemSetup, function(row) {
                if (!row.dummy){
                    var newDetail = Ext.create('Inventory.model.BuildAssemblyDetail');
                    newDetail.set('intItemId', row.get('intAssemblyItemId'));
                    newDetail.set('strItemNo', row.get('strItemNo'));
                    newDetail.set('strItemDescription', row.get('strItemDescription'));
                    newDetail.set('intSubLocationId', null);
                    newDetail.set('dblQuantity', row.get('dblQuantity'));
                    newDetail.set('intItemUOMId', row.get('intItemUnitMeasureId'));
                    newDetail.set('strUnitMeasure', row.get('strUnitMeasure'));
                    newDetail.set('dblCost', row.get('dblCost'));
                    newDetail.set('intSort', row.get('intSort'));
                    record.tblICBuildAssemblyDetails().add(newDetail);
                }
            });
        }
        action(record);
    },

    onViewItemClick: function(button, e, eOpts) {
        var win = button.up('window');
        var grd = win.down('#grdBuildAssemblyBlend');

        var selected = grd.getSelectionModel().getSelection();

        if (selected) {
            if (selected.length > 0){
                var current = selected[0];
                if (!current.dummy)
                    iRely.Functions.openScreen('Inventory.view.Item', current.get('intItemId'));
            }
            else {
                iRely.Functions.showErrorDialog('Please select an Item to view.');
            }
        }
        else {
            iRely.Functions.showErrorDialog('Please select an Item to view.');
        }
    },

    onBuildClick: function(button, e, eOpts) {
        var me = this;
        var win = button.up('window');
        var context = win.context;

        var doPost = function() {
            var strBuildNo = win.viewModel.data.current.get('strBuildNo');
            var posted = win.viewModel.data.current.get('ysnPosted');

            var options = {
                postURL             : '../Inventory/api/BuildAssembly/PostTransaction',
                strTransactionId    : strBuildNo,
                isPost              : !posted,
                isRecap             : false,
                callback            : me.onAfterBuild,
                scope               : me
            };

            CashManagement.common.BusinessRules.callPostRequest(options);
        };

        // If there is no data change, do the post.
        if (!context.data.hasChanges()){
            doPost();
            return;
        }

        // Save has data changes first before doing the post.
        context.data.saveRecord({
            successFn: function() {
                doPost();
            }
        });
    },

    onRecapClick: function(button, e, eOpts) {
        var me = this;
        var win = button.up('window');
        var context = win.context;

        var doRecap = function(recapButton, currentRecord){

            // Call the buildRecapData to generate the recap data
            CashManagement.common.BusinessRules.buildRecapData({
                postURL: '../Inventory/api/BuildAssembly/PostTransaction',
                strTransactionId: currentRecord.get('strBuildNo'),
                ysnPosted: currentRecord.get('ysnPosted'),
                scope: me,
                success: function(){
                    // If data is generated, show the recap screen.
                    CashManagement.common.BusinessRules.showRecap({
                        strTransactionId: currentRecord.get('strBuildNo'),
                        ysnPosted: currentRecord.get('ysnPosted'),
                        dtmDate: currentRecord.get('dtmBuildDate'),
                        strCurrencyId: null,
                        dblExchangeRate: 1,
                        scope: me,
                        postCallback: function(){
                            me.onBuildClick(recapButton);
                        },
                        unpostCallback: function(){
                            me.onBuildClick(recapButton);
                        }
                    });
                },
                failure: function(message){
                    // Show why recap failed.
                    var msgBox = iRely.Functions;
                    msgBox.showCustomDialog(
                        msgBox.dialogType.ERROR,
                        msgBox.dialogButtonType.OK,
                        message
                    );
                }
            });
        };

        // If there is no data change, do the post.
        if (!context.data.hasChanges()){
            doRecap(button, win.viewModel.data.current);
            return;
        }

        // Save has data changes first before doing the post.
        context.data.saveRecord({
            successFn: function() {
                doRecap(button, win.viewModel.data.current);
            }
        });
    },

    onAfterBuild: function(success, message) {
        if (success === true) {
            var me = this;
            var win = me.view;
            win.context.data.load();
        }
        else {
            iRely.Functions.showCustomDialog(iRely.Functions.dialogType.ERROR, iRely.Functions.dialogButtonType.OK, message);
        }
    },

    onItemSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var win = combo.up('window');
        var current = win.viewModel.data.current;
        var record = records[0];

        if (current) {
            var totalCost = 0;
            var assemblyItem = record.data.tblICItemAssemblies;
            if (assemblyItem) {
                Ext.Array.each(assemblyItem, function(row) {
                    var newRecord = Ext.create('Inventory.model.BuildAssemblyDetail');
                    newRecord.set('intItemId', row.intAssemblyItemId);
                    newRecord.set('strItemNo', row.strItemNo);
                    newRecord.set('strItemDescription', row.strItemDescription);
                    newRecord.set('intSubLocationId', null);
                    newRecord.set('dblQuantity', row.dblQuantity);
                    newRecord.set('intItemUOMId', row.intItemUnitMeasureId);
                    newRecord.set('strUnitMeasure', row.strUnitMeasure);
                    newRecord.set('dblCost', (row.dblQuantity * row.dblLastCost));
                    newRecord.set('intSort', row.intSort);
                    current.tblICBuildAssemblyDetails().add(newRecord);
                    totalCost += (row.dblQuantity * row.dblLastCost);
                });
            }
            current.set('dblCost', totalCost);
        }
    },

    onItemSubLocationSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var grid = combo.up('grid');
        var win = grid.up('window');
        var plugin = grid.getPlugin('cepItem');
        var current = plugin.getActiveRecord();

        if (current) {
            current.set('intSubLocationId', records[0].get('intCompanyLocationSubLocationId'));

            var items = win.viewModel.storeInfo.stockUOMList;
            var currentMaster = win.viewModel.data.current;

            if (currentMaster) {
                if (items) {
                    var index = items.data.findIndexBy(function (row) {
                        if (row.get('intItemId') === current.get('intItemId') &&
                            row.get('intLocationId') === currentMaster.get('intLocationId') &&
                            row.get('intItemUOMId') === current.get('intItemUOMId') &&
                            row.get('intSubLocationId') === current.get('intSubLocationId')) {
                            return true;
                        }
                    });
                    if (index >= 0) {
                        var stockUOM = items.getAt(index);
                        current.set('dblStock', stockUOM.get('dblOnHand'));
                    }
                    else
                    {
                        current.set('dblStock', 0.00);
                    }
                }
            }
        }
    },

    onItemBeforeQuery: function(obj) {
        if (obj.combo) {

            var proxy = obj.combo.store.proxy;
            proxy.setExtraParams({
                include: 'tblICItemAssemblies.AssemblyItem',
                columns: 'intItemId:strItemNo:strType:strDescription:strLotTracking:tblICItemAssemblies'
            });
        }
    },

    init: function(application) {
        this.control({
            "#cboItemNumber" : {
                select: this.onItemSelect
            },
            "#cboItemSubLocation" : {
                select: this.onItemSubLocationSelect
            },
            "#btnPost": {
                click: this.onBuildClick
            },
            "#btnPostPreview": {
                click: this.onRecapClick
            },
            "#btnViewItem": {
                click: this.onViewItemClick
            }
        });
    }
});
