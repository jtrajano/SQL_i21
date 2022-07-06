CREATE PROCEDURE [dbo].[uspICMassAddPromotionForCStore]
	-- filter params
	@intItemSpecialPricingId AS INT = NULL 

	-- update params 
	,@intItemLocationToUpdateId AS INT = NULL
	,@intEntityUserSecurityId AS INT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

-- Create the temp table for the audit log. 
IF OBJECT_ID('tempdb..#tmpMassAddPromotionForCStore_itemLocationAuditLog') IS NULL  
	CREATE TABLE #tmpMassAddPromotionForCStore_itemLocationAuditLog (
		intItemId INT 
		-- Original Fields
		,intSpecialPricingId_Original INT
		,intItemLocationId_Original INT 
		,strPromotionType_Original NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,dtmBeginDate_Original DATETIME
		,dtmEndDate_Original DATETIME
		,intItemUnitMeasureId_Original INT
		,dblUnit_Original NUMERIC(18, 6) NULL 
		,strDiscountBy_Original NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
		,dblDiscount_Original NUMERIC(18, 6) NULL 
		,dblUnitAfterDiscount_Original NUMERIC(18, 6) NULL 
		,dblDiscountThruQty_Original	 NUMERIC(18, 6) NULL 
		,dblDiscountThruAmount_Original NUMERIC(18, 6) NULL 
		,dblAccumulatedQty_Original NUMERIC(18, 6) NULL 
		,dblAccumulatedAmount_Original NUMERIC(18, 6) NULL 
		,dblCost_Original NUMERIC(18, 6) NULL 
		,intCurrencyId_Original INT NULL 	
		,intSort_Original INT NULL 	
		,dtmDateCreated_Original	 DATETIME
		,dtmDateModified_Original DATETIME
		,intCreatedByUserId_Original INT NULL 
		,intModifiedByUserId_Original INT NULL 
		
		-- Modified Fields
		,intSpecialPricingId_New INT
		,intItemLocationId_New INT 
		,strPromotionType_New NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
		,dtmBeginDate_New DATETIME
		,dtmEndDate_New DATETIME
		,intItemUnitMeasureId_New INT
		,dblUnit_New NUMERIC(18, 6) NULL 
		,strDiscountBy_New NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
		,dblDiscount_New NUMERIC(18, 6) NULL 
		,dblUnitAfterDiscount_New NUMERIC(18, 6) NULL 
		,dblDiscountThruQty_New	 NUMERIC(18, 6) NULL 
		,dblDiscountThruAmount_New NUMERIC(18, 6) NULL 
		,dblAccumulatedQty_New NUMERIC(18, 6) NULL 
		,dblAccumulatedAmount_New NUMERIC(18, 6) NULL 
		,dblCost_New NUMERIC(18, 6) NULL 
		,intCurrencyId_New INT NULL 	
		,intSort_New INT NULL 	
		,dtmDateCreated_New	 DATETIME
		,dtmDateModified_New DATETIME
		,intCreatedByUserId_New INT NULL 
		,intModifiedByUserId_New INT NULL 
	)
;

