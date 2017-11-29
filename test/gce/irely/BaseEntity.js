/**
 * Base model class for all model that participates in the CRUD operation.
 */
Ext.define('iRely.BaseEntity', {
    extend: 'Ext.data.Model',

    /**
     * @cfg {Ext.data.Field[]} fields
     */
    fields: [
        {
            name: 'intConcurrencyId',
            type: 'int'
        },
        {
            name: 'strDetailChange',
            type:'string',
            audit: false
        },
        {
            name: 'strOriginalRowState',
            type:'string',
            audit: false
        },
        {
            name: 'strRowState',
            type:'string'
        },
        {
            name: 'ysnDeleted',
            type: 'boolean',
            allowNull: true
        },
        {
            name: 'dtmDateDeleted',
            type: 'date',
            allowNull: true
        }
    ],

    /**
     * @cfg {String} clientIdProperty Used to map server record and client record.
     */
    clientIdProperty: 'strClientID',
    identifier: 'sequential',
    idProperty: null,
    audit: {},

    /**
     * Constructor
     * @param data
     * @param id
     * @param raw
     * @param convertedData
     */
    constructor : function(data, id, raw, convertedData){
        var me = this;

        me.callParent(arguments);
        me.data['strClientID'] = raw ? raw['strClientID'] ? raw['strClientID'] : me.internalId : me.internalId;

        if (me.phantom) {
            me.data[me.idProperty] = me.internalId;
            me['id'] = me.internalId;
        }
    }
});