var Harness = Siesta.Harness.Browser.ExtJS,
    version = Math.floor(Math.random() * 9999) + 1,
    functionalTest = '../../TestFramework/FunctionalTest.js?v='+version;

Harness.configure({
    title: 'i21 Test Suite',
    hostPageUrl: '../../i21/',
    forceDOMVisible: false,
    waitForExtReady: false,
    sandbox:false,
    viewportWidth: 1800,
    viewportHeight: 1000

});

localStorage.setItem('i21UserName', window.btoa('irelyadmin'));
localStorage.setItem('i21Password', window.btoa('i21by2015'));
localStorage.setItem('i21Company', '01');
localStorage.setItem('i21RememberMe', true);

Harness.start(

    { group: 'PreSetup',
        items: [
            {
                url: 'PreSetup/PreSetup.js?v='+version,
                title: 'PreSetup',
                preload: [
                    functionalTest,
                    'CommonIC.js'
                ]
            }
        ]
    },


    { group: 'Item',
        items: [
            {
                url: 'Item/AddInventory.js?v='+version,
                title: 'AddInventory',
                preload: [
                    functionalTest
                ]
            },

            {
                url: 'Item/DeleteInventory.js?v='+version,
                title: 'DeleteInventory',
                preload: [
                    functionalTest
                ]
            }
        ]
    },

    { group: 'Commodity',
        items: [
            {
                url: 'Commodity/AddCommodity.js?v='+version,
                title: 'AddCommodity',
                preload: [
                    functionalTest
                ]
            },
            {
                url: 'Commodity/DeleteCommodity.js?v='+version,
                title: 'DeleteCommodity',
                preload: [
                    functionalTest
                ]
            }
        ]
    },

    { group: 'Category',
        items: [
            {
                url: 'Category/AddCategory.js?v='+version,
                title: 'AddCategory',
                preload: [
                    functionalTest
                ]
            },
            {
                url: 'Category/DeleteCategory.js?v='+version,
                title: 'DeleteCategory',
                preload: [
                    functionalTest
                ]
            }
        ]
    },

    { group: 'FuelCategory',
        items: [
            {
                url: 'FuelCategory/AddFuelCategory.js?v='+version,
                title: 'AddFuelCategory',
                preload: [
                    functionalTest
                ]
            },
            {
                url: 'FuelCategory/DeleteFuelCategory.js?v='+version,
                title: 'DeleteFuelCategory',
                preload: [
                    functionalTest
                ]
            }
        ]
    },

    { group: 'FeedStock',
        items: [
            {
                url: 'FeedStock/AddFeedStock.js?v='+version,
                title: 'AddFeedStock',
                preload: [
                    functionalTest
                ]
            },
            {
                url: 'FeedStock/DeleteFeedStock.js?v='+version,
                title: 'DeleteFeedStock',
                preload: [
                    functionalTest
                ]
            }
        ]
    },

    { group: 'FuelCode',
        items: [
            {
                url: 'FuelCode/AddFuelCode.js?v='+version,
                title: 'AddFuelCode',
                preload: [
                    functionalTest
                ]
            },
            {
                url: 'FuelCode/DeleteFuelCode.js?v='+version,
                title: 'DeleteFuelCode',
                preload: [
                    functionalTest
                ]
            }
        ]
    },

    { group: 'ProductionProcess',
        items: [
            {
                url: 'ProductionProcess/AddProductionProcess.js?v='+version,
                title: 'AddProductionProcess',
                preload: [
                    functionalTest
                ]
            },
            {
                url: 'ProductionProcess/DeleteProductionProcess.js?v='+version,
                title: 'DeleteProductionProcess',
                preload: [
                    functionalTest
                ]
            }
        ]
    },

    { group: 'FeedStockUOM',
        items: [
            {
                url: 'FeedStockUOM/AddFeedStockUOM.js?v='+version,
                title: 'AddFeedStockUOM',
                preload: [
                    functionalTest
                ]
            }
        ]
    },

    { group: 'FuelType',
        items: [
            {
                url: 'FuelType/AddFuelType.js?v='+version,
                title: 'AddFuelType',
                preload: [
                    functionalTest
                ]
            }
        ]
    },

    { group: 'InventoryUOM',
        items: [
            {
                url: 'InventoryUOM/AddInventoryUOM.js?v='+version,
                title: 'AddInventoryUOM',

                preload: [
                    functionalTest
                ]
            }
        ]
    },

    { group: 'StorageLocation',
        items: [
            {
                url: 'StorageLocation/AddStorageLocation.js?v='+version,
                title: 'AddStorageLocation',
                preload: [
                    functionalTest
                ]
            }
        ]
    },

    { group: 'InventoryReceipt',
        items: [
            {

                url: 'InventoryReceipt/AddInventoryReceipt.js?v='+version,
                title: 'AddInventoryReceipt',
                preload: [
                    functionalTest
                ]
            }
        ]
    },

    { group: 'InventoryShipment',
        items: [
            {
                url: 'InventoryShipment/AddInventoryShipment.js?v='+version,
                title: 'AddInventoryShipment',
                preload: [
                    functionalTest
                ]
            }
        ]
    },

    { group: 'InventoryTransfer',
        items: [
            {
                url: 'InventoryTransfer/AddInventoryTransfer.js?v='+version,
                title: 'AddInventoryTransfer',
                preload: [
                    functionalTest
                ]
            }
        ]
    },

    { group: 'InventoryAdjustment',
        items: [
            {
                url: 'InventoryAdjustment/AddInventoryAdjustment.js?v='+version,
                title: 'AddInventoryAdjustment',
                preload: [
                    functionalTest
                ]
            }
        ]
    },

    { group: 'InventoryCount',
        items: [
            {
                url: 'InventoryCount/AddInventoryCount.js?v='+version,
                title: 'AddInventoryCount',
                preload: [
                    functionalTest,
                    'CommonIC.js'
                ]
            }
        ]
    },

    { group: 'StorageMeasurementReading',
        items: [
            {
                url: 'StorageMeasurementReading/AddSMR.js?v='+version,
                title: 'AddSMR',
                preload: [
                    functionalTest,
                    'CommonIC.js'
                ]
            }
        ]
    },

    { group: 'SmokeTesting',
        items: [
            {
                url: 'SmokeTesting/ICSmokeTests.js?v='+version,
                title: 'ICSmokeTests',
                preload: [
                    functionalTest,
                    'CommonIC.js'
                ]
            },
            {
                url: 'SmokeTesting/ICOpenScreens.js?v='+version,
                title: 'ICOpenScreens',
                preload: [
                    functionalTest,
                    'CommonIC.js'
                ]
            },
            {
                url: 'SmokeTesting/ICAddMaintenance.js?v='+version,
                title: 'ICAddMaintenance',
                preload: [
                    functionalTest,
                    'CommonIC.js'
                ]
            },
            {
                url: 'SmokeTesting/ICAddTransactions.js?v='+version,
                title: 'ICAddTransactions',
                preload: [
                    functionalTest,
                    'CommonIC.js'
                ]
            }

        ]
    }

);