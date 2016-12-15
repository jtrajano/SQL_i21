UnitTestEngine.testModel({
    name: 'Inventory.model.ReceiptCharge',
    base: 'iRely.BaseEntity',
    idProperty: 'intInventoryReceiptChargeId',
    dependencies: ["Inventory.model.ReceiptChargeTax", "Ext.data.Field"],
    fields: [{
        "name": "intInventoryReceiptChargeId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intInventoryReceiptId",
        "type": "int",
        "allowNull": false
    }, {
        "name": "intContractId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "intChargeId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "ysnInventoryCost",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "strCostMethod",
        "type": "string",
        "allowNull": false
    }, {
        "name": "dblRate",
        "type": "float",
        "allowNull": false
    }, {
        "name": "intCostUOMId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "dblAmount",
        "type": "float",
        "allowNull": false
    }, {
        "name": "strAllocateCostBy",
        "type": "string",
        "allowNull": false
    }, {
        "name": "ysnAccrue",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "intEntityVendorId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "ysnPrice",
        "type": "boolean",
        "allowNull": false
    }, {
        "name": "intSort",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strItemNo",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strItemDescription",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strCostUOM",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strUnitType",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strVendorId",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strVendorName",
        "type": "string",
        "allowNull": false
    }, {
        "name": "strContractNumber",
        "type": "string",
        "allowNull": false
    }, {
        "name": "ysnSubCurrency",
        "type": "boolean",
        "allowNull": true
    }, {
        "name": "dblTax",
        "type": "float",
        "allowNull": false
    }, {
        "name": "intTaxGroupId",
        "type": "int",
        "allowNull": true
    }, {
        "name": "strTaxGroup",
        "type": "string",
        "allowNull": false
    }],
    validators: [
        [{
            "field": "strItemNo",
            "type": "presence"
        }, {
            "field": "strCostMethod",
            "type": "presence"
        }]
    ]
});