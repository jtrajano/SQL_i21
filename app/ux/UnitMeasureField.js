Ext.define('Inventory.ux.UnitMeasureField', {
    extend: 'Ext.panel.Panel',
    xtype: 'unitmeasurefield',
    alias: 'widget.icunitmeasurefield',
    
    requires: [
        'Ext.form.field.ComboBox',
        'Ext.form.field.Text',
        'Ext.form.Label',
        'Inventory.ux.CurrencyNumberField',
        'Inventory.ux.UnitMeasureFieldViewModel'
    ],

    viewModel: 'icunitmeasurefield',

    layout: 'fit',
    padding: 0, 
    margin: 0,
    border: 0,

    publishes: [
        'getUnitMeasure',
        'setUnitMeasure',
        'getQuantity',
        'setQuantity'
    ],

    config: {
         unitMeasure: null,
         quantity: 0.00
    },

    getUnitMeasure: function() {
        if(this.viewModel)
            return this.viewModel.get('unitMeasure');
        return null;
    },

    setUnitMeasure: function(value) {
        if(this.viewModel)
            this.viewModel.set('unitMeasure', value);
    },

    getQuantity: function() {
        if(this.viewModel)
            return this.viewModel.get('quantity');
        return null;
    },

    setQuantity: function(value) {
        if(this.viewModel)
            this.viewModel.set('quantity', value);
    },

    initComponent: function(options) {
        this.callParent(arguments);
    
        var txtQuantity = this.down('#_001txtQuantity');
        var cboUnitMeasure = this.down('#_001cboUnitMeasure');
        var store = Ext.create('Inventory.store.BufferedUnitMeasure', { pageSize: 50 });
        if(this.defaultFilters)
            cboUnitMeasure.defaultFilters = this.defaultFilters;
        cboUnitMeasure.bindStore(store);
        store.load();
        var uomId = parseInt(this.viewModel.get('unitMeasure'));
        cboUnitMeasure.setValue(uomId);
        var uom = cboUnitMeasure.findRecordByValue(uomId);
        if(uom && uom.get('strUnitMeasure'))
            cboUnitMeasure.setRawValue(uom.get('strUnitMeasure'));
        else
            cboUnitMeasure.setRawValue(uomId);
        cboUnitMeasure.on('select', this.onUnitMeasurementChange);
    },

    onUnitMeasurementChange: function(combo, records, eOptss) {
        var txtQuantity = combo.up('window').down('#_001txtQuantity');
        if(records && records.length > 0) {
            var decimal = records[0].get('intDecimalPlaces');
            if(!decimal)
                decimal = 6;
            txtQuantity.setDecimalPrecision(decimal);
            txtQuantity.setDecimalToDisplay(decimal);
            var val = txtQuantity.getValue();
            txtQuantity.setValue(val);
        }
    },

    items: [
        {
            xtype: 'container',
            margin: '0 0 5 0',
            layout: {
                type: 'hbox',
                align: 'stretch'
            },
            items: [
                {
                    xtype: 'numberfield',
                    decimalPrecision: 6,
                    flex: 3,
                    itemId: '_001txtQuantity',
                    margin: '0 5 0 0',
                    fieldLabel: 'Quantity',
                    bind: {
                        value: '{quantity}'
                    },
                    labelWidth: 80,
                },
                {
                    xtype: 'gridcombobox',
                    flex: 1,
                    itemId: '_001cboUnitMeasure',
                    margin: '0 0 0 0',
                    fieldLabel: '',
                    columns: [
                        { 
                            itemId: '_001colUnitMeasureId',
                            dataIndex: 'intUnitMeasureId',
                            text: 'Id',
                            flex: 1,
                            hidden: true
                        },
                        { 
                            itemId: '_001colUnitMeasure',
                            dataIndex: 'strUnitMeasure',
                            text: 'Unit Measure',
                            flex: 1
                        },
                        { 
                            itemId: '_001colSymbol',
                            dataIndex: 'strSymbol',
                            text: 'Symbol',
                            flex: 1
                        },
                        { 
                            itemId: '_001colUnitType',
                            dataIndex: 'strUnitType',
                            text: 'Type',
                            flex: 1
                        },
                        { 
                            itemId: '_001colDecimalPlaces',
                            dataIndex: 'intDecimalPlaces',
                            text: 'Decimal Places',
                            flex: 1
                        }
                    ],
                    dataIndex: 'intUnitMeasureId',
                    displayField: 'strUnitMeasure',
                    valueField: 'intUnitMeasureId',
                    labelWidth: 60,
                    hideLabel: true,
                    bind: {
                        value: '{unitMeasure}'
                    }
                }
            ]
        }
    ]
});