CREATE PROCEDURE [dbo].[uspCFGetItemPrice]    
  @CFItemId				INT    
 ,@CFCustomerId			INT     
 ,@CFLocationId			INT    
 ,@CFItemUOMId			INT				= NULL    
 ,@CFTransactionDate	DATETIME		= NULL    
 ,@CFQuantity			NUMERIC(18,6)    
 ,@CFPriceOut			NUMERIC(18,6)	= NULL OUTPUT    
 ,@CFPricingOut			NVARCHAR(250)	= NULL OUTPUT    
 ,@CFStandardPrice		INT				= 0
 ,@CFTransactionType	NVARCHAR(MAX)
 ,@CFNetworkId			INT
 ,@CFSiteId				INT
AS


---***DEBUG PARAM***---

 --DECLARE      
 --  @CFItemId    INT    
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
@ItemId = @CFItemId,  
@CustomerId = @CFCustomerId,  
@LocationId = @CFLocationId,  
@Quantity = @CFQuantity,  
@ItemUOMId = @CFItemUOMId,  
@TransactionDate = @CFTransactionDate,
@Price = @CFPriceOut OUTPUT,
@Pricing = @CFPricingOut OUTPUT

IF(@CFPriceOut IS NOT NULL) 
   BEGIN    
	IF(@CFPricingOut = 'Inventory - Standard Pricing')
		BEGIN 
			SET @CFStandardPrice = @CFPriceOut  
		END
	ELSE
		BEGIN 
			SET @CFPricingOut = 'Special Pricing'  
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
	dblRate					INT,
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
	SET @CFPriceOut = (SELECT TOP 1 dblRate FROM @cfPriceProfile WHERE intCustomerId = @CFCustomerId AND intSiteId = @CFSiteId AND intItemId = @CFItemId) 
	IF(@CFPriceOut IS NOT NULL)   
	BEGIN
		SET @CFPricingOut = 'Price Profile' 
		RETURN 1;    
	END
END
---***PRICE PROFILE***---


---***ITEM PRICING***---
SET @CFPriceOut = @CFStandardPrice;
---***ITEM PRICING***---
RETURN 1