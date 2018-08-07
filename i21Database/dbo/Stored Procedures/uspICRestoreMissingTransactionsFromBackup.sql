CREATE PROCEDURE uspICRestoreMissingTransactionsFromBackup
	@intBackupId AS INT 
AS 

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

SET IDENTITY_INSERT tblICInventoryTransaction ON; 

INSERT INTO tblICInventoryTransaction (
	intInventoryTransactionId
	,intItemId
	,intItemLocationId
	,intItemUOMId
	,intSubLocationId
	,intStorageLocationId
	,dtmDate
	,dblQty
	,dblUOMQty
	,dblCost
	,dblValue
	,dblSalesPrice
	,intCurrencyId
	,dblExchangeRate
	,intTransactionId
	,strTransactionId
	,intTransactionDetailId
	,strBatchId
	,intTransactionTypeId
	,intLotId
	,ysnIsUnposted
	,intRelatedInventoryTransactionId
	,intRelatedTransactionId
	,strRelatedTransactionId
	,strTransactionForm
	,intCostingMethod
	,intInTransitSourceLocationId
	,dtmCreated
	,strDescription
	,intFobPointId
	,ysnNoGLPosting
	,intForexRateTypeId
	,dblForexRate
	,strActualCostId
	,intCreatedUserId
	,intCreatedEntityId
	,intConcurrencyId
)
-- restore the missing cost adjustments from voucher. 
select 
	bu.intIdentityId
	,bu.intItemId
	,bu.intItemLocationId
	,bu.intItemUOMId
	,bu.intSubLocationId
	,bu.intStorageLocationId
	,bu.dtmDate
	,bu.dblQty
	,bu.dblUOMQty
	,bu.dblCost
	,bu.dblValue
	,bu.dblSalesPrice
	,bu.intCurrencyId
	,bu.dblExchangeRate
	,bu.intTransactionId
	,bu.strTransactionId
	,bu.intTransactionDetailId
	,bu.strBatchId
	,bu.intTransactionTypeId
	,bu.intLotId
	,bu.ysnIsUnposted
	,bu.intRelatedInventoryTransactionId
	,bu.intRelatedTransactionId
	,bu.strRelatedTransactionId
	,bu.strTransactionForm
	,bu.intCostingMethod
	,bu.intInTransitSourceLocationId
	,bu.dtmCreated
	,bu.strDescription
	,bu.intFobPointId
	,bu.ysnNoGLPosting
	,intForexRateTypeId = NULL 
	,dblForexRate = 1
	,strActualCostId = NULL 
	,bu.intCreatedUserId
	,bu.intCreatedEntityId
	,intConcurrencyId = 1
from	tblICBackupDetailInventoryTransaction bu inner join tblAPBill b
			on bu.strTransactionId = b.strBillId
		left join tblICInventoryTransaction t 
			on bu.strTransactionId = t.strTransactionId
			and bu.strBatchId = t.strBatchId
			and bu.intItemId = t.intItemId
			and bu.intItemLocationId = t.intItemLocationId
			and bu.intItemUOMId = t.intItemUOMId
			--and bu.intIdentityId = t.intInventoryTransactionId
		left join tblICInventoryTransaction t2			
			on bu.intIdentityId = t2.intInventoryTransactionId

where	b.ysnPosted = 1
		and t.intInventoryTransactionId is null 
		and t2.intInventoryTransactionId is null 
		and isnull(bu.ysnIsUnposted, 0) = 0
		and bu.dblQty = 0 
		and bu.strTransactionId like 'BL-%'
		--and bu.dblValue <> 0 
		and bu.intBackupId = @intBackupId

--INSERT INTO tblICInventoryTransaction (
--	intInventoryTransactionId
--	,intItemId
--	,intItemLocationId
--	,intItemUOMId
--	,intSubLocationId
--	,intStorageLocationId
--	,dtmDate
--	,dblQty
--	,dblUOMQty
--	,dblCost
--	,dblValue
--	,dblSalesPrice
--	,intCurrencyId
--	,dblExchangeRate
--	,intTransactionId
--	,strTransactionId
--	,intTransactionDetailId
--	,strBatchId
--	,intTransactionTypeId
--	,intLotId
--	,ysnIsUnposted
--	,intRelatedInventoryTransactionId
--	,intRelatedTransactionId
--	,strRelatedTransactionId
--	,strTransactionForm
--	,intCostingMethod
--	,intInTransitSourceLocationId
--	,dtmCreated
--	,strDescription
--	,intFobPointId
--	,ysnNoGLPosting
--	,intForexRateTypeId
--	,dblForexRate
--	,strActualCostId
--	,intCreatedUserId
--	,intCreatedEntityId
--	,intConcurrencyId
--)
--select 
--	bu.intIdentityId
--	,bu.intItemId
--	,bu.intItemLocationId
--	,bu.intItemUOMId
--	,bu.intSubLocationId
--	,bu.intStorageLocationId
--	,bu.dtmDate
--	,bu.dblQty
--	,bu.dblUOMQty
--	,bu.dblCost
--	,bu.dblValue
--	,bu.dblSalesPrice
--	,bu.intCurrencyId
--	,bu.dblExchangeRate
--	,bu.intTransactionId
--	,bu.strTransactionId
--	,bu.intTransactionDetailId
--	,bu.strBatchId
--	,bu.intTransactionTypeId
--	,bu.intLotId
--	,bu.ysnIsUnposted
--	,bu.intRelatedInventoryTransactionId
--	,bu.intRelatedTransactionId
--	,bu.strRelatedTransactionId
--	,bu.strTransactionForm
--	,bu.intCostingMethod
--	,bu.intInTransitSourceLocationId
--	,bu.dtmCreated
--	,bu.strDescription
--	,bu.intFobPointId
--	,bu.ysnNoGLPosting
--	,intForexRateTypeId = NULL 
--	,dblForexRate = 1
--	,strActualCostId = NULL 
--	,bu.intCreatedUserId
--	,bu.intCreatedEntityId
--	,intConcurrencyId = 1
--from	tblICBackupDetailInventoryTransaction bu left join tblICInventoryTransaction t 
--			on bu.strTransactionId = t.strTransactionId
--			and bu.strBatchId = t.strBatchId
--			and bu.intItemId = t.intItemId
--			and bu.intItemLocationId = t.intItemLocationId
--			and bu.intItemUOMId = t.intItemUOMId
--		left join tblICInventoryTransaction t2			
--			on bu.intIdentityId = t2.intInventoryTransactionId

--where	t.intInventoryTransactionId is null 
--		and t2.intInventoryTransactionId is null 
--		and isnull(bu.ysnIsUnposted, 0) = 0
--		and bu.dblQty <> 0  
--		and bu.intBackupId = @intBackupId

SET IDENTITY_INSERT tblICInventoryTransaction OFF; 
