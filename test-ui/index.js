var Harness = Siesta.Harness.Browser.ExtJS,
    version = Math.floor(Math.random() * 9999) + 1,
    commonIC = 'Common/CommonIC.js?v='+version,
    commonICST = 'Common/CommonICSmokeTest.js?v='+version,
    functionalTest = '../../TestFramework/FunctionalTest.js?v='+version,
    commonGL = '../../GeneralLedger/test-ui/Common/commonGL.js?v='+version


var _url = window.location.hash,
    _items = _url.split('/');

if(_url.indexOf('version=TF') < 1) {
    Harness.configure({
        title: 'i21 Test Suite',
        hostPageUrl: '../../i21/index.html',
        forceDOMVisible: false,
        waitForExtReady: false,
        suppressPassedWaitForAssertion: true,
        pauseBetweenTests: 1000,
        defaultTimeout: 300000,
        waitForTimeout: 300000,
        maintainViewportSize: true,
        viewportHeight: 1100,
        viewportWidth: 1800,
        preload: [
            functionalTest
        ]
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

        { group: 'SmokeTesting',
            items: [
                {
                    url: 'SmokeTesting/ICOpenScreens.js?v='+version,
                    title: 'ICOpenScreens',
                    preload: [
                        functionalTest,
                        commonIC,
                        commonICST
                    ]
                },
                {
                    url: 'SmokeTesting/ICAddMaintenance.js?v='+version,
                    title: 'ICAddMaintenance',
                    preload: [
                        functionalTest,
                        commonIC,
                        commonICST
                    ]
                },
                {
                    url: 'SmokeTesting/ICAddTransactions1.js?v='+version,
                    title: 'ICAddTransactions1',
                    preload: [
                        functionalTest,
                        commonIC,
                        commonICST
                    ]
                },
                {
                    url: 'SmokeTesting/ICAddTransactions2.js?v='+version,
                    title: 'ICAddTransactions2',
                    preload: [
                        functionalTest,
                        commonIC,
                        commonICST
                    ]
                }

            ]
        },

        {
            group: 'CRUDScripts',
            items: [
                {
                    group: 'Item',
                    items: [
                        {
                            url: 'CRUDScripts/Item/AddInventory.js?v='+version,
                            title: 'AddInventory',
                            preload: [
                                functionalTest
                            ]
                        },

                        {
                            url: 'CRUDScripts/Item/DeleteInventory.js?v='+version,
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
                            url: 'CRUDScripts/Commodity/AddCommodity.js?v='+version,
                            title: 'AddCommodity',
                            preload: [
                                functionalTest
                            ]
                        },
                        {
                            url: 'CRUDScripts/Commodity/DeleteCommodity.js?v='+version,
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
                            url: 'CRUDScripts/Category/AddCategory.js?v='+version,
                            title: 'AddCategory',
                            preload: [
                                functionalTest
                            ]
                        },
                        {
                            url: 'CRUDScripts/Category/DeleteCategory.js?v='+version,
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
                            url: 'CRUDScripts/FuelCategory/AddFuelCategory.js?v='+version,
                            title: 'AddFuelCategory',
                            preload: [
                                functionalTest
                            ]
                        },
                        {
                            url: 'CRUDScripts/FuelCategory/DeleteFuelCategory.js?v='+version,
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
                            url: 'CRUDScripts/FeedStock/AddFeedStock.js?v='+version,
                            title: 'AddFeedStock',
                            preload: [
                                functionalTest
                            ]
                        },
                        {
                            url: 'CRUDScripts/FeedStock/DeleteFeedStock.js?v='+version,
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
                            url: 'CRUDScripts/FuelCode/AddFuelCode.js?v='+version,
                            title: 'AddFuelCode',
                            preload: [
                                functionalTest
                            ]
                        },
                        {
                            url: 'CRUDScripts/FuelCode/DeleteFuelCode.js?v='+version,
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
                            url: 'CRUDScripts/ProductionProcess/AddProductionProcess.js?v='+version,
                            title: 'AddProductionProcess',
                            preload: [
                                functionalTest
                            ]
                        },
                        {
                            url: 'CRUDScripts/ProductionProcess/DeleteProductionProcess.js?v='+version,
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
                            url: 'CRUDScripts/FeedStockUOM/AddFeedStockUOM.js?v='+version,
                            title: 'AddFeedStockUOM',
                            preload: [
                                functionalTest
                            ]
                        },
                        {
                            url: 'CRUDScripts/FeedStockUOM/DeleteFeedStockUOM.js?v='+version,
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
                            url: 'CRUDScripts/FuelType/AddFuelType.js?v='+version,
                            title: 'AddFuelType',
                            preload: [
                                functionalTest
                            ]
                        },
                        {
                            url: 'CRUDScripts/FuelType/DeleteFuelType.js?v='+version,
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
                            url: 'CRUDScripts/InventoryUOM/AddInventoryUOM.js?v='+version,
                            title: 'AddInventoryUOM',

                            preload: [
                                functionalTest
                            ]
                        },
                        {
                            url: 'CRUDScripts/InventoryUOM/DeleteInventoryUOM.js?v='+version,
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
                            url: 'CRUDScripts/StorageLocation/AddStorageLocation.js?v='+version,
                            title: 'AddStorageLocation',
                            preload: [
                                functionalTest
                            ]
                        },
                        {
                            url: 'CRUDScripts/StorageLocation/DeleteStorageLocation.js?v='+version,
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
                            url: 'CRUDScripts/InventoryReceipt/PreSetup.js?v='+version,
                            title: 'PreSetup',
                            preload: [
                                functionalTest,
                                commonIC
                            ]
                        },
                        {
                            url: 'CRUDScripts/InventoryReceipt/AddInventoryReceipt.js?v='+version,
                            title: 'AddInventoryReceipt',
                            preload: [
                                functionalTest,
                                commonIC
                            ]
                        },
                        {
                            url: 'CRUDScripts/InventoryReceipt/DeleteInventoryReceipt.js?v='+version,
                            title: 'DeleteInventoryReceipt',
                            preload: [
                                functionalTest,
                                commonIC
                            ]
                        }
                    ]
                },

                { group: 'InventoryShipment',
                    items: [

                        {
                            url: 'CRUDScripts/InventoryShipment/PreSetup.js?v='+version,
                            title: 'PreSetup',
                            preload: [
                                functionalTest,
                                commonIC
                            ]
                        },
                        {
                            url: 'CRUDScripts/InventoryShipment/AddInventoryShipment.js?v='+version,
                            title: 'AddInventoryShipment',
                            preload: [
                                functionalTest,
                                commonIC
                            ]
                        },
                        {
                            url: 'CRUDScripts/InventoryShipment/DeleteInventoryShipment.js?v='+version,
                            title: 'DeleteInventoryShipment',
                            preload: [
                                functionalTest,
                                commonIC
                            ]
                        }
                    ]
                },

                { group: 'InventoryTransfer',
                    items: [


                        {
                            url: 'CRUDScripts/InventoryTransfer/PreSetup.js?v='+version,
                            title: 'PreSetup',
                            preload: [
                                functionalTest,
                                commonIC
                            ]
                        },
                        {
                            url: 'CRUDScripts/InventoryTransfer/AddInventoryTransfer.js?v='+version,
                            title: 'AddInventoryTransfer',
                            preload: [
                                functionalTest,
                                commonIC
                            ]
                        },
                        {
                            url: 'CRUDScripts/InventoryTransfer/DeleteInventoryTransfer.js?v='+version,
                            title: 'DeleteInventoryTransfer',
                            preload: [
                                functionalTest,
                                commonIC
                            ]
                        }
                    ]
                },

                { group: 'InventoryAdjustment',
                    items: [
                        {
                            url: 'CRUDScripts/InventoryAdjustment/AddInventoryAdjustment.js?v='+version,
                            title: 'AddInventoryAdjustment',
                            preload: [
                                functionalTest,
                                commonIC
                            ]
                        },
                        {
                            url: 'CRUDScripts/InventoryAdjustment/DeleteInventoryAdjustment.js?v='+version,
                            title: 'DeleteInventoryAdjustment',
                            preload: [
                                functionalTest,
                                commonIC
                            ]
                        }
                    ]
                },

                { group: 'InventoryCount',
                    items: [
                        {
                            url: 'CRUDScripts/InventoryCount/AddInventoryCount.js?v='+version,
                            title: 'AddInventoryCount',
                            preload: [
                                functionalTest,
                                commonIC
                            ]
                        },
                        {
                            url: 'CRUDScripts/InventoryCount/DeleteInventoryCount.js?v='+version,
                            title: 'DeleteInventoryCount',
                            preload: [
                                functionalTest,
                                commonIC
                            ]
                        }
                    ]
                },

                { group: 'StorageMeasurementReading',
                    items: [
                        {
                            url: 'CRUDScripts/StorageMeasurementReading/AddSMR.js?v='+version,
                            title: 'AddSMR',
                            preload: [
                                functionalTest,
                                commonIC
                            ]
                        },
                        {
                            url: 'CRUDScripts/StorageMeasurementReading/DeleteSMR.js?v='+version,
                            title: 'DeleteSMR',
                            preload: [
                                functionalTest,
                                commonIC
                            ]
                        }
                    ]
                }

            ]
        },

        {
            group: 'BusinessDomain',
            items: [

                {
                    group: 'InventoryReceipt',
                    items:
                        [

                            {
                                group: 'OpenIRScreen',
                                items: [
                                    {
                                        url: 'BusinessDomain/InventoryReceipt/OpenIRScreen/IROpenSearchScreen.js?v=' + version,
                                        title: 'IROpenSearchScreen',
                                        preload: [
                                            functionalTest,
                                            commonIC

                                        ]
                                    },
                                    {
                                        url: 'BusinessDomain/InventoryReceipt/OpenIRScreen/IROpenNewIRScreen.js?v=' + version,
                                        title: 'IROpenNewScreen',
                                        preload: [
                                            functionalTest,
                                            commonIC

                                        ]
                                    }
                                ]
                            },


                            {
                                group: 'DirectInventoryReceipt',
                                items: [
                                    {
                                        url: 'BusinessDomain/InventoryReceipt/DirectInventoryReceipt/PreSetup.js?v=' + version,
                                        title: 'PreSetup',
                                        preload: [
                                            functionalTest,
                                            commonIC

                                        ]
                                    },
                                    {
                                        url: 'BusinessDomain/InventoryReceipt/DirectInventoryReceipt/DirectIR1-2.js?v=' + version,
                                        title: 'DirectIR-Scen.1-2',
                                        preload: [
                                            functionalTest,
                                            commonIC

                                        ]
                                    },
                                    {
                                        url: 'BusinessDomain/InventoryReceipt/DirectInventoryReceipt/DirectIR3-5.js?v=' + version,
                                        title: 'DirectIR-Scen.3-5',
                                        preload: [
                                            functionalTest,
                                            commonIC

                                        ]
                                    },
                                    {
                                        url: 'BusinessDomain/InventoryReceipt/DirectInventoryReceipt/DirectIR6-7.js?v=' + version,
                                        title: 'DirectIR-Scen.6-7',
                                        preload: [
                                            functionalTest,
                                            commonIC

                                        ]
                                    },
                                    {
                                        url: 'BusinessDomain/InventoryReceipt/DirectInventoryReceipt/DirectIR8-9.js?v=' + version,
                                        title: 'DirectIR-Scen.8-9',
                                        preload: [
                                            functionalTest,
                                            commonIC

                                        ]
                                    },
                                    {
                                        url: 'BusinessDomain/InventoryReceipt/DirectInventoryReceipt/DirectIR10-11.js?v=' + version,
                                        title: 'DirectIR-Scen.10-11',
                                        preload: [
                                            functionalTest,
                                            commonIC

                                        ]
                                    },
                                    {
                                        url: 'BusinessDomain/InventoryReceipt/DirectInventoryReceipt/DirectIR12-13.js?v=' + version,
                                        title: 'DirectIR-Scen.12-13',
                                        preload: [
                                            functionalTest,
                                            commonIC

                                        ]
                                    },
                                    {
                                        url: 'BusinessDomain/InventoryReceipt/DirectInventoryReceipt/DirectIR14-15.js?v=' + version,
                                        title: 'DirectIR-Scen.14-15',
                                        preload: [
                                            functionalTest,
                                            commonIC

                                        ]
                                    }

                                ]
                            }

                        ]

                },
                {
                    group: 'InventoryShipment',
                    items:
                        [
                            {
                                group: 'OpenISScreen',
                                items: [
                                    {
                                        url: 'BusinessDomain/InventoryShipment/OpenISScreen/ISOpenSearchScreen.js?v=' + version,
                                        title: 'ISOpenSearchScreen',
                                        preload: [
                                            functionalTest,
                                            commonIC

                                        ]
                                    },
                                    {
                                        url: 'BusinessDomain/InventoryShipment/OpenISScreen/ISOpenNewScreen.js?v=' + version,
                                        title: 'ISOpenNewScreen',
                                        preload: [
                                            functionalTest,
                                            commonIC

                                        ]
                                    }
                                ]
                            },

                            {
                                group: 'DirectInventoryShipment',
                                items: [
                                    {
                                        url: 'BusinessDomain/InventoryShipment/DirectInventoryShipment/PreSetup.js?v=' + version,
                                        title: 'PreSetup',
                                        preload: [
                                            functionalTest,
                                            commonIC

                                        ]
                                    },
                                    {
                                        url: 'BusinessDomain/InventoryShipment/DirectInventoryShipment/DirectIS1-2.js?v=' + version,
                                        title: 'DirectIS-Scen.1-2',
                                        preload: [
                                            functionalTest,
                                            commonIC

                                        ]
                                    }

                                ]
                            }

                        ]

                },

                {
                    group: 'InventoryTransfer',
                    items:
                        [
                            {
                                group: 'OpenTransferScreen',
                                items: [
                                    {
                                        url: 'BusinessDomain/InventoryTransfer/OpenTransferScreen/ITOpenSearchScreen.js?v=' + version,
                                        title: 'ITOpenSearchScreen',
                                        preload: [
                                            functionalTest,
                                            commonIC

                                        ]
                                    },
                                    {
                                        url: 'BusinessDomain/InventoryTransfer/OpenTransferScreen/ITOpenNewScreen.js?v=' + version,
                                        title: 'ITOpenNewScreen',
                                        preload: [
                                            functionalTest,
                                            commonIC

                                        ]
                                    }
                                ]
                            }

                        ]

                },

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
                },
                {
                    group: 'Category',
                    items: [
                        {
                            url: 'BusinessDomain/Category/17xOpenSearchCategoryScreen.js?v=' + version,
                            title: '17xOpenSearchCategoryScreen',
                            preload: [
                                functionalTest,
                                commonIC

                            ]
                        },
                        {
                            url: 'BusinessDomain/Category/17xOpenNewCategoryScreen.js?v=' + version,
                            title: '17xOpenNewCategoryScreen',
                            preload: [
                                functionalTest,
                                commonIC

                            ]
                        },
                        {
                            url: 'BusinessDomain/Category/17xAddCategory.js?v=' + version,
                            title: '17xAddCategory',
                            preload: [
                                functionalTest,
                                commonIC

                            ]
                        }
                    ]
                },

                {
                    group: 'Commodity',
                    items: [
                        {
                            url: 'BusinessDomain/Commodity/17xOpenSearchCommodityScreen.js?v=' + version,
                            title: '17xOpenSearchCommodityScreen',
                            preload: [
                                functionalTest,
                                commonIC

                            ]
                        },
                        {
                            url: 'BusinessDomain/Commodity/17xOpenNewCommodityScreen.js?v=' + version,
                            title: '17xOpenNewCommodityScreen',
                            preload: [
                                functionalTest,
                                commonIC

                            ]
                        }
                    ]
                },

                {
                    group: 'StorageLocations',
                    items: [
                        {
                            url: 'BusinessDomain/StorageLocation/17xOpenSearchStorageLocationScreen.js?v=' + version,
                            title: '17xOpenSearchStorageLocationScreen',
                            preload: [
                                functionalTest,
                                commonIC

                            ]
                        },
                        {
                            url: 'BusinessDomain/StorageLocation/17xOpenNewStorageLocationScreen.js?v=' + version,
                            title: '17xOpenNewStorageLocationScreen',
                            preload: [
                                functionalTest,
                                commonIC

                            ]
                        }
                    ]
                },

                {
                    group: 'TaxesAndCharges',
                    items: [
                        {
                            url: 'BusinessDomain/TaxesAndCharges/TaxesAndChargesSetup.js?v=' + version,
                            title: 'TaxesAndChargesSetup',
                            preload: [
                                functionalTest,
                                commonIC,
                                commonGL
                            ]
                        },
                        {
<<<<<<< HEAD
                            url: 'BusinessDomain/TaxesAndCharges/IRTaxesAndChargesCheckOffIsN_A-YReceiptV_P-N_IC-N.js?v=' + version,
                            title: 'IRTaxesAndChargesCheckOffIsN_A-YReceiptV_P-N_IC-N',
=======
                            url: 'BusinessDomain/TaxesAndCharges/IRTaxesAndChargesCheckOffIsN-S1.js?v=' + version,
                            title: 'IRTaxesAndChargesCheckOffIsN-S1',
>>>>>>> 8790f362... TS-2811 - Shorten js file name
                            preload: [
                                functionalTest,
                                commonIC,
                                commonGL
                            ]
                        },
                        {
                            url: 'BusinessDomain/TaxesAndCharges/IRTaxesAndChargesCheckOffIsY.js?v=' + version,
                            title: 'IRTaxesAndChargesCheckOffIsY',
                            preload: [
                                functionalTest,
                                commonIC,
                                commonGL
                            ]
                        }
                    ]
                }


            ]
        }
    )
}
else{
    localStorage.removeItem('ext-i21_Test_Suite-testTree');
    localStorage.removeItem('ext-i21_Test_Suite-resultpanel-domContainer');
    localStorage.removeItem('ext-test-run-i21 Test Suite-collapsed');
    localStorage.removeItem('ext-test-run-i21 Test Suite-selection');
    localStorage.removeItem('ext-test-run-i21 Test Suite');

    localStorage.setItem('i21UserName', window.btoa('irelyadmin'));
    localStorage.setItem('i21Password', window.btoa('i21by2015'));
    localStorage.setItem('i21Company', '01');
    localStorage.setItem('i21RememberMe', true);

    Harness.configure({
        title     : 'i21 Test Suite',
        hostPageUrl: '../../i21/index.html',
        forceDOMVisible: true,
        waitForExtReady: false,
        suppressPassedWaitForAssertion: true,
        pauseBetweenTests: 1000,
        defaultTimeout: 300000,
        waitForTimeout: 300000,
        viewportHeight: 1100,
        viewportWidth: 1800,
        maintainViewportSize: true,
        autoRun: true,
        viewDOM: true,
        needUI: true,
        preload: [
            testFramework
        ]
    });

    Harness.start(
        {
            url: _url.replace('#','')
        }
    )
}