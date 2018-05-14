CREATE PROCEDURE [dbo].[uspICBackupInventory]
	  @intUserId INT
	, @strOperation VARCHAR(50)
	, @strRemarks VARCHAR(200) = NULL
AS

INSERT INTO tblICBackup(dtmDate, intUserId, strOperation, strRemarks)
SELECT GETDATE(), @intUserId, @strOperation, @strRemarks

DECLARE @intBackupId INT
SET @intBackupId = SCOPE_IDENTITY()

INSERT INTO tblICBackupDetailLot(			
	  [intBackupId]				
	, [intIdentityId]				
	, [intItemId]					
	, [intLocationId]				
	, [intItemLocationId]			
	, [intItemUOMId]				
	, [strLotNumber]				
	, [intSubLocationId]			
	, [intStorageLocationId]		
	, [dblQty]					
	, [dblLastCost]				
	, [dtmExpiryDate]				
	, [strLotAlias]				
	, [intLotStatusId]			
	, [intParentLotId]			
	, [intSplitFromLotId]			
	, [dblGrossWeight]			
	, [dblWeight]					
	, [intWeightUOMId]			
	, [dblWeightPerQty]			
	, [intOriginId]				
	, [strBOLNo]					
	, [strVessel]					
	, [strReceiptNumber]			
	, [strMarkings]				
	, [strNotes]					
	, [intEntityVendorId]			
	, [strVendorLotNo]			
	, [strGarden]					
	, [strContractNo]				
	, [dtmManufacturedDate]		
	, [ysnReleasedToWarehouse]	
	, [ysnProduced]				
	, [ysnStorage]				
	, [intOwnershipType]			
	, [intGradeId]				
	, [intNoPallet]				
	, [intUnitPallet]				
	, [strTransactionId]			
	, [strSourceTransactionId]	
	, [intSourceTransactionTypeId]
	, [dtmDateCreated]			
	, [intCreatedUserId]			
	, [intCreatedEntityId]
	, [ysnLockedInventory]
	, [intItemOwnerId]
	, [strContainerNo]
	, [strCondition]
	, [intSeasonCropYear]
	, [intCompanyId]
	, [intBookId]
	, [intSubBookId]
	, [strCertificate]
	, [intProducerId]
	, [strCertificateId]
	, [strTrackingNumber]
    , [dtmDateModified]
    , [intCreatedByUserId]
    , [intModifiedByUserId]
)
SELECT
	  intBackupId					= @intBackupId
	, intIdentityId					= lot.intLotId
	, intItemId						= lot.intItemId					
	, intLocationId					= lot.intLocationId				
	, intItemLocationId				= lot.intItemLocationId			
	, intItemUOMId					= lot.intItemUOMId				
	, strLotNumber					= lot.strLotNumber				
	, intSubLocationId				= lot.intSubLocationId			
	, intStorageLocationId			= lot.intStorageLocationId		
	, dblQty						= lot.dblQty						
	, dblLastCost					= lot.dblLastCost				
	, dtmExpiryDate					= lot.dtmExpiryDate				
	, strLotAlias					= lot.strLotAlias				
	, intLotStatusId				= lot.intLotStatusId				
	, intParentLotId				= lot.intParentLotId				
	, intSplitFromLotId				= lot.intSplitFromLotId			
	, dblGrossWeight				= lot.dblGrossWeight				
	, dblWeight						= lot.dblWeight					
	, intWeightUOMId				= lot.intWeightUOMId				
	, dblWeightPerQty				= lot.dblWeightPerQty			
	, intOriginId					= lot.intOriginId				
	, strBOLNo						= lot.strBOLNo					
	, strVessel						= lot.strVessel					
	, strReceiptNumber				= lot.strReceiptNumber			
	, strMarkings					= lot.strMarkings				
	, strNotes						= lot.strNotes					
	, intEntityVendorId				= lot.intEntityVendorId			
	, strVendorLotNo				= lot.strVendorLotNo				
	, strGarden						= lot.strGarden					
	, strContractNo					= lot.strContractNo				
	, dtmManufacturedDate			= lot.dtmManufacturedDate		
	, ysnReleasedToWarehouse		= lot.ysnReleasedToWarehouse		
	, ysnProduced					= lot.ysnProduced				
	, ysnStorage					= lot.ysnStorage					
	, intOwnershipType				= lot.intOwnershipType			
	, intGradeId					= lot.intGradeId					
	, intNoPallet					= lot.intNoPallet				
	, intUnitPallet					= lot.intUnitPallet				
	, strTransactionId				= lot.strTransactionId			
	, strSourceTransactionId		= lot.strSourceTransactionId		
	, intSourceTransactionTypeId	= lot.intSourceTransactionTypeId	
	, dtmDateCreated				= lot.dtmDateCreated				
	, intCreatedUserId				= lot.intCreatedUserId			
	, intCreatedEntityId			= lot.intCreatedEntityId
	, [ysnLockedInventory]			= lot.[ysnLockedInventory]
	, [intItemOwnerId]				= lot.[intItemOwnerId]
	, [strContainerNo]				= lot.[strContainerNo]
	, [strCondition]				= lot.[strCondition]
	, [intSeasonCropYear]			= lot.[intSeasonCropYear]
	, [intCompanyId]				= lot.[intCompanyId]
	, [intBookId]					= lot.[intBookId]
	, [intSubBookId]				= lot.[intSubBookId]
	, [strCertificate]				= lot.[strCertificate]
	, [intProducerId]				= lot.[intProducerId]
	, [strCertificateId]			= lot.[strCertificateId]
	, [strTrackingNumber]			= lot.[strTrackingNumber]
    , [dtmDateModified]				= lot.[dtmDateModified]
    , [intCreatedByUserId]			= lot.[intCreatedByUserId]
    , [intModifiedByUserId]			= lot.[intModifiedByUserId]
