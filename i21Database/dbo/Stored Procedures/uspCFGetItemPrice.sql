﻿CREATE PROCEDURE [dbo].[uspCFGetItemPrice]    

 @CFItemId				INT    
,@CFCustomerId			INT     
,@CFLocationId			INT    
,@CFItemUOMId			INT				= NULL    
,@CFTransactionDate		DATETIME		= NULL    
,@CFQuantity			NUMERIC(18,6)    
,@CFPriceOut			NUMERIC(18,6)	= NULL OUTPUT    
,@CFPricingOut			NVARCHAR(250)	= NULL OUTPUT    
,@CFStandardPrice		NUMERIC(18,6)	= 0.0
,@CFTransactionType		NVARCHAR(MAX)
,@CFNetworkId			INT
,@CFSiteId				INT
,@CFPriceBasis			NVARCHAR(250)	= NULL OUTPUT  
,@CFContractHeaderId	INT				= NULL OUTPUT
,@CFContractDetailId	INT				= NULL OUTPUT
,@CFContractNumber		INT				= NULL OUTPUT
,@CFContractSeq			INT				= NULL OUTPUT
,@CFAvailableQuantity	NUMERIC(18,6)   = NULL OUTPUT 
,@CFTransferCost		NUMERIC(18,6)   = NULL
,@CFOriginalPrice		NUMERIC(18,6)   = NULL OUTPUT

AS

---***DEBUG PARAM***---

 --DECLARE      
 --@CFItemId    INT    
 -- ,@CFCustomerId  INT     
 -- ,@CFLocationId  INT    
 -- ,@CFItemUOMId   INT    
 -- ,@CFTransactionDate DATETIME    
 -- ,@CFQuantity   NUMERIC(18,6)    
 -- ,@CFCustomerPricing NVARCHAR(250)    
 --SET @CFItemId = 5347    
 --SET @CFCustomerId = 457    
 --SET @CFLocationId = 1    
 --SET @CFItemUOMId = 793    
 --SET @CFTransactionDate = '03/22/2015'    
 --SET @CFQuantity = 6    
 --DECLARE @CFPriceOut AS NUMERIC(18,6)    
 --  ,@CFPricingOut AS NVARCHAR(250)   
 --SET @CFPriceOut = NULL;    
 --SET @CFPricingOut = '';

---***DEBUG PARAM***---
---***SPECIAL PRICING***---

--1. Customer Special Pricing ,
--2. Item Special Pricing, 
--3. Pricing Level, 
--4. Standard Pricing

EXEC [uspARGetItemPrice] 
 @ItemUOMId = @CFItemUOMId
,@TransactionDate = @CFTransactionDate
,@ItemId = @CFItemId    
,@CustomerId = @CFCustomerId    
,@LocationId = @CFLocationId    
,@Quantity = @CFQuantity    
,@Price = @CFPriceOut OUTPUT  
,@Pricing = @CFPricingOut OUTPUT
,@ContractHeaderId = @CFContractHeaderId OUTPUT
,@ContractDetailId = @CFContractDetailId OUTPUT
,@ContractNumber = @CFContractNumber OUTPUT
,@ContractSeq = @CFContractSeq OUTPUT  
,@AvailableQuantity = @CFAvailableQuantity OUTPUT

print @CFPriceOut 

print  @CFPricingOut

IF(@CFPriceOut IS NOT NULL) 

   BEGIN    

	IF(@CFPricingOut = 'Inventory - Standard Pricing')

		BEGIN 

			SET @CFStandardPrice = @CFPriceOut  

		END

	ELSE

		BEGIN 

			SET @CFPricingOut = @CFPricingOut

			RETURN 1

		END

   END    

---***SPECIAL PRICING***---

   

---***PRICE PROFILE***---

--SITE ITEMS WHERE @CFNETWORKID AND @CFSiteId AND @CFItem

DECLARE @cfSiteItem TABLE 

