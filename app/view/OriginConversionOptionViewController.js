/*
 * File: app/view/OriginConversionOptionViewController.js
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

Ext.define('Inventory.view.OriginConversionOptionViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.icoriginconversionoption',
    requires: ['Inventory.controller.Inventory'],
    initViewModel: function() {
        
    },
    load: function(component, con) {
        var me = this || con;

        Ext.Loader.loadScript("./Inventory/app/lib/underscore.js");
        Ext.Loader.loadScript("./Inventory/app/lib/numeraljs/numeral.js");
        Ext.Loader.loadScript({
            url: "./Inventory/app/lib/rx.all.js",
            onLoad: function() {
                me.initializePreferences(me);
            } 
        });        
    },

    initializePreferences: function(me) {
        var win = me.getView();
                
        ic.utils.ajax({
            url: './Inventory/api/CompanyPreference/Get',
            method: 'get',
            params: {
                page: 1,
                start: 0,
                limit: 50
            }
        })
        .subscribe(function(response) {
            var json = JSON.parse(response.responseText);
            var pref = {};
            if(json.data && json.data.length > 0) {
                pref =  { task: json.data[0].strOriginLastTask, lob: json.data[0].strOriginLineOfBusiness };
            }
            
            if(pref) {
                var lastLob = pref.lob;
                if (lastLob && lastLob !== '')
                    me.getViewModel().set('lineOfBusiness', lastLob);
                else {
                    if (me.getViewModel().get('lineOfBusiness') !== '')
                        me.getViewModel().set('lineOfBusiness', '');
                }

                var lastTask = pref.task;
                if (lastTask && lastTask !== '')
                    me.getViewModel().set('currentTask', lastTask);
                else {
                    if (me.getViewModel().get('currentTask') !== '')
                        me.getViewModel().set('currentTask', 'LOB');
                }

                var lob = me.getViewModel().get('lineOfBusiness');
                var currentTask = me.getViewModel().get('currentTask');

                if (lob)
                    win.up('window').down('#cboLOB').setValue(me.getViewModel().get('lineOfBusiness'));
                else
                    win.up('window').down('#cboLOB').setValue(null);

                var originTypes = ["UOM", "Locations", "CategoryClass", "CategoryGLAccts", "AdditionalGLAccts", "Items", "ItemGLAccts", "Balance"];
                var grains = ["UOM", "Locations", "Commodity", "AdditionalGLAccts"];

                if (currentTask && currentTask !== 'LOB') {
                    if (lob === 'Grain')
                        originTypes = grains;
                    var index = _.indexOf(originTypes, currentTask);
                    if (index !== -1) {
                        me.getViewModel().set('currentTask', originTypes[index + 1]);
                    } else
                        me.getViewModel().set('currentTask', "LOB");
                }
            }
        });

        
        // .map(function(res) {
        //     var json = JSON.parse(res.responseText);
        //     if(json.data && json.data.length > 0) {
        //         return  { task: json.data[0].strOriginLastTask, lob: json.data[0].strOriginLineOfBusiness };
        //     }
        //     return null;
        // })
        // .subscribe(
        //     function(pref) {
                
        //     }
        // );
    },

    onImportButtonClick: function(button, e, eOpts) {
        "use strict";
        var me= this;
        var win = button.up('window');

        var type = null;
        var originType = null;
        var grainType = null;
        var originTypes = ["UOM", "Locations", "CategoryClass", "CategoryGLAccts", "AdditionalGLAccts", "Items", "ItemGLAccts", "Balance", "RecipeFormula"];
        var grain = ["UOM", "Locations", "Commodity", "AdditionalGLAccts"];
        
        switch (button.itemId) {
            case "btnImportFuelCategories":
                type = "FuelCategories";
                break;
            case "btnImportFuelTypes":
                type = "FuelTypes";
                break;
            case "btnImportFuelCodes":
                type = "FuelCodes";
                break;
            case "btnImportFeedStocks":
                type = "FeedStocks";
                break;
            case "btnImportProcessCodes":
                type = "ProcessCodes";
                break;
            case "btnImportUnitOfMeasurement":
                type = "UnitOfMeasurement";
                break;
            case "btnImportFeedStockUOM":
                type = "FeedStockUOM";
                break;
            case "btnImportStorageUnitTypes":
                type = "StorageUnitTypes";
                break;
            case "btnImportStorageLocations":
                type = "StorageLocations";
                break;
            case "btnImportLineOfBusiness":
                type = "LineOfBusiness";
                break;
            case "btnImportCategories":
                type = "Categories";
                break;
            case "btnImportManufacturers":
                type = "Manufacturers";
                break;
            case "btnImportBrands":
                type = "Brands";
                break;
            case "btnImportCommodities":
                type = "Commodities";
                break;
            case "btnImportCommodityUOM":
                type = "CommodityUOM";
                break;
            case "btnImportItems":
                type = "Items";
                break;
            case "btnImportItemAccountCategories":
                type = "ItemAccountCategories";
                break;
            case "btnImportItemUOM":
                type = "ItemUOM";
                break;
            case "btnImportItemAccounts":
                type = "ItemAccounts";
                break;
            case "btnImportItemContracts":
                type = "ItemContracts";
                break;
            case "btnImportInventoryCount":
                type = "InventoryCountDetails";
                break;
            // case "btnImportInventoryCountDetails":
            //     type = "InventoryCountDetails";
            //     break;
            case "btnImportItemPricing":
                type = "ItemPricing";
                break;
            case "btnImportItemLocation":
                type = "ItemLocation";
                break;
            case "btnImportItemPricingLevels":
                type = "ItemPricingLevels";
                break;
            /* ORIGIN CONVERSIONS */
            case "btnOriginUOM":
                originType = 0;
                grainType = 0;
                break;
            case "btnOriginLocations":
                originType = 1;
                grainType = 1;
                break;
            case "btnOriginCommodity":
                grainType = 2;
                originType = 1;
                break;
            case "btnOriginCategoryClass":
                originType = 2;
                break;
            case "btnOriginCategoryGLAccts":
                originType = 3;
                break;
            case "btnOriginAdditionalGLAccts":
                originType = 4;
                grainType = 3;
                break;
            case "btnOriginItems":
                originType = 5;
                break;
            case "btnOriginItemGLAccts":
                originType = 6;
                break;
            case "btnOriginBalance":
                originType = 7;
                break;
            case "btnOriginRecipeFormula":
                originType = 8;
                break;
        }

        var lineOfBusiness = this.view.viewModel.getData().lineOfBusiness;
        if (type !== null) {
            iRely.Functions.openScreen('Inventory.view.ImportDataFromCsv', {
                type: type,
                method: "POST",
                title: button.text
            });
        }
        else if(originType !== null) {
            if(lineOfBusiness === 'Grain') {
                originTypes = grain;
                originType = grainType;
            }

            this.importFromOrigins(this.view.viewModel, originTypes, originType, lineOfBusiness, win);
        }
    },

    importFromOrigins: function(viewModel, originTypes, type, lineOfBusiness, win) {
        this.ajaxRequest(viewModel, originTypes, type, lineOfBusiness, win);
    },

    ajaxRequest: function (viewModel, originTypes, type, lineOfBusiness, win) {
        iRely.Msg.showWait('Importing in progress...');
        ic.utils.ajax({
            url: './Inventory/api/ImportData/ImportOrigins',
            method: 'post',
            headers: {
                'Content-Type': 'multipart/form-data',
                'Authorization': iRely.Configuration.Security.AuthToken,
                'X-Import-Type': originTypes[type],
                'X-Import-LineOfBusiness': lineOfBusiness
            }
        })
        .subscribe(function(response) {
            iRely.Msg.close();
            var msgtype = 'info';
            var msg = "File imported successfully.";
            var json = JSON.parse(response.responseText);
            if (json.result.Info == "warning") {
                msgtype = "warning";
                msg = "File imported successfully with warnings.";
            }
            if(json.result.Info == "error") {
                msgtype = "warning";
                msg = "File imported successfully with errors.";
            }
            viewModel.set('lineOfBusiness', lineOfBusiness);
            viewModel.set('currentTask', originTypes[type+1]);

            i21.functions.showCustomDialog(msgtype, 'ok', msg, function() {
                //win.close();

                if (json.result.Messages !== null && json.result.Messages.length > 0) {
                    iRely.Functions.openScreen('Inventory.view.ImportLogMessageBox', {
                        data: json
                    });
                }
            });
        }, function(response) {
            iRely.Msg.close();
            var json = JSON.parse(response.responseText);
            i21.functions.showCustomDialog('error', 'ok', 'Import failed! ' + json.info,
                function() {
                    //win.close();

                    if (json.messages && json.messages.length > 0) {
                        iRely.Functions.openScreen('Inventory.view.ImportLogMessageBox', {
                            data: json
                        });
                    }
                }
            );
        })
    },

    init: function(application) {
        "use strict";
        this.control({
            "icoriginconversionoption button": {
                click: this.onImportButtonClick
            },

            "icoriginconversionoption menuitem": {
                click: this.onExportCsvTemplate
            },

            "#cboLOB": {
                select: this.onLOBSelect
            }
        });
    },

    onLOBSelect: function(combo, record) {
        var lob = record.get('strName');
        if(lob) {
            this.view.viewModel.set('lineOfBusiness', lob);
            this.view.viewModel.set('currentTask', 'UOM');
        }
    },

    onExportCsvTemplate: function(button, e, eOpts) {
        "use strict";
        var me= this;
        var win = button.up('window');

        var data = [];
        var columns = getTemplateColumns(button.menuId);
        download( data, columns, button.text + ".csv" );
    }
});

