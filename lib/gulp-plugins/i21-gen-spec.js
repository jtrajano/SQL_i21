/**
 * Created by WEstrada on 10/7/2016.
 */
var es = require('event-stream');
var esprima = require('esprima');
var gutil = require('gulp-util');
var Stream = require('stream');
var Path = require('path');
var _ = require('../../app/lib/underscore');

var PluginError = gutil.PluginError;
const PLUGIN_NAME = 'i21-gen-spec';

function generateSpecs(config) {
    return es.map(function (file, cb) {

        var fileContent = file.contents.toString();
        var specType = config.type;
        let tree = esprima.parse(fileContent);
        var arguments = tree.body[0].expression.arguments;
        let literal = _.findWhere(arguments, { type: 'Literal'});
        let objectExp = _.findWhere(arguments, { type: 'ObjectExpression'});
        let properties = objectExp.properties;
        let className = literal.value;

        // let spec = "";
        switch(specType) {
            case "model":
                spec = generateModelSpec(config, className, properties);
                break;
            case "store":
                spec = generateStoreSpec(config, className, properties);
                break;
            case "view-controller":
                spec = generateModelSpec(config, className, properties);
                break;
            case "view-model":
                break;
            default:
                break;
        }

        var namespace = config.moduleName + "." + config.type + ".";
        var newPath = parsePath(file.relative);
        file.path = `${config.destDir}\\${className.replace(namespace, "").replace(/([a-z])([A-Z])/g, '$1-$2').toLowerCase()}.${config.type.toLowerCase()}.spec.js`;
        file.contents = new Buffer(spec);

        // send the updated file down the pipe
        cb(null, file);
    });
}

function parsePath(path) {
    var extname = Path.extname(path);
    return {
        dirname: Path.dirname(path),
        basename: Path.basename(path, extname),
        extname: extname
    };
}

function generateModelSpec(config, className, properties) {
    let base, idProperty, fields = [], dependencies = [], validators = [];

    _.each(properties, function(prop) {
        if(prop.type === "Property" && prop.key.type === "Identifier") {
            switch (prop.key.name) {
                case "extend":
                    base = prop.value.value;
                    break;
                case "idProperty":
                    idProperty = prop.value.value;
                    break;
                case "requires":
                    if(prop.value) {
                        _.each(prop.value.elements, function(e) {
                            if(e) dependencies.push(JSON.stringify(e.value));
                        });
                    }
                    break;
                case "fields":
                    _.each(prop.value.elements, function(e) {
                        let name, type, allowNull = false;
                        _.each(e.properties, function(p) {
                            switch(p.key.name) {
                                case "name":
                                    name = p.value.value;
                                    break;
                                case "type":
                                    type = p.value.value;
                                    break;
                                case "allowNull":
                                    allowNull = p.value.value;
                                    break;
                                default:
                                    break;                           
                            }
                        });
                        fields.push({
                            name: name,
                            type: type,
                            allowNull: allowNull
                        });
                    });
                    break;
                case "validators":
                    _.each(prop.value.elements, function(e) {
                        let field, type;
                        _.each(e.properties, function(p) {
                            switch(p.key.name) {
                                case "field":
                                    field = p.value.value;
                                    break;
                                case "type":
                                    type = p.value.value;
                                    break;
                                default:
                                    break;                            
                            }
                        });
                        validators.push({
                            field: field,
                            type: type
                        });
                    });
                    break;
                default:
                    break;
            }
        }
    });
    
    var spec = `
    ${config.moduleName}.TestUtils.testModel({
        name: '${className}',
        base: '${base}',${!_.isUndefined(idProperty) && !_.isNull(idProperty) ? "idProperty: '" + idProperty + "'," : ""}
        dependencies: [${dependencies}],
        fields: ${JSON.stringify(fields)},
        validators: [${JSON.stringify(validators)}]
    });
    `;
    return spec;
}

function generateStoreSpec(gulpConfig, className, properties) {
    let base, alias, fields = [], dependencies = [], validators = [], config = {};

    _.each(properties, function(prop) {
        if(prop.type === "Property" && prop.key.type === "Identifier") {
            switch (prop.key.name) {
                case "extend":
                    base = prop.value.value;
                    break;
                case "alias":
                    alias = prop.value.value;
                    break;
                case "requires":
                    _.each(prop.value.elements, function(e) {
                        dependencies.push(JSON.stringify(e.value));
                    });
                    break;
                case "constructor":
                    if(prop.value.body.type === "BlockStatement") {
                        let stmt = _.find(prop.value.body.body, function(b) {
                            return b.type === "ExpressionStatement" && b.expression.type === "CallExpression";
                        });
                        if(!(_.isNull(stmt) || _.isUndefined(stmt))) {
                            let cfg = _.find(stmt, function(s) {
                                return s.type === "CallExpression";
                            });
                            if(!(_.isNull(cfg) || _.isUndefined(cfg))) {
                                let args = cfg.arguments;
                                let prop = args[0].elements[0].arguments[0].properties;
                                _.each(prop, function(p) {
                                    switch(p.key.name) {
                                        case "model":
                                            config.model = p.value.value;
                                            break;
                                        case "storeId":
                                            config.storeId = p.value.value;
                                            break;
                                        case "pageSize":
                                            config.pageSize = p.value.value;
                                            break;
                                        case "remoteFilter":
                                            config.remoteFilter = p.value.value;
                                            break;
                                        case "remoteSort":
                                            config.remoteSort = p.value.value;
                                            break;
                                        case "proxy":
                                            let proxy = {};
                                            _.each(p.value.properties, function(pr) {
                                                switch(pr.key.name) {
                                                    case "type":
                                                        proxy.type = pr.value.value;
                                                        break;
                                                    case "api":
                                                        let api = {};
                                                        _.each(pr.value.properties, function(a) {
                                                            switch(a.key.name) {
                                                                case "read":
                                                                    api.read = a.value.value;
                                                                    break;
                                                                case "create":
                                                                    api.create = a.value.value;
                                                                    break;
                                                                case "update":
                                                                    api.update = a.value.value;
                                                                    break;
                                                                case "delete":
                                                                    api.delete = a.value.value;
                                                                    break;
                                                                default:
                                                                    break;
                                                            }
                                                        });
                                                        proxy.api = api;
                                                        break;
                                                    default:
                                                        break;
                                                }
                                            });
                                            config.proxy = proxy;
                                            break;
                                        default:
                                            break;
                                    }
                                });
                            }
                        }
                    }
                    break;
                default:
                    break;
            }
        }
    });
    var spec = `Inventory.TestUtils.testStore({
                    name: '${className}',
                    alias: '${alias}',
                    base: '${base}',
                    dependencies: [${dependencies}],
                    config: [${JSON.stringify(config)}]
                });`;
    return spec;
}

module.exports = generateSpecs;