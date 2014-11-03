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
                url: 'ProcessCode/AddProductionProcess.js',
                preload: [
                    '../../GlobalComponentEngine/irely/TestEngine.js'
                ]
            },
            {
                url: 'ProcessCode/DeleteProductionProcess.js',
                preload: [
                    '../../GlobalComponentEngine/irely/TestEngine.js'
                ]
            }
        ]
    },
    { group: 'FeedStockCode',
        items: [
            {
                url: 'FeedStockCode/AddFeedStock.js',  // url of the js file, containing actual test code
                preload: [
                    '../../GlobalComponentEngine/irely/TestEngine.js'
                ]
            },
            {
                url: 'FeedStockCode/DeleteFeedStock.js',  // url of the js file, containing actual test code
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
    },
    { group: 'ManufacturingCell',
        items: [
            {
                url: 'ManufacturingCell/AddManufacturingCell.js',  // url of the js file, containing actual test code
                preload: [
                    '../../GlobalComponentEngine/irely/TestEngine.js'
                ]
            },
            {
                url: 'ManufacturingCell/DeleteManufacturingCell.js',  // url of the js file, containing actual test code
                preload: [
                    '../../GlobalComponentEngine/irely/TestEngine.js'
                ]
            }
        ]
    },
    { group: 'Reason',
        items: [
            {
                url: 'Reason/AddReason.js',  // url of the js file, containing actual test code
                preload: [
                    '../../GlobalComponentEngine/irely/TestEngine.js'
                ]
            },
            {
                url: 'Reason/DeleteReason.js',  // url of the js file, containing actual test code
                preload: [
                    '../../GlobalComponentEngine/irely/TestEngine.js'
                ]
            }
        ]
    },
    { group: 'StorageUnitType',
        items: [
            {
                url: 'StorageUnitType/AddStorageUnitType.js',  // url of the js file, containing actual test code
                preload: [
                    '../../GlobalComponentEngine/irely/TestEngine.js'
                ]
            },
            {
                url: 'StorageUnitType/DeleteStorageUnitType.js',  // url of the js file, containing actual test code
                preload: [
                    '../../GlobalComponentEngine/irely/TestEngine.js'
                ]
            }
        ]
    },
    { group: 'ItemSubstitution',
        items: [
            {
                url: 'ItemSubstitution/AddItemSubstitution.js',  // url of the js file, containing actual test code
                preload: [
                    '../../GlobalComponentEngine/irely/TestEngine.js'
                ]
            },
            {
                url: 'ItemSubstitution/DeleteItemSubstitution.js',  // url of the js file, containing actual test code
                preload: [
                    '../../GlobalComponentEngine/irely/TestEngine.js'
                ]
            }
        ]
    },
    { group: 'Warehouse',
        items: [
            {
                url: 'Warehouse/AddWarehouse.js',  // url of the js file, containing actual test code
                preload: [
                    '../../GlobalComponentEngine/irely/TestEngine.js'
                ]
            },
            {
                url: 'Warehouse/DeleteWarehouse.js',  // url of the js file, containing actual test code
                preload: [
                    '../../GlobalComponentEngine/irely/TestEngine.js'
                ]
            }
        ]
    },
    { group: 'CertificationPrograms',
        items: [
            {
                url: 'CertificationPrograms/AddCertificationPrograms.js',  // url of the js file, containing actual test code
                preload: [
                    '../../GlobalComponentEngine/irely/TestEngine.js'
                ]
            },
            {
                url: 'CertificationPrograms/DeleteCertificationPrograms.js',  // url of the js file, containing actual test code
                preload: [
                    '../../GlobalComponentEngine/irely/TestEngine.js'
                ]
            }
        ]
    },
    { group: 'ContractDocument',
        items: [
            {
                url: 'ContractDocument/AddContractDocument.js',  // url of the js file, containing actual test code
                preload: [
                    '../../GlobalComponentEngine/irely/TestEngine.js'
                ]
            },
            {
                url: 'ContractDocument/DeleteContractDocument.js',  // url of the js file, containing actual test code
                preload: [
                    '../../GlobalComponentEngine/irely/TestEngine.js'
                ]
            }
        ]
    },
    { group: 'LotStatus',
        items: [
            {
                url: 'LotStatus/AddLotStatus.js',  // url of the js file, containing actual test code
                preload: [
                    '../../GlobalComponentEngine/irely/TestEngine.js'
                ]
            },
            {
                url: 'LotStatus/DeleteLotStatus.js',  // url of the js file, containing actual test code
                preload: [
                    '../../GlobalComponentEngine/irely/TestEngine.js'
                ]
            }
        ]
    },
    { group: 'Brand',
        items: [
            {
                url: 'Brand/AddBrand.js',  // url of the js file, containing actual test code
                preload: [
                    '../../GlobalComponentEngine/irely/TestEngine.js'
                ]
            },
            {
                url: 'Brand/DeleteBrand.js',  // url of the js file, containing actual test code
                preload: [
                    '../../GlobalComponentEngine/irely/TestEngine.js'
                ]
            }
        ]
    },
    { group: 'PackType',
        items: [
            {
                url: 'PackType/AddPackType.js',  // url of the js file, containing actual test code
                preload: [
                    '../../GlobalComponentEngine/irely/TestEngine.js'
                ]
            },
            {
                url: 'PackType/DeletePackType.js',  // url of the js file, containing actual test code
                preload: [
                    '../../GlobalComponentEngine/irely/TestEngine.js'
                ]
            }
        ]
    }

)