-- Update the Standard Cost and Retail Price in the Item Pricing table. 
BEGIN 
	INSERT INTO #tmpMassAddPromotionForCStore_itemLocationAuditLog (
		intItemId
		,intItemLocationId_Original  
		,strPromotionType_Original 
		,dtmBeginDate_Original 
		,dtmEndDate_Original 
		,intItemUnitMeasureId_Original 
		,dblUnit_Original 
		,strDiscountBy_Original 
		,dblDiscount_Original 
		,dblUnitAfterDiscount_Original 
		,dblDiscountThruQty_Original	 
		,dblDiscountThruAmount_Original 
		,dblAccumulatedQty_Original 
		,dblAccumulatedAmount_Original 
		,dblCost_Original 
		,intCurrencyId_Original   	
		,intSort_Original   	
		,dtmDateCreated_Original	 
		,dtmDateModified_Original 
		,intCreatedByUserId_Original  
		,intModifiedByUserId_Original 
	
		-- Modified Fields
		,intItemLocationId_New  
		,strPromotionType_New 
		,dtmBeginDate_New 
		,dtmEndDate_New 
		,intItemUnitMeasureId_New 
		,dblUnit_New  
		,strDiscountBy_New 
		,dblDiscount_New 
		,dblUnitAfterDiscount_New 
		,dblDiscountThruQty_New	 
		,dblDiscountThruAmount_New 
		,dblAccumulatedQty_New 
		,dblAccumulatedAmount_New 
		,dblCost_New 
		,intCurrencyId_New  	
		,intSort_New   	
		,dtmDateCreated_New	 
		,dtmDateModified_New 
		,intCreatedByUserId_New   
		,intModifiedByUserId_New   
	)
	SELECT	
			[Changes].intItemId  
			,[Changes].intItemLocationId_Original  
			,[Changes].strPromotionType_Original 
			,[Changes].dtmBeginDate_Original 
			,[Changes].dtmEndDate_Original 
			,[Changes].intItemUnitMeasureId_Original 
			,[Changes].dblUnit_Original 
			,[Changes].strDiscountBy_Original 
			,[Changes].dblDiscount_Original 
			,[Changes].dblUnitAfterDiscount_Original 
			,[Changes].dblDiscountThruQty_Original	 
			,[Changes].dblDiscountThruAmount_Original 
			,[Changes].dblAccumulatedQty_Original 
			,[Changes].dblAccumulatedAmount_Original 
			,[Changes].dblCost_Original 
			,[Changes].intCurrencyId_Original   	
			,[Changes].intSort_Original   	
			,[Changes].dtmDateCreated_Original	 
			,[Changes].dtmDateModified_Original 
			,[Changes].intCreatedByUserId_Original  
			,[Changes].intModifiedByUserId_Original 
	
			-- Modified Fields
			,[Changes].intItemLocationId_New  
			,[Changes].strPromotionType_New 
			,[Changes].dtmBeginDate_New 
			,[Changes].dtmEndDate_New 
			,[Changes].intItemUnitMeasureId_New 
			,[Changes].dblUnit_New  
			,[Changes].strDiscountBy_New 
			,[Changes].dblDiscount_New 
			,[Changes].dblUnitAfterDiscount_New 
			,[Changes].dblDiscountThruQty_New	 
			,[Changes].dblDiscountThruAmount_New 
			,[Changes].dblAccumulatedQty_New 
			,[Changes].dblAccumulatedAmount_New 
			,[Changes].dblCost_New 
			,[Changes].intCurrencyId_New  	
			,[Changes].intSort_New   	
			,[Changes].dtmDateCreated_New	 
			,[Changes].dtmDateModified_New 
			,[Changes].intCreatedByUserId_New   
			,[Changes].intModifiedByUserId_New  
	FROM	(
				-- Merge will help us build the audit log and update the records at the same time. 
				MERGE	
					INTO	dbo.tblICItemSpecialPricing  
					WITH	(HOLDLOCK) 
					AS		specialpricing	
					USING (
						SELECT	
							intItemId	
							,intItemLocationId	= @intItemLocationToUpdateId
							,strPromotionType	
							,dtmBeginDate	
							,dtmEndDate
							,intItemUnitMeasureId
							,dblUnit	
							,strDiscountBy
							,dblDiscount	
							,dblUnitAfterDiscount
							,dblDiscountThruQty	
							,dblDiscountThruAmount
							,dblAccumulatedQty
							,dblAccumulatedAmount
							,dblCost
							,intCurrencyId	
							,intSort	
							,dtmDateCreated	
							,dtmDateModified
							,intCreatedByUserId
							,intModifiedByUserId	
						FROM	tblICItemSpecialPricing 
						WHERE intItemSpecialPricingId = @intItemSpecialPricingId
					) AS Source_Query  
						ON specialpricing.intItemLocationId = Source_Query.intItemLocationId
						AND specialpricing.intItemId = Source_Query.intItemId
						AND specialpricing.dtmBeginDate = Source_Query.dtmBeginDate
						AND specialpricing.dtmEndDate = Source_Query.dtmEndDate
						AND specialpricing.intItemUnitMeasureId = Source_Query.intItemUnitMeasureId
					
					-- If matched, update the Standard Cost and Retail Price. 
					WHEN MATCHED THEN 
						UPDATE 
						SET		
							strPromotionType		  = Source_Query.strPromotionType	
							, dtmBeginDate			  =	Source_Query.dtmBeginDate			
							, dtmEndDate			  =	Source_Query.dtmEndDate			
							, intItemUnitMeasureId	  =	Source_Query.intItemUnitMeasureId	
							, dblUnit				  =	Source_Query.dblUnit				
							, strDiscountBy			  =	Source_Query.strDiscountBy			
							, dblDiscount			  =	Source_Query.dblDiscount			
							, dblUnitAfterDiscount	  =	Source_Query.dblUnitAfterDiscount	
							, dblDiscountThruQty	  =	Source_Query.dblDiscountThruQty	
							, dblDiscountThruAmount	  =	Source_Query.dblDiscountThruAmount	
							, dblAccumulatedQty		  =	Source_Query.dblAccumulatedQty		
							, dblAccumulatedAmount	  =	Source_Query.dblAccumulatedAmount	
							, dblCost				  =	Source_Query.dblCost				
							, intCurrencyId			  =	Source_Query.intCurrencyId			
							, intSort				  =	Source_Query.intSort	
							, dtmDateModified		  =	GETDATE()
							, intModifiedByUserId	  = @intEntityUserSecurityId
							
					WHEN NOT MATCHED 
						-- https://stackoverflow.com/questions/325933/determine-whether-two-date-ranges-overlap
						-- This will validate if the date range to insert does not overlap on the existing promotions
						AND (1 NOT IN  (SELECT 1 FROM tblICItemSpecialPricing 
									WHERE intItemLocationId = Source_Query.intItemLocationId
									AND intItemId = Source_Query.intItemId
									AND intItemUnitMeasureId = Source_Query.intItemUnitMeasureId
									AND Source_Query.dtmBeginDate <= dtmEndDate)) 
						AND (1 NOT IN  (SELECT 1 FROM tblICItemSpecialPricing 
									WHERE intItemLocationId = Source_Query.intItemLocationId
									AND intItemId = Source_Query.intItemId
									AND intItemUnitMeasureId = Source_Query.intItemUnitMeasureId
									AND Source_Query.dtmEndDate <= dtmBeginDate)) 
						THEN 
						INSERT (
								intItemId
								, intItemLocationId
								, strPromotionType		
								, dtmBeginDate			
								, dtmEndDate				
								, intItemUnitMeasureId	
								, dblUnit				
								, strDiscountBy			
								, dblDiscount			 
								, dblUnitAfterDiscount	
								, dblDiscountThruQty	
								, dblDiscountThruAmount	
								, dblAccumulatedQty		
								, dblAccumulatedAmount	
								, dblCost				
								, intCurrencyId			
								, intSort				 
								, dtmDateCreated		
								, dtmDateModified		
								, intCreatedByUserId	
								, intModifiedByUserId	
							)
							VALUES
							(
								intItemId
								, intItemLocationId
								, strPromotionType		
								, dtmBeginDate			
								, dtmEndDate				
								, intItemUnitMeasureId	
								, dblUnit				
								, strDiscountBy			
								, dblDiscount			 
								, dblUnitAfterDiscount	
								, dblDiscountThruQty	
								, dblDiscountThruAmount	
								, dblAccumulatedQty		
								, dblAccumulatedAmount	
								, dblCost				
								, intCurrencyId			
								, intSort				 
								, GETDATE()		
								, NULL		
								, @intEntityUserSecurityId	
								, NULL
							)
					OUTPUT 
						inserted.intItemId
						, inserted.intItemLocationId
						, inserted.strPromotionType	
						, inserted.dtmBeginDate	
						, inserted.dtmEndDate
						, inserted.intItemUnitMeasureId
						, inserted.dblUnit	
						, inserted.strDiscountBy
						, inserted.dblDiscount	
						, inserted.dblUnitAfterDiscount
						, inserted.dblDiscountThruQty	
						, inserted.dblDiscountThruAmount
						, inserted.dblAccumulatedQty
						, inserted.dblAccumulatedAmount
						, inserted.dblCost
						, inserted.intCurrencyId	
						, inserted.intSort	
						, inserted.dtmDateCreated	
						, inserted.dtmDateModified
						, inserted.intCreatedByUserId
						, inserted.intModifiedByUserId	
						
						, deleted.intItemLocationId
						, deleted.strPromotionType	
						, deleted.dtmBeginDate	
						, deleted.dtmEndDate
						, deleted.intItemUnitMeasureId
						, deleted.dblUnit	
						, deleted.strDiscountBy
						, deleted.dblDiscount	
						, deleted.dblUnitAfterDiscount
						, deleted.dblDiscountThruQty	
						, deleted.dblDiscountThruAmount
						, deleted.dblAccumulatedQty
						, deleted.dblAccumulatedAmount
						, deleted.dblCost
						, deleted.intCurrencyId	
						, deleted.intSort	
						, deleted.dtmDateCreated	
						, deleted.dtmDateModified
						, deleted.intCreatedByUserId
						, deleted.intModifiedByUserId	
			) AS [Changes] (
				intItemId
				,intItemLocationId_Original  
				,strPromotionType_Original 
				,dtmBeginDate_Original 
				,dtmEndDate_Original 
				,intItemUnitMeasureId_Original 
				,dblUnit_Original 
				,strDiscountBy_Original 
				,dblDiscount_Original 
				,dblUnitAfterDiscount_Original 
				,dblDiscountThruQty_Original	 
				,dblDiscountThruAmount_Original 
				,dblAccumulatedQty_Original 
				,dblAccumulatedAmount_Original 
				,dblCost_Original 
				,intCurrencyId_Original   	
				,intSort_Original   	
				,dtmDateCreated_Original	 
				,dtmDateModified_Original 
				,intCreatedByUserId_Original  
				,intModifiedByUserId_Original 
				
				,intItemLocationId_New  
				,strPromotionType_New 
				,dtmBeginDate_New 
				,dtmEndDate_New 
				,intItemUnitMeasureId_New 
				,dblUnit_New  
				,strDiscountBy_New 
				,dblDiscount_New 
				,dblUnitAfterDiscount_New 
				,dblDiscountThruQty_New	 
				,dblDiscountThruAmount_New 
				,dblAccumulatedQty_New 
				,dblAccumulatedAmount_New 
				,dblCost_New 
				,intCurrencyId_New  	
				,intSort_New   	
				,dtmDateCreated_New	 
				,dtmDateModified_New 
				,intCreatedByUserId_New   
				,intModifiedByUserId_New  
			)
	;
