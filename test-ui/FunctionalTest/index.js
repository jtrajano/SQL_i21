var Harness = new Siesta.Harness.Browser.ExtJS (),
    functionalTest = '../../../TestFramework/FunctionalTest.js';

Harness.configure({
    title: 'i21 Test Suite',
    hostPageUrl: '../../../i21',
    forceDOMVisible: false,
    waitForExtReady: false,
    sandbox: false

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
    }


);