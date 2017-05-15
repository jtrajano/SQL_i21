CREATE PROCEDURE [dbo].[uspCFGetItemPrice]    

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
,@CFCreditCard			BIT				= 0
,@CFPostedOrigin		BIT				= 0
,@CFPostedCSV			BIT				= 0
,@CFPriceProfileId		INT				= NULL OUTPUT
,@CFPriceProfileDetailId INT				= NULL OUTPUT
,@CFPriceIndexId		INT				= NULL OUTPUT
,@CFSiteGroupId			INT				= NULL

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

DECLARE @CFItemPricingOnly INT
IF(@CFTransactionType = 'Local/Network')
BEGIN
	SET @CFItemPricingOnly = 0
END
ELSE
BEGIN
	SET @CFItemPricingOnly = 1
END

IF (@CFCreditCard = 1)
BEGIN
	IF (@CFOriginalPrice IS NOT NULL)
	BEGIN
		SET @CFStandardPrice = @CFOriginalPrice
		SET @CFPricingOut = 'Credit Card'
	END
END
ELSE IF(@CFPostedOrigin = 1)
BEGIN
	IF (@CFOriginalPrice IS NOT NULL)
	BEGIN
		SET @CFStandardPrice = @CFOriginalPrice
		SET @CFPricingOut = 'Origin History'
	END
END
ELSE IF(@CFPostedCSV = 1)
BEGIN
	IF (@CFOriginalPrice IS NOT NULL)
	BEGIN
		SET @CFStandardPrice = @CFOriginalPrice
		SET @CFPricingOut = 'Posted Trans from CSV'
	END
END
ELSE IF (@CFTransactionType = 'Foreign Sale')
BEGIN
	IF (@CFOriginalPrice IS NOT NULL)
	BEGIN
		SET @CFPricingOut = 'Network Cost'
		SET @CFStandardPrice = @CFOriginalPrice
	END
END
ELSE
BEGIN

DECLARE @currency INT
EXEC @currency = dbo.fnSMGetDefaultCurrency 'FUNCTIONAL'

EXEC [uspARGetItemPrice] 
 @ItemUOMId = @CFItemUOMId
,@TransactionDate = @CFTransactionDate
,@ItemId = @CFItemId    
,@CustomerId = @CFCustomerId    
,@LocationId = @CFLocationId    
,@Quantity = @CFQuantity    
,@CurrencyId = @currency
,@ItemPricingOnly = @CFItemPricingOnly
,@Price = @CFPriceOut OUTPUT  
,@Pricing = @CFPricingOut OUTPUT
,@ContractHeaderId = @CFContractHeaderId OUTPUT
,@ContractDetailId = @CFContractDetailId OUTPUT
,@ContractNumber = @CFContractNumber OUTPUT
,@ContractSeq = @CFContractSeq OUTPUT  
,@AvailableQuantity = @CFAvailableQuantity OUTPUT
,@AllowQtyToExceedContract = 1

IF(@CFPriceOut IS NOT NULL) 

   BEGIN    

	IF(@CFPricingOut = 'Inventory - Standard Pricing')

	BEGIN 
		IF (@CFOriginalPrice IS NOT NULL AND @CFOriginalPrice > 0)
			BEGIN 
				SET @CFStandardPrice = @CFOriginalPrice  
				SET @CFPricingOut = 'Import File Price'

				IF (@CFCreditCard = 1)
				BEGIN -- ALWAYS USE IMPORT FILE PRICE ON CREDIT CARD TRANSACTION
					SET @CFPriceOut = @CFStandardPrice
					RETURN
				END

					
			END 
		ELSE
			BEGIN
				SET @CFStandardPrice = @CFPriceOut
				SET @CFPricingOut = 'Inventory - Standard Pricing'
			END
	END

	ELSE

	BEGIN 

		SET @CFPricingOut = @CFPricingOut

		RETURN 1

	END

   END    
ELSE
   BEGIN
		IF (@CFOriginalPrice IS NOT NULL AND @CFOriginalPrice > 0)
			BEGIN 
				SET @CFStandardPrice = @CFOriginalPrice  
				SET @CFPricingOut = 'Import File Price'

				IF (@CFCreditCard = 1)
				BEGIN -- ALWAYS USE IMPORT FILE PRICE ON CREDIT CARD TRANSACTION
					SET @CFPriceOut = @CFStandardPrice
					RETURN
				END

					
			END 
		ELSE
			BEGIN
				SET @CFStandardPrice = @CFPriceOut
				SET @CFPricingOut = 'Inventory - Standard Pricing'
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