FROM tblICLot lot

INSERT INTO tblICBackupDetailInventoryTransaction(
	  intBackupId
	, intIdentityId
	, intItemId
	, intItemLocationId
	, intItemUOMId
	, intSubLocationId
	, intStorageLocationId
	, dtmDate
	, dblQty
	, dblUOMQty
	, dblCost
	, dblValue
	, dblSalesPrice
	, intCurrencyId
	, dblExchangeRate
	, intTransactionId
	, strTransactionId
	, intTransactionDetailId
	, strBatchId
	, intTransactionTypeId
	, intLotId
	, ysnIsUnposted
	, intRelatedInventoryTransactionId
	, intRelatedTransactionId
	, strRelatedTransactionId
	, strTransactionForm
	, intCostingMethod
	, intInTransitSourceLocationId
	, dtmCreated
	, strDescription
	, intFobPointId
	, ysnNoGLPosting
	, intForexRateTypeId
	, dblForexRate
	, strActualCostId
	, dblUnitRetail
	, dblCategoryCostValue
	, dblCategoryRetailValue
	, intCategoryId
	, intCompanyId
	, intCreatedUserId
	, intCreatedEntityId
	
)
SELECT
	  intBackupId						= @intBackupId
	, intIdentityId						= t.intInventoryTransactionId
	, intItemId							= t.intItemId							
	, intItemLocationId					= t.intItemLocationId					
	, intItemUOMId						= t.intItemUOMId						
	, intSubLocationId					= t.intSubLocationId					
	, intStorageLocationId				= t.intStorageLocationId				
	, dtmDate							= t.dtmDate							
	, dblQty							= t.dblQty							
	, dblUOMQty							= t.dblUOMQty							
	, dblCost							= t.dblCost							
	, dblValue							= t.dblValue							
	, dblSalesPrice						= t.dblSalesPrice						
	, intCurrencyId						= t.intCurrencyId						
	, dblExchangeRate					= t.dblExchangeRate					
	, intTransactionId					= t.intTransactionId					
	, strTransactionId					= t.strTransactionId					
	, intTransactionDetailId			= t.intTransactionDetailId			
	, strBatchId						= t.strBatchId						
	, intTransactionTypeId				= t.intTransactionTypeId				
	, intLotId							= t.intLotId							
	, ysnIsUnposted						= t.ysnIsUnposted						
	, intRelatedInventoryTransactionId	= t.intRelatedInventoryTransactionId	
	, intRelatedTransactionId			= t.intRelatedTransactionId			
	, strRelatedTransactionId			= t.strRelatedTransactionId			
	, strTransactionForm				= t.strTransactionForm				
	, intCostingMethod					= t.intCostingMethod					
	, intInTransitSourceLocationId		= t.intInTransitSourceLocationId		
	, dtmCreated						= t.dtmCreated						
	, strDescription					= t.strDescription					
	, intFobPointId						= t.intFobPointId						
	, ysnNoGLPosting					= t.ysnNoGLPosting		
	, intForexRateTypeId				= t.intForexRateTypeId		
	, dblForexRate						= t.dblForexRate		
	, strActualCostId					= t.strActualCostId		
	, dblUnitRetail						= t.dblUnitRetail		
	, dblCategoryCostValue				= t.dblCategoryCostValue		
	, dblCategoryRetailValue			= t.dblCategoryRetailValue		
	, intCategoryId						= t.ysnNoGLPosting		
	, intCompanyId						= t.intCompanyId						
	, intCreatedUserId					= t.intCreatedUserId					
	, intCreatedEntityId				= t.intCreatedEntityId				