(

	intSiteId			INT,

	intNetworkId		INT,

	strSiteNumber		NVARCHAR(MAX),

	intARLocationId		INT,

	intCardId			INT,

	strTaxState			NVARCHAR(MAX),

	strAuthorityId1		NVARCHAR(MAX),

	strAuthorityId2		NVARCHAR(MAX),

	strSiteName			NVARCHAR(MAX),

	strSiteType			NVARCHAR(MAX),

	intItemId			INT,

	strProductNumber	NVARCHAR(MAX),

	intARItemId			INT

)

INSERT INTO @cfSiteItem 

(

	intSiteId,		

	intNetworkId,	

	strSiteNumber,	

	intARLocationId,

	intCardId,		

	strTaxState,	

	strAuthorityId1,

	strAuthorityId2,

	strSiteName,

	strSiteType,

	intItemId,

	strProductNumber,

	intARItemId

)		

SELECT 

	cfSite.intSiteId,		

	cfSite.intNetworkId,	

	strSiteNumber,	

	intARLocationId,

	intCardId,		

	strTaxState,	

	strAuthorityId1,

	strAuthorityId2,

	strSiteName,

	strSiteType,

	intItemId,

	strProductNumber,

	intARItemId

FROM tblCFSite cfSite

INNER JOIN tblCFItem cfItem

on cfSite.intSiteId = cfItem.intSiteId

WHERE

	cfSite.intNetworkId = @CFNetworkId AND

	cfSite.intSiteId = @CFSiteId AND

	intARItemId = @CFItemId



--PRICE PROFILE WHERE @CFNETWORKID AND @CFSiteId

DECLARE @cfPriceProfile TABLE 

(

	intAccountId			INT,

	intCustomerId			INT,

	intDiscountDays			INT,

	intDiscountScheduleId	INT,

	intSalesPersonId		INT,

	intPriceProfileDetailId	INT,

	intPriceProfileHeaderId	INT,

	intItemId				INT,

	intNetworkId			INT,

	intSiteGroupId			INT,

	intSiteId				INT,

	intLocalPricingIndex	INT,

	dblRate					NUMERIC(18,6),

	strBasis				NVARCHAR(MAX),

	strType					NVARCHAR(MAX)

)



IF(@CFTransactionType = 'Local/Network')

	BEGIN

		INSERT INTO @cfPriceProfile 

	(

		intAccountId,			

		intCustomerId,			

		intDiscountDays,			

		intDiscountScheduleId,	

		intSalesPersonId,		

		intPriceProfileDetailId,	

		intPriceProfileHeaderId,	

		intItemId,				

		intNetworkId,			

		intSiteGroupId,			

		intSiteId,				

		intLocalPricingIndex,	

		dblRate,					

		strBasis,				

		strType					

	)		

	SELECT 

		intAccountId,			

		intCustomerId,			

		intDiscountDays,			

		intDiscountScheduleId,	

		intSalesPersonId,		

		cfPProfileDetail.intPriceProfileDetailId,	

		cfPProfileHeader.intPriceProfileHeaderId,	

		intItemId,				

		intNetworkId,			

		intSiteGroupId,			

		intSiteId,				

		intLocalPricingIndex,	

		dblRate,					

		strBasis,				

		strType		

	FROM tblCFAccount cfAccount

	INNER JOIN tblCFPriceProfileHeader cfPProfileHeader

	ON cfAccount.intLocalPriceProfileId = cfPProfileHeader.intPriceProfileHeaderId

	INNER JOIN tblCFPriceProfileDetail cfPProfileDetail

	ON cfPProfileHeader.intPriceProfileHeaderId = cfPProfileDetail.intPriceProfileHeaderId

	WHERE 

		cfAccount.intCustomerId = @CFCustomerId AND 

		cfPProfileHeader.strType = @CFTransactionType

	END

