var Harness = Siesta.Harness.Browser.ExtJS,
    version = Math.floor(Math.random() * 9999) + 1,
    commonIC = 'Common/CommonIC.js?v='+version,
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
                url: 'PreSetup/UsersLocation.js?v='+version,
                title: 'UserLocation',
                preload: [
                    functionalTest,
                    commonIC
                ]
            },
            {
                url: 'PreSetup/StorageLocation.js?v='+version,
                title: 'StorageLocation',
                preload: [
                    functionalTest,
                    commonIC
                ]
            },
            {
                url: 'PreSetup/Items.js?v='+version,
                title: 'Items',
                preload: [
                    functionalTest,
                    commonIC
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
            },
            {
                url: 'FeedStockUOM/DeleteFeedStockUOM.js?v='+version,
                title: 'DeleteFeedStockUOM',
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
            },
            {
                url: 'FuelType/DeleteFuelType.js?v='+version,
                title: 'DeleteFuelType',
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
            },
            {
                url: 'InventoryUOM/DeleteInventoryUOM.js?v='+version,
                title: 'DeleteInventoryUOM',

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
            },
            {
                url: 'StorageLocation/DeleteStorageLocation.js?v='+version,
                title: 'DeleteStorageLocation',
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
            },
            {
                url: 'InventoryReceipt/DeleteInventoryReceipt.js?v='+version,
                title: 'DeleteInventoryReceipt',
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
            },
            {
                url: 'InventoryShipment/DeleteInventoryShipment.js?v='+version,
                title: 'DeleteInventoryShipment',
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
            },
            {
                url: 'InventoryTransfer/DeleteInventoryTransfer.js?v='+version,
                title: 'DeleteInventoryTransfer',
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
            },
            {
                url: 'InventoryAdjustment/DeleteInventoryAdjustment.js?v='+version,
                title: 'DeleteInventoryAdjustment',
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
                    functionalTest
                ]
            },
            {
                url: 'InventoryCount/DeleteInventoryCount.js?v='+version,
                title: 'DeleteInventoryCount',
                preload: [
                    functionalTest
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
                    functionalTest
                ]
            },
            {
                url: 'StorageMeasurementReading/DeleteSMR.js?v='+version,
                title: 'DeleteSMR',
                preload: [
                    functionalTest
                ]
            }
        ]
    },

    { group: 'SmokeTesting',
        items: [
            {
                url: 'SmokeTesting/ICOpenScreens.js?v='+version,
                title: 'ICOpenScreens',
                preload: [
                    functionalTest,
                    commonIC
                ]
            },
            {
                url: 'SmokeTesting/ICSmokeTests.js?v='+version,
                title: 'ICSmokeTests',
                preload: [
                    functionalTest,
                    commonIC
                ]
            }

        ]
    },

    {
        group: 'BusinessDomain',
        items: [
            {
                group: 'StockChecking',
                items: [
                    {
                        url: 'BusinessDomain/StockChecking/ICStockCheckingLotted.js?v=' + version,
                        title: 'ICStockCheckingLotted',
                        preload: [
                            functionalTest,
                            commonIC

                        ]
                    },
                    {
                        url: 'BusinessDomain/StockChecking/ICStockCheckingNonLotted.js?v=' + version,
                        title: 'ICStockCheckingNonLotted',
                        preload: [
                            functionalTest,
                            commonIC

                        ]
                    }

                ]
            },
            {
                group: 'OtherCharges',
                items: [
                    {
                        url: 'BusinessDomain/OtherCharges/CalculateChargesByCostMethod.js?v=' + version,
                        title: 'CalculateChargesByCostMethod',
                        preload: [
                            functionalTest,
                            commonIC

                        ]
                    }

                ]
            }


        ]
    }


);