CREATE FUNCTION [dbo].[fnCFRemoteTaxes] 
    (   
		 @strTaxState					NVARCHAR(MAX)   = 'ALL'
		,@strTaxCodeId					NVARCHAR(MAX)	= ''
		,@FederalExciseTaxRate        	NUMERIC(18,6)	= 0.000000
		,@StateExciseTaxRate1         	NUMERIC(18,6)	= 0.000000
		,@StateExciseTaxRate2         	NUMERIC(18,6)	= 0.000000
		,@CountyExciseTaxRate         	NUMERIC(18,6)	= 0.000000
		,@CityExciseTaxRate           	NUMERIC(18,6)	= 0.000000
		,@StateSalesTaxPercentageRate 	NUMERIC(18,6)	= 0.000000
		,@CountySalesTaxPercentageRate	NUMERIC(18,6)	= 0.000000
		,@CitySalesTaxPercentageRate  	NUMERIC(18,6)	= 0.000000
		,@OtherSalesTaxPercentageRate 	NUMERIC(18,6)	= 0.000000
		--,@LC7							NUMERIC(18,6)	= 0.000000
		--,@LC8							NUMERIC(18,6)	= 0.000000
		--,@LC9							NUMERIC(18,6)	= 0.000000
		--,@LC10							NUMERIC(18,6)	= 0.000000
		--,@LC11							NUMERIC(18,6)	= 0.000000
		--,@LC12							NUMERIC(18,6)	= 0.000000
		,@intNetworkId					INT
		,@intItemId						INT
		,@intLocationId					INT
		,@intCustomerId					INT			
		,@intCustomerLocationId			INT			
		,@dtmTransactionDate			DATETIME	
    )
RETURNS @tblTaxTable TABLE
    (
		 [intTransactionDetailTaxId]	INT
		,[intTransactionDetailId]		INT
		,[intTaxGroupMasterId]			INT
		,[intTaxGroupId]				INT
		,[intTaxCodeId]					INT
		,[intTaxClassId]				INT
		,[strTaxableByOtherTaxes]		NVARCHAR(MAX)
		,[strCalculationMethod]			NVARCHAR(30)
		,[dblRate]						NUMERIC(18,6)
		,[dblTax]						NUMERIC(18,6)
		,[dblAdjustedTax]				NUMERIC(18,6)
		,[intTaxAccountId]				INT
		,[ysnSeparateOnInvoice]			BIT
		,[ysnCheckoffTax]				BIT
		,[strTaxCode]					NVARCHAR(100)						
		,[ysnTaxExempt]					BIT
		,[strTaxGroup]					NVARCHAR(100)
		,[ysnInvalid]					BIT
		,[strNotes]						NVARCHAR(MAX)
		,[strReason]					NVARCHAR(MAX)
    )
