/*
 * File: apps/view/ImportDataFromCsvViewController.js
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
Ext.define('Inventory.view.ImportDataFromCsvViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.icimportdatafromcsv',
    formParams: null,

    onBtnCloseClick: function(button, e, eOpts) {
        "use strict";
        var win = button.up('window');
        win.close();
    },

    onImportButtonClick: function(button, e, eOpts) {
        "use strict";
        var me = this;
        var win = button.up('window');
        var params = me.formParams;

        var dataToImport = '';
        var form = button.up('form').getForm();
        var txtBrowseFile = win.down("#txtBrowseFile");
        var fileInput = txtBrowseFile.extractFileInput();
        var chbOverwrite = win.down("#chbOverwrite");
        
        if(fileInput && fileInput.files.length > 0) {
            if (txtBrowseFile.isValid()) {
                if (form.isValid()) {
                    var file = fileInput.files[0];
                    me.ajaxRequest({
                        url: '../Inventory/api/ImportData/Import',
                        file: file,
                        importType: params.type,
                        allowOverwrite: chbOverwrite.checked,
                        lineOfBusiness: params.lineOfBusiness,
                        params: params.params,
                        method: params.method,
                        callback: function(records, success, options) {
                            alert(success);
                        }
                    }, win);
                }
            } else {
                i21.functions.showCustomDialog('error', 'ok', 'The file is invalid!.');
            }
        } else {
            i21.functions.showCustomDialog('error', 'ok', 'Please select a file to import!.');
        }
    },

    onTxtBrowseFileChange: function(field,value){
        "use strict";
        var newValue = value.replace(/C:\\fakepath\\/g, '');
        field.setRawValue(newValue);
    },

    show: function(cfg) {
        var me = this;
        me.formParams = cfg.param;
        me.getView().setTitle(cfg.param.title + ' from CSV File');
    },

    init: function(application) {
        "use strict";
        this.control({
            "icimportdatafromcsv #btnClose": {
                click: this.onBtnCloseClick
            },
            "icimportdatafromcsv #btnImport": {
                click: this.onImportButtonClick
            },
            "icimportdatafromcsv #txtBrowseFile": {
                change: this.onTxtBrowseFileChange
            }
        });
    },

    ajaxRequest: function (p, win) {
        jQuery.ajax({
            url: p.url,
            method: p.method,
            headers: {
               'Content-Type': 'multipart/form-data',
               'Authorization': iRely.Configuration.Security.AuthToken,
               'X-File-Name': p.file.name,
               'X-File-Size': p.file.size,
               'X-File-Type': p.file.type,
               'X-Import-Type': p.importType,
               'X-Import-Allow-Overwrite': p.allowOverwrite ? "true" : "false",
               'X-Import-Allow-LineOfBusiness': p.lineOfBusiness
            },
            data: p.file,
            processData: false,
            beforeSend: function(jqXHR, settings) {
                iRely.Msg.showWait('Importing in progress...');
            },

            success: function(data, status, jqXHR) {
                iRely.Msg.close();
                var type = 'info';
                var msg = "File imported successfully.";
                var json = JSON.parse(jqXHR.responseText);
                if(json.rows === 0)
                    msg = "There's nothing to import.";

                if (json.result.Info == "warning") {
                    type = "warning";
                    msg = "File imported successfully with warnings.";
                }
                if(json.result.Info == "error") {
                    type = "warning";
                    msg = "File imported successfully with errors.";
                }

                i21.functions.showCustomDialog(type, 'ok', msg, function() {
                    win.close();

                    if (data.messages !== null && data.messages.length > 0) {
                        iRely.Functions.openScreen('Inventory.view.ImportLogMessageBox', {
                            data: data
                        });
                    }
                    if(!iRely.Functions.isEmpty(json.result.Description)) {
                        iRely.Functions.openScreen('Inventory.view.InventoryCount', json.result.Description);
                    }
                });
            },
            error: function(jqXHR, status, error) {
                iRely.Msg.close();
                var json = JSON.parse(jqXHR.responseText);
                i21.functions.showCustomDialog('error', 'ok', 'Import completed with error(s)! ' + json.info,
                    function() {
                        win.close();

                        if (json.messages !== null && json.messages.length > 0) {
                            iRely.Functions.openScreen('Inventory.view.ImportLogMessageBox', {
                                data: json
                            });
                        }
                    }
                );
            }
        });
    }
});