ELSE IF (@CFTransactionType = 'Remote')

	

	BEGIN

		INSERT INTO @cfPriceProfile 

	(

		intAccountId,			

		intCustomerId,			

		intDiscountDays,			

		intDiscountScheduleId,	

		intSalesPersonId,		

		intPriceProfileDetailId,	

		intPriceProfileHeaderId,	

		intItemId,				

		intNetworkId,			

		intSiteGroupId,			

		intSiteId,				

		intLocalPricingIndex,	

		dblRate,					

		strBasis,				

		strType					

	)		

	SELECT 

		intAccountId,			

		intCustomerId,			

		intDiscountDays,			

		intDiscountScheduleId,	

		intSalesPersonId,		

		cfPProfileDetail.intPriceProfileDetailId,	

		cfPProfileHeader.intPriceProfileHeaderId,	

		intItemId,				

		intNetworkId,			

		intSiteGroupId,			

		intSiteId,				

		intLocalPricingIndex,	

		dblRate,					

		strBasis,				

		strType		

	FROM tblCFAccount cfAccount

	INNER JOIN tblCFPriceProfileHeader cfPProfileHeader

	ON cfAccount.intRemotePriceProfileId = cfPProfileHeader.intPriceProfileHeaderId

	INNER JOIN tblCFPriceProfileDetail cfPProfileDetail

	ON cfPProfileHeader.intPriceProfileHeaderId = cfPProfileDetail.intPriceProfileHeaderId

	WHERE 

		cfAccount.intCustomerId = @CFCustomerId AND 

		cfPProfileHeader.strType = @CFTransactionType

	END

ELSE IF (@CFTransactionType = 'Extended Remote')

	BEGIN

		INSERT INTO @cfPriceProfile 

	(

		intAccountId,			

		intCustomerId,			

		intDiscountDays,			

		intDiscountScheduleId,	

		intSalesPersonId,		

		intPriceProfileDetailId,	

		intPriceProfileHeaderId,	

		intItemId,				

		intNetworkId,			

		intSiteGroupId,			

		intSiteId,				

		intLocalPricingIndex,	

		dblRate,					

		strBasis,				

		strType					

	)		

	SELECT 

		intAccountId,			

		intCustomerId,			

		intDiscountDays,			

		intDiscountScheduleId,	

		intSalesPersonId,		

		cfPProfileDetail.intPriceProfileDetailId,	

		cfPProfileHeader.intPriceProfileHeaderId,	

		intItemId,				

		intNetworkId,			

		intSiteGroupId,			

		intSiteId,				

		intLocalPricingIndex,	

		dblRate,					

		strBasis,				

		strType		

	FROM tblCFAccount cfAccount

	INNER JOIN tblCFPriceProfileHeader cfPProfileHeader

	ON cfAccount.intExtRemotePriceProfileId = cfPProfileHeader.intPriceProfileHeaderId

	INNER JOIN tblCFPriceProfileDetail cfPProfileDetail

	ON cfPProfileHeader.intPriceProfileHeaderId = cfPProfileDetail.intPriceProfileHeaderId

	WHERE 

		cfAccount.intCustomerId = @CFCustomerId AND 

		cfPProfileHeader.strType = @CFTransactionType

	END

	BEGIN

		INSERT INTO @cfPriceProfile 

	(

		intAccountId,			

		intCustomerId,			

		intDiscountDays,			

		intDiscountScheduleId,	

		intSalesPersonId,		

		intPriceProfileDetailId,	

		intPriceProfileHeaderId,	

		intItemId,				

		intNetworkId,			

		intSiteGroupId,			

		intSiteId,				

		intLocalPricingIndex,	

		dblRate,					

		strBasis,				

		strType					

	)		

	SELECT 

		intAccountId,			

		intCustomerId,			

		intDiscountDays,			

		intDiscountScheduleId,	

		intSalesPersonId,		

		cfPProfileDetail.intPriceProfileDetailId,	

		cfPProfileHeader.intPriceProfileHeaderId,	

		intItemId,				

		intNetworkId,			

		intSiteGroupId,			

		intSiteId,				

		intLocalPricingIndex,	

		dblRate,					

		strBasis,				

		strType		

	FROM tblCFAccount cfAccount

	INNER JOIN tblCFPriceProfileHeader cfPProfileHeader

	ON cfAccount.intExtRemotePriceProfileId = cfPProfileHeader.intPriceProfileHeaderId

	INNER JOIN tblCFPriceProfileDetail cfPProfileDetail

	ON cfPProfileHeader.intPriceProfileHeaderId = cfPProfileDetail.intPriceProfileHeaderId

	WHERE 

		cfAccount.intCustomerId = @CFCustomerId AND 

		cfPProfileHeader.strType = @CFTransactionType

	END