AS
BEGIN
	DECLARE @tblNetworkTaxMapping TABLE
	(
		 strNetwork						NVARCHAR(MAX)
		,strNetworkType					NVARCHAR(MAX)
		,intNetworkId					INT
		,intNetworkTaxCodeId			INT
		,intTaxCodeId					INT
		,strDescription					NVARCHAR(MAX)
		,strNetworkTaxCode				NVARCHAR(MAX)
		,strState						NVARCHAR(MAX)
		,strTaxCode						NVARCHAR(MAX)
		,intTaxClassId					INT
		,strTaxClass					NVARCHAR(MAX)
		,strCalculationMethod			NVARCHAR(MAX)
		,dblRate						NUMERIC(18,6)
		,strTaxableByOtherTaxes			NVARCHAR(MAX)
		,intSalesTaxAccountId			INT
		,ysnCheckoffTax					BIT
		,ysnTaxExempt					BIT
		,strNotes						NVARCHAR(MAX)
		,strReason						NVARCHAR(MAX)
	)

	DECLARE @tblTaxCodeRecord TABLE
	(
		RecordKey   int ,  -- Array index
		Record      varchar(1000)   
	)

	IF (@strTaxState IS NULL OR @strTaxState = '')
	BEGIN 
		SET @strTaxState = 'ALL'
	END

	DECLARE @ZeroDecimal NUMERIC(18, 6)
			,@intItemCategoryId INT

	SET @ZeroDecimal = 0.000000
	SELECT @intItemCategoryId = intCategoryId FROM tblICItem WHERE intItemId = @intItemId 

	INSERT INTO @tblNetworkTaxMapping
	SELECT
		 cfNetwork.strNetwork				
		,cfNetwork.strNetworkType			
		,cfNetworkTax.intNetworkId			
		,cfNetworkTax.intNetworkTaxCodeId	
		,cfNetworkTax.intTaxCodeId			
		,cfNetworkTax.strDescription			
		,cfNetworkTax.strNetworkTaxCode		
		,cfNetworkTax.strState				
		,smTaxCode.strTaxCode				
		,smTaxCode.intTaxClassId			
		,smTaxClass.strTaxClass			
		,smTaxCodeRate.strCalculationMethod	
		,smTaxCodeRate.dblRate				
		,smTaxCode.strTaxableByOtherTaxes	
		,smTaxCode.intSalesTaxAccountId	
		,smTaxCode.ysnCheckoffTax
		,ysnTaxExempt = E.ysnTaxExempt
		,strNotes = E.strExemptionNotes
		,''
	FROM tblCFNetwork cfNetwork
	INNER JOIN tblCFNetworkTaxCode cfNetworkTax
		ON cfNetwork.intNetworkId = cfNetworkTax.intNetworkId
	INNER JOIN tblSMTaxCode smTaxCode
		ON cfNetworkTax.intTaxCodeId = smTaxCode.intTaxCodeId
	INNER JOIN tblSMTaxClass smTaxClass
		ON smTaxCode.intTaxClassId = smTaxClass.intTaxClassId
	INNER JOIN tblSMTaxCodeRate smTaxCodeRate
		ON smTaxCode.intTaxCodeId = smTaxCodeRate.intTaxCodeId
	CROSS APPLY
		[dbo].[fnGetCustomerTaxCodeExemptionDetails](@intCustomerId, @dtmTransactionDate, smTaxCode.intTaxCodeId, smTaxClass.intTaxClassId, smTaxCode.strState, @intItemId, @intItemCategoryId, @intCustomerLocationId,null) E
	WHERE cfNetwork.intNetworkId = @intNetworkId


	IF(@FederalExciseTaxRate != 0)
	BEGIN
		IF ((SELECT COUNT(*) FROM @tblNetworkTaxMapping WHERE strNetworkTaxCode = 'Federal Excise Tax Rate' AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  AND (strState = @strTaxState OR strState IS NULL OR strState = '')) != 0)
		BEGIN 
			INSERT INTO @tblTaxTable
			SELECT TOP 1
				 0
				,0	
				,0		
				,0			
				,[intTaxCodeId]				
				,[intTaxClassId]			
				,[strTaxableByOtherTaxes]	
				,[strCalculationMethod]		
				,@FederalExciseTaxRate					
				,null					
				,null			
				,[intSalesTaxAccountId]			
				,0		
				,[ysnCheckoffTax]			
				,[strTaxCode]				
				,[ysnTaxExempt]				
				,''				
				,0				
				,[strNotes]		
				,''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'Federal Excise Tax Rate'
		END
		ELSE
		BEGIN
			INSERT INTO @tblTaxTable(
				 [ysnInvalid]
				,[strReason]
			)
			VALUES(
				 1
				,'Unable to find match for ' + @strTaxState + ' state tax Federal Excise Tax Rate'
			)
		END
	END

	IF(@StateExciseTaxRate1 != 0)
	BEGIN
		IF ((SELECT COUNT(*) FROM @tblNetworkTaxMapping WHERE strNetworkTaxCode = 'State Excise Tax Rate 1' AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  AND (strState = @strTaxState OR strState IS NULL OR strState = '')) != 0)
		BEGIN 
			INSERT INTO @tblTaxTable
			SELECT TOP 1
				 0
				,0	
				,0		
				,0			
				,[intTaxCodeId]				
				,[intTaxClassId]			
				,[strTaxableByOtherTaxes]	
				,[strCalculationMethod]		
				,@StateExciseTaxRate1					
				,null					
				,null			
				,[intSalesTaxAccountId]			
				,0		
				,[ysnCheckoffTax]			
				,[strTaxCode]				
				,[ysnTaxExempt]				
				,''				
				,0				
				,[strNotes]		
				,''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'State Excise Tax Rate 1'
		END
		ELSE
		BEGIN
			INSERT INTO @tblTaxTable(
				 [ysnInvalid]
				,[strReason]
			)
			VALUES(
				 1
				,'Unable to find match for ' + @strTaxState + ' state tax State Excise Tax Rate 1'
			)
		END
	END

	IF(@StateExciseTaxRate2 != 0)
	BEGIN
		IF ((SELECT COUNT(*) FROM @tblNetworkTaxMapping WHERE strNetworkTaxCode = 'State Excise Tax Rate 2' AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  AND (strState = @strTaxState OR strState IS NULL OR strState = '')) != 0)
		BEGIN 
			INSERT INTO @tblTaxTable
			SELECT TOP 1
				 0
				,0	
				,0		
				,0			
				,[intTaxCodeId]				
				,[intTaxClassId]			
				,[strTaxableByOtherTaxes]	
				,[strCalculationMethod]		
				,@StateExciseTaxRate2					
				,null					
				,null			
				,[intSalesTaxAccountId]			
				,0		
				,[ysnCheckoffTax]			
				,[strTaxCode]				
				,[ysnTaxExempt]				
				,''				
				,0				
				,[strNotes]		
				,''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'State Excise Tax Rate 2'
		END
		ELSE
		BEGIN
			INSERT INTO @tblTaxTable(
				 [ysnInvalid]
				,[strReason]
			)
			VALUES(
				 1
				,'Unable to find match for ' + @strTaxState + ' state tax State Excise Tax Rate 2'
			)
		END
	END

	IF(@CountyExciseTaxRate != 0)
	BEGIN
		IF ((SELECT COUNT(*) FROM @tblNetworkTaxMapping WHERE strNetworkTaxCode = 'County Excise Tax Rate' AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  AND (strState = @strTaxState OR strState IS NULL OR strState = '')) != 0)
		BEGIN 
			INSERT INTO @tblTaxTable
			SELECT TOP 1
				  0
				,0	
				,0		
				,0			
				,[intTaxCodeId]				
				,[intTaxClassId]			
				,[strTaxableByOtherTaxes]	
				,[strCalculationMethod]		
				,@CountyExciseTaxRate					
				,null					
				,null			
				,[intSalesTaxAccountId]			
				,0		
				,[ysnCheckoffTax]			
				,[strTaxCode]				
				,[ysnTaxExempt]				
				,''				
				,0				
				,[strNotes]		
				,''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'County Excise Tax Rate'
		END
		ELSE
		BEGIN
			INSERT INTO @tblTaxTable(
				 [ysnInvalid]
				,[strReason]
			)
			VALUES(
				 1
				,'Unable to find match for ' + @strTaxState + ' state tax County Excise Tax Rate'
			)
		END
	END

	IF(@CityExciseTaxRate != 0)
	BEGIN
		IF ((SELECT COUNT(*) FROM @tblNetworkTaxMapping WHERE strNetworkTaxCode = 'City Excise Tax Rate' AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  AND (strState = @strTaxState OR strState IS NULL OR strState = '')) != 0)
		BEGIN 
			INSERT INTO @tblTaxTable
			SELECT TOP 1
				  0
				,0	
				,0		
				,0			
				,[intTaxCodeId]				
				,[intTaxClassId]			
				,[strTaxableByOtherTaxes]	
				,[strCalculationMethod]		
				,@CityExciseTaxRate					
				,null					
				,null			
				,[intSalesTaxAccountId]			
				,0		
				,[ysnCheckoffTax]			
				,[strTaxCode]				
				,[ysnTaxExempt]				
				,''				
				,0				
				,[strNotes]		
				,''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'City Excise Tax Rate'
		END
		ELSE
		BEGIN
			INSERT INTO @tblTaxTable(
				 [ysnInvalid]
				,[strReason]
			)
			VALUES(
				 1
				,'Unable to find match for ' + @strTaxState + ' state tax City Excise Tax Rate'
			)
		END
	END

	IF(@StateSalesTaxPercentageRate != 0)
	BEGIN
		IF ((SELECT COUNT(*) FROM @tblNetworkTaxMapping WHERE strNetworkTaxCode = 'State Sales Tax Percentage Rate' AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  AND (strState = @strTaxState OR strState IS NULL OR strState = '')) != 0)
		BEGIN 
			INSERT INTO @tblTaxTable
			SELECT TOP 1
				 0
				,0	
				,0		
				,0			
				,[intTaxCodeId]				
				,[intTaxClassId]			
				,[strTaxableByOtherTaxes]	
				,[strCalculationMethod]		
				,@StateSalesTaxPercentageRate					
				,null					
				,null			
				,[intSalesTaxAccountId]			
				,0		
				,[ysnCheckoffTax]			
				,[strTaxCode]				
				,[ysnTaxExempt]				
				,''				
				,0				
				,[strNotes]		
				,''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'State Sales Tax Percentage Rate'
		END
		ELSE
		BEGIN
			INSERT INTO @tblTaxTable(
				 [ysnInvalid]
				,[strReason]
			)
			VALUES(
				 1
				,'Unable to find match for ' + @strTaxState + ' state tax State Sales Tax Percentage Rate'
			)
		END
	END

	IF(@CountySalesTaxPercentageRate != 0)
	BEGIN
		IF ((SELECT COUNT(*) FROM @tblNetworkTaxMapping WHERE strNetworkTaxCode = 'County Sales Tax Percentage Rate' AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  AND (strState = @strTaxState OR strState IS NULL OR strState = '')) != 0)
		BEGIN 
			INSERT INTO @tblTaxTable
			SELECT TOP 1
				  0
				,0	
				,0		
				,0			
				,[intTaxCodeId]				
				,[intTaxClassId]			
				,[strTaxableByOtherTaxes]	
				,[strCalculationMethod]		
				,@CountySalesTaxPercentageRate					
				,null					
				,null			
				,[intSalesTaxAccountId]			
				,0		
				,[ysnCheckoffTax]			
				,[strTaxCode]				
				,[ysnTaxExempt]				
				,''				
				,0				
				,[strNotes]		
				,''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'County Sales Tax Percentage Rate'
		END
		ELSE
		BEGIN
			INSERT INTO @tblTaxTable(
				 [ysnInvalid]
				,[strReason]
			)
			VALUES(
				 1
				,'Unable to find match for ' + @strTaxState + ' state tax County Sales Tax Percentage Rate'
			)
		END
	END

	IF(@CitySalesTaxPercentageRate != 0)
	BEGIN
		IF ((SELECT COUNT(*) FROM @tblNetworkTaxMapping WHERE strNetworkTaxCode = 'City Sales Tax Percentage Rate' AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  AND (strState = @strTaxState OR strState IS NULL OR strState = '')) != 0)
		BEGIN 
			INSERT INTO @tblTaxTable
			SELECT TOP 1
				  0
				,0	
				,0		
				,0			
				,[intTaxCodeId]				
				,[intTaxClassId]			
				,[strTaxableByOtherTaxes]	
				,[strCalculationMethod]		
				,@CitySalesTaxPercentageRate					
				,null					
				,null			
				,[intSalesTaxAccountId]			
				,0		
				,[ysnCheckoffTax]			
				,[strTaxCode]				
				,[ysnTaxExempt]				
				,''				
				,0				
				,[strNotes]		
				,''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'City Sales Tax Percentage Rate'
		END
		ELSE
		BEGIN
			INSERT INTO @tblTaxTable(
				 [ysnInvalid]
				,[strReason]
			)
			VALUES(
				 1
				,'Unable to find match for ' + @strTaxState + ' state tax City Sales Tax Percentage Rate'
			)
		END
	END

	IF(@OtherSalesTaxPercentageRate != 0)
	BEGIN
		IF ((SELECT COUNT(*) FROM @tblNetworkTaxMapping WHERE strNetworkTaxCode = 'Other Sales Tax Percentage Rate' AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  AND (strState = @strTaxState OR strState IS NULL OR strState = '')) != 0)
		BEGIN 
			INSERT INTO @tblTaxTable
			SELECT TOP 1
				  0
				,0	
				,0		
				,0			
				,[intTaxCodeId]				
				,[intTaxClassId]			
				,[strTaxableByOtherTaxes]	
				,[strCalculationMethod]		
				,@OtherSalesTaxPercentageRate					
				,null					
				,null			
				,[intSalesTaxAccountId]			
				,0		
				,[ysnCheckoffTax]			
				,[strTaxCode]				
				,[ysnTaxExempt]				
				,''				
				,0				
				,[strNotes]		
				,''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'Other Sales Tax Percentage Rate'
		END
		ELSE
		BEGIN
			INSERT INTO @tblTaxTable(
				 [ysnInvalid]
				,[strReason]
			)
			VALUES(
				 1
				,'Unable to find match for ' + @strTaxState + ' state tax Other Sales Tax Percentage Rate'
			)
		END
	END

	--IF(@LC7 != 0)
	--BEGIN
	--	IF ((SELECT COUNT(*) FROM @tblNetworkTaxMapping WHERE strNetworkTaxCode = 'LC7' AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  AND (strState = @strTaxState OR strState IS NULL OR strState = '')) != 0)
	--	BEGIN 
	--		INSERT INTO @tblTaxTable
	--		SELECT TOP 1
	--			  0
	--			,0	
	--			,0		
	--			,0			
	--			,[intTaxCodeId]				
	--			,[intTaxClassId]			
	--			,[strTaxableByOtherTaxes]	
	--			,[strCalculationMethod]		
	--			,@LC7					
	--			,null					
	--			,null			
	--			,[intSalesTaxAccountId]			
	--			,0		
	--			,[ysnCheckoffTax]			
	--			,[strTaxCode]				
	--			,[ysnTaxExempt]				
	--			,''				
	--			,0				
	--			,[strNotes]		
	--			,''			
	--		FROM
	--			@tblNetworkTaxMapping
	--		WHERE strNetworkTaxCode = 'LC7'
	--	END
	--	ELSE
	--	BEGIN
	--		INSERT INTO @tblTaxTable(
	--			 [ysnInvalid]
	--			,[strReason]
	--		)
	--		VALUES(
	--			 1
	--			,'Unable to find match for ' + @strTaxState + ' state tax LC7'
	--		)
	--	END
	--END

	--IF(@LC8 != 0)
	--BEGIN
	--	IF ((SELECT COUNT(*) FROM @tblNetworkTaxMapping WHERE strNetworkTaxCode = 'LC8' AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  AND (strState = @strTaxState OR strState IS NULL OR strState = '')) != 0)
	--	BEGIN 
	--		INSERT INTO @tblTaxTable
	--		SELECT TOP 1
	--			  0
	--			,0	
	--			,0		
	--			,0			
	--			,[intTaxCodeId]				
	--			,[intTaxClassId]			
	--			,[strTaxableByOtherTaxes]	
	--			,[strCalculationMethod]		
	--			,@LC8					
	--			,null					
	--			,null			
	--			,[intSalesTaxAccountId]			
	--			,0		
	--			,[ysnCheckoffTax]			
	--			,[strTaxCode]				
	--			,[ysnTaxExempt]				
	--			,''				
	--			,0				
	--			,[strNotes]		
	--			,''			
	--		FROM
	--			@tblNetworkTaxMapping
	--		WHERE strNetworkTaxCode = 'LC8'
	--	END
	--	ELSE
	--	BEGIN
	--		INSERT INTO @tblTaxTable(
	--			 [ysnInvalid]
	--			,[strReason]
	--		)
	--		VALUES(
	--			 1
	--			,'Unable to find match for ' + @strTaxState + ' state tax LC8'
	--		)
	--	END
	--END

	--IF(@LC9 != 0)
	--BEGIN
	--	IF ((SELECT COUNT(*) FROM @tblNetworkTaxMapping WHERE strNetworkTaxCode = 'LC9' AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  AND (strState = @strTaxState OR strState IS NULL OR strState = '')) != 0)
	--	BEGIN 
	--		INSERT INTO @tblTaxTable
	--		SELECT TOP 1
	--			  0
	--			,0	
	--			,0		
	--			,0			
	--			,[intTaxCodeId]				
	--			,[intTaxClassId]			
	--			,[strTaxableByOtherTaxes]	
	--			,[strCalculationMethod]		
	--			,@LC9					
	--			,null					
	--			,null			
	--			,[intSalesTaxAccountId]			
	--			,0		
	--			,[ysnCheckoffTax]			
	--			,[strTaxCode]				
	--			,[ysnTaxExempt]				
	--			,''				
	--			,0				
	--			,[strNotes]		
	--			,''			
	--		FROM
	--			@tblNetworkTaxMapping
	--		WHERE strNetworkTaxCode = 'LC9'
	--	END
	--	ELSE
	--	BEGIN
	--		INSERT INTO @tblTaxTable(
	--			 [ysnInvalid]
	--			,[strReason]
	--		)
	--		VALUES(
	--			 1
	--			,'Unable to find match for ' + @strTaxState + ' state tax LC9'
	--		)
	--	END
	--END

	--IF(@LC10 != 0)
	--BEGIN
	--	IF ((SELECT COUNT(*) FROM @tblNetworkTaxMapping WHERE strNetworkTaxCode = 'LC10' AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  AND (strState = @strTaxState OR strState IS NULL OR strState = '')) != 0)
	--	BEGIN 
	--		INSERT INTO @tblTaxTable
	--		SELECT TOP 1
	--			  0
	--			,0	
	--			,0		
	--			,0			
	--			,[intTaxCodeId]				
	--			,[intTaxClassId]			
	--			,[strTaxableByOtherTaxes]	
	--			,[strCalculationMethod]		
	--			,@LC10					
	--			,null					
	--			,null			
	--			,[intSalesTaxAccountId]			
	--			,0		
	--			,[ysnCheckoffTax]			
	--			,[strTaxCode]				
	--			,[ysnTaxExempt]				
	--			,''				
	--			,0				
	--			,[strNotes]		
	--			,''			
	--		FROM
	--			@tblNetworkTaxMapping
	--		WHERE strNetworkTaxCode = 'LC10'
	--	END
	--	ELSE
	--	BEGIN
	--		INSERT INTO @tblTaxTable(
	--			 [ysnInvalid]
	--			,[strReason]
	--		)
	--		VALUES(
	--			 1
	--			,'Unable to find match for ' + @strTaxState + ' state tax LC10'
	--		)
	--	END
	--END

	--IF(@LC11 != 0)
	--BEGIN
	--	IF ((SELECT COUNT(*) FROM @tblNetworkTaxMapping WHERE strNetworkTaxCode = 'LC11' AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  AND (strState = @strTaxState OR strState IS NULL OR strState = '')) != 0)
	--	BEGIN 
	--		INSERT INTO @tblTaxTable
	--		SELECT TOP 1
	--			  0
	--			,0	
	--			,0		
	--			,0			
	--			,[intTaxCodeId]				
	--			,[intTaxClassId]			
	--			,[strTaxableByOtherTaxes]	
	--			,[strCalculationMethod]		
	--			,@LC11					
	--			,null					
	--			,null			
	--			,[intSalesTaxAccountId]			
	--			,0		
	--			,[ysnCheckoffTax]			
	--			,[strTaxCode]				
	--			,[ysnTaxExempt]				
	--			,''				
	--			,0				
	--			,[strNotes]		
	--			,''			
	--		FROM
	--			@tblNetworkTaxMapping
	--		WHERE strNetworkTaxCode = 'LC11'
	--	END
	--	ELSE
	--	BEGIN
	--		INSERT INTO @tblTaxTable(
	--			 [ysnInvalid]
	--			,[strReason]
	--		)
	--		VALUES(
	--			 1
	--			,'Unable to find match for ' + @strTaxState + ' state tax LC11'
	--		)
	--	END
	--END

	--IF(@LC12 != 0)
	--BEGIN
	--	IF ((SELECT COUNT(*) FROM @tblNetworkTaxMapping WHERE strNetworkTaxCode = 'LC12' AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  AND (strState = @strTaxState OR strState IS NULL OR strState = '')) != 0)
	--	BEGIN 
	--		INSERT INTO @tblTaxTable
	--		SELECT TOP 1
	--			  0
	--			,0	
	--			,0		
	--			,0			
	--			,[intTaxCodeId]				
	--			,[intTaxClassId]			
	--			,[strTaxableByOtherTaxes]	
	--			,[strCalculationMethod]		
	--			,@LC12					
	--			,null					
	--			,null			
	--			,[intSalesTaxAccountId]			
	--			,0		
	--			,[ysnCheckoffTax]			
	--			,[strTaxCode]				
	--			,[ysnTaxExempt]				
	--			,''				
	--			,0				
	--			,[strNotes]		
	--			,''			
	--		FROM
	--			@tblNetworkTaxMapping
	--		WHERE strNetworkTaxCode = 'LC12'
	--	END
	--	ELSE
	--	BEGIN
	--		INSERT INTO @tblTaxTable(
	--			 [ysnInvalid]
	--			,[strReason]
	--		)
	--		VALUES(
	--			 1
	--			,'Unable to find match for ' + @strTaxState + ' state tax LC12'
	--		)
	--	END
	--END


	IF(@strTaxCodeId != '')
	BEGIN
		INSERT INTO @tblTaxCodeRecord(
		 [Record]
		,[RecordKey]
		)
		SELECT 
		Record,
		RecordKey
		FROM [fnCFSplitString](@strTaxCodeId,',') 
			
			DECLARE @intCreatedRecordKey INT
			DECLARE @intCreatedInvoiceId INT
			WHILE (EXISTS(SELECT 1 FROM @tblTaxCodeRecord))
			BEGIN
				SELECT @intCreatedRecordKey = RecordKey FROM @tblTaxCodeRecord
				SELECT @intCreatedInvoiceId = CAST(Record AS INT) FROM @tblTaxCodeRecord WHERE RecordKey = @intCreatedRecordKey
				
				IF ((SELECT COUNT(*) FROM @tblNetworkTaxMapping WHERE (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  AND (strState = @strTaxState OR strState IS NULL OR strState = '')) != 0)
				BEGIN 
					INSERT INTO @tblTaxTable
					SELECT TOP 1
						 0
						,0	
						,0		
						,0			
						,[intTaxCodeId]				
						,[intTaxClassId]			
						,[strTaxableByOtherTaxes]	
						,[strCalculationMethod]		
						,0				
						,null					
						,null			
						,[intSalesTaxAccountId]			
						,0		
						,[ysnCheckoffTax]			
						,[strTaxCode]				
						,[ysnTaxExempt]				
						,''				
						,0				
						,[strNotes]		
						,''			
					FROM
						@tblNetworkTaxMapping
					WHERE [intTaxCodeId] = @intCreatedInvoiceId
				END
				ELSE
				BEGIN
					INSERT INTO @tblTaxTable(
						 [ysnInvalid]
						,[strReason]
					)
					VALUES(
						 1
						,'Unable to find match for ' + @strTaxState + ' state tax'
					)
				END

				DELETE FROM @tblTaxCodeRecord WHERE RecordKey = @intCreatedRecordKey

			END
		
	END



    RETURN
END