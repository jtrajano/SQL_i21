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
        if(selected) {
            var msgAction = function (button) {
                if (button === 'yes') {
                    var sourceItem = me.view.viewModel.get('hasSourceItem');
                    me.copyLocation(selected.items, sourceItem);
                }
            };
            iRely.Functions.showCustomDialog('question', 'yesno', 'Are you sure you want to copy the location(s) from this item?', msgAction);
        }
    },

    copyLocation: function(selectedItems, sourceItem) {
        console.log(selectedItems);
        console.log(sourceItem);
        var context = this.getView().context;
        context.data.saveRecord({
            successFn: function() {
                console.log(arguments);
            }
        });
    },

    setupContext: function(config) {
        var me = this;
        var win = config.window;
        var store = Ext.create('Inventory.store.Item', { pageSize: 50 });
        
        win.context = Ext.create('iRely.mvvm.Engine', {
            window : win,
            store: store,
            include: 'tblICItemLocations, tblICItemLocations.vyuICGetItemLocation',
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
            var context = me.setupContext( { window : win } );
            context.data.load();
        }
    }
});