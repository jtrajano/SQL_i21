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
)
AS
BEGIN

	IF(@ysnAccountQuote = 0)
	BEGIN
		DELETE FROM tblCFCSRSingleQuote
		DELETE FROM tblCFCSRSingleQuoteDetailTax
	END
	
	
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
	INNER JOIN tblCFSite as cfSite ON cfNetwork.intNetworkId = cfSite.intNetworkId
	INNER JOIN tblCFItem as cfItem ON cfNetwork.intNetworkId = cfItem.intNetworkId
	INNER JOIN tblICItem as icItem ON cfItem.intARItemId = icItem.intItemId
	INNER JOIN tblCFItemCategory as cfItemCat ON icItem.intCategoryId = cfItemCat.intCategoryId' + ' ' 
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
		--,@loopItemId			= 	 intItemId	
		,@loopARItemId			= 	 intARItemId	
		,@loopSiteType			=	 strSiteType
		FROM @tblNetworkSiteItem


		SET @networkCost = (SELECT TOP 1 ISNULL(dblTransferCost,0) FROM tblCFNetworkCost 
		WHERE intNetworkId = @loopNetworkId 
		AND intSiteId = @loopSiteId
		AND intItemId = @loopARItemId
		AND CONVERT( varchar, dtmDate, 101) >= CONVERT( varchar, @dtmDate, 101)
		AND CONVERT( varchar, dtmDate, 101) <= CONVERT( varchar, DATEADD(day, 7, @dtmDate), 101)
		ORDER BY dtmDate ASC
		)

		IF(ISNULL(@networkCost,0) != 0)
		BEGIN

			EXEC dbo.uspCFRecalculateTransaciton 
			@CustomerId = @intCustomerId,
			@ProductId=@loopItemId,
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
			@IsImporting = 1

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
			--AND intItemId	 = @loopItemId	
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

			IF(ISNULL(@isPortal,0) = 1 )
			BEGIN
				DELETE FROM tblCFCSRSingleQuote WHERE ISNULL(dblGrossPrice,0) = 0 
			END
		
		
		
			END
			ELSE
			BEGIN	

					IF NOT EXISTS(SELECT 1 FROM tblCFAccountQuote WHERE intSiteId = @loopSiteId AND intEntityCustomerId = @intCustomerId) 
					BEGIN 
						INSERT INTO tblCFAccountQuote
						(
							 intSiteId
							,strSite
							,strAddress
							,strCity
							,strState
							,intEntityCustomerId
						)
						SELECT
							 intSiteId
							,strSiteNumber 
							,strSiteAddress
							,strSiteCity
							,strTaxState
							,@intCustomerId
						FROM @tblNetworkSiteItem
						WHERE 
						intNetworkId	 = @loopNetworkId	
						AND intSiteId	 = @loopSiteId	
						--AND intItemId	 = @loopItemId	
						AND intARItemId	 = @loopARItemId	
						AND strSiteType	 = @loopSiteType	
					END

					IF(@intItemSequence = 1)
					BEGIN

						UPDATE tblCFAccountQuote
						SET
						 intItem1 = tblnsi.intARItemId
						,strItem1 = tblnsi.strProductNumber
						FROM @tblNetworkSiteItem as tblnsi
						WHERE 
						intNetworkId	 = @loopNetworkId	
						AND tblnsi.intSiteId	 = @loopSiteId	
						--AND tblnsi.intItemId	 = @loopItemId	
						AND tblnsi.intARItemId	 = @loopARItemId	
						AND tblnsi.strSiteType	 = @loopSiteType	

						UPDATE tblCFAccountQuote
						SET dblItem1Price	= (SELECT TOP 1 ISNULL(dblTaxCalculatedAmount,0)	FROM ##tblCFTransactionPriceType WHERE strTransactionPriceId = 'Gross Price')
						WHERE intSiteId = @loopSiteId
						AND intEntityCustomerId = @intCustomerId

					END

					IF(@intItemSequence = 2)
					BEGIN

						UPDATE tblCFAccountQuote
						SET
						 intItem2 = tblnsi.intARItemId
						,strItem2 = tblnsi.strProductNumber
						FROM @tblNetworkSiteItem as tblnsi
						WHERE 
						intNetworkId	 = @loopNetworkId	
						AND tblnsi.intSiteId	 = @loopSiteId	
						--AND tblnsi.intItemId	 = @loopItemId	
						AND tblnsi.intARItemId	 = @loopARItemId	
						AND tblnsi.strSiteType	 = @loopSiteType	

						UPDATE tblCFAccountQuote
						SET dblItem2Price	= (SELECT TOP 1 ISNULL(dblTaxCalculatedAmount,0)	FROM ##tblCFTransactionPriceType WHERE strTransactionPriceId = 'Gross Price')
						WHERE intSiteId = @loopSiteId
						AND intEntityCustomerId = @intCustomerId

					END

					IF(@intItemSequence = 3)
					BEGIN

						UPDATE tblCFAccountQuote
						SET
						 intItem3 = tblnsi.intARItemId
						,strItem3 = tblnsi.strProductNumber
						FROM @tblNetworkSiteItem as tblnsi
						WHERE 
						intNetworkId	 = @loopNetworkId	
						AND tblnsi.intSiteId	 = @loopSiteId	
						--AND tblnsi.intItemId	 = @loopItemId	
						AND tblnsi.intARItemId	 = @loopARItemId	
						AND tblnsi.strSiteType	 = @loopSiteType	

						UPDATE tblCFAccountQuote
						SET dblItem3Price	= (SELECT TOP 1 ISNULL(dblTaxCalculatedAmount,0)	FROM ##tblCFTransactionPriceType WHERE strTransactionPriceId = 'Gross Price')
						WHERE intSiteId = @loopSiteId
						AND intEntityCustomerId = @intCustomerId

					END

					IF(@intItemSequence = 4)
					BEGIN

						UPDATE tblCFAccountQuote
						SET
						 intItem4 = tblnsi.intARItemId
						,strItem4 = tblnsi.strProductNumber
						FROM @tblNetworkSiteItem as tblnsi
						WHERE 
						intNetworkId	 = @loopNetworkId	
						AND tblnsi.intSiteId	 = @loopSiteId	
						--AND tblnsi.intItemId	 = @loopItemId	
						AND tblnsi.intARItemId	 = @loopARItemId	
						AND tblnsi.strSiteType	 = @loopSiteType	

						UPDATE tblCFAccountQuote
						SET dblItem4Price	= (SELECT TOP 1 ISNULL(dblTaxCalculatedAmount,0)	FROM ##tblCFTransactionPriceType WHERE strTransactionPriceId = 'Gross Price')
						WHERE intSiteId = @loopSiteId
						AND intEntityCustomerId = @intCustomerId

					END

					IF(@intItemSequence = 5)
					BEGIN

						UPDATE tblCFAccountQuote
						SET
						 intItem5 = tblnsi.intARItemId
						,strItem5 = tblnsi.strProductNumber
						FROM @tblNetworkSiteItem as tblnsi
						WHERE 
						intNetworkId	 = @loopNetworkId	
						AND tblnsi.intSiteId	 = @loopSiteId	
						--AND tblnsi.intItemId	 = @loopItemId	
						AND tblnsi.intARItemId	 = @loopARItemId	
						AND tblnsi.strSiteType	 = @loopSiteType	

						UPDATE tblCFAccountQuote
						SET dblItem5Price	= (SELECT TOP 1 ISNULL(dblTaxCalculatedAmount,0)	FROM ##tblCFTransactionPriceType WHERE strTransactionPriceId = 'Gross Price')
						WHERE intSiteId = @loopSiteId
						AND intEntityCustomerId = @intCustomerId

					END
			END
		END


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
			--AND intItemId		= @loopItemId			
			AND intARItemId		= @loopARItemId		
			AND strSiteType		 = @loopSiteType		
		

		

	END


	
END


