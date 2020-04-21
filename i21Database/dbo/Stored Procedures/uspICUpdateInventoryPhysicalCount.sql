﻿CREATE PROCEDURE [dbo].[uspICUpdateInventoryPhysicalCount]
	-- Count No and Physical Count are required
	@strCountNo NVARCHAR(50),
	@dblPhysicalCount NUMERIC(18,6),

	-- ========================================
	--    Required for a lotted item
	-- ========================================
	-- Set this to NULL for a non-lotted item
	@intLotId INT = NULL,

	-- This is also required
	@intUserSecurityId INT,

	-- ========================================
	--    Parameters for a non-lotted item
	-- ========================================
	-- Required for a non-lotted item
	@intItemId INT = NULL,
	@intItemLocationId INT = NULL,

	-- Set this to change the Count UOM 
	@intItemUOMId INT = NULL,
	-- Set these to change the storage unit/loc
	@intStorageLocationId INT = NULL,
	@intStorageUnitId INT = NULL,
	@ysnUpdatedOutdatedStock BIT = NULL
AS

DECLARE @intInventoryCountId INT
DECLARE @ysnPosted BIT
DECLARE @ysnCountByLots BIT
DECLARE @msg NVARCHAR(600)
DECLARE @intLocationId INT
DECLARE @countDate DATETIME

SELECT
	  @intInventoryCountId = intInventoryCountId
	, @ysnPosted = ysnPosted
	, @ysnCountByLots = ISNULL(ysnCountByLots, 0)
	, @intLocationId = intLocationId
	, @countDate = dtmCountDate
FROM tblICInventoryCount 
WHERE strCountNo = @strCountNo

