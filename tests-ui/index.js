/**
 * Created by RQuidato on 10/23/14.
 */
var Harness = Siesta.Harness.Browser.ExtJS


Harness.configure({
    title: 'i21 Test Suite',
    preload: [
        "../resources/extjs/ext-4.2.1.883/resources/css/ext-all.css",
        "../resources/extjs/ext-4.2.1.883/ext.js",


    ],
    hostPageUrl: '../../SystemManager/app.html',
    forceDOMVisible: false,
    waitForExtReady: false
    //runCore: 'sequential',
    //autoRun: true
});
Harness.start(

    { group: 'FuelCategory',
        items: [
            {
                url: 'FuelCategory/AddFuelCategory.js',
                preload: [
                    '../../GlobalComponentEngine/irely/TestEngine.js'
                ]
            },
            {
                url: 'FuelCategory/DeleteFuelCategory.js',
                preload: [
                    '../../GlobalComponentEngine/irely/TestEngine.js'
                ]
            }
        ]
    },
    { group: 'FuelCode',
        items: [
            {
                url: 'FuelCode/AddFuelCode.js',
                preload: [
                    '../../GlobalComponentEngine/irely/TestEngine.js'
                ]
            },
            {
                url: 'FuelCode/DeleteFuelCode.js',
                preload: [
                    '../../GlobalComponentEngine/irely/TestEngine.js'
                ]
            }
        ]
    },

    { group: 'ProcessCode',
        items: [
            {
                url: 'ProcessCode/AddProcessCode.js',
                preload: [
                    '../../GlobalComponentEngine/irely/TestEngine.js'
                ]
            },
            {
                url: 'ProcessCode/DeleteProcessCode.js',
                preload: [
                    '../../GlobalComponentEngine/irely/TestEngine.js'
                ]
            }
        ]
    },
    { group: 'FeedStockCode',
        items: [
            {
                url: 'FeedStockCode/AddFeedStockCode.js',  // url of the js file, containing actual test code
                preload: [
                    '../../GlobalComponentEngine/irely/TestEngine.js'
                ]
            },
            {
                url: 'FeedStockCode/DeleteFeedStockCode.js',  // url of the js file, containing actual test code
                preload: [
                    '../../GlobalComponentEngine/irely/TestEngine.js'
                ]
            }
        ]
    },
    { group: 'FeedStockUOM',
        items: [
            {
                url: 'FeedStockUOM/AddFeedStockUOM.js',  // url of the js file, containing actual test code
                preload: [
                    '../../GlobalComponentEngine/irely/TestEngine.js'
                ]
            },
            {
                url: 'FeedStockUOM/DeleteFeedStockUOM.js',  // url of the js file, containing actual test code
                preload: [
                    '../../GlobalComponentEngine/irely/TestEngine.js'
                ]
            }
        ]
    },
    { group: 'FuelType',
        items: [
            {
                url: 'FuelType/AddFuelType.js',  // url of the js file, containing actual test code
                preload: [
                    '../../GlobalComponentEngine/irely/TestEngine.js'
                ]
            },
            {
                url: 'FuelType/DeleteFuelType.js',  // url of the js file, containing actual test code
                preload: [
                    '../../GlobalComponentEngine/irely/TestEngine.js'
                ]
            }
        ]
    },
    { group: 'FuelTaxClass',
        items: [
            {
                url: 'FuelTaxClass/AddFuelTaxClass.js',  // url of the js file, containing actual test code
                preload: [
                    '../../GlobalComponentEngine/irely/TestEngine.js'
                ]
            },
            {
                url: 'FuelTaxClass/DeleteFuelTaxClass.js',  // url of the js file, containing actual test code
                preload: [
                    '../../GlobalComponentEngine/irely/TestEngine.js'
                ]
            }
        ]
    },
    { group: 'InventoryTag',
        items: [
            {
                url: 'InventoryTag/AddInventoryTag.js',  // url of the js file, containing actual test code
                preload: [
                    '../../GlobalComponentEngine/irely/TestEngine.js'
                ]
            },
            {
                url: 'InventoryTag/DeleteInventoryTag.js',  // url of the js file, containing actual test code
                preload: [
                    '../../GlobalComponentEngine/irely/TestEngine.js'
                ]
            }
        ]
    },
    { group: 'PatronageCategory',
        items: [
            {
                url: 'PatronageCategory/AddPatronageCategory.js',  // url of the js file, containing actual test code
                preload: [
                    '../../GlobalComponentEngine/irely/TestEngine.js'
                ]
            },
            {
                url: 'PatronageCategory/DeletePatronageCategory.js',  // url of the js file, containing actual test code
                preload: [
                    '../../GlobalComponentEngine/irely/TestEngine.js'
                ]
            }
        ]
    },
    { group: 'Manufacturer',
        items: [
            {
                url: 'Manufacturer/AddManufacturer.js',  // url of the js file, containing actual test code
                preload: [
                    '../../GlobalComponentEngine/irely/TestEngine.js'
                ]
            },
            {
                url: 'Manufacturer/DeleteManufacturer.js',  // url of the js file, containing actual test code
                preload: [
                    '../../GlobalComponentEngine/irely/TestEngine.js'
                ]
            }
        ]
    },
    { group: 'InventoryUOM',
        items: [
            {
                url: 'InventoryUOM/AddInventoryUOM.js',  // url of the js file, containing actual test code
                preload: [
                    '../../GlobalComponentEngine/irely/TestEngine.js'
                ]
            },
            {
                url: 'InventoryUOM/DeleteInventoryUOM.js',  // url of the js file, containing actual test code
                preload: [
                    '../../GlobalComponentEngine/irely/TestEngine.js'
                ]
            }
        ]
    }


)