DECLARE @ValidSiteItem INT

SET @ValidSiteItem = (SELECT TOP 1 intARItemId FROM @cfSiteItem)



IF(@ValidSiteItem IS NOT NULL) 

BEGIN

	DECLARE @Rate NUMERIC(18,6)
	DECLARE @SiteGroupId INT
	DECLARE @PriceIndexId INT
	DECLARE @TransactionSiteGroup INT
	DECLARE @cfMatchProfileSkip INT
	DECLARE @cfMatchProfileCount INT
	DECLARE @cfMatchPriceProfile TABLE 
	(

		intAccountId			INT,

		intCustomerId			INT,

		intDiscountDays			INT,

		intDiscountScheduleId	INT,

		intSalesPersonId		INT,

		intPriceProfileDetailId	INT,

		intPriceProfileHeaderId	INT,

		intItemId				INT,

		intNetworkId			INT,

		intSiteGroupId			INT,

		intSiteId				INT,

		intLocalPricingIndex	INT,

		dblRate					NUMERIC(18,6),

		strBasis				NVARCHAR(MAX),

		strType					NVARCHAR(MAX)

	)
	SET @TransactionSiteGroup = (SELECT TOP 1 intAdjustmentSiteGroupId FROM tblCFSite WHERE intSiteId = @CFSiteId);
	SET @cfMatchProfileCount = 0
	SET @cfMatchProfileSkip = 0

	----------------------------------------------
	--   SITE | SITE GROUP | PRODUCT | NETWORK  --
	----------------------------------------------
	--   1    |		N/A    |	1	 |     1    --
	----------------------------------------------
	IF (@cfMatchProfileCount = 0 AND @cfMatchProfileSkip = 0)
		BEGIN
			SELECT @cfMatchProfileCount = Count(*) 
			FROM @cfPriceProfile 
			WHERE intSiteId = @CFSiteId
			AND intItemId = @CFItemId
			AND intNetworkId = @CFNetworkId
		END
	IF (@cfMatchProfileCount != 0 AND @cfMatchProfileSkip = 0)
		BEGIN
			print '1-n/a-1-1'
			SET @cfMatchProfileSkip = 1
			INSERT INTO @cfMatchPriceProfile 
			(
				intAccountId,			
				intCustomerId,			
				intDiscountDays,			
				intDiscountScheduleId,	
				intSalesPersonId,		
				intPriceProfileDetailId,	
				intPriceProfileHeaderId,	
				intItemId,				
				intNetworkId,			
				intSiteGroupId,			
				intSiteId,				
				intLocalPricingIndex,	
				dblRate,					
				strBasis,				
				strType					
			)
			SELECT TOP 1
				intAccountId,			
				intCustomerId,			
				intDiscountDays,			
				intDiscountScheduleId,	
				intSalesPersonId,		
				intPriceProfileDetailId,	
				intPriceProfileHeaderId,	
				intItemId,				
				intNetworkId,			
				intSiteGroupId,			
				intSiteId,				
				intLocalPricingIndex,	
				dblRate,					
				strBasis,				
				strType		
			FROM @cfPriceProfile 
			WHERE intSiteId = @CFSiteId
			AND intItemId = @CFItemId
			AND intNetworkId = @CFNetworkId 
		END
	----------------------------------------------

	----------------------------------------------
	--   SITE | SITE GROUP | PRODUCT | NETWORK  --
	----------------------------------------------
	--   1    |		N/A    |   ALL	 |     1    --
	----------------------------------------------
	IF (@cfMatchProfileCount = 0 AND @cfMatchProfileSkip = 0)
		BEGIN
			SELECT @cfMatchProfileCount = Count(*) 
			FROM @cfPriceProfile 
			WHERE intSiteId = @CFSiteId
			AND intNetworkId = @CFNetworkId
		END
	IF (@cfMatchProfileCount != 0 AND @cfMatchProfileSkip = 0)
		BEGIN
			print '1-n/a-all-1'
			SET @cfMatchProfileSkip = 1
			INSERT INTO @cfMatchPriceProfile 
			(
				intAccountId,			
				intCustomerId,			
				intDiscountDays,			
				intDiscountScheduleId,	
				intSalesPersonId,		
				intPriceProfileDetailId,	
				intPriceProfileHeaderId,	
				intItemId,				
				intNetworkId,			
				intSiteGroupId,			
				intSiteId,				
				intLocalPricingIndex,	
				dblRate,					
				strBasis,				
				strType					
			)
			SELECT TOP 1
				intAccountId,			
				intCustomerId,			
				intDiscountDays,			
				intDiscountScheduleId,	
				intSalesPersonId,		
				intPriceProfileDetailId,	
				intPriceProfileHeaderId,	
				intItemId,				
				intNetworkId,			
				intSiteGroupId,			
				intSiteId,				
				intLocalPricingIndex,	
				dblRate,					
				strBasis,				
				strType		
			FROM @cfPriceProfile 
			WHERE intSiteId = @CFSiteId
			AND intNetworkId = @CFNetworkId 
		END
	----------------------------------------------

	----------------------------------------------
	--   SITE | SITE GROUP | PRODUCT | NETWORK  --
	----------------------------------------------
	--   N/A  |		 1     |    1	 |    N/A   --
	----------------------------------------------
	IF (@cfMatchProfileCount = 0 AND @cfMatchProfileSkip = 0)
		BEGIN
			SELECT @cfMatchProfileCount = Count(*) 
			FROM @cfPriceProfile 
			WHERE intSiteGroupId = @TransactionSiteGroup
			AND intItemId = @CFItemId
		END
	IF (@cfMatchProfileCount != 0 AND @cfMatchProfileSkip = 0)
		BEGIN
			print 'n/a-1-1-n/a'
			SET @cfMatchProfileSkip = 1
			INSERT INTO @cfMatchPriceProfile 
			(
				intAccountId,			
				intCustomerId,			
				intDiscountDays,			
				intDiscountScheduleId,	
				intSalesPersonId,		
				intPriceProfileDetailId,	
				intPriceProfileHeaderId,	
				intItemId,				
				intNetworkId,			
				intSiteGroupId,			
				intSiteId,				
				intLocalPricingIndex,	
				dblRate,					
				strBasis,				
				strType					
			)
			SELECT TOP 1
				intAccountId,			
				intCustomerId,			
				intDiscountDays,			
				intDiscountScheduleId,	
				intSalesPersonId,		
				intPriceProfileDetailId,	
				intPriceProfileHeaderId,	
				intItemId,				
				intNetworkId,			
				intSiteGroupId,			
				intSiteId,				
				intLocalPricingIndex,	
				dblRate,					
				strBasis,				
				strType		
			FROM @cfPriceProfile 
			WHERE intSiteGroupId = @TransactionSiteGroup
			AND intItemId = @CFItemId
		END
	----------------------------------------------

	----------------------------------------------
	--   SITE | SITE GROUP | PRODUCT | NETWORK  --
	----------------------------------------------
	--   N/A  |		 1     |   ALL	 |    N/A   --
	----------------------------------------------
	IF (@cfMatchProfileCount = 0 AND @cfMatchProfileSkip = 0)
		BEGIN
			SELECT @cfMatchProfileCount = Count(*) 
			FROM @cfPriceProfile 
			WHERE intSiteGroupId = @TransactionSiteGroup
		END
	IF (@cfMatchProfileCount != 0 AND @cfMatchProfileSkip = 0)
		BEGIN
			print 'n/a-1-all-n/a'
			SET @cfMatchProfileSkip = 1
			INSERT INTO @cfMatchPriceProfile 
			(
				intAccountId,			
				intCustomerId,			
				intDiscountDays,			
				intDiscountScheduleId,	
				intSalesPersonId,		
				intPriceProfileDetailId,	
				intPriceProfileHeaderId,	
				intItemId,				
				intNetworkId,			
				intSiteGroupId,			
				intSiteId,				
				intLocalPricingIndex,	
				dblRate,					
				strBasis,				
				strType					
			)
			SELECT TOP 1
				intAccountId,			
				intCustomerId,			
				intDiscountDays,			
				intDiscountScheduleId,	
				intSalesPersonId,		
				intPriceProfileDetailId,	
				intPriceProfileHeaderId,	
				intItemId,				
				intNetworkId,			
				intSiteGroupId,			
				intSiteId,				
				intLocalPricingIndex,	
				dblRate,					
				strBasis,				
				strType		
			FROM @cfPriceProfile 
			WHERE intSiteGroupId = @TransactionSiteGroup
		END
	----------------------------------------------

	----------------------------------------------
	--   SITE | SITE GROUP | PRODUCT | NETWORK  --
	----------------------------------------------
	--   N/A  |	   N/A     |    1	 |     1    --
	----------------------------------------------
	IF (@cfMatchProfileCount = 0 AND @cfMatchProfileSkip = 0)
		BEGIN
			SELECT @cfMatchProfileCount = Count(*) 
			FROM @cfPriceProfile 
			WHERE intItemId = @CFItemId
			AND intNetworkId = @CFNetworkId
		END
	IF (@cfMatchProfileCount != 0 AND @cfMatchProfileSkip = 0)
		BEGIN
			print 'n/a-n/a-1-1'
			SET @cfMatchProfileSkip = 1
			INSERT INTO @cfMatchPriceProfile 
			(
				intAccountId,			
				intCustomerId,			
				intDiscountDays,			
				intDiscountScheduleId,	
				intSalesPersonId,		
				intPriceProfileDetailId,	
				intPriceProfileHeaderId,	
				intItemId,				
				intNetworkId,			
				intSiteGroupId,			
				intSiteId,				
				intLocalPricingIndex,	
				dblRate,					
				strBasis,				
				strType					
			)
			SELECT TOP 1
				intAccountId,			
				intCustomerId,			
				intDiscountDays,			
				intDiscountScheduleId,	
				intSalesPersonId,		
				intPriceProfileDetailId,	
				intPriceProfileHeaderId,	
				intItemId,				
				intNetworkId,			
				intSiteGroupId,			
				intSiteId,				
				intLocalPricingIndex,	
				dblRate,					
				strBasis,				
				strType		
			FROM @cfPriceProfile 
			WHERE intItemId = @CFItemId
			AND intNetworkId = @CFNetworkId
		END
	----------------------------------------------

	----------------------------------------------
	--   SITE | SITE GROUP | PRODUCT | NETWORK  --
	----------------------------------------------
	--   N/A  |	   N/A     |    1	 |    N/A   --
	----------------------------------------------
	IF (@cfMatchProfileCount = 0 AND @cfMatchProfileSkip = 0)
		BEGIN
			SELECT @cfMatchProfileCount = Count(*) 
			FROM @cfPriceProfile 
			WHERE intItemId = @CFItemId
		END
	IF (@cfMatchProfileCount != 0 AND @cfMatchProfileSkip = 0)
		BEGIN
			print 'n/a-n/a-1-n/a'
			SET @cfMatchProfileSkip = 1
			INSERT INTO @cfMatchPriceProfile 
			(
				intAccountId,			
				intCustomerId,			
				intDiscountDays,			
				intDiscountScheduleId,	
				intSalesPersonId,		
				intPriceProfileDetailId,	
				intPriceProfileHeaderId,	
				intItemId,				
				intNetworkId,			
				intSiteGroupId,			
				intSiteId,				
				intLocalPricingIndex,	
				dblRate,					
				strBasis,				
				strType					
			)
			SELECT TOP 1
				intAccountId,			
				intCustomerId,			
				intDiscountDays,			
				intDiscountScheduleId,	
				intSalesPersonId,		
				intPriceProfileDetailId,	
				intPriceProfileHeaderId,	
				intItemId,				
				intNetworkId,			
				intSiteGroupId,			
				intSiteId,				
				intLocalPricingIndex,	
				dblRate,					
				strBasis,				
				strType		
			FROM @cfPriceProfile 
			WHERE intItemId = @CFItemId
		END
	----------------------------------------------

	----------------------------------------------
	--   SITE | SITE GROUP | PRODUCT | NETWORK  --
	----------------------------------------------
	--   N/A  |	   N/A     |   ALL	 |    N/A   --
	----------------------------------------------
	IF (@cfMatchProfileCount = 0 AND @cfMatchProfileSkip = 0)
		BEGIN
			SELECT @cfMatchProfileCount = Count(*) 
			FROM @cfPriceProfile 
		END
	IF (@cfMatchProfileCount != 0 AND @cfMatchProfileSkip = 0)
		BEGIN
			print 'n/a-n/a-all-n/a'
			SET @cfMatchProfileSkip = 1
			INSERT INTO @cfMatchPriceProfile 
			(
				intAccountId,			
				intCustomerId,			
				intDiscountDays,			
				intDiscountScheduleId,	
				intSalesPersonId,		
				intPriceProfileDetailId,	
				intPriceProfileHeaderId,	
				intItemId,				
				intNetworkId,			
				intSiteGroupId,			
				intSiteId,				
				intLocalPricingIndex,	
				dblRate,					
				strBasis,				
				strType					
			)
			SELECT TOP 1
				intAccountId,			
				intCustomerId,			
				intDiscountDays,			
				intDiscountScheduleId,	
				intSalesPersonId,		
				intPriceProfileDetailId,	
				intPriceProfileHeaderId,	
				intItemId,				
				intNetworkId,			
				intSiteGroupId,			
				intSiteId,				
				intLocalPricingIndex,	
				dblRate,					
				strBasis,				
				strType		
			FROM @cfPriceProfile 
		END
	----------------------------------------------


	
	-------------------------------
	-- Price Profile Computation --
	-------------------------------
	

	
	SET @CFPricingOut = 'Price Profile' 
	SET @CFOriginalPrice = @CFStandardPrice
	SET @Rate = (SELECT TOP 1 dblRate FROM @cfMatchPriceProfile) 
	print 'rate'
	print @Rate
	SET @CFPriceBasis = (SELECT TOP 1 strBasis FROM @cfMatchPriceProfile)
	
	IF(@CFTransactionType = 'Local/Network')
	BEGIN 
		IF(@CFPriceBasis = 'Pump Price Adjustment')
			BEGIN
				SET @CFPriceOut = @CFOriginalPrice + @Rate
				RETURN 1;    
			END
		ELSE
			BEGIN 
				SET @SiteGroupId = (SELECT TOP 1 intSiteGroupId 
									FROM @cfMatchPriceProfile 
									WHERE intCustomerId = @CFCustomerId 
									AND intSiteId = @CFSiteId 
									AND intItemId = @CFItemId) 

				SET @PriceIndexId = (SELECT TOP 1 intLocalPricingIndex 
									 FROM @cfMatchPriceProfile 
									 WHERE intCustomerId = @CFCustomerId 
									 AND intSiteId = @CFSiteId 
									 AND intItemId = @CFItemId) 

				SET @CFOriginalPrice = (SELECT TOP 1 dblIndexPrice
										FROM tblCFIndexPricingBySiteGroupHeader IPH
										INNER JOIN tblCFIndexPricingBySiteGroup IPD
										ON IPH.intIndexPricingBySiteGroupHeaderId = IPD.intIndexPricingBySiteGroupHeaderId
										WHERE IPH.intPriceIndexId = @PriceIndexId 
										AND IPH.intSiteGroupId = @SiteGroupId)

				IF(@CFOriginalPrice IS NOT NULL)
					BEGIN
						SET @CFPriceOut = @CFOriginalPrice + @Rate
						RETURN 1;    
					END
			END
	END
	ELSE IF (@CFTransactionType = 'Remote')
	BEGIN
		IF(@CFPriceBasis = 'Remote Pricing Index')
			BEGIN

				SET @SiteGroupId = (SELECT TOP 1 intSiteGroupId 
									FROM @cfMatchPriceProfile 
									WHERE intCustomerId = @CFCustomerId 
									AND intSiteId = @CFSiteId 
									AND intItemId = @CFItemId) 

				SET @PriceIndexId = (SELECT TOP 1 intLocalPricingIndex 
									 FROM @cfMatchPriceProfile 
									 WHERE intCustomerId = @CFCustomerId 
									 AND intSiteId = @CFSiteId 
									 AND intItemId = @CFItemId) 

				SET @CFOriginalPrice = (SELECT TOP 1 dblIndexPrice
										FROM tblCFIndexPricingBySiteGroupHeader IPH
										INNER JOIN tblCFIndexPricingBySiteGroup IPD
										ON IPH.intIndexPricingBySiteGroupHeaderId = IPD.intIndexPricingBySiteGroupHeaderId
										WHERE IPH.intPriceIndexId = @PriceIndexId 
										AND IPH.intSiteGroupId = @SiteGroupId)

				IF(@CFOriginalPrice IS NOT NULL)
					BEGIN
						SET @CFPriceOut = @CFOriginalPrice + @Rate
						RETURN 1;    
					END
			END
		ELSE IF(@CFPriceBasis = 'Transfer Cost' OR @CFPriceBasis = 'Transfer Price')
			BEGIN
				IF(@CFTransferCost IS NOT NULL)
					BEGIN
						SET @CFPriceOut = @CFTransferCost + @Rate
						RETURN 1;    
					END
			END
	END
	ELSE IF (@CFTransactionType = 'Extended Remote')
	BEGIN
		IF(@CFPriceBasis = 'Discounted Price')
			BEGIN
				IF(@CFTransferCost IS NOT NULL)
					BEGIN
						SET @CFPriceOut = @CFTransferCost + @Rate
						RETURN 1;    
					END
			END
		ELSE
			BEGIN
				SET @SiteGroupId = (SELECT TOP 1 intSiteGroupId 
										FROM @cfMatchPriceProfile 
										WHERE intCustomerId = @CFCustomerId 
										AND intSiteId = @CFSiteId 
										AND intItemId = @CFItemId) 

				SET @PriceIndexId = (SELECT TOP 1 intLocalPricingIndex 
										FROM @cfMatchPriceProfile 
										WHERE intCustomerId = @CFCustomerId 
										AND intSiteId = @CFSiteId 
										AND intItemId = @CFItemId) 

				SET @CFOriginalPrice = (SELECT TOP 1 dblIndexPrice
										FROM tblCFIndexPricingBySiteGroupHeader IPH
										INNER JOIN tblCFIndexPricingBySiteGroup IPD
										ON IPH.intIndexPricingBySiteGroupHeaderId = IPD.intIndexPricingBySiteGroupHeaderId
										WHERE IPH.intPriceIndexId = @PriceIndexId 
										AND IPH.intSiteGroupId = @SiteGroupId)

				IF(@CFOriginalPrice IS NOT NULL)
					BEGIN
						SET @CFPriceOut = @CFOriginalPrice + @Rate
						RETURN 1;    
					END
			END
		
	END
	
END

---***PRICE PROFILE***---



---***ITEM PRICING***---
SET @CFPricingOut = 'Inventory - Standard Pricing' 
SET @CFPriceOut = @CFStandardPrice;

---***ITEM PRICING***---

RETURN 1

GO