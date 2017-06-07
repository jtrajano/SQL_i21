/* 
    This store is used for paging, when paging out, modified records will be persisted.
*/
Ext.define('Inventory.store.PersistentPagedStore', {
    extend: 'Ext.data.Store',

    pruneModifiedRecords: false,

    listeners: {
        load: {
            scope: this,
            fn: function(store) {
                var modified = store.getModifiedRecords();
                for(var i = 0; i < modified.length; i++) {
                    var r = store.getById(modified[i].id);
                    if(r) {
                        var changes = modified[i].getChanges();
                        for(p in changes) {
                            if(changes.hasOwnProperty(p)) {
                                r.set(p, changes[p]);
                            }
                        }
                    }
                }
            }
        }
    }
});