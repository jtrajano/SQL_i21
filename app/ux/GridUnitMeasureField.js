Ext.define('Inventory.ux.GridUnitMeasureField', {
    extend: 'Inventory.ux.UnitMeasureField',
    alias: 'widget.gridunitmeasurefield',
    mixins: {
        field: 'Ext.form.field.Base'
    },

    publishes: [
        'getValue',
        'setValue'
    ],

    initComponent: function() {
        this.callParent(arguments);

        var panel = this.items.items[0];
        var qty = panel.items.items[0];
        var uom = panel.items.items[1];
        qty.hideLabel = true;
        qty.flex = 2;
        panel.margin = 0;
        this.setValue({ quantity: this.config.data.get('dblUnitQty'), unitMeasureId: this.config.data.get('intUnitMeasureId') });
    },

    constructor: function(config) {
        this.callParent([config]);
    },

    getValue : function(){
        var vm = this.viewModel;
        return {
            quantity: vm.get('quantity'),
            unitMeasureId: vm.get('unitMeasureId')
        };
    },

    setValue : function(value){
        var val = value;
        var qty = null;
        var uomId = null;
        if(value) {
            if(val.quantity)
                qty = val.quantity;
            if(val.unitMeasureId)
                uomId = val.unitMeasureId;
            this.viewModel.set('unitMeasureId', uomId);
            this.viewModel.set('quantity', qty);

            var panel = this.items.items[0];
            var txt = panel.items.items[0];
            var cbo = panel.items.items[1];
            var store = Ext.create('Inventory.store.BufferedUnitMeasure', { pageSize: 50 });
            cbo.bindStore(store);
            store.load();
            cbo.setValue(uomId);
            var uom = cbo.findRecordByValue(uomId);
            if(uom && uom.get('strUnitMeasure'))
                cbo.setRawValue(uom.get('strUnitMeasure'));
            else
                cbo.setRawValue(uomId);
        }
    }
});