FROM tblICInventoryTransaction t

INSERT INTO tblICBackupDetailTransactionDetailLog(
	  intBackupId
	, intIdentityId
	, strTransactionType
	, intTransactionId
	, intTransactionDetailId
	, intOrderNumberId
	, intOrderType
	, intSourceNumberId
	, intSourceType
	, intLineNo
	, intItemId
	, intItemUOMId
	, dblQuantity
	, ysnLoad
	, intLoadReceive
)
SELECT
      intBackupId				= @intBackupId
	, intIdentityId				= t.intTransactionDetailLogId			
	, strTransactionType		= t.strTransactionType	
	, intTransactionId			= t.intTransactionId		
	, intTransactionDetailId	= t.intTransactionDetailId
	, intOrderNumberId			= t.intOrderNumberId		
	, intOrderType				= t.intOrderType			
	, intSourceNumberId			= t.intSourceNumberId		
	, intSourceType				= t.intSourceType			
	, intLineNo					= t.intLineNo				
	, intItemId					= t.intItemId				
	, intItemUOMId				= t.intItemUOMId			
	, dblQuantity				= t.dblQuantity			
	, ysnLoad					= t.ysnLoad				
	, intLoadReceive			= t.intLoadReceive
FROM tblICTransactionDetailLog t

INSERT INTO tblICBackupDetailInventoryTransactionStorage(
	  intBackupId						
	, intIdentityId						
	, intItemId							
	, intItemLocationId					
	, intItemUOMId						
	, intSubLocationId					
	, intStorageLocationId				
	, intLotId							
	, dtmDate							
	, dblQty							
	, dblUOMQty							
	, dblCost							
	, dblValue							
	, dblSalesPrice						
	, intCurrencyId						
	, dblExchangeRate					
	, intTransactionId					
	, intTransactionDetailId			
	, strTransactionId					
	, intInventoryCostBucketStorageId	
	, strBatchId						
	, intTransactionTypeId				
	, ysnIsUnposted						
	, strTransactionForm				
	, intRelatedInventoryTransactionId	
	, intRelatedTransactionId			
	, strRelatedTransactionId			
	, intCostingMethod			
	, intForexRateTypeId
	, dblForexRate
	, intCompanyId
	, dtmCreated						
	, intCreatedUserId					
	, intCreatedEntityId
)
SELECT
	  intBackupId						= @intBackupId
	, intIdentityId						= t.intInventoryTransactionStorageId
	, intItemId							= t.intItemId							
	, intItemLocationId					= t.intItemLocationId					
	, intItemUOMId						= t.intItemUOMId						
	, intSubLocationId					= t.intSubLocationId					
	, intStorageLocationId				= t.intStorageLocationId				
	, intLotId							= t.intLotId							
	, dtmDate							= t.dtmDate							
	, dblQty							= t.dblQty							
	, dblUOMQty							= t.dblUOMQty							
	, dblCost							= t.dblCost							
	, dblValue							= t.dblValue							
	, dblSalesPrice						= t.dblSalesPrice						
	, intCurrencyId						= t.intCurrencyId						
	, dblExchangeRate					= t.dblExchangeRate					
	, intTransactionId					= t.intTransactionId					
	, intTransactionDetailId			= t.intTransactionDetailId			
	, strTransactionId					= t.strTransactionId					
	, intInventoryCostBucketStorageId	= t.intInventoryCostBucketStorageId	
	, strBatchId						= t.strBatchId						
	, intTransactionTypeId				= t.intTransactionTypeId				
	, ysnIsUnposted						= t.ysnIsUnposted						
	, strTransactionForm				= t.strTransactionForm				
	, intRelatedInventoryTransactionId	= t.intRelatedInventoryTransactionId	
	, intRelatedTransactionId			= t.intRelatedTransactionId			
	, strRelatedTransactionId			= t.strRelatedTransactionId			
	, intCostingMethod					= t.intCostingMethod	
	, intForexRateTypeId				= t.intForexRateTypeId	
	, dblForexRate						= t.dblForexRate	
	, intCompanyId						= t.intCompanyId	
	, dtmCreated						= t.dtmCreated						
	, intCreatedUserId					= t.intCreatedUserId					
	, intCreatedEntityId				= t.intCreatedEntityId
FROM tblICInventoryTransactionStorage t