/**
 * Created by LZabala on 11/25/2014.
 */
Ext.define('Inventory.model.ItemFactoryManufacturingCell', {
    extend: 'iRely.BaseEntity',

    requires: [
        'Ext.data.Field'
    ],

    idProperty: 'intItemFactoryManufacturingCellId',

    fields: [
        { name: 'intItemFactoryManufacturingCellId', type: 'int'},
        { name: 'intItemFactoryId', type: 'int',
            reference: {
                type: 'Inventory.model.ItemFactory',
                inverse: {
                    role: 'tblICItemFactoryManufacturingCells',
                    storeConfig: {
                        complete: true,
                        sortOnLoad: true,
                        sorters: {
                            direction: 'ASC',
                            property: 'intSort'
                        }
                    }
                }
            }
        },
        { name: 'intManufacturingCellId', type: 'int', allowNull: true },
        { name: 'ysnDefault', type: 'boolean'},
        { name: 'intPreference', type: 'int'},
        { name: 'intSort', type: 'int'},

        { name: 'strCellName', type: 'string'}

    ],

    validators: [
        {type: 'presence', field: 'strCellName'}
    ]
});