Ext.define('Inventory.view.InventoryBaseViewController', {
    extend: 'Ext.app.ViewController',
    alias: 'controller.icinventorybase',

    afterSave: null,

    pokeGrid: function (grid) {
        // Temporary fix for the issue on grid alignment: After saving the screen, the grid header is misaligned with the grid cells.
        if (grid.getView().body.dom && grid.getView().body.dom.offsetParent) {
            if (grid.getView().body.dom.offsetParent.scrollLeft % 2 === 0)
                grid.getView().scrollBy(1, 0);
            else
                grid.getView().scrollBy(-1, 0);
        }
    },

    saveAndPokeGrid: function(win, grid) {
        var me = this;

        return Ext.bind(function(success, failure) {

            // Do not continue with Save if beforeSave returned false. 
            if (me.beforeSave && me.beforeSave(win) === false){
                return; 
            }

            // Save, poke the grid, and call the after Save function. 
            win.context.data.saveRecord({
                callbackFn: function(batch, options) {
                    me.pokeGrid(grid);
                    if(me.afterSave) {
                        me.afterSave(me, win, batch, options);
                    }
                }
            });
        }, me);
    },

    saveRecord: function(win, afterSaveFn, finallyFn) {
        var me = this;
        var context = win ? win.context : null; 

        if (!context) {
            if(finallyFn) {
                finallyFn(false, "No or invalid context.");
            }
            return;
        } 

        // If there is no data change, return immediately. 
        if (!context.data.hasChanges()) {
            if(finallyFn) {
                finallyFn(true, "No changes.");
            }
            return; 
        }

        // Do not continue with Save if beforeSave returned false. 
        if (me.beforeSave && me.beforeSave(win) === false){
            if(finallyFn) {
                finallyFn(false, "Errors occurred before saving the record.");
            }
            return; 
        }

        // Validate the record first. 
        context.data.validator.validateRecord({ window: win }, function(valid) {
            // If records are valid, continue with the save. 
            if (valid){
                // Save and call the after Save callback. 
                context.data.saveRecord({
                    callbackFn: function (batch, options) {
                        if (afterSaveFn && Ext.isFunction(afterSaveFn)){
                            afterSaveFn(batch, options); 
                        }

                        if(finallyFn) {
                            finallyFn(true, "Record saved successfully.");
                        }
                    }
                });                    
            } else {
                if(finallyFn) {
                    finallyFn(false, "Record has invalid data.");
                }
            }
        });
    },    

    getCurrent: function() {
        return this.getView().getViewModel().data.current;
    },

    getData: function(key) {
        return this.getView().getViewModel().get(key);
    },

    setData: function(key, value) {
        this.getView().getViewModel().set('key', value);
    },

    getCurrentValue: function(key) {
        return this.getCurrent().get(key);
    }
});