--DECLARE @ValidSiteItem INT

--SET @ValidSiteItem = (SELECT TOP 1 intARItemId FROM @cfSiteItem)

--IF(@ValidSiteItem IS NOT NULL) 

--BEGIN

	DECLARE @Rate NUMERIC(18,6)
	DECLARE @SiteGroupId INT
	DECLARE @PriceIndexId INT
	DECLARE @ItemId INT
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


	------------------UPDATED---------------------

	----------------------------------------------
	--   SITE | SITE GROUP | PRODUCT | NETWORK  --
	----------------------------------------------
	--   1    |		N/A    |	1	 |   N/A    --
	----------------------------------------------
	IF (@cfMatchProfileCount = 0 AND @cfMatchProfileSkip = 0)
		BEGIN
			SELECT @cfMatchProfileCount = Count(*) 
			FROM @cfPriceProfile 
			WHERE intSiteId = @CFSiteId
			AND intItemId = @CFItemId
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
		END


	----------------------------------------------
	--   SITE | SITE GROUP | PRODUCT | NETWORK  --
	----------------------------------------------
	--   1    |		N/A    |	ALL  |   N/A    --
	----------------------------------------------
	IF (@cfMatchProfileCount = 0 AND @cfMatchProfileSkip = 0)
		BEGIN
			SELECT @cfMatchProfileCount = Count(*) 
			FROM @cfPriceProfile 
			WHERE intSiteId = @CFSiteId 
			AND ISNULL(intItemId,0) = 0 -- ALL ITEMS
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
			AND ISNULL(intItemId,0) = 0 -- ALL ITEMS
		END
	

	----------------------------------------------
	--   SITE | SITE GROUP | PRODUCT | NETWORK  --
	----------------------------------------------
	--   N/A  |		1      |	1	 |   1      --
	----------------------------------------------
	IF (@cfMatchProfileCount = 0 AND @cfMatchProfileSkip = 0)
		BEGIN
			SELECT @cfMatchProfileCount = Count(*) 
			FROM @cfPriceProfile 
			WHERE intItemId = @CFItemId
			AND intSiteGroupId = @CFSiteGroupId
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
			WHERE intItemId = @CFItemId
			AND intSiteGroupId = @CFSiteGroupId
			AND intNetworkId = @CFNetworkId
		END


	----------------------------------------------
	--   SITE | SITE GROUP | PRODUCT | NETWORK  --
	----------------------------------------------
	--   N/A  |		1      |   ALL	 |   1      --
	----------------------------------------------
	IF (@cfMatchProfileCount = 0 AND @cfMatchProfileSkip = 0)
		BEGIN
			SELECT @cfMatchProfileCount = Count(*) 
			FROM @cfPriceProfile 
			WHERE intSiteGroupId = @CFSiteGroupId
			AND intNetworkId = @CFNetworkId
			AND ISNULL(intItemId,0) = 0 -- ALL ITEMS
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
			WHERE intSiteGroupId = @CFSiteGroupId
			AND intNetworkId = @CFNetworkId
			AND ISNULL(intItemId,0) = 0 -- ALL ITEMS
		END


	----------------------------------------------
	--   SITE | SITE GROUP | PRODUCT | NETWORK  --
	----------------------------------------------
	--   N/A  |		1      |   1	 |   ALL    --
	----------------------------------------------
	IF (@cfMatchProfileCount = 0 AND @cfMatchProfileSkip = 0)
		BEGIN
			SELECT @cfMatchProfileCount = Count(*) 
			FROM @cfPriceProfile 
			WHERE intSiteGroupId = @CFSiteGroupId
			AND intItemId = @CFItemId
			AND ISNULL(intNetworkId,0) = 0 -- ALL NETWORKS
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
			WHERE intSiteGroupId = @CFSiteGroupId
			AND intItemId = @CFItemId
			AND ISNULL(intNetworkId,0) = 0 -- ALL NETWORKS
		END


	----------------------------------------------
	--   SITE | SITE GROUP | PRODUCT | NETWORK  --
	----------------------------------------------
	--   N/A  |		1      |   ALL	 |   ALL    --
	----------------------------------------------
	IF (@cfMatchProfileCount = 0 AND @cfMatchProfileSkip = 0)
		BEGIN
			SELECT @cfMatchProfileCount = Count(*) 
			FROM @cfPriceProfile 
			WHERE intSiteGroupId = @CFSiteGroupId
			AND ISNULL(intItemId,0) = 0 -- ALL ITEMS
			AND ISNULL(intNetworkId,0) = 0 -- ALL NETWORKS
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
			WHERE intSiteGroupId = @CFSiteGroupId
			AND ISNULL(intItemId,0) = 0 -- ALL ITEMS
			AND ISNULL(intNetworkId,0) = 0 -- ALL NETWORKS

		END

		
	----------------------------------------------
	--   SITE | SITE GROUP | PRODUCT | NETWORK  --
	----------------------------------------------
	--   ALL  |		ALL    |   1	 |   1      --
	----------------------------------------------
	IF (@cfMatchProfileCount = 0 AND @cfMatchProfileSkip = 0)
		BEGIN
			SELECT @cfMatchProfileCount = Count(*) 
			FROM @cfPriceProfile 
			WHERE intItemId = @CFItemId
			AND intNetworkId = @CFNetworkId
			AND ISNULL(intSiteId,0) = 0 -- ALL SITES
			AND ISNULL(intSiteGroupId,0) = 0 -- ALL SITE GROUPS
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
			WHERE intItemId = @CFItemId
			AND intNetworkId = @CFNetworkId
			AND ISNULL(intSiteId,0) = 0 -- ALL SITES
			AND ISNULL(intSiteGroupId,0) = 0 -- ALL SITE GROUPS

		END
		

	----------------------------------------------
	--   SITE | SITE GROUP | PRODUCT | NETWORK  --
	----------------------------------------------
	--   ALL  |		ALL    |   ALL	 |   1      --
	----------------------------------------------
	IF (@cfMatchProfileCount = 0 AND @cfMatchProfileSkip = 0)
		BEGIN
			SELECT @cfMatchProfileCount = Count(*) 
			FROM @cfPriceProfile 
			WHERE intNetworkId = @CFNetworkId
			AND ISNULL(intItemId,0) = 0 -- ALL ITEMS
			AND ISNULL(intSiteId,0) = 0 -- ALL SITES
			AND ISNULL(intSiteGroupId,0) = 0 -- ALL SITE GROUPS

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
			WHERE intNetworkId = @CFNetworkId
			AND ISNULL(intItemId,0) = 0 -- ALL ITEMS
			AND ISNULL(intSiteId,0) = 0 -- ALL SITES
			AND ISNULL(intSiteGroupId,0) = 0 -- ALL SITE GROUPS


		END


	----------------------------------------------
	--   SITE | SITE GROUP | PRODUCT | NETWORK  --
	----------------------------------------------
	--   ALL  |		ALL    |   1	 |   ALL    --
	----------------------------------------------
	IF (@cfMatchProfileCount = 0 AND @cfMatchProfileSkip = 0)
		BEGIN
			SELECT @cfMatchProfileCount = Count(*) 
			FROM @cfPriceProfile 
			WHERE intItemId = @CFItemId
			AND ISNULL(intSiteId,0) = 0 -- ALL SITES
			AND ISNULL(intSiteGroupId,0) = 0 -- ALL SITE GROUPS
			AND ISNULL(intNetworkId,0) = 0 -- ALL NETWORKS
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
			WHERE intItemId = @CFItemId
			AND ISNULL(intSiteId,0) = 0 -- ALL SITES
			AND ISNULL(intSiteGroupId,0) = 0 -- ALL SITE GROUPS
			AND ISNULL(intNetworkId,0) = 0 -- ALL NETWORKS

		END


	----------------------------------------------
	--   SITE | SITE GROUP | PRODUCT | NETWORK  --
	----------------------------------------------
	--   ALL  |		ALL    |   ALL	 |   ALL    --
	----------------------------------------------
	IF (@cfMatchProfileCount = 0 AND @cfMatchProfileSkip = 0)
		BEGIN
			SELECT @cfMatchProfileCount = Count(*) 
			FROM @cfPriceProfile 
			WHERE ISNULL(intItemId,0) = 0 -- ALL ITEMS
			AND ISNULL(intSiteId,0) = 0 -- ALL SITES
			AND ISNULL(intSiteGroupId,0) = 0 -- ALL SITE GROUPS
			AND ISNULL(intNetworkId,0) = 0 -- ALL NETWORKS
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
			WHERE ISNULL(intItemId,0) = 0 -- ALL ITEMS
			AND ISNULL(intSiteId,0) = 0 -- ALL SITES
			AND ISNULL(intSiteGroupId,0) = 0 -- ALL SITE GROUPS
			AND ISNULL(intNetworkId,0) = 0 -- ALL NETWORKS

		END


	--OBSOLETE OBSOLETE OBSOLETE OBSOLETE OBSOLETE--
	--OBSOLETE OBSOLETE OBSOLETE OBSOLETE OBSOLETE--
	
	------------------------------------------------
	----   SITE | SITE GROUP | PRODUCT | NETWORK  --
	------------------------------------------------
	----   1    |		N/A    |	1	 |     1    --
	------------------------------------------------
	--IF (@cfMatchProfileCount = 0 AND @cfMatchProfileSkip = 0)
	--	BEGIN
	--		SELECT @cfMatchProfileCount = Count(*) 
	--		FROM @cfPriceProfile 
	--		WHERE intSiteId = @CFSiteId
	--		AND intItemId = @CFItemId
	--		AND intNetworkId = @CFNetworkId
	--	END
	--IF (@cfMatchProfileCount != 0 AND @cfMatchProfileSkip = 0)
	--	BEGIN
	--		print '1-n/a-1-1'
	--		SET @cfMatchProfileSkip = 1
	--		INSERT INTO @cfMatchPriceProfile 
	--		(
	--			intAccountId,			
	--			intCustomerId,			
	--			intDiscountDays,			
	--			intDiscountScheduleId,	
	--			intSalesPersonId,		
	--			intPriceProfileDetailId,	
	--			intPriceProfileHeaderId,	
	--			intItemId,				
	--			intNetworkId,			
	--			intSiteGroupId,			
	--			intSiteId,				
	--			intLocalPricingIndex,	
	--			dblRate,					
	--			strBasis,				
	--			strType					
	--		)
	--		SELECT TOP 1
	--			intAccountId,			
	--			intCustomerId,			
	--			intDiscountDays,			
	--			intDiscountScheduleId,	
	--			intSalesPersonId,		
	--			intPriceProfileDetailId,	
	--			intPriceProfileHeaderId,	
	--			intItemId,				
	--			intNetworkId,			
	--			intSiteGroupId,			
	--			intSiteId,				
	--			intLocalPricingIndex,	
	--			dblRate,					
	--			strBasis,				
	--			strType		
	--		FROM @cfPriceProfile 
	--		WHERE intSiteId = @CFSiteId
	--		AND intItemId = @CFItemId
	--		AND intNetworkId = @CFNetworkId 
	--	END
	------------------------------------------------

	------------------------------------------------
	----   SITE | SITE GROUP | PRODUCT | NETWORK  --
	------------------------------------------------
	----   1    |		N/A    |   ALL	 |     1    --
	------------------------------------------------
	--IF (@cfMatchProfileCount = 0 AND @cfMatchProfileSkip = 0)
	--	BEGIN
	--		SELECT @cfMatchProfileCount = Count(*) 
	--		FROM @cfPriceProfile 
	--		WHERE intSiteId = @CFSiteId
	--		AND intNetworkId = @CFNetworkId
	--		AND (intItemId IS NULL OR intItemId = 0)          ------ADDED------
	--	END
	--IF (@cfMatchProfileCount != 0 AND @cfMatchProfileSkip = 0)
	--	BEGIN
	--		print '1-n/a-all-1'
	--		SET @cfMatchProfileSkip = 1
	--		INSERT INTO @cfMatchPriceProfile 
	--		(
	--			intAccountId,			
	--			intCustomerId,			
	--			intDiscountDays,			
	--			intDiscountScheduleId,	
	--			intSalesPersonId,		
	--			intPriceProfileDetailId,	
	--			intPriceProfileHeaderId,	
	--			intItemId,				
	--			intNetworkId,			
	--			intSiteGroupId,			
	--			intSiteId,				
	--			intLocalPricingIndex,	
	--			dblRate,					
	--			strBasis,				
	--			strType					
	--		)
	--		SELECT TOP 1
	--			intAccountId,			
	--			intCustomerId,			
	--			intDiscountDays,			
	--			intDiscountScheduleId,	
	--			intSalesPersonId,		
	--			intPriceProfileDetailId,	
	--			intPriceProfileHeaderId,	
	--			intItemId,				
	--			intNetworkId,			
	--			intSiteGroupId,			
	--			intSiteId,				
	--			intLocalPricingIndex,	
	--			dblRate,					
	--			strBasis,				
	--			strType		
	--		FROM @cfPriceProfile 
	--		WHERE intSiteId = @CFSiteId
	--		AND intNetworkId = @CFNetworkId 
	--		AND (intItemId IS NULL OR intItemId = 0)                 ------ADDED------
	--	END
	------------------------------------------------

	------------------------------------------------
	----   SITE | SITE GROUP | PRODUCT | NETWORK  --
	------------------------------------------------
	----   N/A  |		 1     |    1	 |    N/A   --
	------------------------------------------------
	--IF (@cfMatchProfileCount = 0 AND @cfMatchProfileSkip = 0)
	--	BEGIN
	--		SELECT @cfMatchProfileCount = Count(*) 
	--		FROM @cfPriceProfile 
	--		WHERE intSiteGroupId = @TransactionSiteGroup
	--		AND intItemId = @CFItemId
	--	END
	--IF (@cfMatchProfileCount != 0 AND @cfMatchProfileSkip = 0)
	--	BEGIN
	--		print 'n/a-1-1-n/a'
	--		SET @cfMatchProfileSkip = 1
	--		INSERT INTO @cfMatchPriceProfile 
	--		(
	--			intAccountId,			
	--			intCustomerId,			
	--			intDiscountDays,			
	--			intDiscountScheduleId,	
	--			intSalesPersonId,		
	--			intPriceProfileDetailId,	
	--			intPriceProfileHeaderId,	
	--			intItemId,				
	--			intNetworkId,			
	--			intSiteGroupId,			
	--			intSiteId,				
	--			intLocalPricingIndex,	
	--			dblRate,					
	--			strBasis,				
	--			strType					
	--		)
	--		SELECT TOP 1
	--			intAccountId,			
	--			intCustomerId,			
	--			intDiscountDays,			
	--			intDiscountScheduleId,	
	--			intSalesPersonId,		
	--			intPriceProfileDetailId,	
	--			intPriceProfileHeaderId,	
	--			intItemId,				
	--			intNetworkId,			
	--			intSiteGroupId,			
	--			intSiteId,				
	--			intLocalPricingIndex,	
	--			dblRate,					
	--			strBasis,				
	--			strType		
	--		FROM @cfPriceProfile 
	--		WHERE intSiteGroupId = @TransactionSiteGroup
	--		AND intItemId = @CFItemId
	--	END
	------------------------------------------------

	------------------------------------------------
	----   SITE | SITE GROUP | PRODUCT | NETWORK  --
	------------------------------------------------
	----   N/A  |		 1     |   ALL	 |    N/A   --
	------------------------------------------------
	--IF (@cfMatchProfileCount = 0 AND @cfMatchProfileSkip = 0)
	--	BEGIN
	--		SELECT @cfMatchProfileCount = Count(*) 
	--		FROM @cfPriceProfile 
	--		WHERE intSiteGroupId = @TransactionSiteGroup
	--		AND (intItemId IS NULL OR intItemId = 0)             ------ADDED------
	--	END
	--IF (@cfMatchProfileCount != 0 AND @cfMatchProfileSkip = 0)
	--	BEGIN
	--		print 'n/a-1-all-n/a'
	--		SET @cfMatchProfileSkip = 1
	--		INSERT INTO @cfMatchPriceProfile 
	--		(
	--			intAccountId,			
	--			intCustomerId,			
	--			intDiscountDays,			
	--			intDiscountScheduleId,	
	--			intSalesPersonId,		
	--			intPriceProfileDetailId,	
	--			intPriceProfileHeaderId,	
	--			intItemId,				
	--			intNetworkId,			
	--			intSiteGroupId,			
	--			intSiteId,				
	--			intLocalPricingIndex,	
	--			dblRate,					
	--			strBasis,				
	--			strType					
	--		)
	--		SELECT TOP 1
	--			intAccountId,			
	--			intCustomerId,			
	--			intDiscountDays,			
	--			intDiscountScheduleId,	
	--			intSalesPersonId,		
	--			intPriceProfileDetailId,	
	--			intPriceProfileHeaderId,	
	--			intItemId,				
	--			intNetworkId,			
	--			intSiteGroupId,			
	--			intSiteId,				
	--			intLocalPricingIndex,	
	--			dblRate,					
	--			strBasis,				
	--			strType		
	--		FROM @cfPriceProfile 
	--		WHERE intSiteGroupId = @TransactionSiteGroup
	--		AND (intItemId IS NULL OR intItemId = 0)             ------ADDED------
	--	END
	------------------------------------------------

	------------------------------------------------
	----   SITE | SITE GROUP | PRODUCT | NETWORK  --
	------------------------------------------------
	----   ALL  |	   N/A     |    1	 |     1    --
	------------------------------------------------
	--IF (@cfMatchProfileCount = 0 AND @cfMatchProfileSkip = 0)
	--	BEGIN
	--		SELECT @cfMatchProfileCount = Count(*) 
	--		FROM @cfPriceProfile 
	--		WHERE intItemId = @CFItemId
	--		AND intNetworkId = @CFNetworkId
	--		AND (intSiteId IS NULL OR intSiteId = 0)               ------ADDED------
	--	END
	--IF (@cfMatchProfileCount != 0 AND @cfMatchProfileSkip = 0)
	--	BEGIN
	--		print 'n/a-n/a-1-1'
	--		SET @cfMatchProfileSkip = 1
	--		INSERT INTO @cfMatchPriceProfile 
	--		(
	--			intAccountId,			
	--			intCustomerId,			
	--			intDiscountDays,			
	--			intDiscountScheduleId,	
	--			intSalesPersonId,		
	--			intPriceProfileDetailId,	
	--			intPriceProfileHeaderId,	
	--			intItemId,				
	--			intNetworkId,			
	--			intSiteGroupId,			
	--			intSiteId,				
	--			intLocalPricingIndex,	
	--			dblRate,					
	--			strBasis,				
	--			strType					
	--		)
	--		SELECT TOP 1
	--			intAccountId,			
	--			intCustomerId,			
	--			intDiscountDays,			
	--			intDiscountScheduleId,	
	--			intSalesPersonId,		
	--			intPriceProfileDetailId,	
	--			intPriceProfileHeaderId,	
	--			intItemId,				
	--			intNetworkId,			
	--			intSiteGroupId,			
	--			intSiteId,				
	--			intLocalPricingIndex,	
	--			dblRate,					
	--			strBasis,				
	--			strType		
	--		FROM @cfPriceProfile 
	--		WHERE intItemId = @CFItemId
	--		AND intNetworkId = @CFNetworkId
	--		AND (intSiteId IS NULL OR intSiteId = 0)            ------ADDED------
	--	END
	------------------------------------------------

	------------------------------------------------
	----   SITE | SITE GROUP | PRODUCT | NETWORK  --
	------------------------------------------------
	----   ALL  |	   N/A     |    1	 |    N/A   --
	------------------------------------------------
	--IF (@cfMatchProfileCount = 0 AND @cfMatchProfileSkip = 0)
	--	BEGIN
	--		SELECT @cfMatchProfileCount = Count(*) 
	--		FROM @cfPriceProfile 
	--		WHERE intItemId = @CFItemId
	--		AND (intSiteId IS NULL OR intSiteId = 0)               ------ADDED------
	--	END
	--IF (@cfMatchProfileCount != 0 AND @cfMatchProfileSkip = 0)
	--	BEGIN
	--		print 'n/a-n/a-1-n/a'
	--		SET @cfMatchProfileSkip = 1
	--		INSERT INTO @cfMatchPriceProfile 
	--		(
	--			intAccountId,			
	--			intCustomerId,			
	--			intDiscountDays,			
	--			intDiscountScheduleId,	
	--			intSalesPersonId,		
	--			intPriceProfileDetailId,	
	--			intPriceProfileHeaderId,	
	--			intItemId,				
	--			intNetworkId,			
	--			intSiteGroupId,			
	--			intSiteId,				
	--			intLocalPricingIndex,	
	--			dblRate,					
	--			strBasis,				
	--			strType					
	--		)
	--		SELECT TOP 1
	--			intAccountId,			
	--			intCustomerId,			
	--			intDiscountDays,			
	--			intDiscountScheduleId,	
	--			intSalesPersonId,		
	--			intPriceProfileDetailId,	
	--			intPriceProfileHeaderId,	
	--			intItemId,				
	--			intNetworkId,			
	--			intSiteGroupId,			
	--			intSiteId,				
	--			intLocalPricingIndex,	
	--			dblRate,					
	--			strBasis,				
	--			strType		
	--		FROM @cfPriceProfile 
	--		WHERE intItemId = @CFItemId
	--		AND (intSiteId IS NULL OR intSiteId = 0)               ------ADDED------
	--	END
	------------------------------------------------

	------------------------------------------------
	----   SITE | SITE GROUP | PRODUCT | NETWORK  --
	------------------------------------------------
	----   ALL  |	   N/A     |   ALL	 |    N/A   --
	------------------------------------------------
	--IF (@cfMatchProfileCount = 0 AND @cfMatchProfileSkip = 0)
	--	BEGIN
	--		SELECT @cfMatchProfileCount = Count(*) 
	--		FROM @cfPriceProfile 
	--		WHERE (intItemId IS NULL OR intItemId = 0)               ------ADDED------
	--		AND (intSiteId IS NULL OR intSiteId = 0)               ------ADDED------
	--	END
	--IF (@cfMatchProfileCount != 0 AND @cfMatchProfileSkip = 0)
	--	BEGIN
	--		print 'n/a-n/a-all-n/a'
	--		SET @cfMatchProfileSkip = 1
	--		INSERT INTO @cfMatchPriceProfile 
	--		(
	--			intAccountId,			
	--			intCustomerId,			
	--			intDiscountDays,			
	--			intDiscountScheduleId,	
	--			intSalesPersonId,		
	--			intPriceProfileDetailId,	
	--			intPriceProfileHeaderId,	
	--			intItemId,				
	--			intNetworkId,			
	--			intSiteGroupId,			
	--			intSiteId,				
	--			intLocalPricingIndex,	
	--			dblRate,					
	--			strBasis,				
	--			strType					
	--		)
	--		SELECT TOP 1
	--			intAccountId,			
	--			intCustomerId,			
	--			intDiscountDays,			
	--			intDiscountScheduleId,	
	--			intSalesPersonId,		
	--			intPriceProfileDetailId,	
	--			intPriceProfileHeaderId,	
	--			intItemId,				
	--			intNetworkId,			
	--			intSiteGroupId,			
	--			intSiteId,				
	--			intLocalPricingIndex,	
	--			dblRate,					
	--			strBasis,				
	--			strType		
	--		FROM @cfPriceProfile 
	--		WHERE (intItemId IS NULL OR intItemId = 0)             ------ADDED------
	--		AND (intSiteId IS NULL OR intSiteId = 0)               ------ADDED------
	--	END
	------------------------------------------------

	--OBSOLETE OBSOLETE OBSOLETE OBSOLETE OBSOLETE--
	--OBSOLETE OBSOLETE OBSOLETE OBSOLETE OBSOLETE--

	
	-------------------------------
	-- Price Profile Computation --
	-------------------------------

	--select dblOriginalGrossPrice from tblCFTransaction
	
	--SET @Rate = (SELECT TOP 1 dblRate FROM @cfMatchPriceProfile) 

	--SELECT * FROM @cfMatchPriceProfile

	SELECT TOP 1
	 @Rate = dblRate
	,@CFPriceProfileId = intPriceProfileHeaderId
	,@CFPriceProfileDetailId = intPriceProfileDetailId
	,@CFPriceIndexId = intLocalPricingIndex
	--,@CFSiteGroupId = intSiteGroupId
	FROM @cfMatchPriceProfile

	--SELECT @CFSiteGroupId = intAdjustmentSiteGroupId
	--FROM tblCFSite WHERE intSiteId = @CFSiteId

	
	SET @CFPriceBasis = (SELECT TOP 1 strBasis FROM @cfMatchPriceProfile)
	
	IF(@CFTransactionType = 'Local/Network')
	BEGIN 
		IF(@CFPriceBasis = 'Pump Price Adjustment')
			BEGIN
				SET @CFPriceOut = @CFStandardPrice + @Rate
				SET @CFPricingOut = 'Price Profile' 
				RETURN 1;    
			END
		ELSE IF(@CFPriceBasis IS NOT NULL)
			BEGIN 
				--SET @SiteGroupId = (SELECT TOP 1 intSiteGroupId 
				--					FROM @cfMatchPriceProfile) 

				SET @PriceIndexId = (SELECT TOP 1 intLocalPricingIndex 
									 FROM @cfMatchPriceProfile) 

				--SET @ItemId = (SELECT TOP 1 intItemId 
				--					 FROM @cfMatchPriceProfile) 

				SET @CFStandardPrice = (SELECT TOP 1 dblIndexPrice
										FROM tblCFIndexPricingBySiteGroupHeader IPH
										INNER JOIN tblCFIndexPricingBySiteGroup IPD
										ON IPH.intIndexPricingBySiteGroupHeaderId = IPD.intIndexPricingBySiteGroupHeaderId
										WHERE IPH.intPriceIndexId = @PriceIndexId 
										AND IPH.intSiteGroupId = @CFSiteGroupId
										AND IPD.intARItemID = @CFItemId
										AND IPH.dtmDate <= @CFTransactionDate 
										ORDER BY IPH.dtmDate DESC)

				IF(@CFStandardPrice IS NOT NULL)
					BEGIN
						SET @CFPriceOut = @CFStandardPrice + @Rate
						SET @CFPricingOut = 'Price Profile' 
						RETURN 1;    
					END
					
				SET @CFPricingOut = 'Price Profile' 
			END
	END
	ELSE IF (@CFTransactionType = 'Remote')
	BEGIN
		IF(@CFPriceBasis = 'Remote Pricing Index')
			BEGIN
				
				--SET @SiteGroupId = (SELECT TOP 1 intSiteGroupId 
				--					FROM @cfMatchPriceProfile) 

				SET @PriceIndexId = (SELECT TOP 1 intLocalPricingIndex 
									 FROM @cfMatchPriceProfile) 

				--SET @ItemId = (SELECT TOP 1 intItemId 
				--					 FROM @cfMatchPriceProfile) 

				SET @CFStandardPrice = (SELECT TOP 1 dblIndexPrice
										FROM tblCFIndexPricingBySiteGroupHeader IPH
										INNER JOIN tblCFIndexPricingBySiteGroup IPD
										ON IPH.intIndexPricingBySiteGroupHeaderId = IPD.intIndexPricingBySiteGroupHeaderId
										WHERE IPH.intPriceIndexId = @PriceIndexId 
										AND IPH.intSiteGroupId = @CFSiteGroupId
										AND IPD.intARItemID = @CFItemId
										AND IPH.dtmDate <= @CFTransactionDate 
										ORDER BY IPH.dtmDate DESC)

				IF(@CFStandardPrice IS NOT NULL)
					BEGIN
						SET @CFPriceOut = @CFStandardPrice + @Rate
						SET @CFPricingOut = 'Price Profile' 
						RETURN 1;    
					END

					
				SET @CFPricingOut = 'Price Profile' 

			END
		ELSE IF(@CFPriceBasis = 'Transfer Cost' OR @CFPriceBasis = 'Transfer Price')
			BEGIN
				IF(@CFTransferCost IS NOT NULL)
					BEGIN
						SET @CFPriceOut = @CFTransferCost + @Rate
						SET @CFPricingOut = 'Price Profile' 
						RETURN 1;    
					END
					
				SET @CFPricingOut = 'Price Profile' 
			END
	END
	ELSE IF (@CFTransactionType = 'Extended Remote')
	BEGIN
		IF(@CFPriceBasis = 'Discounted Price')
			BEGIN
				IF(@CFTransferCost IS NOT NULL)
					BEGIN
						SET @CFPriceOut = @CFTransferCost + @Rate
						SET @CFPricingOut = 'Price Profile' 
						RETURN 1;    
					END
					
				SET @CFPricingOut = 'Price Profile' 
			END
		ELSE IF(@CFPriceBasis = 'Full Retail')
			BEGIN
				IF(@CFTransferCost IS NOT NULL)
					BEGIN
						SET @CFPriceOut = @CFStandardPrice + @Rate
						SET @CFPricingOut = 'Price Profile' 
						RETURN 1;    
					END
					
				SET @CFPricingOut = 'Price Profile' 
			END
		ELSE IF(@CFPriceBasis IS NOT NULL)
			BEGIN
				--SET @SiteGroupId = (SELECT TOP 1 intSiteGroupId 
				--						FROM @cfMatchPriceProfile) 

				SET @PriceIndexId = (SELECT TOP 1 intLocalPricingIndex 
										FROM @cfMatchPriceProfile) 

				--SET @ItemId = (SELECT TOP 1 intItemId 
				--					 FROM @cfMatchPriceProfile) 

				SET @CFStandardPrice = (SELECT TOP 1 dblIndexPrice
										FROM tblCFIndexPricingBySiteGroupHeader IPH
										INNER JOIN tblCFIndexPricingBySiteGroup IPD
										ON IPH.intIndexPricingBySiteGroupHeaderId = IPD.intIndexPricingBySiteGroupHeaderId
										WHERE IPH.intPriceIndexId = @PriceIndexId 
										AND IPH.intSiteGroupId = @CFSiteGroupId
										AND IPD.intARItemID = @CFItemId
										AND IPH.dtmDate <= @CFTransactionDate 
										ORDER BY IPH.dtmDate DESC)

				IF(@CFStandardPrice IS NOT NULL)
					BEGIN
						SET @CFPriceOut = @CFStandardPrice + @Rate
						SET @CFPricingOut = 'Price Profile' 
						RETURN 1;    
					END
					
				SET @CFPricingOut = 'Price Profile' 
			END
END

---***PRICE PROFILE***---

END

---***ITEM PRICING***---
SET @CFPricingOut = @CFPricingOut 
SET @CFPriceOut = @CFStandardPrice;

---***ITEM PRICING***---

RETURN 1