Ext.define('Inventory.view.CopyItemLocationViewModel', {
    extend: 'Ext.app.ViewModel',
    alias: 'viewmodel.iccopyitemlocation',
    requires: [
        'Inventory.store.BufferedItem',
        'Inventory.store.Item'
    ],

    stores: {
        items: {
            type: 'icitem',
            proxy: {
                extraParams: {
                    include: 'tblICItemLocations, tblICItemLocations.vyuICGetItemLocation' 
                },
                type: 'rest',
                api: {
                    read: '../Inventory/api/Item/Get'
                },
                reader: {
                    type: 'json',
                    rootProperty: 'data',
                    messageProperty: 'message'
                },
                writer: {
                    type: 'json',
                    allowSingle: false
                }
            },
            sorters: {
                direction: 'ASC',
                property: 'strItemNo'
            }
        }
    },

    formulas: {
        hasSourceItem: function(get) {
            return get('cboItem.selection');
        }
    }
});