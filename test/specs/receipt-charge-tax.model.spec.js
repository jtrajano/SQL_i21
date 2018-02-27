UnitTestEngine.testModel({
    name: 'Inventory.model.ReceiptChargeTax',
    base: 'iRely.BaseEntity',
    idProperty: 'intInventoryReceiptChargeTaxId',
    dependencies: ["Ext.data.Field"],
    fields: [{
        "name": "intInventoryReceiptChargeTaxId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intInventoryReceiptChargeId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intTaxGroupId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intTaxCodeId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intTaxClassId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strTaxableByOtherTaxes",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strCalculationMethod",
        "type": "string",
        "allowNull": false
    }, {
        "name": "dblRate",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblTax",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblAdjustedTax",
        "type": "float",
        "allowNull": false
    }, {
        "name": "intTaxAccountId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "ysnTaxAdjusted",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "strUnitMeasure",
        "type": "string",
        "allowNull": false
    }, {
        "name": "intUnitMeasureId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "ysnTaxOnly",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "ysnCheckoffTax",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "strTaxCode",
        "type": "string",
        "allowNull": false
    }, {
        "name": "dblQty",
        "type": "float",
        "allowNull": false
    }, {
        "name": "dblCost",
        "type": "float",
        "allowNull": false
    }, {
        "name": "intSort",
        "type": "int",
        "allowNull": true
    }],
    validators: [
        []
    ]
});