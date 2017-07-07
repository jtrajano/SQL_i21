var parameters = null;

Ext.define('Inventory.view.StorageMeasurementReadingViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.icstoragemeasurementreading',

    config: {
        binding: {
            bind: {
                title: 'Storage Measurement Reading - {current.strReadingNo}'
            },
            cboLocation: {
                value: '{current.strLocation}',
                origValueField: 'intCompanyLocationId',
                origUpdateField: 'intLocationId',
                store: '{location}'
            },
            dtmDate: '{current.dtmDate}',
            txtReadingNumber: '{current.strReadingNo}',

            grdStorageMeasurementReading: {
                colCommodity: 'strCommodity',
                colItem: 'strItemNo',
                colStorageLocation: {
                    dataIndex: 'strStorageLocationName',
                    editor: {
                        origValueField: 'intStorageUnitId',
                        origUpdateField: 'intStorageLocationId',
                        store: '{storageLocation}',
                        defaultFilters: [
                            {
                                column: 'intLocationId',
                                value: '{current.intLocationId}',
                                conjunction: 'and'
                            }
                        ]
                    }
                },
                colSubLocation: 'strSubLocationName',
                colEffectiveDepth: 'dblEffectiveDepth',
                colAirSpaceReading: 'dblAirSpaceReading',
                colCashPrice: 'dblCashPrice',
                colUnitMeasure: 'strUnitMeasure',
                colDiscountSchedule: {
                     dataIndex: 'strDiscountDescription',
                     editor: {
                        origValueField: 'intDiscountScheduleId',
                        origUpdateField: 'intDiscountScheduleId',
                        store: '{discountSchedule}',
                        defaultFilters: [
                            {
                                column: 'intCommodityId',
                                value: '{grdStorageMeasurementReading.selection.intCommodityId}',
                                conjunction: 'and'
                            }
                        ]
                    }
                },
                colStock: 'dblOnHand',
                colNewStock: 'dblNewOnHand',
                colValue: 'dblValue',
                colVariance: 'dblVariance',
                colGainLoss: 'dblGainLoss'
            }
        }
    },

    setupContext : function(options){
        "use strict";
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.StorageMeasurementReading', { pageSize: 1 });

        win.context = Ext.create('iRely.Engine', {
            window : win,
            store  : store,
            include: 'tblSMCompanyLocation, tblICStorageMeasurementReadingConversions.vyuICGetStorageMeasurementReadingConversion',
            binding: me.config.binding,
            createRecord : me.createRecord,
            details: [
                {
                    key: 'tblICStorageMeasurementReadingConversions',
                    component: Ext.create('iRely.grid.Manager', {
                        grid: win.down('#grdStorageMeasurementReading'),
                        deleteButton : win.down('#btnRemove')
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

        if (config.param.mustLoadRecordParams == true) {
            parameters = config.param;
        }

        if (config) {
            win.show();

            var context = me.setupContext( {window : win} );

            if (config.action === 'new') {
                context.data.addRecord();
            } else {
                if (config.id) {
                    config.filters = [{
                        column: 'intStorageMeasurementReadingId',
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
        "use strict";
        var today = new i21.ModuleMgr.Inventory.getTodayDate();
        var newRecord = Ext.create('Inventory.model.StorageMeasurementReading');
        var defaultLocation = iRely.Configuration.Application.CurrentLocation; 

        newRecord.set('dtmDate', today);

        if (defaultLocation){
            newRecord.set('intLocationId', defaultLocation);
            Ext.create('i21.store.CompanyLocationBuffered', {
                storeId: 'icReceiptCompanyLocation',
                autoLoad: {
                    filters: [
                        {
                            dataIndex: 'intCompanyLocationId',
                            value: defaultLocation,
                            condition: 'eq'
                        }
                    ],
                    params: {
                        columns: 'strLocationName:intCompanyLocationId:'
                    },
                    callback: function(records, operation, success){
                        var record; 
                        if (records && records.length > 0) {
                            record = records[0];
                        }

                        if(success && record){
                            newRecord.set('strLocation', record.get('strLocationName'));
                            newRecord.set('intLocationId', record.get('intCompanyLocationId'));
                        }
                    }
                }
            });            
        }         

        // ******************************************************************************
        // Comment out for the meantime. 
        // This needs to be improved. Don't use a global variable "parameter". 

        // if (parameters != null && parameters != 'undefined') {
        //     var locationId = parameters.record.data.intLocationId;
        //     var storageLocationId = parameters.intStorageLocationId;
        //     //var details = parameters.details;
        //     iRely.Msg.showWait('Loading storage measurement conversions...');
        //     Ext.Ajax.request({
        //         timeout: 120000,
        //         url: '../Inventory/api/StorageLocation/GetStorageBinMeasurementReading',
        //         method: 'Get',
        //         params: {
        //             intStorageLocationId: storageLocationId
        //         },
        //         success: function (response) {
        //             var jsonData = Ext.decode(response.responseText);
        //             newRecord.set('intLocationId', locationId);
        //             var data = [];
        //             Ext.Array.each(jsonData.data, function(item){
        //                 var i = {
        //                     intStorageMeasurementReadingId: parameters.record.data.intStorageMeasurementReadingId,
        //                     intCompanyLocationId: locationId,
        //                     intCommodityId: item.intCommodityId,
        //                     intItemId: item.intItemId,
        //                     intStorageLocationId: item.intStorageLocationId,
        //                     intSubLocationId: item.intCompanyLocationSubLocationId,
        //                     dblAirSpaceReading: item.dblAirSpaceReading,
        //                     dblCashPrice: item.dblCashPrice,
        //                     dblEffectiveDepth: item.dblEffectiveDepth,
        //                     strStorageLocationName: item.strStorageLocation,
        //                     strSubLocationName: item.strSubLocation,
        //                     strItemNo: item.strItemNo,
        //                     strCommodity: item.strCommodityCode,
        //                     strUnitMeasure: item.strUnitMeasure,
        //                     intUnitMeasureId: item.intUnitMeasureId
        //                 };
        //                 data.push(i);
        //             });
        //             newRecord.tblICStorageMeasurementReadingConversions().add(data);

        //             var viewModel = config.viewModel;
        //             viewModel.setData({ current: newRecord });
        //             iRely.Msg.close();
        //         },
        //         failure: function (response) {
        //             var jsonData = Ext.decode(response.responseText);
        //             iRely.Functions.showErrorDialog(jsonData.ExceptionMessage);
        //             iRely.Msg.close();
        //         }
        //     });
        // }
        // ******************************************************************************

        action(newRecord);
    },

    onStorageLocationSelect: function(combo, records, eOpts) {
        if (records.length <= 0)
            return;

        var grid = combo.up('grid');
        var win = combo.up('window');
        var plugin = grid.getPlugin('cepStorageMeasurementReading');
        var current = plugin.getActiveRecord();

        current.set('intSubLocationId', records[0].get('intStorageLocationId'));
        current.set('strSubLocationName', records[0].get('strStorageLocation'));
        current.set('strStorageLocationName', records[0].get('strStorageUnit'));
        current.set('intStorageLocationId', records[0].get('intStorageUnitId'));
        current.set('intItemId', records[0].get('intItemId'));
        current.set('strItemNo', records[0].get('strItemNo'));
        current.set('intCommodityId', records[0].get('intCommodityId'));
        current.set('strCommodity', records[0].get('strCommodity'));
        current.set('strUnitMeasure', records[0].get('strUnitMeasure'));
        current.set('dblEffectiveDepth', records[0].get('dblEffectiveDepth'));

        current.set('dblUnitPerFoot', records[0].get('dblUnitPerFoot'));
        current.set('dblResidualUnit', records[0].get('dblResidualUnit'));
        current.set('dblOnHand', records[0].get('dblOnHand'));
    },

    onItemSelect: function(combo, records, opts) {
        if(records.length <= 0)
            return;

        var grid = combo.up('grid');
        var win = combo.up('window');
        var plugin = grid.getPlugin('cepStorageMeasurementReading');
        var current = plugin.getActiveRecord();

        current.set('strUnitMeasure', records[0].get('strStockUOM'));
    },

    onQualityClick: function(button, e, eOpts) {
        var grd = button.up('grid');

        var selected = grd.getSelectionModel().getSelection();

        if (selected) {
            if (selected.length > 0){
                var current = selected[0];
                if (!current.dummy)
                    iRely.Functions.openScreen('Grain.view.QualityTicketDiscount', { 
                        strSourceType: 'Storage Measurement Reading', 
                        intTicketFileId: current.get('intStorageMeasurementReadingConversionId'),
                        intDiscountScheduleId: current.get('intDiscountScheduleId')
                    });
            }
            else {
                iRely.Functions.showErrorDialog('Please select an Item to view.');
            }
        }
        else {
            iRely.Functions.showErrorDialog('Please select an Item to view.');
        }
    },

    init: function(application) {
        this.control({
            "#cboStorageLocation": {
                select: this.onStorageLocationSelect
            },
            "#cboItem": {
                select: this.onItemSelect
            },
            "#btnQuality": {
                click: this.onQualityClick
            }
        });
    }
});
