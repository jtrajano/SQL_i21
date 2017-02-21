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
            //me.pokeGrid(grid);
            win.context.data.saveRecord({
                callbackFn: function(batch, options) {
                    me.pokeGrid(grid);
                    if(me.afterSave) {
                        me.afterSave(me, batch, options);
                    }
                }
            });
        }, me);
    },

    getCurrent: function() {
        return this.getView().getViewModel().data.current;
    },

    getCurrentValue: function(key) {
        return this.getCurrent().get(key);
    }
});