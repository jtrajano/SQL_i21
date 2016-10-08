/**
 * Created by WEstrada on 10/7/2016.
 */
var es = require('event-stream');
var esprima = require('esprima');
var TopoSort = require('topo-sort');
var gutil = require('gulp-util');
var Stream = require('stream');
var Path = require('path');

var PluginError = gutil.PluginError;
const PLUGIN_NAME = 'i21-gen-spec';

function generateSpecs(config) {
    return es.map(function (file, cb) {
        var fileContent = file.contents.toString();
        var defineRegexp = /Ext[\s|\n|\r]*\.define[\s|\n|\r]*\(/;
        var startIndex = regexIndexOf(fileContent, defineRegexp);
        var stopIndex = regexIndexOf(fileContent, defineRegexp, startIndex + 1);
        var files = {};
        var referencesFilesMap = {};
        var tsort = new TopoSort();
        var currentClass, currentIdProperty, extendClasses;
        var extObject = {};

        var dependencies = {};
        var addedClasses = [];

        while (startIndex !== -1) {
            var defineContent, contentUntilStopIndex, contentUntilStopIndexCleared;
            if (stopIndex !== -1) {
                defineContent = fileContent.substr(startIndex, stopIndex - startIndex);
                contentUntilStopIndex = fileContent.substr(0, stopIndex);
                contentUntilStopIndexCleared = removeNotRequiredBracesFrom(contentUntilStopIndex);
            } else {
                defineContent = fileContent.substr(startIndex);
                contentUntilStopIndex = fileContent;
                contentUntilStopIndexCleared = removeNotRequiredBracesFrom(fileContent);
            }
            var braceDiffUntilStopIndex = Math.abs(countChars(contentUntilStopIndexCleared, '{') - countChars(contentUntilStopIndexCleared, '}'));

            var strClearedContent = removeNotRequiredBracesFrom(defineContent);
            var openBraces = countChars(strClearedContent, '{');
            var closedBraces = countChars(strClearedContent, '}');


            if (openBraces === closedBraces) {
                var currentClassWithApostrophes = defineContent.match(/Ext[\s|\n|\r]*\.[\s|\n|\r]*define[\s|\n|\r|\(]*?[\'|\"][a-zA-Z0-9\.]*?[\'|\"]/);

                var requirements = defineContent.match(/requires[.|\n|\r|\s]*:[\s|\n|\r|]*[\[]*[a-zA-Z0-9|\n|\r|\'|\"|\s|\.|,|\/]*[\]]*/);
                var mixins = defineContent.match(/mixins[.|\n|\r| ]*:[\s|\n|\r][\{|\[]+(.|\n|\r)*?(\}|\])+/);
                var extend = defineContent.match(/extend[\s|\n|\r]*:[\s|\n|\r]*[\'|\"][a-zA-Z\.\s]*[\'|\"]/);
                var model = defineContent.match(/model[\s|\n|\r]*:[\s|\n|\r]*[\'|\"][a-zA-Z\.\s]*[\'|\"]/);
                var idProperty = defineContent.match(/idProperty[\s|\n|\r]*:[\s|\n|\r]*[\'|\"][a-zA-Z\.\s]*[\'|\"]/);
                var fields = defineContent.match(/fields[.|\n|\r|\s]*:[\s|\r|\n]*[\[]*([/g \s|\r|\n|\{]*[a-zA-Z0-9|\n|\r|\s|\'|\"|\.|\,|\:|\|\-|\\|\/}])*[\]]*/g);
                var fieldList = fields[0].toString().match(/\[[\s|\r|\n]*[\[]*([\s|\r|\n|\{]*[a-zA-Z0-9|\n|\r|\s|\'|\"|\-|\.|\,|\:|\}|\\|\/])*[\]]*/);

                //parse classnames
                currentClass = getClassNames(currentClassWithApostrophes)[0];
                var reqClasses = getClassNames(requirements);
                extendClasses = getClassNames(extend);
                var mixinClasses = getClassNames(mixins);
                var modelClass = getClassNames(model);
                currentIdProperty = getClassNames(idProperty);
                var dependencyClasses = mixinClasses.concat(extendClasses).concat(reqClasses).concat(modelClass);

                // Map to Ext object

                extObject = {
                    class: currentClass,
                    base: extendClasses[0],
                    idProperty: currentIdProperty[0],
                    dependencies: JSON.stringify(dependencyClasses)
                };

                if (stopIndex !== -1) {
                    startIndex = regexIndexOf(fileContent, defineRegexp, stopIndex + 1);
                } else {
                    startIndex = regexIndexOf(fileContent, defineRegexp, startIndex + 1);
                }

                stopIndex = regexIndexOf(fileContent, defineRegexp, startIndex + 1);
            } else {
                if (stopIndex !== -1) {
                    stopIndex = regexIndexOf(fileContent, defineRegexp, stopIndex + 1);
                } else {
                    startIndex = regexIndexOf(fileContent, defineRegexp, startIndex + 1);
                }
            }
        }

        //@Todo: Need an improvement on this
        if (config.type === "model") {
            var str = `Inventory.TestUtils.testModel({
                    model: '${extObject.class}',
                    base: '${extObject.base}',
                    idProperty: '${extObject.idProperty}',
                    dependencies: ${extObject.dependencies},
                    fields: ${extObject.fields}
                });`;
        }
        var namespace = config.moduleName + "." + config.type + ".";
        var newPath = parsePath(file.relative);
        file.path = `${config.destDir}\\${currentClass.replace(namespace, "").replace(/([a-z])([A-Z])/g, '$1-$2').toLowerCase()}.${config.type.toLowerCase()}.spec.js`;
        file.contents = new Buffer(str);

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

function getClassNames(stringWithClassNames) {
    var allClassNames = [];

    if (stringWithClassNames) {
        var i = 0;
        stringWithClassNames.forEach(function (req) {
            var classNames = req.match(/[\'|\"][a-zA-Z0-9\.]+[\'|\"]/g);
            if (classNames) {
                classNames.forEach(function (c, index) {
                    if (typeof index === "number") {
                        allClassNames[i++] = c.substr(1, c.length - 2);
                    }
                });
            }
        });
    }

    return allClassNames;
}

function concatUnique(arr1, arr2) {
    arr2.forEach(function (element) {
        if (arr1.indexOf(element) === -1) {
            arr1.push(element);
        }
    });
    return arr1;
}

function removeComments(content) {
    return content.replace(/(?:\/\*(?:[\s\S]*?)\*\/)|(?:([\s;])+\/\/(?:.*)$)/gm, '');
}

function regexIndexOf(str, regex, startpos) {
    var indexOf = str.substring(startpos || 0).search(regex);
    return (indexOf >= 0) ? (indexOf + (startpos || 0)) : indexOf;
}

function sortObjectByKey(obj) {
    var keys = [];
    var sorted_obj = {};

    for (var key in obj) {
        if (obj.hasOwnProperty(key)) {
            keys.push(key);
        }
    }

    // sort keys
    keys.sort();

    // create new array based on Sorted Keys
    keys.forEach(function (key) {
        sorted_obj[key] = obj[key];
    });

    return sorted_obj;
}

function removeNotRequiredBracesFrom(str) {
    return str.replace(/('.*?[^\\]'|".*?[^\\]"|\/.*?[^\\]\/)/gm, '')
}

function countChars(str, char) {
    var hist = {};
    for (var si in str) {
        hist[str[si]] = hist[str[si]] ? 1 + hist[str[si]] : 1;
    }
    return hist[char];
}

function afterFileCollection() {

    dependencies = sortObjectByKey(dependencies);
    for (var className in dependencies) {
        if (className != "undefined") {
            tsort.add(className, dependencies[className]);
        }
    }

    //fs.writeFile('tsort.map.txt', JSON.stringify(tsort.map));

    try {
        var result = tsort.sort().reverse();
    } catch (e) {
        return this.emit('error', new PluginError(PLUGIN_NAME, e.message));
    }

    //fs.writeFile('tsort.result.txt', JSON.stringify(result));

    result.forEach(function (className) {
        if (files[className] && addedClasses.indexOf(files[className]) === -1) {
            addedClasses.push(files[className]);
            this.emit('data', files[className]);
        }
    }.bind(this));

    this.emit('end');
}

module.exports = generateSpecs;

/*
gulp.task('fix-config', function() {
    return gulp.src('path/to/original/!*.config')
        .pipe(fixConfigFile())
        .pipe(gulp.dest('path/to/fixed/configs'));
});*/