IF @intInventoryCountId IS NOT NULL AND @ysnPosted = 0
BEGIN
	DECLARE @strCountLine NVARCHAR(50)
	SELECT @strCountLine = @strCountNo + '-' + CAST(COUNT(*) + 1 AS NVARCHAR(50)) FROM tblICInventoryCountDetail WHERE intInventoryCountId = @intInventoryCountId
	DECLARE @ysnLotWeightsRequired BIT

	IF(@ysnCountByLots = 1)
	BEGIN
		IF(@intLotId IS NULL)
		BEGIN
			SET @msg = 'Inventory Count "' + @strCountNo + '" needs a lot id.'
			RAISERROR(@msg, 11, 1)
			GOTO _Exit
		END

		SELECT
			@intItemId = i.intItemId,
			@ysnLotWeightsRequired = i.ysnLotWeightsRequired
		FROM tblICLot lot
			INNER JOIN tblICItem i ON i.intItemId = lot.intItemId
		WHERE lot.intLotId = @intLotId

		IF EXISTS(SELECT * FROM tblICInventoryCountDetail WHERE intInventoryCountId = @intInventoryCountId AND intLotId = @intLotId)
		BEGIN
			UPDATE cd
			SET
				  cd.dblPhysicalCount = @dblPhysicalCount
				, cd.dblWeightQty = CASE WHEN lot.intWeightUOMId IS NOT NULL THEN dbo.fnCalculateQtyBetweenUOM(lot.intItemUOMId, lot.intWeightUOMId, @dblPhysicalCount) ELSE dblWeightQty END
				, cd.dblNetQty = CASE WHEN lot.intWeightUOMId IS NOT NULL THEN dbo.fnCalculateQtyBetweenUOM(lot.intItemUOMId, lot.intWeightUOMId, @dblPhysicalCount) ELSE dblNetQty END
				, cd.intEntityUserSecurityId = @intUserSecurityId
				, cd.dtmDateModified = GETDATE()
				, cd.intModifiedByUserId = @intUserSecurityId
				, cd.dblLastCost = ISNULL(CASE 
							WHEN lot.intWeightUOMId IS NOT NULL THEN 
								ISNULL(dbo.fnCalculateCostBetweenUOM(LastLotTransaction.intItemUOMId, lot.intWeightUOMId, LastLotTransaction.dblCost), 0)
							ELSE 
								ISNULL(dbo.fnCalculateCostBetweenUOM(LastLotTransaction.intItemUOMId, lot.intItemUOMId, LastLotTransaction.dblCost), 0)
						END 
						, ISNULL(pricing.dblLastCost, pricing.dblStandardCost))
				, dblSystemCount = ISNULL(LotTransactions.dblQty, 0)
			FROM tblICInventoryCountDetail cd
				INNER JOIN tblICLot lot ON lot.intLotId = cd.intLotId
					AND lot.intItemId = cd.intItemId
					AND lot.intItemLocationId = cd.intItemLocationId
				LEFT OUTER JOIN tblICItemPricing pricing ON pricing.intItemId = lot.intItemId
					AND pricing.intItemLocationId = lot.intItemLocationId
				OUTER APPLY (
					SELECT
						TOP 1 
						t.intItemUOMId
						,t.dblCost
						,t.intInventoryTransactionId
					FROM 
						tblICInventoryTransaction t
					WHERE 
						t.intItemId = lot.intItemId
						AND t.intItemLocationId = lot.intItemLocationId
						AND t.intSubLocationId = lot.intSubLocationId
						AND t.intStorageLocationId = lot.intStorageLocationId
						AND t.intLotId = lot.intLotId
						AND t.dblQty > 0 
						AND ISNULL(t.ysnIsUnposted, 0) = 0 
						AND dbo.fnDateLessThanEquals(t.dtmDate, @countDate) = 1	
					ORDER BY
						t.intInventoryTransactionId DESC 		
				) LastLotTransaction
				CROSS APPLY (
					SELECT 
						dblQty = SUM(dbo.fnCalculateQtyBetweenUOM(t.intItemUOMId, l.intItemUOMId, t.dblQty)) 
						, dblWeight = 
							SUM(
								CASE 
									WHEN l.intWeightUOMId IS NOT NULL THEN 
										CASE 
											WHEN t.intItemUOMId = l.intWeightUOMId THEN t.dblQty 
											WHEN t.intItemUOMId = t.intItemUOMId THEN dbo.fnMultiply(t.dblQty, ISNULL(l.dblWeightPerQty, 0)) 
											ELSE 0
										END 
									ELSE 
										0
								END 
							)
					FROM tblICInventoryTransaction t INNER JOIN tblICLot l
						ON t.intLotId = l.intLotId
					WHERE
						t.intItemId = lot.intItemId
						AND t.intItemLocationId = lot.intItemLocationId
						AND t.intSubLocationId = lot.intSubLocationId
						AND t.intStorageLocationId = lot.intStorageLocationId
						AND t.intLotId = lot.intLotId
						AND dbo.fnDateLessThanEquals(t.dtmDate, @countDate) = 1		
				) LotTransactions
			WHERE cd.intLotId = @intLotId
				AND cd.intInventoryCountId = @intInventoryCountId
		END
		ELSE
		BEGIN
			IF NOT EXISTS(SELECT * FROM tblICLot WHERE intLotId = @intLotId)
			BEGIN
				SET @msg = 'Lot id does not exists. Inventory Count "' + @strCountNo + '" needs a lot id.'
				RAISERROR(@msg, 11, 1)
				GOTO _Exit	
			END

			INSERT INTO tblICInventoryCountDetail (
					intInventoryCountId
				, intItemId
				, intItemLocationId
				, intSubLocationId
				, intStorageLocationId
				, intLotId
				, strLotNo
				, strLotAlias
				, intParentLotId
				, strParentLotNo
				, strParentLotAlias
				, intEntityUserSecurityId
				, dblPhysicalCount
				, intItemUOMId
				, intWeightUOMId
				, dblWeightQty
				, dblNetQty
				, intConcurrencyId
				, dtmDateCreated
				, intCreatedByUserId
				, strCountLine
				, intStockUOMId
				, dblLastCost
				, dblSystemCount
			)
			SELECT
				  intInventoryCountId = @intInventoryCountId
				, intItemId = lot.intItemId
				, intItemLocationId = lot.intItemLocationId
				, intSubLocationId = lot.intSubLocationId
				, intStorageLocationId = lot.intStorageLocationId
				, intLotId = lot.intLotId
				, strLotNo = lot.strLotNumber
				, strLotAlias = lot.strLotAlias
				, intParentLotId = pLot.intParentLotId
				, strParentLotNo = pLot.strParentLotNumber
				, strParentLotAlias = pLot.strParentLotAlias
				, intEntityUserSecurityId = @intUserSecurityId
				, dblPhysicalCount = @dblPhysicalCount
				, intItemUOMId = lot.intItemUOMId
				, intWeightUOMId = lot.intWeightUOMId
				, dblWeightQty = dbo.fnCalculateQtyBetweenUOM(lot.intItemUOMId, intWeightUOMId, @dblPhysicalCount)
				, dblNetQty = dbo.fnCalculateQtyBetweenUOM(lot.intItemUOMId, intWeightUOMId, @dblPhysicalCount)
				, intConcurrencyId = 1
				, dtmDateCreated = GETDATE()
				, intCreatedByUserId = @intUserSecurityId
				, strCountLine = @strCountLine
				, intStockUOMId = stockUOM.intItemUOMId
				, dblLastCost = ISNULL(CASE 
									WHEN lot.intWeightUOMId IS NOT NULL THEN 
										ISNULL(dbo.fnCalculateCostBetweenUOM(LastLotTransaction.intItemUOMId, lot.intWeightUOMId, LastLotTransaction.dblCost), 0)
									ELSE 
										ISNULL(dbo.fnCalculateCostBetweenUOM(LastLotTransaction.intItemUOMId, lot.intItemUOMId, LastLotTransaction.dblCost), 0)
								END 
								, ISNULL(pricing.dblLastCost, pricing.dblStandardCost))
				, dblSystemCount = ISNULL(LotTransactions.dblQty, 0)
			FROM tblICLot lot
				LEFT JOIN tblICItemStockUOM stockUOM ON stockUOM.intItemUOMId = lot.intItemUOMId
					AND stockUOM.intItemId = lot.intItemId
					AND stockUOM.intStorageLocationId = lot.intStorageLocationId
					AND stockUOM.intSubLocationId = lot.intSubLocationId
					AND stockUOM.intItemLocationId = lot.intItemLocationId
				LEFT OUTER JOIN tblICParentLot pLot ON lot.intParentLotId = pLot.intParentLotId
				LEFT OUTER JOIN tblICItemPricing pricing ON pricing.intItemId = lot.intItemId
					AND pricing.intItemLocationId = lot.intItemLocationId
				CROSS APPLY (
					SELECT 
						dblQty = SUM(dbo.fnCalculateQtyBetweenUOM(t.intItemUOMId, l.intItemUOMId, t.dblQty)) 
						, dblWeight = 
							SUM(
								CASE 
									WHEN l.intWeightUOMId IS NOT NULL THEN 
										CASE 
											WHEN t.intItemUOMId = l.intWeightUOMId THEN t.dblQty 
											WHEN t.intItemUOMId = t.intItemUOMId THEN dbo.fnMultiply(t.dblQty, ISNULL(l.dblWeightPerQty, 0)) 
											ELSE 0
										END 
									ELSE 
										0
								END 
							)
					FROM tblICInventoryTransaction t INNER JOIN tblICLot l
						ON t.intLotId = l.intLotId
					WHERE
						t.intItemId = lot.intItemId
						AND t.intItemLocationId = lot.intItemLocationId
						AND t.intSubLocationId = lot.intSubLocationId
						AND t.intStorageLocationId = lot.intStorageLocationId
						AND t.intLotId = lot.intLotId
						AND dbo.fnDateLessThanEquals(t.dtmDate, @countDate) = 1		
				) LotTransactions 
				OUTER APPLY (
					SELECT
						TOP 1 
						t.intItemUOMId
						,t.dblCost
						,t.intInventoryTransactionId
					FROM 
						tblICInventoryTransaction t
					WHERE 
						t.intItemId = lot.intItemId
						AND t.intItemLocationId = lot.intItemLocationId
						AND t.intSubLocationId = lot.intSubLocationId
						AND t.intStorageLocationId = lot.intStorageLocationId
						AND t.intLotId = lot.intLotId
						AND t.dblQty > 0 
						AND ISNULL(t.ysnIsUnposted, 0) = 0 
						AND dbo.fnDateLessThanEquals(t.dtmDate, @countDate) = 1	
					ORDER BY
						t.intInventoryTransactionId DESC 		
				) LastLotTransaction
			WHERE lot.intLotId = @intLotId	
		END
	END
	ELSE -- Non-lotted Item
	BEGIN
		IF(@intItemUOMId IS NULL)
		BEGIN
			SET @msg = 'Count UOM is required. Provide a value to the @intItemUOMId parameter.'
			RAISERROR(@msg, 11, 1)
			GOTO _Exit
		END

		IF NOT EXISTS(
			SElECT TOP 1 1 FROM tblICItemUOM where intItemId = @intItemId AND intItemUOMId = @intItemUOMId
		)
		BEGIN
			SET @msg = 'Invalid Count UOM. Provide a valid value to the @intItemUOMId parameter.'
			RAISERROR(@msg, 11, 1)
			GOTO _Exit	
		END

		IF @intStorageLocationId IS NOT NULL
		BEGIN
			IF NOT EXISTS(SELECT TOP 1 1
				FROM tblSMCompanyLocationSubLocation sub
					INNER JOIN tblICItemLocation il ON il.intLocationId = sub.intCompanyLocationId
				WHERE il.intItemId = @intItemId
					AND il.intItemLocationId = @intItemLocationId
					AND sub.intCompanyLocationSubLocationId = @intStorageLocationId
			)
			BEGIN
				SET @msg = 'The storage location is not set up for the item. Provide a valid value to the @intStorageLocationId parameter.'
				RAISERROR(@msg, 11, 1)
				GOTO _Exit		
			END
		END

		IF @intStorageUnitId IS NOT NULL
		BEGIN
			IF @intStorageLocationId IS NULL
			BEGIN
				SELECT @intStorageLocationId = sub.intCompanyLocationSubLocationId
				FROM tblSMCompanyLocationSubLocation sub
					INNER JOIN tblICStorageLocation sl ON sl.intSubLocationId = sub.intCompanyLocationSubLocationId
				WHERE sl.intStorageLocationId = @intStorageUnitId
			END

			IF NOT EXISTS(SELECT TOP 1 1
				FROM tblICStorageLocation sl
					INNER JOIN tblICItemLocation il ON il.intLocationId = sl.intLocationId
				WHERE sl.intStorageLocationId = @intStorageUnitId
					AND il.intItemLocationId = @intItemLocationId
					AND sl.intSubLocationId = @intStorageLocationId
					AND il.intItemId = @intItemId
			)
			BEGIN
				SET @msg = 'The storage unit is not set up for the item. Provide a valid value to the @intStorageUnitId parameter.'
				RAISERROR(@msg, 11, 1)
				GOTO _Exit			
			END

		END

		IF EXISTS(SELECT *
			FROM tblICInventoryCount c
				INNER JOIN tblICInventoryCountDetail cd ON cd.intInventoryCountId = c.intInventoryCountId
			WHERE c.intInventoryCountId = @intInventoryCountId
				AND cd.intItemLocationId = @intItemLocationId
				AND cd.intItemId = @intItemId
				AND cd.intItemUOMId = @intItemUOMId
				AND ((cd.intSubLocationId IS NULL AND @intStorageLocationId IS NULL) OR (cd.intSubLocationId = @intStorageLocationId AND @intStorageLocationId IS NOT NULL))
				AND ((cd.intStorageLocationId IS NULL AND @intStorageUnitId IS NULL) OR (cd.intStorageLocationId = @intStorageUnitId AND @intStorageUnitId IS NOT NULL))
		)
		BEGIN
			UPDATE cd
			SET
				  cd.dblPhysicalCount			= @dblPhysicalCount
				, cd.intItemUOMId				= @intItemUOMId
				, cd.dtmDateModified			= GETDATE()
				, cd.intModifiedByUserId		= @intUserSecurityId
				, cd.intEntityUserSecurityId	= @intUserSecurityId
				, dblSystemCount			    = ISNULL(stockUnitQty.dblOnHand, 0)
				, cd.dblLastCost				= ISNULL(
						CASE 
							-- Get the average cost. 
							WHEN il.intCostingMethod = 1 THEN 				
								dbo.fnCalculateCostBetweenUOM (
									stockUOM.intItemUOMId
									,COALESCE(stock.intItemUOMId, stockUOM.intItemUOMId)
									,ISNULL(
										dbo.fnICGetMovingAverageCost(
											i.intItemId
											,il.intItemLocationId
											,lastTransaction.intInventoryTransactionId
							
										)
										,pricing.dblLastCost
									)					
								)
					
							-- Or else, get the last cost. 
							ELSE 				
								dbo.fnCalculateQtyBetweenUOM (
									lastTransaction.intItemUOMId
									, COALESCE(stock.intItemUOMId, stockUOM.intItemUOMId)
									, lastTransaction.dblCost
								)
						END 
						, ISNULL(pricing.dblLastCost, pricing.dblStandardCost))
			FROM tblICInventoryCount c
				INNER JOIN tblICInventoryCountDetail cd ON cd.intInventoryCountId = c.intInventoryCountId
				INNER JOIN tblICItemLocation il ON il.intItemId = cd.intItemId
				INNER JOIN tblICItem i ON i.intItemId = cd.intItemId
				INNER JOIN tblICItemUOM u ON u.intItemId = cd.intItemId
					AND u.ysnStockUnit = 1
				LEFT OUTER JOIN tblICItemPricing pricing ON pricing.intItemId = cd.intItemId
					AND pricing.intItemLocationId = il.intItemLocationId
				INNER JOIN tblICItemUOM stockUOM ON stockUOM.intItemId = il.intItemId
					AND stockUOM.ysnStockUnit = 1
				LEFT JOIN (
					SELECT	 
						st.intItemId
						,st.intItemLocationId
						,st.intSubLocationId
						,st.intStorageLocationId
						,st.intLocationId
						,dblOnHand = SUM (
								dbo.fnCalculateQtyBetweenUOM (
									st.intItemUOMId
									, suom.intItemUOMId
									, ISNULL(st.dblOnHand, 0.00)
								)
							)
					FROM	
						vyuICGetItemStockSummary st
						INNER JOIN tblICItemUOM suom 
							ON suom.intItemId = st.intItemId
							AND suom.ysnStockUnit = 1
					WHERE	
						dbo.fnDateLessThanEquals(dtmDate, @countDate) = 1
						--AND st.intItemLocationId = @intItemLocationId
					GROUP BY 
						st.intItemId
						,st.intItemLocationId
						,st.intSubLocationId
						,st.intStorageLocationId
						,st.intLocationId
				) stockUnit 
				ON stockUnit.intItemId = i.intItemId			
					AND stockUnit.intItemLocationId = il.intItemLocationId
					AND stockUnit.intLocationId = il.intLocationId
				LEFT JOIN (
					SELECT	 
						st.intItemId
						,st.intItemLocationId
						,st.intSubLocationId
						,st.intStorageLocationId
						,st.intLocationId
						,dblOnHand = SUM (
								dbo.fnCalculateQtyBetweenUOM (
									st.intItemUOMId
									, suom.intItemUOMId
									, ISNULL(st.dblOnHand, 0.00)
								)
							)
					FROM	
						vyuICGetItemStockSummary st
						INNER JOIN tblICItemUOM suom 
							ON suom.intItemId = st.intItemId
							AND suom.ysnStockUnit = 1
					WHERE	
						dbo.fnDateLessThanEquals(dtmDate, @countDate) = 1
						AND st.intItemLocationId = @intItemLocationId
					GROUP BY 
						st.intItemId
						,st.intItemLocationId
						,st.intSubLocationId
						,st.intStorageLocationId
						,st.intLocationId
				) stockUnitQty
				ON stockUnitQty.intItemId = i.intItemId			
					AND stockUnitQty.intItemLocationId = il.intItemLocationId
					AND stockUnitQty.intLocationId = il.intLocationId
				LEFT JOIN (
					SELECT	intItemId
							,intItemUOMId
							,intItemLocationId
							,intSubLocationId
							,intStorageLocationId
							,dblOnHand =  SUM(COALESCE(dblOnHand, 0.00))
					FROM	vyuICGetItemStockSummary
					WHERE	dbo.fnDateLessThanEquals(dtmDate, @countDate) = 1
					GROUP BY 
							intItemId,
							intItemUOMId,
							intItemLocationId,
							intSubLocationId,
							intStorageLocationId
				) stock 
					ON stock.intItemId = cd.intItemId
					AND stock.intItemLocationId = il.intItemLocationId
					--AND stock.intItemUOMId = stockUOM.intItemUOMId 
				OUTER APPLY (
					SELECT
						TOP 1 
						t.intItemUOMId
						,t.dblCost
						,t.intInventoryTransactionId
					FROM 
						tblICInventoryTransaction t
					WHERE 
						t.intItemId = i.intItemId
						AND t.intItemLocationId = il.intItemLocationId 
						AND t.dblQty > 0 
						AND ISNULL(t.ysnIsUnposted, 0) = 0 
						AND dbo.fnDateLessThanEquals(CONVERT(VARCHAR(10), t.dtmDate,112), @countDate) = 1
					ORDER BY
						t.intInventoryTransactionId DESC 		
				) lastTransaction 
			WHERE c.intInventoryCountId = @intInventoryCountId
				AND cd.intItemLocationId = @intItemLocationId
				AND cd.intItemId = @intItemId
				AND cd.intItemUOMId = @intItemUOMId
				AND ((cd.intSubLocationId IS NULL AND @intStorageLocationId IS NULL) OR (cd.intSubLocationId = @intStorageLocationId AND @intStorageLocationId IS NOT NULL))
				AND ((cd.intStorageLocationId IS NULL AND @intStorageUnitId IS NULL) OR (cd.intStorageLocationId = @intStorageUnitId AND @intStorageUnitId IS NOT NULL))
		END
		ELSE
		BEGIN
			INSERT INTO tblICInventoryCountDetail (
					intInventoryCountId
				, intItemId
				, intItemLocationId
				, intSubLocationId
				, intStorageLocationId
				, intEntityUserSecurityId
				, dblPhysicalCount
				, intItemUOMId
				, intConcurrencyId
				, dtmDateCreated
				, intCreatedByUserId
				, strCountLine
				, intStockUOMId
				, dblLastCost
				, dblSystemCount
			)
			SELECT
				  intInventoryCountId		= @intInventoryCountId
				, intItemId					= i.intItemId
				, intItemLocationId			= il.intItemLocationId
				, intSubLocationId			= @intStorageLocationId
				, intStorageLocationId		= @intStorageUnitId
				, intEntityUserSecurityId	= @intUserSecurityId
				, dblPhysicalCount			= @dblPhysicalCount
				, intItemUOMId				= @intItemUOMId
				, intConcurrencyId			= 1
				, dtmDateCreated			= GETDATE()
				, intCreatedByUserId		= @intUserSecurityId
				, strCountLine				= @strCountLine
				, intStockUOMId				= u.intItemUOMId
				, dblLastCost				= ISNULL(
											CASE 
												-- Get the average cost. 
												WHEN il.intCostingMethod = 1 THEN 				
													dbo.fnCalculateCostBetweenUOM (
														stockUOM.intItemUOMId
														,COALESCE(stock.intItemUOMId, stockUOM.intItemUOMId)
														,ISNULL(
															dbo.fnICGetMovingAverageCost(
																i.intItemId
																,il.intItemLocationId
																,lastTransaction.intInventoryTransactionId
							
															)
															,pricing.dblLastCost
														)					
													)
					
												-- Or else, get the last cost. 
												ELSE 				
													dbo.fnCalculateQtyBetweenUOM (
														lastTransaction.intItemUOMId
														, COALESCE(stock.intItemUOMId, stockUOM.intItemUOMId)
														, lastTransaction.dblCost
													)
											END 
											, ISNULL(pricing.dblLastCost, pricing.dblStandardCost))
					, dblSystemCount		= ISNULL(stockUnitQty.dblOnHand, 0)
			FROM tblICItem i
				INNER JOIN tblICItemLocation il ON il.intItemId = i.intItemId
				INNER JOIN tblICItemUOM u ON u.intItemId = i.intItemId
					AND u.ysnStockUnit = 1
				LEFT OUTER JOIN tblICItemPricing pricing ON pricing.intItemId = i.intItemId
					AND pricing.intItemLocationId = il.intItemLocationId
				INNER JOIN tblICItemUOM stockUOM ON stockUOM.intItemId = il.intItemId
					AND stockUOM.ysnStockUnit = 1
				LEFT JOIN (
					SELECT	 
						st.intItemId
						,st.intItemLocationId
						,st.intSubLocationId
						,st.intStorageLocationId
						,st.intLocationId
						,dblOnHand = SUM (
								dbo.fnCalculateQtyBetweenUOM (
									st.intItemUOMId
									, suom.intItemUOMId
									, ISNULL(st.dblOnHand, 0.00)
								)
							)
					FROM	
						vyuICGetItemStockSummary st
						INNER JOIN tblICItemUOM suom 
							ON suom.intItemId = st.intItemId
							AND suom.ysnStockUnit = 1
					WHERE	
						dbo.fnDateLessThanEquals(dtmDate, @countDate) = 1
					GROUP BY 
						st.intItemId
						,st.intItemLocationId
						,st.intSubLocationId
						,st.intStorageLocationId
						,st.intLocationId
				) stockUnit 
				ON stockUnit.intItemId = i.intItemId			
					AND stockUnit.intItemLocationId = il.intItemLocationId
					AND stockUnit.intLocationId = il.intLocationId
				LEFT JOIN (
					SELECT	 
						st.intItemId
						,st.intItemLocationId
						,st.intSubLocationId
						,st.intStorageLocationId
						,st.intLocationId
						,dblOnHand = SUM (
								dbo.fnCalculateQtyBetweenUOM (
									st.intItemUOMId
									, suom.intItemUOMId
									, ISNULL(st.dblOnHand, 0.00)
								)
							)
					FROM	
						vyuICGetItemStockSummary st
						INNER JOIN tblICItemUOM suom 
							ON suom.intItemId = st.intItemId
							AND suom.ysnStockUnit = 1
					WHERE	
						dbo.fnDateLessThanEquals(dtmDate, @countDate) = 1
						AND st.intItemLocationId = @intItemLocationId
					GROUP BY 
						st.intItemId
						,st.intItemLocationId
						,st.intSubLocationId
						,st.intStorageLocationId
						,st.intLocationId
				) stockUnitQty
				ON stockUnitQty.intItemId = i.intItemId			
					AND stockUnitQty.intItemLocationId = il.intItemLocationId
					AND stockUnitQty.intLocationId = il.intLocationId
				LEFT JOIN (
					SELECT	intItemId
							,intItemUOMId
							,intItemLocationId
							,intSubLocationId
							,intStorageLocationId
							,dblOnHand =  SUM(COALESCE(dblOnHand, 0.00))
					FROM	vyuICGetItemStockSummary
					WHERE	dbo.fnDateLessThanEquals(dtmDate, @countDate) = 1
					GROUP BY 
							intItemId,
							intItemUOMId,
							intItemLocationId,
							intSubLocationId,
							intStorageLocationId
				) stock 
					ON stock.intItemId = i.intItemId
					AND stock.intItemLocationId = il.intItemLocationId
					--AND stock.intItemUOMId = stockUOM.intItemUOMId 
				OUTER APPLY (
					SELECT
						TOP 1 
						t.intItemUOMId
						,t.dblCost
						,t.intInventoryTransactionId
					FROM 
						tblICInventoryTransaction t
					WHERE 
						t.intItemId = i.intItemId
						AND t.intItemLocationId = il.intItemLocationId 
						AND t.dblQty > 0 
						AND ISNULL(t.ysnIsUnposted, 0) = 0 
						AND dbo.fnDateLessThanEquals(CONVERT(VARCHAR(10), t.dtmDate,112), @countDate) = 1
					ORDER BY
						t.intInventoryTransactionId DESC 		
				) lastTransaction 
			WHERE i.intItemId = @intItemId
				AND il.intItemLocationId = @intItemLocationId
		END
	END

	IF @ysnUpdatedOutdatedStock = 1
		EXEC dbo.uspICInventoryCountUpdateOutdatedItemStock @intInventoryCountId
END
ELSE
BEGIN
	IF @intInventoryCountId IS NOT NULL
	BEGIN
		SET @msg = 'Unable to modify an Inventory Count that has already been posted.'
		RAISERROR(@msg, 11, 1)
	END
	ELSE
		RAISERROR('Invalid Inventory Count number.', 11, 1)
END

_Exit: