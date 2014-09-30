Ext.define('Inventory.view.override.ManufacturerViewController', {
    override: 'Inventory.view.ManufacturerViewController',

    config: {
        searchConfig: {
            title:  'Search Manufacturer',
            type: 'Manufacturer',
            api: {
                read: '../Inventory/api/Manufacturer/SearchManufacturers'
            },
            columns: [
                {dataIndex: 'intManufacturerId',text: "Manufacturer Id", flex: 1, defaultSort:true, dataType: 'numeric', key: true, hidden: true},
                {dataIndex: 'strManufacturer', text: 'Manufacturer', flex: 1,  dataType: 'string'},
                {dataIndex: 'strContact', text: 'Contact', flex: 1,  dataType: 'string'},
                {dataIndex: 'strEmail',text: 'Email', flex: 1,  dataType: 'string'},
                {dataIndex: 'strNotes',text: 'Notes', flex: 1,  dataType: 'string'}
            ]
        },
        binding: {
            txtManufacturer: '{current.strManufacturer}',
            txtContact: '{current.strContact}',
            txtAddress: '{current.strAddress}',
            cboZipCode: {
                         value:'{current.strZipCode}',
                         store:'{ZipCodeBuffered}'
                        },
            txtCity: '{current.strCity}',
            txtState: '{current.strState}',
            cboCountry: {
                value:'{current.strCountry}',
                store:'{CountryBuffered}'
            },
            txtPhone: '{current.strPhone}',
            txtFax: '{current.strFax}',
            txtWebsite: '{current.strWebsite}',
            txtEmail: '{current.strEmail}',
            txtNotes: '{current.strNotes}'

        }
    },

    setupContext : function(options){
        var me = this,
            win = options.window,
            store = Ext.create('Inventory.store.Manufacturer', { pageSize: 1 });

        win.context = Ext.create('iRely.Engine', {
            window : win,
            store  : store,
            createRecord : me.createRecord,
            binding: me.config.binding
        });

        return win.context;
    },

    show : function(config) {
        "use strict";

        var me = this,
            win = this.getView();

        if (config) {
            win.show();

            var context = me.setupContext( {window : win} );

            if (config.action === 'new') {
                context.data.addRecord();
            } else {
                if (config.id) {
                    config.filters = [{
                        column: 'intManufacturerId',
                        value: config.id
                    }];
                }
                context.data.load({
                    filters: config.filters
                });
            }
        }
    }

});