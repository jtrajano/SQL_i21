﻿/*
	Delete the records from the backup table. Keep only the last two backup ids.
*/
CREATE PROCEDURE [dbo].[uspICRebuildCleanUp]
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

SET NOCOUNT OFF

IF OBJECT_ID('tempdb..#tmp_tblICBackupDetailInventoryTransaction_all') IS NOT NULL DROP TABLE #tmp_tblICBackupDetailInventoryTransaction_all
IF OBJECT_ID('tempdb..#tmp_tblICBackupDetailInventoryTransaction_item') IS NOT NULL DROP TABLE #tmp_tblICBackupDetailInventoryTransaction_item
IF OBJECT_ID('tempdb..#tmp_tblICBackupDetailInventoryTransaction_catgegory') IS NOT NULL DROP TABLE #tmp_tblICBackupDetailInventoryTransaction_category

SELECT t.* 
INTO #tmp_tblICBackupDetailInventoryTransaction_all
FROM 
	tblICBackup b INNER JOIN tblICBackupDetailInventoryTransaction t 
		ON b.intBackupId = t.intBackupId
	CROSS APPLY (
		SELECT deleteList.intBackupId
		FROM 
			tblICBackup deleteList 				
		WHERE
			deleteList.intBackupId = b.intBackupId
			AND deleteList.strItemNo IS NULL 
			AND deleteList.strCategoryCode IS NULL 
			AND deleteList.intBackupId IN (
				SELECT TOP 2 
					topBackup.intBackupId
				FROM 
					tblICBackup topBackup
				WHERE
					topBackup.strItemNo IS NULL 
					AND topBackup.strCategoryCode IS NULL 
					AND topBackup.strRemarks <> 'Stock is up to date.'
				ORDER BY 
					topBackup.intBackupId DESC 				
			)
	) deleteBackup
WHERE
	b.strItemNo IS NULL 
	AND b.strCategoryCode IS NULL 

SELECT t.* 
INTO #tmp_tblICBackupDetailInventoryTransaction_item
FROM 
	tblICBackup b INNER JOIN tblICBackupDetailInventoryTransaction t 
		ON b.intBackupId = t.intBackupId
	CROSS APPLY (
		SELECT topBackup.intBackupId
		FROM (
				SELECT TOP 2 
					topBackup.intBackupId
				FROM 
					tblICBackup topBackup
				WHERE
					topBackup.strItemNo IS NOT NULL
					AND topBackup.strRemarks <> 'Stock is up to date.'
				ORDER BY 
					topBackup.intBackupId DESC 				
			) topBackup
		WHERE
			topBackup.intBackupId = b.intBackupId
	) deleteBackup
WHERE
	b.strItemNo IS NOT NULL 

SELECT t.* 
INTO #tmp_tblICBackupDetailInventoryTransaction_category
FROM 
	tblICBackup b INNER JOIN tblICBackupDetailInventoryTransaction t 
		ON b.intBackupId = t.intBackupId
	CROSS APPLY (
		SELECT topBackup.intBackupId
		FROM (
				SELECT TOP 2 
					topBackup.intBackupId
				FROM 
					tblICBackup topBackup
				WHERE
					topBackup.strCategoryCode IS NOT NULL
					AND topBackup.strRemarks <> 'Stock is up to date.'
				ORDER BY 
					topBackup.intBackupId DESC 				
			) topBackup
		WHERE
			topBackup.intBackupId = b.intBackupId
	) deleteBackup
WHERE
	b.strCategoryCode IS NOT NULL 


TRUNCATE TABLE tblICBackupDetailInventoryTransaction