function setFile( data, fileName, fileType ) {
    // Set objects for file generation.
    var blob, url, a, extension;

    // Get time stamp for fileName.
    var stamp = new Date().getTime();

    // Set MIME type and encoding.
    fileType = ( fileType || "text/csv;charset=UTF-8" );
    extension = fileType.split( "/" )[1].split( ";" )[0];
    // Set file name.
    fileName = ( fileName || "CSV_Template" + stamp + "." + extension );

    // Set data on blob.
    blob = new Blob( [ data ], { type: fileType } );

    // Set view.
    if ( blob ) {
        // Read blob.
        url = window.URL.createObjectURL( blob );

        // Create link.
        a = document.createElement( "a" );
        // Set link on DOM.
        document.body.appendChild( a );
        // Set link's visibility.
        a.style = "display: none";
        // Set href on link.
        a.href = url;
        // Set file name on link.
        a.download = fileName;

        // Trigger click of link.
        a.click();

        // Clear.
        window.URL.revokeObjectURL( url );
    } else {
        // Handle error.
    }
}

function download( data, columns, filename ) {
    var result = "",
        headers = columns,
        header = "",
        field = "";

    // Process data.
    $.each( data, function( index, rows ) {
        // Set columns.
        $.each( rows, function( name, column ) {
            if ( column.value ) {
                // Format header.
                header = name;

                // Set header if not already set.
                if ( $.inArray( header, headers ) === -1 ) {
                    // Set column header and delimiter.
                    headers.push( header );
                }

                // Set field.
                // Escape commas that will split value into columns.
                field = ( column.value ).replace( /,/g, "" );

                // Set column value and delimiter.
                result += field + ",";
            }
        });

        // Set new row.
        result += "\n";
    });

    // Set headers.
    headers = headers.join( "," );

    // Ready data for reading.
    result = headers + "\n" + result;

    setFile( result, filename );
}

