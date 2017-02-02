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
        'unitMeasure'
    ],

    config: {
        unitMeasure: null,
        quantity: 0.00
    },

    initComponent: function(options) {
        this.callParent(arguments);
    
        var txtQuantity = this.down('#_001txtQuantity');
        var cboUnitMeasure = this.down('#_001cboUnitMeasure');
        var store = Ext.create('Inventory.store.BufferedUnitMeasure', { pageSize: 50 });
        cboUnitMeasure.bindStore(store);
        store.load();

        if(this.config.unitMeasure) {
            var qty = this.quantity;
            var uom = this.unitMeasure;
            txtQuantity.setValue(qty);
            cboUnitMeasure.setRawValue(uom);
        }
        console.log(options);
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
                    xtype: 'currencynumberfield',
                    decimalPrecision: 4,
                    flex: 3,
                    itemId: '_001txtQuantity',
                    margin: '0 5 0 0',
                    fieldLabel: 'Quantity',
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
                    displayField: 'strUnitMeasure',
                    valueField: 'intUnitMeasureId',
                    labelWidth: 60,
                    hideLabel: true,
                }
            ]
        }
    ]
});