-- Re-insert the backup data. 
INSERT INTO tblICBackupDetailInventoryTransaction (
	[intBackupId]
	,[intIdentityId]
	,[intItemId]
	,[intItemLocationId]
	,[intItemUOMId]
	,[intSubLocationId] 
	,[intStorageLocationId] 
	,[dtmDate] 
	,[dblQty]
	,[dblUOMQty]
	,[dblCost]
	,[dblValue]
	,[dblSalesPrice]
	,[intCurrencyId]
	,[dblExchangeRate]
	,[intTransactionId]
	,[strTransactionId]
	,[intTransactionDetailId]
	,[strBatchId]
	,[intTransactionTypeId] 
	,[intLotId] 
	,[ysnIsUnposted] 
	,[intRelatedInventoryTransactionId] 
	,[intRelatedTransactionId] 
	,[strRelatedTransactionId] 
	,[strTransactionForm] 
	,[intCostingMethod] 
	,[intInTransitSourceLocationId] 
	,[dtmCreated] 
	,[strDescription] 
	,[intFobPointId] 
	,[ysnNoGLPosting]
	,[intForexRateTypeId] 
	,[dblForexRate] 
	,[strActualCostId] 
	,[dblUnitRetail] 
	,[dblCategoryCostValue] 
	,[dblCategoryRetailValue] 
	,[intCategoryId] 
	,[intCreatedUserId] 
	,[intCreatedEntityId] 
	,[intCompanyId] 
)
SELECT 	
	[intBackupId]
	,[intIdentityId]
	,[intItemId]
	,[intItemLocationId]
	,[intItemUOMId]
	,[intSubLocationId] 
	,[intStorageLocationId] 
	,[dtmDate] 
	,[dblQty]
	,[dblUOMQty]
	,[dblCost]
	,[dblValue]
	,[dblSalesPrice]
	,[intCurrencyId]
	,[dblExchangeRate]
	,[intTransactionId]
	,[strTransactionId]
	,[intTransactionDetailId]
	,[strBatchId]
	,[intTransactionTypeId] 
	,[intLotId] 
	,[ysnIsUnposted] 
	,[intRelatedInventoryTransactionId] 
	,[intRelatedTransactionId] 
	,[strRelatedTransactionId] 
	,[strTransactionForm] 
	,[intCostingMethod] 
	,[intInTransitSourceLocationId] 
	,[dtmCreated] 
	,[strDescription] 
	,[intFobPointId] 
	,[ysnNoGLPosting]
	,[intForexRateTypeId] 
	,[dblForexRate] 
	,[strActualCostId] 
	,[dblUnitRetail] 
	,[dblCategoryCostValue] 
	,[dblCategoryRetailValue] 
	,[intCategoryId] 
	,[intCreatedUserId] 
	,[intCreatedEntityId] 
	,[intCompanyId] 
FROM 
	#tmp_tblICBackupDetailInventoryTransaction_all

INSERT INTO tblICBackupDetailInventoryTransaction (
	[intBackupId]
	,[intIdentityId]
	,[intItemId]
	,[intItemLocationId]
	,[intItemUOMId]
	,[intSubLocationId] 
	,[intStorageLocationId] 
	,[dtmDate] 
	,[dblQty]
	,[dblUOMQty]
	,[dblCost]
	,[dblValue]
	,[dblSalesPrice]
	,[intCurrencyId]
	,[dblExchangeRate]
	,[intTransactionId]
	,[strTransactionId]
	,[intTransactionDetailId]
	,[strBatchId]
	,[intTransactionTypeId] 
	,[intLotId] 
	,[ysnIsUnposted] 
	,[intRelatedInventoryTransactionId] 
	,[intRelatedTransactionId] 
	,[strRelatedTransactionId] 
	,[strTransactionForm] 
	,[intCostingMethod] 
	,[intInTransitSourceLocationId] 
	,[dtmCreated] 
	,[strDescription] 
	,[intFobPointId] 
	,[ysnNoGLPosting]
	,[intForexRateTypeId] 
	,[dblForexRate] 
	,[strActualCostId] 
	,[dblUnitRetail] 
	,[dblCategoryCostValue] 
	,[dblCategoryRetailValue] 
	,[intCategoryId] 
	,[intCreatedUserId] 
	,[intCreatedEntityId] 
	,[intCompanyId] 
)
SELECT 	
	[intBackupId]
	,[intIdentityId]
	,[intItemId]
	,[intItemLocationId]
	,[intItemUOMId]
	,[intSubLocationId] 
	,[intStorageLocationId] 
	,[dtmDate] 
	,[dblQty]
	,[dblUOMQty]
	,[dblCost]
	,[dblValue]
	,[dblSalesPrice]
	,[intCurrencyId]
	,[dblExchangeRate]
	,[intTransactionId]
	,[strTransactionId]
	,[intTransactionDetailId]
	,[strBatchId]
	,[intTransactionTypeId] 
	,[intLotId] 
	,[ysnIsUnposted] 
	,[intRelatedInventoryTransactionId] 
	,[intRelatedTransactionId] 
	,[strRelatedTransactionId] 
	,[strTransactionForm] 
	,[intCostingMethod] 
	,[intInTransitSourceLocationId] 
	,[dtmCreated] 
	,[strDescription] 
	,[intFobPointId] 
	,[ysnNoGLPosting]
	,[intForexRateTypeId] 
	,[dblForexRate] 
	,[strActualCostId] 
	,[dblUnitRetail] 
	,[dblCategoryCostValue] 
	,[dblCategoryRetailValue] 
	,[intCategoryId] 
	,[intCreatedUserId] 
	,[intCreatedEntityId] 
	,[intCompanyId] 