function getTemplateColumns(name) {
    switch (name) {
        case "fuelcategories":
            return ["Fuel Category", "Description", "Equivalence Value"];
        case "feedstocks":
            return ["Code", "Description"];
        case "fuelcodes":
            return ["Code", "Description"];
        case "processcodes":
            return ["Code", "Description"];
        case "uom":
            return ["Unit of Measure", "Symbol", "Unit Type"];
        case "feedstockuom":
            return ["Unit of Measure", "Code"];
        case "fueltypes":
            return ["Fuel Category", "Feed Stock", "Batch No", "Ending Rin Gallons", "Equivalence Value", "Fuel Code",
                "Production Process", "Feed Stock UOM", "Feed Stock Factor", "Renewable Biomass", "Percent of Denaturant", "Deduct Denaturant"];
        case "storageunittypes":
            return ["Name", "Description", "Internal Code", "Capacity UOM", "Max Weight", "Allows Picking", "Dimension UOM",
                "Height", "Depth", "Width", "Pallet Stack", "Pallet Columns", "Pallet Rows"];
        case "storageunits":
            return ["Name", "Description", "Storage Unit Type", "Location", "Storage Location", "Parent Unit", "Restriction Type",
                "Aisle", "Min Batch Size", "Batch Size", "Batch Size UOM", "Commodity", "Pack Factor", "Effective Depth", "Units Per Foot", "Residual Units",
                "Sequence", "Active", "X Position", "Y Position", "Z Position", "Allow Consume", "Allow Multiple Items",
                "Allow Multiple Lots", "Merge on Move", "Cycle Counted", "Default Warehouse Staging Unit"];
        case "lineofbusiness":
            return ["Line of Business", "Sales Person Id", "SIC Code", "Type", "Segment Code", "Visible on Web"];
        case "categories":
            return ["Category Code", "Description", "Inventory Type", "Line of Business", "Costing Method", "Inventory Valuation",
                "GL Division No", "Sales Analysis"];
        case "brands":
            return ["Brand Code", "Brand Name", "Manufacturer"];
        case "manufacturers":
            return ["Manufacturer"];
        case "commodities":
            return ["Commodity Code", "Description", "Exchange Traded", "Decimals on DPR", "Default Future Market", "Price Checks Min",
                "Price Checks Max", "Checkoff Tax Desc", "Checkoff All States", "Insurance Tax Desc", "Insurance All States",
                "Crop End Date Current", "Crop End Date New", "EDI Code", "Default Schedule Store", "Discount", "Scale Auto Dist Default"];
        case "items":
            return ["Item No","Type","Short Name","Description","Manufacturer","Status","Commodity","Lot Tracking","Brand","Model No","Category","Stocked Item","Dyed Fuel","Barcode Print","MSDS Required","EPA Number","Inbound Tax","Outbound Tax","Restricted Chemical","Fuel Item","List Bundle Items Separately","Fuel Inspect Fee","RIN Required","Fuel Category","Denaturant Percentage","Tonnage Tax","Load Tracking","Mix Order","Hand Add Ingredients","Medication Tag","Ingredient Tag","Volume Rebate Group","Physical Item","Extend Pick Ticket","Export EDI","Hazard Material","Material Fee","Auto Blend","User Group Fee Percentage","Wgt Tolerance Percentage","Over Receive Tolerance Percentage","Maintenance Calculation Method","Rate","NACS Category","WIC Code","Receipt Comment Req","Count Code","Landed Cost","Lead Time","Taxable","Keywords","Case Qty","Date Ship","Tax Exempt","Drop Ship","Commissionable","Special Commission","Tank Required","Available for TM","Default Percentage Full","Patronage Category","Direct Sale"];
        case "accountcategories":
            return ["Category", "Group", "Restricted"];
        case "accounts":
            return ["Item No", "Account Category", "Account Id"];
        case "itemuom":
            return ["Item No", "UOM", "Unit Qty", "Weight UOM", "UPC Code", "Short UPC Code", "Is Stock Unit",
                "Allow Purchase", "Allow Sale", "Length", "Width", "Height", "Dimension UOM",
                "Volume", "Volume UOM", "Max Qty"];
        case "contractitems":
            return ["Item No","Location","Contract Name","Origin","Grade","Grade Type","Garden","Yield","Tolerance","Franchise"];
        case "inventorycountdetails":
            return ["Location", "Count Group", "Description", "Date", "Item No", "Storage Location", "Storage Unit", 
                "Physical Count", "UOM", "Lot No", "Pallets", "Qty Per Pallet", "Count by Lots", "Count by Pallets", "Recount"];
        case "itempricing":
            return ["Item No", "Location", "Last Cost", "Standard Cost", "Average Cost", "Pricing Method",
                "Amount/Percent", "Retail Price", "MSRP"];
        case "itemlocation":
            return ["Item No","Location","POS Description","Vendor Id","Costing Method","Storage Location","Storage Unit",
                "Sale UOM","Purchase UOM","Family","Class","Product Code","Passport Fuel ID 1","Passport Fuel ID 2","Passport Fuel ID 3",
                "Tax Flag 1","Tax Flag 2","Tax Flag 3","Tax Flag 4","Promotional Item","Promotion Item","Deposit Required","Deposit PLU",
                "Bottle Deposit No:","Saleable","Quantity Required","Scale Item","Food Stampable","Returnable","Pre Priced",
                "Open Priced PLU","Linked Item","Vendor Category","ID Required (liquor)","ID Required (cigarrettes)","Minimum Age",
                "Apply Blue Law 1","Apply Blue Law 2","Car Wash","Item Type Code","Item Type Subcode","Allow Negative Inventory",
                "Reorder Point","Min Order","Suggested Qty","Lead Time (Days)","Inventory Count Group","Counted","Counted Daily",
                "Count by Serial Number","Serial Number Begin","Serial Number End","Auto Calculate Freight","Freight Rate",
                "Freight Term","Ship Via"];
        case "itempricinglevels":
            return ["Item No", "Location", "Price Level", "UOM", "Min", "Max", "Pricing Method",
                "Amount/Percent", "Unit Price", "Commission On", "Comm Amount/Percent"];
        case "commodityuom":
            return ["Commodity Code", "UOM", "Unit Qty", "Is Stock Unit", "Is Default UOM"]; 
    }
}