var Harness = new Siesta.Harness.Browser.ExtJS (),
    functionalTest = '../../../TestFramework/FunctionalTest.js';

Harness.configure({
    title: 'i21 Test Suite',
    hostPageUrl: '../../../i21',
    forceDOMVisible: false,
    waitForExtReady: false,
    sandbox: false,
    viewportWidth: 1200,
    viewPortHeight: 1000

});

localStorage.setItem('i21UserName', window.btoa('irelyadmin'));
localStorage.setItem('i21Password', window.btoa('i21by2015'));
localStorage.setItem('i21Company', '01');
localStorage.setItem('i21RememberMe', true);

Harness.start(

    { group: 'Item',
        items: [
            {
                url: '../Item/AddInventory.js',
                preload: [
                    functionalTest
                ]
            }
        ]
    },

    { group: 'Commodity',
        items: [
            {
                url: '../Commodity/AddCommodity.js',
                preload: [
                    functionalTest
                ]
            }
        ]
    },

    { group: 'Category',
        items: [
            {
                url: '../Category/AddCategory.js',
                preload: [
                    functionalTest
                ]
            }
        ]
    },

    { group: 'FuelCategory',
        items: [
            {
                url: '../FuelCategory/AddFuelCategory.js',
                preload: [
                    functionalTest
                ]
            }
        ]
    },

    { group: 'FeedStock',
        items: [
            {
                url: '../FeedStock/AddFeedStock.js',
                preload: [
                    functionalTest
                ]
            }
        ]
    },

    { group: 'FuelCode',
        items: [
            {
                url: '../FuelCode/AddFuelCode.js',
                preload: [
                    functionalTest
                ]
            }
        ]
    },

    { group: 'ProductionProcess',
        items: [
            {
                url: '../ProductionProcess/AddProductionProcess.js',
                preload: [
                    functionalTest
                ]
            }
        ]
    },

    { group: 'FeedStockUOM',
        items: [
            {
                url: '../FeedStockUOM/AddFeedStockUOM.js',
                preload: [
                    functionalTest
                ]
            }
        ]
    }



);