FROM 
	#tmp_tblICBackupDetailInventoryTransaction_item

INSERT INTO tblICBackupDetailInventoryTransaction (
	[intBackupId]
	,[intIdentityId]
	,[intItemId]
	,[intItemLocationId]
	,[intItemUOMId]
	,[intSubLocationId] 
	,[intStorageLocationId] 
	,[dtmDate] 
	,[dblQty]
	,[dblUOMQty]
	,[dblCost]
	,[dblValue]
	,[dblSalesPrice]
	,[intCurrencyId]
	,[dblExchangeRate]
	,[intTransactionId]
	,[strTransactionId]
	,[intTransactionDetailId]
	,[strBatchId]
	,[intTransactionTypeId] 
	,[intLotId] 
	,[ysnIsUnposted] 
	,[intRelatedInventoryTransactionId] 
	,[intRelatedTransactionId] 
	,[strRelatedTransactionId] 
	,[strTransactionForm] 
	,[intCostingMethod] 
	,[intInTransitSourceLocationId] 
	,[dtmCreated] 
	,[strDescription] 
	,[intFobPointId] 
	,[ysnNoGLPosting]
	,[intForexRateTypeId] 
	,[dblForexRate] 
	,[strActualCostId] 
	,[dblUnitRetail] 
	,[dblCategoryCostValue] 
	,[dblCategoryRetailValue] 
	,[intCategoryId] 
	,[intCreatedUserId] 
	,[intCreatedEntityId] 
	,[intCompanyId] 
)
SELECT 	
	[intBackupId]
	,[intIdentityId]
	,[intItemId]
	,[intItemLocationId]
	,[intItemUOMId]
	,[intSubLocationId] 
	,[intStorageLocationId] 
	,[dtmDate] 
	,[dblQty]
	,[dblUOMQty]
	,[dblCost]
	,[dblValue]
	,[dblSalesPrice]
	,[intCurrencyId]
	,[dblExchangeRate]
	,[intTransactionId]
	,[strTransactionId]
	,[intTransactionDetailId]
	,[strBatchId]
	,[intTransactionTypeId] 
	,[intLotId] 
	,[ysnIsUnposted] 
	,[intRelatedInventoryTransactionId] 
	,[intRelatedTransactionId] 
	,[strRelatedTransactionId] 
	,[strTransactionForm] 
	,[intCostingMethod] 
	,[intInTransitSourceLocationId] 
	,[dtmCreated] 
	,[strDescription] 
	,[intFobPointId] 
	,[ysnNoGLPosting]
	,[intForexRateTypeId] 
	,[dblForexRate] 
	,[strActualCostId] 
	,[dblUnitRetail] 
	,[dblCategoryCostValue] 
	,[dblCategoryRetailValue] 
	,[intCategoryId] 
	,[intCreatedUserId] 
	,[intCreatedEntityId] 
	,[intCompanyId] 
FROM 
	#tmp_tblICBackupDetailInventoryTransaction_category