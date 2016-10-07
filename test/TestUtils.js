/**
 * Created by WEstrada on 10/6/2016.
 */
Ext.define('Inventory.TestUtils', {
    name: 'testutils',

    statics: {
        /**
         * Check if field exists.
         * @param fields
         * @param name
         * @param type
         */
        shouldHaveField: function (fields, name, type) {
            should.exist(_.findWhere(fields, {name: name, type: type}), name
                + ' does not exists. The field name or data type might have been changed.');
        },

        shouldHaveReference: function (fields, name, reference, inverse) {
            var field = _.find(fields, function (field) {
                return field.name === 'intInventoryAdjustmentId'
                    && field.reference
                    && field.reference.type === reference;
            });
            should.exist(field, "Reference model '" + reference + "' for '" + name + "' does not exists.");
            if (inverse && reference) {
                field.reference.inverse.role.should.be.equal(inverse, "The inverse role '"
                    + inverse + "' is not equal to '" + field.reference.inverse.role + "'.")
            }
        },

        /**
         * Unit test for a odel
         * @param config Contains all the configurations of the Model
         *  - modelName Name of the model including the namespace.
         *  - fieldList List of fields { name: <fieldname>, type: <datatype> }
         *  - referenceList List of field references { name: <fieldname>, type: <referencemodel>, role: <role> }
         *  - idProperty The id of the Model
         *  - callbacks Includes some events for handling the model
         *      Events: afterInit
         */
        testModel: function (config) {
            var modelName = config.model,
                idProperty = config.idProperty,
                fieldList = config.fields,
                referenceList = config.references,
                callbacks = config.callbacks,
                dontCheckFields = config.dontCheckFields;

            var model = Ext.create(modelName);

            describe(modelName, function () {
                it('should exists', function () {
                    should.exist(model, "Adjustment Note model is not initialized.");
                });

                it('should be derived from iRely.BaseEntity', function () {
                    model.should.be.an.instanceof(iRely.BaseEntity, "Not derived from iRely.BaseEntity");
                });

                it('should have idProperty', function () {
                    if (model.idProperty)
                        model.idProperty.should.equal(idProperty);
                });

                if(fieldList && !dontCheckFields) {
                    describe('should have fields', function () {
                        model.should.have.property('fields');
                        var fields = model.fields;
                        should.exist(fields, 'No fields');

                        it('should have the correct fields', function () {
                            _.isEmpty(fields).should.be.false;
                            _.each(fieldList, function (field) {
                                Inventory.TestUtils.shouldHaveField(fields, field.name, field.type);
                            });
                        });

                        it('should have reference model(s)', function () {
                            _.each(referenceList, function (ref) {
                                Inventory.TestUtils.shouldHaveReference(fields, ref.name, ref.type, ref.role);
                            })
                        });

                        /*if (callbacks) {
                         if (callbacks.afterInit) {
                         callbacks.afterInit(model);
                         }
                         }*/
                    });
                }

                describe("after initialization", function () {
                    if (callbacks) {
                        if (callbacks.afterInit) {
                            callbacks.afterInit(model);
                        }
                    }
                })
            });
        },

        /**
         * Unit test for a view controller
         * @param cfg A configuration object that is passed to this function that contains information about the view controller.
         *  - name: The name of the view controller including the namespace.
         *  - callbacks: Contains some events to handle the view controller.
         *      Events: init, searchConfig, binConfig
         */
        testViewController: function (cfg) {
            var name = cfg.name,
                callbacks = cfg.callbacks,
                controller, config, search, binding;

            controller = Ext.create(name);
            config = controller.config;
            search = config.searchConfig;
            binding = config.binding;

            describe(name, function () {
                // Initialize controller
                if (cfg.init) {
                    describe("initialize view controller", function () {
                        cfg.init(controller);
                    });
                }

                it('should exist', function () {
                    should.exist(controller);
                });

                it('should have a config', function () {
                    should.exist(config);
                });

                describe('config', function () {
                    it('should have a search config', function () {
                        should.exist(search);
                    });

                    it('should have a binding config', function () {
                        should.exist(binding);
                    });

                    if (callbacks) {
                        describe("search config", function () {
                            callbacks.searchConfig(search);
                        });

                        describe("binding config", function () {
                            callbacks.bindConfig(binding);
                        });
                    }
                });
            });
        },

        outputFields: function (modelName) {
            var model = Ext.create(modelName);
            var ff = [];
            _.each(model.fields, function (f) {
                ff.push({name: f.name, type: 'int'});
            });
            console.log(ff);
        }
    }
})