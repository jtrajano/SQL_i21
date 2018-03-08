Ext.define('Inventory.view.CopyItemLocationViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.iccopyitemlocation',
    
    config: {
        binding: {
            cboItem: {
                store: '{items}'
            },
            btnCopy: {
                disabled: '{!hasSourceItem}'
            },
            grdItems: {
                colStrItemNo: 'strItemNo',
                colDescription: 'strItemDescription',
                colType: 'strType',
                colCommodity: 'strCommodityCode',
                colCategory: 'strCategoryCode',
                colManufacturer: 'strManufacturer',
                colBrand: 'strBrandName',
                colVendor: 'strVendorName'
            }
        }
    },

    init: function(application) {
        this.control({
            "#btnCopy": {
                click: this.onCopy
            }
        });
    },

    onCopy: function(e) {
        var me = this;
        
        var grid = this.getView().down('#grdItems');
        var selected = grid.getSelectionModel().selected;
        var win = grid.up('window');

        if(selected && selected.length > 0) {
            var msgAction = function (button) {
                if (button === 'yes') {
                    var sourceItem = me.view.viewModel.get('hasSourceItem');
                    me.copyLocation(selected.items, sourceItem);
                }
            };
            iRely.Functions.showCustomDialog('question', 'yesno', 'Are you sure you want to copy the location(s) from this item?', msgAction);
        }
        else {
            iRely.Functions.showCustomDialog('Warning', 'ok', 'Please select the target items from the grid.');
        }
    },

    copyLocation: function(selectedItems, sourceItem) {
        var me = this;
        var win = me.getView();

        var destinationItems = _.map(selectedItems, function(o) { return o.data; });
        var destinationItemIds = _.map(destinationItems, function(r) { return r.intItemId; });
        //destinationItemIds = _.filter(destinationItemIds, function(e) { return e !== sourceItem.get('intItemId'); });
        if(destinationItemIds.length === 1 && destinationItemIds[0] === sourceItem.get('intItemId')) {
            i21.functions.showCustomDialog('info', 'ok', 'Cannot copy locations when the source and destination items are the same.');    
            return;
        }
        Inventory.Utils.ajax({
            url: './inventory/api/item/copyitemlocation',
            params: {
                intSourceItemId: sourceItem.get('intItemId'),
                strDestinationItemIds: destinationItemIds.join()
            },
            method: 'post'
        })
        .subscribe(
            function(successResponse) {
                var json = JSON.parse(successResponse.responseText);
                if(json.success) {
                    i21.functions.showCustomDialog('info', 'ok', 'Location(s) copied successfully.');   

                    // Auto-Close                     
                    win.close();
                } else {
                    i21.functions.showCustomDialog('error', 'ok', json.message.statusText);   
                }
            },
            function(failedResponse) {
                var json = JSON.parse(successResponse.responseText);
                if(json.success)
                    i21.functions.showCustomDialog('error', 'ok', json.message.statusText);
                else
                    i21.functions.showCustomDialog('error', 'ok', json.Message);
            }
        );
    },

    setupContext: function(config) {
        var me = this;
        var win = me.getView();
        var store = Ext.create('Inventory.store.ItemLocation', { pageSize: 0 });
        
        store.getProxy().api.read = './inventory/api/itemlocation/getitemswithnolocation';

        win.context = Ext.create('iRely.Engine', {
            window : win,
            store: store,
            //include: 'tblICItemLocations, tblICItemLocations.vyuICGetItemLocation',
            binding: me.config.binding
        });

        var grid = win.down('#grdItems');
        grid.reconfigure(store);
        
        return win.context;
    },

    show: function(config) {
        "use strict";

        var me = this;
        var win = me.getView();

        if(config) {
            win.show();
            var context = win.context ? win.context.initialize() : me.setupContext();
            context.data.load();
        }
    }
});