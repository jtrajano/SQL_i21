CREATE PROCEDURE [dbo].[uspCFGenerateQuoting](
	 @intCustomerId				NVARCHAR(MAX)  
	,@intSiteId					NVARCHAR(MAX)  = NULL
	,@intProductId				NVARCHAR(MAX)  = NULL 
	,@dtmDate					DATETIME
	,@strCity					NVARCHAR(MAX)  = ''	
	,@strState					NVARCHAR(MAX)  = ''	
)
AS
BEGIN

	DELETE FROM tblCFCSRSingleQuote
	DELETE FROM tblCFCSRSingleQuoteDetailTax

	
DECLARE @tblNetworkSiteItem TABLE (
		 intNetworkId		   INT
		,strNetwork			   NVARCHAR(max)
		,intSiteId			   INT
		,strSiteNumber		   NVARCHAR(max)
		,strSiteName		   NVARCHAR(max)
		,strSiteType		   NVARCHAR(max)
		,strSiteAddress		   NVARCHAR(max)
		,strSiteCity		   NVARCHAR(max)
		,strTaxState		   NVARCHAR(max)
		,intItemId			   INT
		,intARItemId		   INT
		,strProductNumber	   NVARCHAR(max)
		,strItemNo			   NVARCHAR(max)
		,strDescription		   NVARCHAR(max)
	)

	DECLARE @where NVARCHAR(MAX) 
	DECLARE @firstAppend BIT	= 0

	--IF OBJECT_ID('tempdb..@tblNetworkSiteItem') IS NOT NULL
 --   begin
 --           drop table @tblNetworkSiteItem
 --   end
	SET @where = 'WHERE '
	IF(ISNULL(@intProductId,0) != 0)
	BEGIN
		IF(@firstAppend = 1)
		BEGIN
			SET @where += ' AND cfItem.intARItemId = ' + @intProductId
		END
		ELSE
		BEGIN
			SET @firstAppend = 1
			SET @where += 'cfItem.intARItemId = ' + @intProductId
		END
	END
	
	IF(ISNULL(@intSiteId,0) != 0)
	BEGIN
		IF(@firstAppend = 1)
		BEGIN
			SET @where += ' AND cfSite.intSiteId = ' + @intSiteId
		END
		ELSE
		BEGIN
			SET @firstAppend = 1
			SET @where += 'cfSite.intSiteId = ' + @intSiteId
		END
	END
	ELSE
	BEGIN
		IF(ISNULL(@strCity,'') != '')
		BEGIN
			IF(@firstAppend = 1)
			BEGIN
				SET @where += ' AND cfSite.strSiteCity = ' + '''' +  @strCity + ''''
			END
			ELSE
			BEGIN
				SET @firstAppend = 1
				SET @where += 'cfSite.strSiteCity = ' + '''' + @strCity + ''''
			END
		END

		IF(ISNULL(@strState,'') != '')
		BEGIN
			IF(@firstAppend = 1)
			BEGIN
				SET @where += ' AND cfSite.strTaxState = ' + '''' + @strState + ''''
			END
			ELSE
			BEGIN
				SET @firstAppend = 1
				SET @where += 'cfSite.strTaxState = ' + '''' + @strState + ''''
			END
		END

	END

	DECLARE @q  NVARCHAR(MAX) = ''
	SET @q = 'SELECT
	cfNetwork.intNetworkId, 
	strNetwork , 
	cfSite.intSiteId, 
	strSiteNumber ,
	strSiteName, 
	cfSite.strSiteType, 
	cfSite.strSiteAddress, 
	cfSite.strSiteCity,
	cfSite.strTaxState,
	cfItem.intItemId,
	cfItem.intARItemId,
	ISNULL(icItem.strItemNo,'''') + '' - '' + ISNULL(icItem.strDescription,'''') as strProductNumber,
	icItem.strItemNo, 
	icItem.strDescription
	FROM tblCFNetwork as cfNetwork 
	INNER JOIN tblCFSite as cfSite ON cfNetwork.intNetworkId = cfSite.intNetworkId
	INNER JOIN tblCFItem as cfItem ON cfNetwork.intNetworkId = cfItem.intNetworkId
	INNER JOIN tblICItem as icItem ON cfItem.intARItemId = icItem.intItemId
	INNER JOIN tblCFItemCategory as cfItemCat ON icItem.intCategoryId = cfItemCat.intCategoryId' + ' ' + @where

	INSERT INTO @tblNetworkSiteItem
	EXEC(@q)

	DECLARE @loopNetworkId	INT	
	DECLARE @loopSiteId		INT
	DECLARE @loopItemId		INT
	DECLARE @loopARItemId	INT
	DECLARE	@loopSiteType	NVARCHAR(MAX)		
	DECLARE @networkCost	NUMERIC(18,6)
	DECLARE @pk				INT

	

	WHILE (EXISTS(SELECT 1 FROM @tblNetworkSiteItem))
	BEGIN
		SELECT 
		 @loopNetworkId			= 	 intNetworkId	
		,@loopSiteId			= 	 intSiteId	
		,@loopItemId			= 	 intItemId	
		,@loopARItemId			= 	 intARItemId	
		,@loopSiteType			=	 strSiteType
		FROM @tblNetworkSiteItem


		SET @networkCost = (SELECT TOP 1 ISNULL(dblTransferCost,0) FROM tblCFNetworkCost 
		WHERE intNetworkId = @loopNetworkId 
		AND intSiteId = @loopSiteId
		AND intItemId = @loopARItemId
		AND CONVERT( varchar, dtmDate, 101) = CONVERT( varchar, @dtmDate, 101)
		)
		
		EXEC dbo.uspCFRecalculateTransaciton 
		@CustomerId = @intCustomerId,
		@ProductId=@loopItemId,
		@SiteId=@loopSiteId,
		@NetworkId=@loopNetworkId,
		@TransactionDate=@dtmDate,
		@TransactionType=N'Local/Network',
		---------STATIC VALUE----------
		@TransactionId=0,
		@CreditCardUsed=0,
		@PumpId=0,
		@VehicleId=0,
		@CardId=0,
		@Quantity=1,
		@OriginalPrice=@networkCost, -- NETWORK COST
		@TransferCost=@networkCost,	-- NETWORK COST
		@IsImporting = 1


		INSERT INTO tblCFCSRSingleQuote(
			 intNetworkId
			,intSiteId
			,strAddress
			,strCity
			,strState
			,intItem
			,dblUnitCost
			,dblProfileRate
			,dblAdjRate
			,dblNetPrice
			,dblTaxes
			,dblGrossPrice
			,strNetwork
			,strSite
			,strItem
		)
		SELECT 
		 intNetworkId
		,intSiteId
		,strSiteAddress
		,strSiteCity
		,strTaxState
		,intARItemId
		,@networkCost
		,0
		,0
		,0
		,0
		,0
		,strNetwork
		,strSiteNumber + ' - ' + strSiteName
		,strProductNumber
		FROM @tblNetworkSiteItem
		WHERE 
		intNetworkId	 = @loopNetworkId	
		AND intSiteId	 = @loopSiteId	
		AND intItemId	 = @loopItemId	
		AND intARItemId	 = @loopARItemId	
		AND strSiteType	 = @loopSiteType	


		SET @pk = SCOPE_IDENTITY()

		UPDATE tblCFCSRSingleQuote
		SET
		 dblProfileRate = (SELECT TOP 1 ISNULL(dblPriceProfileRate,0)		FROM ##tblCFTransactionPricingType)
		,dblAdjRate		= (SELECT TOP 1 ISNULL(dblAdjustmentRate,0)			FROM ##tblCFTransactionPricingType)
		,dblNetPrice	= (SELECT TOP 1 ISNULL(dblTaxCalculatedAmount,0)	FROM ##tblCFTransactionPriceType WHERE strTransactionPriceId = 'Net Price')
		,dblGrossPrice	= (SELECT TOP 1 ISNULL(dblTaxCalculatedAmount,0)	FROM ##tblCFTransactionPriceType WHERE strTransactionPriceId = 'Gross Price')
		,dblTaxes		= (SELECT	ISNULL(SUM(dblTaxCalculatedAmount),0)	FROM ##tblCFTransactionTaxType)
		WHERE 
		intCSRSingleQuoteId = @pk
		

		INSERT INTO tblCFCSRSingleQuoteDetailTax
		(
			 intCSRSingleQuoteId
			,intTaxGroupId
			,intTaxCodeId
			,strCalculationMethod
			,dblRate
			,dblTax
			,strTaxCode
			,strTaxGroup
			,dblAdjustedTax
		)
		SELECT
		 @pk
		,intTaxGroupId
		,intTaxCodeId
		,strCalculationMethod
		,dblTaxRate
		,dblTaxCalculatedAmount
		,strTaxCode
		,strTaxGroup
		,dblTaxCalculatedAmount
		FROM ##tblCFTransactionTaxType


		IF OBJECT_ID('tempdb..##tblCFTransactionTaxType') IS NOT NULL
		begin
				drop table ##tblCFTransactionTaxType
		end

		IF OBJECT_ID('tempdb..##tblCFTransactionPriceType') IS NOT NULL
		begin
				drop table ##tblCFTransactionPriceType
		end

		IF OBJECT_ID('tempdb..##tblCFTransactionPricingType') IS NOT NULL
		begin
				drop table ##tblCFTransactionPricingType
		end

		PRINT 'S------------------'
		PRINT @loopNetworkId
		PRINT @loopSiteId	
		PRINT @loopItemId	
		PRINT @loopARItemId	
		PRINT 'E------------------'

		DELETE FROM  @tblNetworkSiteItem
		WHERE 
			intNetworkId		= @loopNetworkId		
			AND intSiteId		= @loopSiteId			
			AND intItemId		= @loopItemId			
			AND intARItemId		= @loopARItemId		
			AND strSiteType		 = @loopSiteType		
		

		

	END


	
END