END


IF EXISTS (SELECT TOP 1 1 FROM #tmpMassAddPromotionForCStore_itemLocationAuditLog)
BEGIN 
	DECLARE @strLocationFrom AS VARCHAR(100) = (SELECT TOP 1 strLocationName FROM tblSMCompanyLocation cl 
																		INNER JOIN tblICItemLocation il
																		ON cl.intCompanyLocationId = il.intLocationId
																		INNER JOIN tblICItemSpecialPricing sp
																		ON il.intItemLocationId = sp.intItemLocationId
																		WHERE sp.intItemSpecialPricingId = @intItemSpecialPricingId)
	DECLARE @strLocationTo   AS VARCHAR(100) =  (SELECT TOP 1 strLocationName FROM tblSMCompanyLocation cl 
																		INNER JOIN tblICItemLocation il
																		ON cl.intCompanyLocationId = il.intLocationId
																		WHERE il.intItemLocationId = @intItemLocationToUpdateId)
																		
	DECLARE @auditLog_actionType AS NVARCHAR(50) = 'Updated'
			,@auditLog_intItemId INT = (SELECT TOP 1 intItemId FROM #tmpMassAddPromotionForCStore_itemLocationAuditLog)
	
	IF ISNULL(@strLocationFrom, '') <> ISNULL(@strLocationTo, '')
	BEGIN 
		EXEC dbo.uspSMAuditLog 
			@keyValue = @auditLog_intItemId
			,@screenName = 'Store.view.InventoryMassMaintenance'
			,@entityId = @intEntityUserSecurityId
			,@actionType = @auditLog_actionType
			,@changeDescription = 'C-Store Executes Mass Add of Promotion'
			,@fromValue = @strLocationFrom
			,@toValue = @strLocationTo
	END

END