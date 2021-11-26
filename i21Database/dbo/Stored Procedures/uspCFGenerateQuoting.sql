CREATE PROCEDURE [dbo].[uspCFGenerateQuoting](
	 @intCustomerId				NVARCHAR(MAX)  
	,@intSiteId					NVARCHAR(MAX)  = NULL
	,@intProductId				NVARCHAR(MAX)  = NULL 
	,@dtmDate					DATETIME
	,@strCity					NVARCHAR(MAX)  = ''	
	,@strState					NVARCHAR(MAX)  = ''	
	,@isPortal					BIT			   = 0
	,@ysnAccountQuote			BIT			   = 0
	,@intItemSequence			INT			   = 0
	,@intEntityUserId			INT			   = 0
)
AS
BEGIN

	IF(@ysnAccountQuote = 0)
	BEGIN
		DELETE FROM tblCFCSRSingleQuote	WHERE intEntityUserId = @intEntityUserId OR ISNULL(intEntityUserId,0) = 0
		--DELETE FROM tblCFCSRSingleQuoteDetailTax
	END

	DECLARE @dblMaxAvailableDiscount NUMERIC(18,6)


	
	SELECT @dblMaxAvailableDiscount = MAX(dblRate) FROM tblCFDiscountSchedule 
	INNER JOIN tblCFAccount
	ON tblCFDiscountSchedule.intDiscountScheduleId = tblCFAccount.intDiscountScheduleId
	LEFT JOIN tblCFDiscountScheduleDetail
	ON tblCFDiscountSchedule.intDiscountScheduleId = tblCFDiscountScheduleDetail.intDiscountScheduleId
	WHERE tblCFAccount.intCustomerId = @intCustomerId


	
	
	DECLARE @tblNetworkSiteItem TABLE (
		intId				   INT
		,intNetworkId		   INT
		,strNetwork			   NVARCHAR(max)
		,intSiteId			   INT
		,strSiteNumber		   NVARCHAR(max)
		,strSiteName		   NVARCHAR(max)
		,strSiteType		   NVARCHAR(max)
		,strSiteAddress		   NVARCHAR(max)
		,strSiteCity		   NVARCHAR(max)
		,strTaxState		   NVARCHAR(max)
		--,intItemId			   INT
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
	
	IF(ISNULL(@intProductId,0) != 0)
	BEGIN
		IF(@firstAppend = 1)
		BEGIN
			SET @where += ' AND cfItem.intARItemId = ' + @intProductId
		END
		ELSE
		BEGIN
			SET @firstAppend = 1
			SET @where = 'WHERE '
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
			SET @where = 'WHERE '
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
				SET @where = 'WHERE '
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
				SET @where = 'WHERE '
				SET @where += 'cfSite.strTaxState = ' + '''' + @strState + ''''
			END
		END

	END

	DECLARE @q  NVARCHAR(MAX) = ''
	SET @q = 'SELECT 
	ROW_NUMBER() OVER(ORDER BY cfSite.intSiteId DESC),
	cfNetwork.intNetworkId, 
	strNetwork , 
	cfSite.intSiteId, 
	strSiteNumber ,
	strSiteName, 
	cfSite.strSiteType, 
	cfSite.strSiteAddress, 
	cfSite.strSiteCity,
	cfSite.strTaxState,
	cfItem.intARItemId,
	ISNULL(icItem.strItemNo,'''') + '' - '' + ISNULL(icItem.strDescription,'''') as strProductNumber,
	icItem.strItemNo, 
	icItem.strDescription
	FROM tblCFNetwork as cfNetwork 
	INNER JOIN (SELECT * FROM tblCFSite WHERE strSiteType = ''Remote'') AS cfSite 
		ON cfNetwork.intNetworkId = cfSite.intNetworkId
	INNER JOIN tblCFItem as cfItem 
		ON cfNetwork.intNetworkId = cfItem.intNetworkId
	INNER JOIN tblICItem as icItem 
		ON cfItem.intARItemId = icItem.intItemId
	INNER JOIN tblCFItemCategory as cfItemCat
		ON icItem.intCategoryId = cfItemCat.intCategoryId 
	INNER JOIN tblCFNetworkCost as cfNetCost
		ON cfNetCost.intItemId = cfItem.intARItemId
		AND cfNetCost.intSiteId = cfSite.intSiteId
		AND cfNetwork.intNetworkId = cfNetwork.intNetworkId' + ' ' 
	+ ISNULL(@where,'')
	+ ' GROUP BY
	 cfNetwork	.intNetworkId	
	,cfNetwork	.strNetwork		
	,cfSite		.intSiteId		
	,cfSite		.strSiteNumber	
	,cfSite		.strSiteName	
	,cfSite		.strSiteType	
	,cfSite		.strSiteAddress	
	,cfSite		.strSiteCity	
	,cfSite		.strTaxState	
	,cfItem		.intARItemId	
	,icItem		.strItemNo
	,icItem		.strDescription'

	--SELECT @q
	INSERT INTO @tblNetworkSiteItem
	EXEC(@q)


	SET @q = 'SELECT 
	ROW_NUMBER() OVER(ORDER BY cfSite.intSiteId DESC),
	cfNetwork.intNetworkId, 
	strNetwork , 
	cfSite.intSiteId, 
	strSiteNumber ,
	strSiteName, 
	cfSite.strSiteType, 
	cfSite.strSiteAddress, 
	cfSite.strSiteCity,
	cfSite.strTaxState,
	cfItem.intARItemId,
	ISNULL(icItem.strItemNo,'''') + '' - '' + ISNULL(icItem.strDescription,'''') as strProductNumber,
	icItem.strItemNo, 
	icItem.strDescription
	FROM tblCFNetwork as cfNetwork 
	INNER JOIN (SELECT * FROM tblCFSite WHERE strSiteType = ''Local/Network'') AS cfSite 
		ON cfNetwork.intNetworkId = cfSite.intNetworkId
	INNER JOIN tblCFItem as cfItem 
		ON cfNetwork.intNetworkId = cfItem.intNetworkId
	INNER JOIN tblICItem as icItem 
		ON cfItem.intARItemId = icItem.intItemId
	INNER JOIN tblCFItemCategory as cfItemCat
		ON icItem.intCategoryId = cfItemCat.intCategoryId' + ' ' 
	+ ISNULL(@where,'')
	+ ' GROUP BY
	 cfNetwork	.intNetworkId	
	,cfNetwork	.strNetwork		
	,cfSite		.intSiteId		
	,cfSite		.strSiteNumber	
	,cfSite		.strSiteName	
	,cfSite		.strSiteType	
	,cfSite		.strSiteAddress	
	,cfSite		.strSiteCity	
	,cfSite		.strTaxState	
	,cfItem		.intARItemId	
	,icItem		.strItemNo
	,icItem		.strDescription'


	--SELECT @q
	INSERT INTO @tblNetworkSiteItem
	EXEC(@q)


	
	--SELECT COUNT (*) FROM @tblNetworkSiteItem

	DECLARE @loopNetworkId	INT	
	DECLARE @loopSiteId		INT
	DECLARE @loopItemId		INT
	DECLARE @loopARItemId	INT
	DECLARE	@loopSiteType	NVARCHAR(MAX)		
	DECLARE @networkCost	NUMERIC(18,6)
	DECLARE @effectiveDate	DATETIME
	DECLARE @pk				INT


	--FOR LOCAL SITE EXCLUDE ITEM THAT IS NOT PART OF INVENTORY--
	--JIRA CF-1820--
	DECLARE @tblCFLocalSiteItem TABLE
	(
		 intSite INT
		,intLocationId INT
		,intItemId INT
	)

	INSERT INTO @tblCFLocalSiteItem
	(
		intSite,
		intLocationId,
		intItemId
	)
	SELECT 
	cfSite.intSiteId
	,icLoc.intLocationId
	,icItem.intItemId
	FROM tblICItem as icItem
	INNER JOIN tblICItemLocation as icLoc
	ON icItem.intItemId = icLoc.intItemId
	INNER JOIN tblCFSite as cfSite
	ON  cfSite.intARLocationId = icLoc.intLocationId
	WHERE cfSite.strSiteType = 'Local/Network'
	ORDER BY cfSite.intSiteId

	--SELECT '@tblNetworkSiteItem',* FROM @tblNetworkSiteItem
	--SELECT '@tblCFLocalSiteItem',* FROM @tblCFLocalSiteItem

	DELETE FROM @tblNetworkSiteItem WHERE intId NOT IN (
	SELECT intId FROM @tblNetworkSiteItem AS records
	INNER JOIN @tblCFLocalSiteItem AS localItems
	ON records.intARItemId = localItems.intItemId
	AND records.intSiteId = localItems.intSite)
	AND strSiteType = 'Local/Network'

	
	--JIRA CF-1820--
	---------------------------------------------

	DECLARE @ysnApplyTaxExemption BIT
	DECLARE @intPriceRuleGroup BIT
	SELECT TOP 1 @ysnApplyTaxExemption = ysnQuoteTaxExempt FROM tblCFAccount WHERE intCustomerId = @intCustomerId
	

	DECLARE @counter INT = 0

	WHILE (EXISTS(SELECT 1 FROM @tblNetworkSiteItem))
	BEGIN
		

		SELECT 
		 @loopNetworkId			= 	 intNetworkId	
		,@loopSiteId			= 	 intSiteId	
		--,@loopItemId			= 	 intItemId	
		,@loopARItemId			= 	 intARItemId	
		,@loopSiteType			=	 strSiteType
		FROM @tblNetworkSiteItem


		--SET @networkCost = (SELECT TOP 1 ISNULL(dblTransferCost,0) FROM tblCFNetworkCost 
		--WHERE intNetworkId = @loopNetworkId 
		--AND intSiteId = @loopSiteId
		--AND intItemId = @loopARItemId
		--AND CONVERT( varchar, dtmDate, 101) >= CONVERT( varchar, @dtmDate, 101)
		--AND CONVERT( varchar, dtmDate, 101) <= CONVERT( varchar, DATEADD(day, 7, @dtmDate), 101)
		--ORDER BY dtmDate ASC
		--)
		
		SET @networkCost = NULL
		SET @effectiveDate = NULL

		SELECT TOP 1 
		 @networkCost = ISNULL(dblTransferCost,0)
		,@effectiveDate = dtmDate
		FROM tblCFNetworkCost 
		WHERE intNetworkId = @loopNetworkId
		AND intSiteId = @loopSiteId
		AND intItemId = @loopARItemId
		AND DATEADD(dd, DATEDIFF(dd, 0, dtmDate), 0) <= DATEADD(dd, DATEDIFF(dd, 0, @dtmDate), 0)
		ORDER BY dtmDate DESC
		

		IF(ISNULL(@networkCost,0) = 0 AND @loopSiteType = 'Remote')
		BEGIN
			GOTO ENDLOOP
		END

		

		EXEC dbo.uspCFRecalculateTransaciton 
		@CustomerId = @intCustomerId,
		@ProductId=0,
		@SiteId=@loopSiteId,
		@NetworkId=@loopNetworkId,
		@TransactionDate=@dtmDate,
		@TransactionType=@loopSiteType,
		---------STATIC VALUE----------
		@TransactionId=0,
		@CreditCardUsed=0,
		@PumpId=0,
		@VehicleId=0,
		@CardId=0,
		@Quantity=1,
		@OriginalPrice=@networkCost, -- NETWORK COST
		@TransferCost=@networkCost,	-- NETWORK COST
		@IsImporting = 1,
		@ItemId = @loopARItemId,
		@QuoteTaxExemption = @ysnApplyTaxExemption,
		@ProcessType	= 'quote'

		
		

		DECLARE @dblOutPriceProfileRate				NUMERIC(18,6)
		DECLARE @dblOutAdjustmentRate				NUMERIC(18,6)
		DECLARE @dblOutTaxCalculatedAmount			NUMERIC(18,6)
		DECLARE @dblOutNetTaxCalculatedAmount	    NUMERIC(18,6)
		DECLARE @dblOutGrossTaxCalculatedAmount	    NUMERIC(18,6)
		DECLARE @strOutPriceBasis					NVARCHAR(MAX)
		DECLARE @dtmOutPriceIndexDate				DATETIME
		DECLARE @ysnHavePriceIndex					BIT


		SELECT TOP 1 
		 @dblOutPriceProfileRate = ISNULL(dblPriceProfileRate,0)	
		,@dblOutAdjustmentRate 	 = ISNULL(dblAdjustmentRate,0)
		,@dtmOutPriceIndexDate	 = dtmPriceIndexDate
		,@strOutPriceBasis		 = strPriceBasis
		FROM tblCFTransactionPricingType


		--DEBUGGER--
		--SELECT @counter  ,@loopARItemId ,@loopSiteId, @loopNetworkId, GETDATE() ,@loopSiteType, @strOutPriceBasis ,@dblOutNetTaxCalculatedAmount 
		--DEBUGGER--

		SELECT TOP 1 @dblOutNetTaxCalculatedAmount = ISNULL(dblTaxCalculatedAmount,0)	
		FROM tblCFTransactionPriceType 
		WHERE strTransactionPriceId = 'Net Price'

		SELECT TOP 1 @dblOutGrossTaxCalculatedAmount =ISNULL(dblTaxCalculatedAmount,0)	
		FROM tblCFTransactionPriceType 
		WHERE strTransactionPriceId = 'Gross Price'

		SELECT	@dblOutTaxCalculatedAmount = ISNULL(SUM(dblTaxCalculatedAmount),0)	FROM tblCFTransactionTaxType


		--IF(LOWER(ISNULL(@strOutPriceBasis,'')) IN ('index cost','index retail','index fixed'))
		--BEGIN
		--	SET @ysnHavePriceIndex = 1
		--END
		--ELSE
		--BEGIN
		--	SET @ysnHavePriceIndex = 0
		--END

		--IF(@loopSiteType = 'Local/Network' AND ISNULL(@ysnHavePriceIndex,0) = 0)
		--BEGIN
		--	--FOR LOCAL SITE EXCLUDE ITEM THAT DOESNT HAVE PRICE INDEX--
		--	--JIRA CF-1820--
		--	print 'skip'	
		--END
		IF((ISNULL(@networkCost,0) != 0 OR ISNULL(@ysnHavePriceIndex,0) = 1) AND ISNULL(@dblOutNetTaxCalculatedAmount,0) > 0)
		BEGIN
			
				--DEBUGGER--
				--SELECT @counter 
				--DEBUGGER--
			IF(ISNULL(@ysnHavePriceIndex,0) = 1)
			BEGIN
				IF(@dtmOutPriceIndexDate IS NOT NULL)
				BEGIN
					SET @effectiveDate = @dtmOutPriceIndexDate
				END
			END
		
			IF(@ysnAccountQuote = 0)
			BEGIN
			
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
				,intEntityUserId
				,dtmEffectiveDate
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
			,@intEntityUserId
			,@effectiveDate
			FROM @tblNetworkSiteItem
			WHERE 
			intNetworkId	 = @loopNetworkId	
			AND intSiteId	 = @loopSiteId	
			--AND intItemId	 = @loopItemId	
			AND intARItemId	 = @loopARItemId	
			AND strSiteType	 = @loopSiteType	
		
			SET @pk = SCOPE_IDENTITY()

			UPDATE tblCFCSRSingleQuote
			SET
			 dblProfileRate = @dblOutPriceProfileRate
			,dblAdjRate		= @dblOutAdjustmentRate
			,dtmEffectiveDate = @effectiveDate
			,dblNetPrice	= @dblOutNetTaxCalculatedAmount
			,dblGrossPrice	= @dblOutGrossTaxCalculatedAmount
			,dblTaxes		= @dblOutTaxCalculatedAmount
			,dblBestPrice = @dblOutGrossTaxCalculatedAmount - @dblMaxAvailableDiscount
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
			FROM tblCFTransactionTaxType

			IF(ISNULL(@isPortal,0) = 1 )
			BEGIN
				DELETE FROM tblCFCSRSingleQuote WHERE ISNULL(dblGrossPrice,0) = 0 
			END
		
		
		
			END
			ELSE
			BEGIN	
					DECLARE @dblAmount NUMERIC(18,6)
					(SELECT TOP 1 @dblAmount = ISNULL(dblTaxCalculatedAmount,0)	FROM tblCFTransactionPriceType WHERE strTransactionPriceId = 'Gross Price')

					INSERT INTO tblCFAccountQuote
					(
						 intSiteId
						,strSite
						,strAddress
						,strCity
						,strState
						,intEntityCustomerId
						,intItem
						,strItem
						,dblItemPrice
						,dtmEffectiveDate
						,intEntityUserId
						,dblBestPrice
					)
					SELECT
						 intSiteId
						,strSiteNumber 
						,strSiteAddress
						,strSiteCity
						,strTaxState
						,@intCustomerId
						,intARItemId
						,strProductNumber
						,@dblAmount
						,@effectiveDate
						,@intEntityUserId
						,@dblAmount - @dblMaxAvailableDiscount
					FROM @tblNetworkSiteItem
					WHERE 
					intNetworkId	 = @loopNetworkId	
					AND intSiteId	 = @loopSiteId	
					AND intARItemId	 = @loopARItemId	
					AND strSiteType	 = @loopSiteType	
			END
		END


		

		

		ENDLOOP:

		--DEBUGGER--
		--SET @counter += 1
		--DEBUGGER--

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
			--AND intItemId		= @loopItemId			
			AND intARItemId		= @loopARItemId		
			AND strSiteType		 = @loopSiteType		
		

		

	END


	
END