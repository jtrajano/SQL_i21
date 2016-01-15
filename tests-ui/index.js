/**
 * Created by RQuidato on 10/23/14.
 */
var Harness = Siesta.Harness.Browser.ExtJS,
    testEnginePath = '../../TestEngine/TestEngine.js';


Harness.configure({
    title: 'i21 Test Suite',
//    preload: [
//        "../resources/extjs/ext-4.2.1.883/resources/css/ext-all.css",
//        "../resources/extjs/ext-4.2.1.883/ext.js",
//
//
//    ],
    hostPageUrl: '../../i21',
    forceDOMVisible: false,
    waitForExtReady: false,
    sandbox: false
    //runCore: 'sequential',
    //autoRun: true
});
Harness.start(
    { group: 'Item',
        items: [
            {
                url: 'Item/AddItem_InventoryType.js',
                preload: [
                    testEnginePath
                ]
            },
            {
                url: 'Item/AddItem_RawMaterialType.js',
                preload: [
                    testEnginePath
                ]
            },
            {
                url: 'Item/AddItem_FinishedGoodType.js',
                preload: [
                    testEnginePath
                ]
            }
        ]
    },
    { group: 'InventoryUOM',
        items: [
            {
                url: 'InventoryUOM/AddInventoryUOM.js',  // url of the js file, containing actual test code
                preload: [
                    testEnginePath
                ]
            },
            {
                url: 'InventoryUOM/DeleteInventoryUOM.js',  // url of the js file, containing actual test code
                preload: [
                    testEnginePath
                ]
            }
        ]
    },
    { group: 'FuelCategory',
        items: [
            {
                url: 'FuelCategory/AddFuelCategory.js',
                preload: [
                    testEnginePath
                ]
            },
            {
                url: 'FuelCategory/AddFuelCategory.js',
                preload: [
                    testEnginePath
                ]
            },
            {
                url: 'FuelCategory/DeleteFuelCategory.js',
                preload: [
                    testEnginePath
                ]
            }
        ]
    },
    { group: 'FuelCode',
        items: [
            {
                url: 'FuelCode/AddFuelCode.js',
                preload: [
                    testEnginePath
                ]
            },
            {
                url: 'FuelCode/DeleteFuelCode.js',
                preload: [
                    testEnginePath
                ]
            }
        ]
    },

    { group: 'ProductionProcess',
        items: [
            {
                url: 'ProductionProcess/AddProductionProcess.js',
                preload: [
                    testEnginePath
                ]
            },
            {
                url: 'ProductionProcess/DeleteProductionProcess.js',
                preload: [
                    testEnginePath
                ]
            }
        ]
    },
    { group: 'FeedStockCode',
        items: [
            {
                url: 'FeedStockCode/AddFeedStock.js',  // url of the js file, containing actual test code
                preload: [
                    testEnginePath
                ]
            },
            {
                url: 'FeedStockCode/DeleteFeedStock.js',  // url of the js file, containing actual test code
                preload: [
                    testEnginePath
                ]
            }
        ]
    },
    { group: 'FeedStockUOM',
        items: [
            {
                url: 'FeedStockUOM/AddFeedStockUOM.js',  // url of the js file, containing actual test code
                preload: [
                    testEnginePath
                ]
            },
            {
                url: 'FeedStockUOM/DeleteFeedStockUOM.js',  // url of the js file, containing actual test code
                preload: [
                    testEnginePath
                ]
            }
        ]
    },
    { group: 'FuelType',
        items: [
            {
                url: 'FuelType/AddFuelType.js',  // url of the js file, containing actual test code
                preload: [
                    testEnginePath
                ]
            },
            {
                url: 'FuelType/DeleteFuelType.js',  // url of the js file, containing actual test code
                preload: [
                    testEnginePath
                ]
            }
        ]
    },
    { group: 'FuelTaxClass',
        items: [
            {
                url: 'FuelTaxClass/AddFuelTaxClass.js',  // url of the js file, containing actual test code
                preload: [
                    testEnginePath
                ]
            },
            {
                url: 'FuelTaxClass/DeleteFuelTaxClass.js',  // url of the js file, containing actual test code
                preload: [
                    testEnginePath
                ]
            }
        ]
    },
    { group: 'InventoryTag',
        items: [
            {
                url: 'InventoryTag/AddInventoryTag.js',  // url of the js file, containing actual test code
                preload: [
                    testEnginePath
                ]
            },
            {
                url: 'InventoryTag/DeleteInventoryTag.js',  // url of the js file, containing actual test code
                preload: [
                    testEnginePath
                ]
            }
        ]
    },
    { group: 'PatronageCategory',
        items: [
            {
                url: 'PatronageCategory/AddPatronageCategory.js',  // url of the js file, containing actual test code
                preload: [
                    testEnginePath
                ]
            },
            {
                url: 'PatronageCategory/DeletePatronageCategory.js',  // url of the js file, containing actual test code
                preload: [
                    testEnginePath
                ]
            }
        ]
    },
    { group: 'Manufacturer',
        items: [
            {
                url: 'Manufacturer/AddManufacturer.js',  // url of the js file, containing actual test code
                preload: [
                    testEnginePath
                ]
            },
            {
                url: 'Manufacturer/DeleteManufacturer.js',  // url of the js file, containing actual test code
                preload: [
                    testEnginePath
                ]
            }
        ]
    },
    { group: 'ManufacturingCell',
        items: [
            {
                url: 'ManufacturingCell/AddManufacturingCell.js',  // url of the js file, containing actual test code
                preload: [
                    testEnginePath
                ]
            },
            {
                url: 'ManufacturingCell/DeleteManufacturingCell.js',  // url of the js file, containing actual test code
                preload: [
                    testEnginePath
                ]
            }
        ]
    },
    { group: 'Reason',
        items: [
            {
                url: 'Reason/AddReason.js',  // url of the js file, containing actual test code
                preload: [
                    testEnginePath
                ]
            },
            {
                url: 'Reason/DeleteReason.js',  // url of the js file, containing actual test code
                preload: [
                    testEnginePath
                ]
            }
        ]
    },
    { group: 'StorageUnitType',
        items: [
            {
                url: 'StorageUnitType/AddStorageUnitType.js',  // url of the js file, containing actual test code
                preload: [
                    testEnginePath
                ]
            },
            {
                url: 'StorageUnitType/DeleteStorageUnitType.js',  // url of the js file, containing actual test code
                preload: [
                    testEnginePath
                ]
            }
        ]
    },
    { group: 'ItemSubstitution',
        items: [
            {
                url: 'ItemSubstitution/AddItemSubstitution.js',  // url of the js file, containing actual test code
                preload: [
                    testEnginePath
                ]
            },
            {
                url: 'ItemSubstitution/DeleteItemSubstitution.js',  // url of the js file, containing actual test code
                preload: [
                    testEnginePath
                ]
            }
        ]
    },
    { group: 'Warehouse',
        items: [
            {
                url: 'Warehouse/AddWarehouse.js',  // url of the js file, containing actual test code
                preload: [
                    testEnginePath
                ]
            },
            {
                url: 'Warehouse/DeleteWarehouse.js',  // url of the js file, containing actual test code
                preload: [
                    testEnginePath
                ]
            }
        ]
    },
    { group: 'CertificationPrograms',
        items: [
            {
                url: 'CertificationPrograms/AddCertificationPrograms.js',  // url of the js file, containing actual test code
                preload: [
                    testEnginePath
                ]
            },
            {
                url: 'CertificationPrograms/DeleteCertificationPrograms.js',  // url of the js file, containing actual test code
                preload: [
                    testEnginePath
                ]
            }
        ]
    },
    { group: 'ContractDocument',
        items: [
            {
                url: 'ContractDocument/AddContractDocument.js',  // url of the js file, containing actual test code
                preload: [
                    testEnginePath
                ]
            },
            {
                url: 'ContractDocument/DeleteContractDocument.js',  // url of the js file, containing actual test code
                preload: [
                    testEnginePath
                ]
            }
        ]
    },
    { group: 'LotStatus',
        items: [
            {
                url: 'LotStatus/AddLotStatus.js',  // url of the js file, containing actual test code
                preload: [
                    testEnginePath
                ]
            },
            {
                url: 'LotStatus/DeleteLotStatus.js',  // url of the js file, containing actual test code
                preload: [
                    testEnginePath
                ]
            }
        ]
    },
    { group: 'Brand',
        items: [
            {
                url: 'Brand/AddBrand.js',  // url of the js file, containing actual test code
                preload: [
                    testEnginePath
                ]
            },
            {
                url: 'Brand/DeleteBrand.js',  // url of the js file, containing actual test code
                preload: [
                    testEnginePath
                ]
            }
        ]
    },
    { group: 'PackType',
        items: [
            {
                url: 'PackType/AddPackType.js',  // url of the js file, containing actual test code
                preload: [
                    testEnginePath
                ]
            },
            {
                url: 'PackType/DeletePackType.js',  // url of the js file, containing actual test code
                preload: [
                    testEnginePath
                ]
            }
        ]
    },
    { group: 'InventoryCountGroup',
        items: [
            {
                url: 'InventoryCountGroup/AddInventoryCountGroup.js',  // url of the js file, containing actual test code
                preload: [
                    testEnginePath
                ]
            },
            {
                url: 'InventoryCountGroup/DeleteInventoryCountGroup.js',  // url of the js file, containing actual test code
                preload: [
                    testEnginePath
                ]
            }
        ]
    },
    { group: 'LineOfBusiness',
        items: [
            {
                url: 'LineOfBusiness/AddLineOfBusiness.js',  // url of the js file, containing actual test code
                preload: [
                    testEnginePath
                ]
            },
            {
                url: 'LineOfBusiness/DeleteLineOfBusiness.js',  // url of the js file, containing actual test code
                preload: [
                    testEnginePath
                ]
            }
        ]
    }

)