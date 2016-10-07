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

        shouldHaveReference: function(fields, name, reference, inverse) {
            var field = _.find(fields, function(field) {
                return field.name === 'intInventoryAdjustmentId'
                    && field.reference
                    && field.reference.type === reference;
            });
            should.exist(field, "Reference model '" + reference + "' for '" + name + "' does not exists.");
            if(inverse && reference) {
                field.reference.inverse.role.should.be.equal(inverse, "The inverse role '"
                    + inverse + "' is not equal to '" + field.reference.inverse.role + "'.")
            }
        },

        /**
         * Tests required properties of a model
         * @param modelName Name of the model including the namespace.
         * @param fieldList List of fields { name: <fieldname>, type: <datatype> }
         * @param referenceList List of field references { name: <fieldname>, type: <referencemodel>, role: <role> }
         */
        checkModelProperties: function(config) {
            var modelName = config.model,
                idProperty = config.idProperty,
                fieldList = config.fields,
                referenceList = config.references,
                listeners = config.listeners;
            var model = Ext.create(modelName);

            describe(modelName, function() {
                it('should exists', function() {
                    should.exist(model, "Adjustment Note model is not initialized.");
                });

                it('should be derived from iRely.BaseEntity', function() {
                    model.should.be.an.instanceof(iRely.BaseEntity, "Not derived from iRely.BaseEntity");
                });

                it('should have idProperty', function() {
                    if(model.idProperty)
                        model.idProperty.should.equal(idProperty);
                });

                it('should have fields', function() {
                    model.should.have.property('fields');
                    describe(modelName, function() {
                        var fields = model.fields;
                        should.exist(fields, 'No fields');

                        it('should have the correct fields', function() {
                            _.isEmpty(fields).should.be.false;
                            _.each(fieldList, function(field) {
                                Inventory.TestUtils.shouldHaveField(fields, field.name, field.type);
                            });
                        });

                        it('should have reference model(s)', function() {
                            _.each(referenceList, function(ref) {
                                Inventory.TestUtils.shouldHaveReference(fields, ref.name, ref.type, ref.role);
                            })
                        });

                        if(listeners) {
                            if(listeners.afterInit) {
                                listeners.afterInit(model);
                            }
                        }
                    });
                });
            });
        },

        outputFields: function(modelName) {
            var model = Ext.create(modelName);
            var ff = [];
            _.each(model.fields, function(f) {
                ff.push({ name: f.name, type: 'int' });
            });
            console.log(ff);
        }
    }
})