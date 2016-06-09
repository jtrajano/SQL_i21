CREATE FUNCTION [dbo].[fnCFRemoteTaxes] 
    (   
		 @strTaxState					NVARCHAR(MAX)   = ''
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
		,[ysnInvalidSetup]				BIT
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
		,ysnInvalidSetup				BIT
		,intItemCategoryId				INT
	)

	DECLARE @tblTaxCodeRecord TABLE
	(
		RecordKey   int ,  -- Array index
		Record      varchar(1000)   
	)

	--IF (@strTaxState IS NULL OR @strTaxState = '')
	--BEGIN 
	--	SET @strTaxState = ''
	--END

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
		,strReason = E.strExemptionNotes
		,E.ysnInvalidSetup
		,cfNetworkTax.intItemCategory
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

	

	DECLARE @intFirstLevelMatch INT
	DECLARE @intSecondLevelMatch INT
	DECLARE @intThirdLevelMatch INT
	DECLARE @intFourthLevelMatch INT


	------------------------------
	-- Federal Excise Tax Rate  --
	------------------------------

	IF(@FederalExciseTaxRate != 0)
	BEGIN
		-- STATE AND CATEGORY
		SET @intFirstLevelMatch = (SELECT COUNT(*) 
									FROM @tblNetworkTaxMapping 
									WHERE strNetworkTaxCode = 'Federal Excise Tax Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND strState = @strTaxState 
									AND intItemCategoryId = @intItemCategoryId)

		-- NO STATE AND CATEGORY
		SET @intSecondLevelMatch = (SELECT COUNT(*) 
									FROM @tblNetworkTaxMapping 
									WHERE strNetworkTaxCode = 'Federal Excise Tax Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND (strState IS NULL OR strState = '')
									AND intItemCategoryId = @intItemCategoryId)
									
		-- STATE AND NO CATEGORY
		SET @intThirdLevelMatch = (SELECT COUNT(*) 
									FROM @tblNetworkTaxMapping 
									WHERE strNetworkTaxCode = 'Federal Excise Tax Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND strState = @strTaxState
									AND (intItemCategoryId IS NULL OR intItemCategoryId = 0)) 

		-- NO STATE AND NO CATEGORY							
		SET @intFourthLevelMatch = (SELECT COUNT(*) 
									FROM @tblNetworkTaxMapping 
									WHERE strNetworkTaxCode = 'Federal Excise Tax Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)
									AND (intItemCategoryId IS NULL OR intItemCategoryId = 0)
									AND (strState IS NULL OR strState = ''))


		IF(@intFirstLevelMatch > 0)
		BEGIN
			INSERT INTO @tblTaxTable(
				[intTransactionDetailTaxId],[intTransactionDetailId],[intTaxGroupMasterId],[intTaxGroupId],[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],[dblRate],[dblTax],[dblAdjustedTax],[intTaxAccountId],[ysnSeparateOnInvoice],[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],[strTaxGroup],[ysnInvalidSetup],[strNotes],[strReason]		
			)
			SELECT TOP 1
				 0,0,0,0,[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],@FederalExciseTaxRate,0,0,[intSalesTaxAccountId],0,[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],'',[ysnInvalidSetup],[strNotes],''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'Federal Excise Tax Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND strState = @strTaxState 
									AND intItemCategoryId = @intItemCategoryId
		END
		ELSE IF (@intSecondLevelMatch > 0)
		BEGIN
			INSERT INTO @tblTaxTable(
				[intTransactionDetailTaxId],[intTransactionDetailId],[intTaxGroupMasterId],[intTaxGroupId],[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],[dblRate],[dblTax],[dblAdjustedTax],[intTaxAccountId],[ysnSeparateOnInvoice],[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],[strTaxGroup],[ysnInvalidSetup],[strNotes],[strReason]		
			)
			SELECT TOP 1
				 0,0,0,0,[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],@FederalExciseTaxRate,0,0,[intSalesTaxAccountId],0,[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],'',[ysnInvalidSetup],[strNotes],''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'Federal Excise Tax Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND (strState IS NULL OR strState = '')
									AND intItemCategoryId = @intItemCategoryId
		END
		ELSE IF (@intThirdLevelMatch > 0)
		BEGIN
			INSERT INTO @tblTaxTable(
				[intTransactionDetailTaxId],[intTransactionDetailId],[intTaxGroupMasterId],[intTaxGroupId],[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],[dblRate],[dblTax],[dblAdjustedTax],[intTaxAccountId],[ysnSeparateOnInvoice],[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],[strTaxGroup],[ysnInvalidSetup],[strNotes],[strReason]		
			)
			SELECT TOP 1
				 0,0,0,0,[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],@FederalExciseTaxRate,0,0,[intSalesTaxAccountId],0,[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],'',[ysnInvalidSetup],[strNotes],''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'Federal Excise Tax Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND strState = @strTaxState
									AND (intItemCategoryId IS NULL OR intItemCategoryId = 0)
		END
		ELSE IF (@intFourthLevelMatch > 0)
		BEGIN
			INSERT INTO @tblTaxTable(
				[intTransactionDetailTaxId],[intTransactionDetailId],[intTaxGroupMasterId],[intTaxGroupId],[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],[dblRate],[dblTax],[dblAdjustedTax],[intTaxAccountId],[ysnSeparateOnInvoice],[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],[strTaxGroup],[ysnInvalidSetup],[strNotes],[strReason]		
			)
			SELECT TOP 1
				 0,0,0,0,[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],@FederalExciseTaxRate,0,0,[intSalesTaxAccountId],0,[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],'',[ysnInvalidSetup],[strNotes],''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'Federal Excise Tax Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)
									AND (intItemCategoryId IS NULL OR intItemCategoryId = 0)
									AND (strState IS NULL OR strState = '')
		END
		ELSE
		BEGIN
			INSERT INTO @tblTaxTable(
				 [ysnInvalidSetup]
				,[strReason]
			)
			VALUES(
				 1
				,'Unable to find match for ' + @strTaxState + ' state tax Federal Excise Tax Rate'
			)
		END
	END
	------------------------------
	-- Federal Excise Tax Rate  --
	------------------------------





	------------------------------
	-- State Excise Tax Rate 1  --
	------------------------------
	IF(@StateExciseTaxRate1 != 0)
	BEGIN
		-- STATE AND CATEGORY
		SET @intFirstLevelMatch = (SELECT COUNT(*) 
									FROM @tblNetworkTaxMapping 
									WHERE strNetworkTaxCode = 'State Excise Tax Rate 1' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND strState = @strTaxState 
									AND intItemCategoryId = @intItemCategoryId)

		-- NO STATE AND CATEGORY
		SET @intSecondLevelMatch = (SELECT COUNT(*) 
									FROM @tblNetworkTaxMapping 
									WHERE strNetworkTaxCode = 'State Excise Tax Rate 1' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND (strState IS NULL OR strState = '')
									AND intItemCategoryId = @intItemCategoryId)
									
		-- STATE AND NO CATEGORY
		SET @intThirdLevelMatch = (SELECT COUNT(*) 
									FROM @tblNetworkTaxMapping 
									WHERE strNetworkTaxCode = 'State Excise Tax Rate 1' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND strState = @strTaxState
									AND (intItemCategoryId IS NULL OR intItemCategoryId = 0)) 

		-- NO STATE AND NO CATEGORY							
		SET @intFourthLevelMatch = (SELECT COUNT(*) 
									FROM @tblNetworkTaxMapping 
									WHERE strNetworkTaxCode = 'State Excise Tax Rate 1' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)
									AND (intItemCategoryId IS NULL OR intItemCategoryId = 0)
									AND (strState IS NULL OR strState = ''))

		IF(@intFirstLevelMatch > 0)
		BEGIN
			INSERT INTO @tblTaxTable(
				[intTransactionDetailTaxId],[intTransactionDetailId],[intTaxGroupMasterId],[intTaxGroupId],[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],[dblRate],[dblTax],[dblAdjustedTax],[intTaxAccountId],[ysnSeparateOnInvoice],[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],[strTaxGroup],[ysnInvalidSetup],[strNotes],[strReason]		
			)
			SELECT TOP 1
				 0,0,0,0,[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],@StateExciseTaxRate1,0,0,[intSalesTaxAccountId],0,[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],'',[ysnInvalidSetup],[strNotes],''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'State Excise Tax Rate 1' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND strState = @strTaxState 
									AND intItemCategoryId = @intItemCategoryId
		END
		ELSE IF (@intSecondLevelMatch > 0)
		BEGIN
			INSERT INTO @tblTaxTable(
				[intTransactionDetailTaxId],[intTransactionDetailId],[intTaxGroupMasterId],[intTaxGroupId],[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],[dblRate],[dblTax],[dblAdjustedTax],[intTaxAccountId],[ysnSeparateOnInvoice],[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],[strTaxGroup],[ysnInvalidSetup],[strNotes],[strReason]		
			)
			SELECT TOP 1
				 0,0,0,0,[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],@StateExciseTaxRate1,0,0,[intSalesTaxAccountId],0,[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],'',[ysnInvalidSetup],[strNotes],''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'State Excise Tax Rate 1' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND (strState IS NULL OR strState = '')
									AND intItemCategoryId = @intItemCategoryId
		END
		ELSE IF (@intThirdLevelMatch > 0)
		BEGIN
			INSERT INTO @tblTaxTable(
				[intTransactionDetailTaxId],[intTransactionDetailId],[intTaxGroupMasterId],[intTaxGroupId],[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],[dblRate],[dblTax],[dblAdjustedTax],[intTaxAccountId],[ysnSeparateOnInvoice],[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],[strTaxGroup],[ysnInvalidSetup],[strNotes],[strReason]		
			)
			SELECT TOP 1
				 0,0,0,0,[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],@StateExciseTaxRate1,0,0,[intSalesTaxAccountId],0,[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],'',[ysnInvalidSetup],[strNotes],''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'State Excise Tax Rate 1' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND strState = @strTaxState
									AND (intItemCategoryId IS NULL OR intItemCategoryId = 0)
		END
		ELSE IF (@intFourthLevelMatch > 0)
		BEGIN
			INSERT INTO @tblTaxTable(
				[intTransactionDetailTaxId],[intTransactionDetailId],[intTaxGroupMasterId],[intTaxGroupId],[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],[dblRate],[dblTax],[dblAdjustedTax],[intTaxAccountId],[ysnSeparateOnInvoice],[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],[strTaxGroup],[ysnInvalidSetup],[strNotes],[strReason]		
			)
			SELECT TOP 1
				 0,0,0,0,[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],@StateExciseTaxRate1,0,0,[intSalesTaxAccountId],0,[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],'',[ysnInvalidSetup],[strNotes],''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'State Excise Tax Rate 1' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)
									AND (intItemCategoryId IS NULL OR intItemCategoryId = 0)
									AND (strState IS NULL OR strState = '')
		END
		ELSE
		BEGIN
			INSERT INTO @tblTaxTable(
				 [ysnInvalidSetup]
				,[strReason]
			)
			VALUES(
				 1
				,'Unable to find match for ' + @strTaxState + ' state tax State Excise Tax Rate 1'
			)
		END
	END
	------------------------------
	-- State Excise Tax Rate 1  --
	------------------------------



	------------------------------
	-- State Excise Tax Rate 2  --
	------------------------------


	IF(@StateExciseTaxRate2 != 0)
	BEGIN
		-- STATE AND CATEGORY
		SET @intFirstLevelMatch = (SELECT COUNT(*) 
									FROM @tblNetworkTaxMapping 
									WHERE strNetworkTaxCode = 'State Excise Tax Rate 2' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND strState = @strTaxState 
									AND intItemCategoryId = @intItemCategoryId)

		-- NO STATE AND CATEGORY
		SET @intSecondLevelMatch = (SELECT COUNT(*) 
									FROM @tblNetworkTaxMapping 
									WHERE strNetworkTaxCode = 'State Excise Tax Rate 2' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND (strState IS NULL OR strState = '')
									AND intItemCategoryId = @intItemCategoryId)
									
		-- STATE AND NO CATEGORY
		SET @intThirdLevelMatch = (SELECT COUNT(*) 
									FROM @tblNetworkTaxMapping 
									WHERE strNetworkTaxCode = 'State Excise Tax Rate 2' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND strState = @strTaxState
									AND (intItemCategoryId IS NULL OR intItemCategoryId = 0)) 

		-- NO STATE AND NO CATEGORY							
		SET @intFourthLevelMatch = (SELECT COUNT(*) 
									FROM @tblNetworkTaxMapping 
									WHERE strNetworkTaxCode = 'State Excise Tax Rate 2' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)
									AND (intItemCategoryId IS NULL OR intItemCategoryId = 0)
									AND (strState IS NULL OR strState = ''))

		IF(@intFirstLevelMatch > 0)
		BEGIN
			INSERT INTO @tblTaxTable(
				[intTransactionDetailTaxId],[intTransactionDetailId],[intTaxGroupMasterId],[intTaxGroupId],[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],[dblRate],[dblTax],[dblAdjustedTax],[intTaxAccountId],[ysnSeparateOnInvoice],[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],[strTaxGroup],[ysnInvalidSetup],[strNotes],[strReason]		
			)
			SELECT TOP 1
				 0,0,0,0,[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],@StateExciseTaxRate2,0,0,[intSalesTaxAccountId],0,[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],'',[ysnInvalidSetup],[strNotes],''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'State Excise Tax Rate 2' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND strState = @strTaxState 
									AND intItemCategoryId = @intItemCategoryId
		END
		ELSE IF (@intSecondLevelMatch > 0)
		BEGIN
			INSERT INTO @tblTaxTable(
				[intTransactionDetailTaxId],[intTransactionDetailId],[intTaxGroupMasterId],[intTaxGroupId],[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],[dblRate],[dblTax],[dblAdjustedTax],[intTaxAccountId],[ysnSeparateOnInvoice],[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],[strTaxGroup],[ysnInvalidSetup],[strNotes],[strReason]		
			)
			SELECT TOP 1
				 0,0,0,0,[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],@StateExciseTaxRate2,0,0,[intSalesTaxAccountId],0,[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],'',[ysnInvalidSetup],[strNotes],''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'State Excise Tax Rate 2' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND (strState IS NULL OR strState = '')
									AND intItemCategoryId = @intItemCategoryId
		END
		ELSE IF (@intThirdLevelMatch > 0)
		BEGIN
			INSERT INTO @tblTaxTable(
				[intTransactionDetailTaxId],[intTransactionDetailId],[intTaxGroupMasterId],[intTaxGroupId],[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],[dblRate],[dblTax],[dblAdjustedTax],[intTaxAccountId],[ysnSeparateOnInvoice],[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],[strTaxGroup],[ysnInvalidSetup],[strNotes],[strReason]		
			)
			SELECT TOP 1
				 0,0,0,0,[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],@StateExciseTaxRate2,0,0,[intSalesTaxAccountId],0,[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],'',[ysnInvalidSetup],[strNotes],''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'State Excise Tax Rate 2' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND strState = @strTaxState
									AND (intItemCategoryId IS NULL OR intItemCategoryId = 0)
		END
		ELSE IF (@intFourthLevelMatch > 0)
		BEGIN
			INSERT INTO @tblTaxTable(
				[intTransactionDetailTaxId],[intTransactionDetailId],[intTaxGroupMasterId],[intTaxGroupId],[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],[dblRate],[dblTax],[dblAdjustedTax],[intTaxAccountId],[ysnSeparateOnInvoice],[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],[strTaxGroup],[ysnInvalidSetup],[strNotes],[strReason]		
			)
			SELECT TOP 1
				 0,0,0,0,[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],@StateExciseTaxRate2,0,0,[intSalesTaxAccountId],0,[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],'',[ysnInvalidSetup],[strNotes],''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'State Excise Tax Rate 2' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)
									AND (intItemCategoryId IS NULL OR intItemCategoryId = 0)
									AND (strState IS NULL OR strState = '')
		END
		ELSE
		BEGIN
			INSERT INTO @tblTaxTable(
				 [ysnInvalidSetup]
				,[strReason]
			)
			VALUES(
				 1
				,'Unable to find match for ' + @strTaxState + ' state tax State Excise Tax Rate 2'
			)
		END
	END

	------------------------------
	-- State Excise Tax Rate 2  --
	------------------------------





	-----------------------------
	-- County Excise Tax Rate  --
	-----------------------------

	IF(@CountyExciseTaxRate != 0)
	BEGIN
		-- STATE AND CATEGORY
		SET @intFirstLevelMatch = (SELECT COUNT(*) 
									FROM @tblNetworkTaxMapping 
									WHERE strNetworkTaxCode = 'County Excise Tax Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND strState = @strTaxState 
									AND intItemCategoryId = @intItemCategoryId)

		-- NO STATE AND CATEGORY
		SET @intSecondLevelMatch = (SELECT COUNT(*) 
									FROM @tblNetworkTaxMapping 
									WHERE strNetworkTaxCode = 'County Excise Tax Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND (strState IS NULL OR strState = '')
									AND intItemCategoryId = @intItemCategoryId)
									
		-- STATE AND NO CATEGORY
		SET @intThirdLevelMatch = (SELECT COUNT(*) 
									FROM @tblNetworkTaxMapping 
									WHERE strNetworkTaxCode = 'County Excise Tax Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND strState = @strTaxState
									AND (intItemCategoryId IS NULL OR intItemCategoryId = 0)) 

		-- NO STATE AND NO CATEGORY							
		SET @intFourthLevelMatch = (SELECT COUNT(*) 
									FROM @tblNetworkTaxMapping 
									WHERE strNetworkTaxCode = 'County Excise Tax Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)
									AND (intItemCategoryId IS NULL OR intItemCategoryId = 0)
									AND (strState IS NULL OR strState = ''))

		IF(@intFirstLevelMatch > 0)
		BEGIN
			INSERT INTO @tblTaxTable(
				[intTransactionDetailTaxId],[intTransactionDetailId],[intTaxGroupMasterId],[intTaxGroupId],[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],[dblRate],[dblTax],[dblAdjustedTax],[intTaxAccountId],[ysnSeparateOnInvoice],[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],[strTaxGroup],[ysnInvalidSetup],[strNotes],[strReason]		
			)
			SELECT TOP 1
				 0,0,0,0,[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],@CountyExciseTaxRate,0,0,[intSalesTaxAccountId],0,[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],'',[ysnInvalidSetup],[strNotes],''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'County Excise Tax Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND strState = @strTaxState 
									AND intItemCategoryId = @intItemCategoryId
		END
		ELSE IF (@intSecondLevelMatch > 0)
		BEGIN
			INSERT INTO @tblTaxTable(
				[intTransactionDetailTaxId],[intTransactionDetailId],[intTaxGroupMasterId],[intTaxGroupId],[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],[dblRate],[dblTax],[dblAdjustedTax],[intTaxAccountId],[ysnSeparateOnInvoice],[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],[strTaxGroup],[ysnInvalidSetup],[strNotes],[strReason]		
			)
			SELECT TOP 1
				 0,0,0,0,[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],@CountyExciseTaxRate,0,0,[intSalesTaxAccountId],0,[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],'',[ysnInvalidSetup],[strNotes],''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'County Excise Tax Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND (strState IS NULL OR strState = '')
									AND intItemCategoryId = @intItemCategoryId
		END
		ELSE IF (@intThirdLevelMatch > 0)
		BEGIN
			INSERT INTO @tblTaxTable(
				[intTransactionDetailTaxId],[intTransactionDetailId],[intTaxGroupMasterId],[intTaxGroupId],[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],[dblRate],[dblTax],[dblAdjustedTax],[intTaxAccountId],[ysnSeparateOnInvoice],[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],[strTaxGroup],[ysnInvalidSetup],[strNotes],[strReason]		
			)
			SELECT TOP 1
				 0,0,0,0,[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],@CountyExciseTaxRate,0,0,[intSalesTaxAccountId],0,[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],'',[ysnInvalidSetup],[strNotes],''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'County Excise Tax Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND strState = @strTaxState
									AND (intItemCategoryId IS NULL OR intItemCategoryId = 0)
		END
		ELSE IF (@intFourthLevelMatch > 0)
		BEGIN
			INSERT INTO @tblTaxTable(
				[intTransactionDetailTaxId],[intTransactionDetailId],[intTaxGroupMasterId],[intTaxGroupId],[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],[dblRate],[dblTax],[dblAdjustedTax],[intTaxAccountId],[ysnSeparateOnInvoice],[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],[strTaxGroup],[ysnInvalidSetup],[strNotes],[strReason]		
			)
			SELECT TOP 1
				 0,0,0,0,[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],@CountyExciseTaxRate,0,0,[intSalesTaxAccountId],0,[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],'',[ysnInvalidSetup],[strNotes],''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'County Excise Tax Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)
									AND (intItemCategoryId IS NULL OR intItemCategoryId = 0)
									AND (strState IS NULL OR strState = '')
		END
		ELSE
		BEGIN
			INSERT INTO @tblTaxTable(
				 [ysnInvalidSetup]
				,[strReason]
			)
			VALUES(
				 1
				,'Unable to find match for ' + @strTaxState + ' state tax County Excise Tax Rate'
			)
		END
	END

	-----------------------------
	-- County Excise Tax Rate  --
	-----------------------------




	---------------------------
	-- City Excise Tax Rate  --
	---------------------------

	IF(@CityExciseTaxRate != 0)
	BEGIN
		-- STATE AND CATEGORY
		SET @intFirstLevelMatch = (SELECT COUNT(*) 
									FROM @tblNetworkTaxMapping 
									WHERE strNetworkTaxCode = 'City Excise Tax Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND strState = @strTaxState 
									AND intItemCategoryId = @intItemCategoryId)

			-- NO STATE AND CATEGORY
		SET @intSecondLevelMatch = (SELECT COUNT(*) 
									FROM @tblNetworkTaxMapping 
									WHERE strNetworkTaxCode = 'City Excise Tax Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND (strState IS NULL OR strState = '')
									AND intItemCategoryId = @intItemCategoryId)
									
		-- STATE AND NO CATEGORY
		SET @intThirdLevelMatch = (SELECT COUNT(*) 
									FROM @tblNetworkTaxMapping 
									WHERE strNetworkTaxCode = 'City Excise Tax Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND strState = @strTaxState
									AND (intItemCategoryId IS NULL OR intItemCategoryId = 0)) 

		-- NO STATE AND NO CATEGORY							
		SET @intFourthLevelMatch = (SELECT COUNT(*) 
									FROM @tblNetworkTaxMapping 
									WHERE strNetworkTaxCode = 'City Excise Tax Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)
									AND (intItemCategoryId IS NULL OR intItemCategoryId = 0)
									AND (strState IS NULL OR strState = ''))

		IF(@intFirstLevelMatch > 0)
		BEGIN
			INSERT INTO @tblTaxTable(
				[intTransactionDetailTaxId],[intTransactionDetailId],[intTaxGroupMasterId],[intTaxGroupId],[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],[dblRate],[dblTax],[dblAdjustedTax],[intTaxAccountId],[ysnSeparateOnInvoice],[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],[strTaxGroup],[ysnInvalidSetup],[strNotes],[strReason]		
			)
			SELECT TOP 1
				 0,0,0,0,[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],@CityExciseTaxRate,0,0,[intSalesTaxAccountId],0,[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],'',[ysnInvalidSetup],[strNotes],''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'City Excise Tax Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND strState = @strTaxState 
									AND intItemCategoryId = @intItemCategoryId
		END
		ELSE IF (@intSecondLevelMatch > 0)
		BEGIN
			INSERT INTO @tblTaxTable(
				[intTransactionDetailTaxId],[intTransactionDetailId],[intTaxGroupMasterId],[intTaxGroupId],[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],[dblRate],[dblTax],[dblAdjustedTax],[intTaxAccountId],[ysnSeparateOnInvoice],[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],[strTaxGroup],[ysnInvalidSetup],[strNotes],[strReason]		
			)
			SELECT TOP 1
				 0,0,0,0,[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],@CityExciseTaxRate,0,0,[intSalesTaxAccountId],0,[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],'',[ysnInvalidSetup],[strNotes],''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'City Excise Tax Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND (strState IS NULL OR strState = '')
									AND intItemCategoryId = @intItemCategoryId
		END
		ELSE IF (@intThirdLevelMatch > 0)
		BEGIN
			INSERT INTO @tblTaxTable(
				[intTransactionDetailTaxId],[intTransactionDetailId],[intTaxGroupMasterId],[intTaxGroupId],[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],[dblRate],[dblTax],[dblAdjustedTax],[intTaxAccountId],[ysnSeparateOnInvoice],[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],[strTaxGroup],[ysnInvalidSetup],[strNotes],[strReason]		
			)
			SELECT TOP 1
				 0,0,0,0,[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],@CityExciseTaxRate,0,0,[intSalesTaxAccountId],0,[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],'',[ysnInvalidSetup],[strNotes],''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'City Excise Tax Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND strState = @strTaxState
									AND (intItemCategoryId IS NULL OR intItemCategoryId = 0)
		END
		ELSE IF (@intFourthLevelMatch > 0)
		BEGIN
			INSERT INTO @tblTaxTable(
				[intTransactionDetailTaxId],[intTransactionDetailId],[intTaxGroupMasterId],[intTaxGroupId],[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],[dblRate],[dblTax],[dblAdjustedTax],[intTaxAccountId],[ysnSeparateOnInvoice],[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],[strTaxGroup],[ysnInvalidSetup],[strNotes],[strReason]		
			)
			SELECT TOP 1
				 0,0,0,0,[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],@CityExciseTaxRate,0,0,[intSalesTaxAccountId],0,[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],'',[ysnInvalidSetup],[strNotes],''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'City Excise Tax Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)
									AND (intItemCategoryId IS NULL OR intItemCategoryId = 0)
									AND (strState IS NULL OR strState = '')
		END
		ELSE
		BEGIN
			INSERT INTO @tblTaxTable(
				 [ysnInvalidSetup]
				,[strReason]
			)
			VALUES(
				 1
				,'Unable to find match for ' + @strTaxState + ' state tax City Excise Tax Rate'
			)
		END
	END

	---------------------------
	-- City Excise Tax Rate  --
	---------------------------





	--------------------------------------
	-- State Sales Tax Percentage Rate  --
	--------------------------------------

	
	IF(@StateSalesTaxPercentageRate != 0)
	BEGIN
		-- STATE AND CATEGORY
		SET @intFirstLevelMatch = (SELECT COUNT(*) 
									FROM @tblNetworkTaxMapping 
									WHERE strNetworkTaxCode = 'State Sales Tax Percentage Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND strState = @strTaxState 
									AND intItemCategoryId = @intItemCategoryId)

			-- NO STATE AND CATEGORY
		SET @intSecondLevelMatch = (SELECT COUNT(*) 
									FROM @tblNetworkTaxMapping 
									WHERE strNetworkTaxCode = 'State Sales Tax Percentage Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND (strState IS NULL OR strState = '')
									AND intItemCategoryId = @intItemCategoryId)
									
		-- STATE AND NO CATEGORY
		SET @intThirdLevelMatch = (SELECT COUNT(*) 
									FROM @tblNetworkTaxMapping 
									WHERE strNetworkTaxCode = 'State Sales Tax Percentage Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND strState = @strTaxState
									AND (intItemCategoryId IS NULL OR intItemCategoryId = 0)) 

		-- NO STATE AND NO CATEGORY							
		SET @intFourthLevelMatch = (SELECT COUNT(*) 
									FROM @tblNetworkTaxMapping 
									WHERE strNetworkTaxCode = 'State Sales Tax Percentage Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)
									AND (intItemCategoryId IS NULL OR intItemCategoryId = 0)
									AND (strState IS NULL OR strState = ''))

		IF(@intFirstLevelMatch > 0)
		BEGIN
			INSERT INTO @tblTaxTable(
				[intTransactionDetailTaxId],[intTransactionDetailId],[intTaxGroupMasterId],[intTaxGroupId],[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],[dblRate],[dblTax],[dblAdjustedTax],[intTaxAccountId],[ysnSeparateOnInvoice],[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],[strTaxGroup],[ysnInvalidSetup],[strNotes],[strReason]		
			)
			SELECT TOP 1
				 0,0,0,0,[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],@StateSalesTaxPercentageRate,0,0,[intSalesTaxAccountId],0,[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],'',[ysnInvalidSetup],[strNotes],''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'State Sales Tax Percentage Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND strState = @strTaxState 
									AND intItemCategoryId = @intItemCategoryId
		END
		ELSE IF (@intSecondLevelMatch > 0)
		BEGIN
			INSERT INTO @tblTaxTable(
				[intTransactionDetailTaxId],[intTransactionDetailId],[intTaxGroupMasterId],[intTaxGroupId],[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],[dblRate],[dblTax],[dblAdjustedTax],[intTaxAccountId],[ysnSeparateOnInvoice],[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],[strTaxGroup],[ysnInvalidSetup],[strNotes],[strReason]		
			)
			SELECT TOP 1
				 0,0,0,0,[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],@StateSalesTaxPercentageRate,0,0,[intSalesTaxAccountId],0,[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],'',[ysnInvalidSetup],[strNotes],''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'State Sales Tax Percentage Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND (strState IS NULL OR strState = '')
									AND intItemCategoryId = @intItemCategoryId
		END
		ELSE IF (@intThirdLevelMatch > 0)
		BEGIN
			INSERT INTO @tblTaxTable(
				[intTransactionDetailTaxId],[intTransactionDetailId],[intTaxGroupMasterId],[intTaxGroupId],[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],[dblRate],[dblTax],[dblAdjustedTax],[intTaxAccountId],[ysnSeparateOnInvoice],[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],[strTaxGroup],[ysnInvalidSetup],[strNotes],[strReason]		
			)
			SELECT TOP 1
				 0,0,0,0,[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],@StateSalesTaxPercentageRate,0,0,[intSalesTaxAccountId],0,[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],'',[ysnInvalidSetup],[strNotes],''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'State Sales Tax Percentage Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND strState = @strTaxState
									AND (intItemCategoryId IS NULL OR intItemCategoryId = 0)
		END
		ELSE IF (@intFourthLevelMatch > 0)
		BEGIN
			INSERT INTO @tblTaxTable(
				[intTransactionDetailTaxId],[intTransactionDetailId],[intTaxGroupMasterId],[intTaxGroupId],[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],[dblRate],[dblTax],[dblAdjustedTax],[intTaxAccountId],[ysnSeparateOnInvoice],[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],[strTaxGroup],[ysnInvalidSetup],[strNotes],[strReason]		
			)
			SELECT TOP 1
				 0,0,0,0,[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],@StateSalesTaxPercentageRate,0,0,[intSalesTaxAccountId],0,[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],'',[ysnInvalidSetup],[strNotes],''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'State Sales Tax Percentage Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)
									AND (intItemCategoryId IS NULL OR intItemCategoryId = 0)
									AND (strState IS NULL OR strState = '')
		END
		ELSE
		BEGIN
			INSERT INTO @tblTaxTable(
				 [ysnInvalidSetup]
				,[strReason]
			)
			VALUES(
				 1
				,'Unable to find match for ' + @strTaxState + ' state tax State Sales Tax Percentage Rate'
			)
		END
	END

	--------------------------------------
	-- State Sales Tax Percentage Rate  --
	--------------------------------------






	--------------------------------------
	-- County Sales Tax Percentage Rate --
	--------------------------------------

	IF(@CountySalesTaxPercentageRate != 0)
	BEGIN
		-- STATE AND CATEGORY
		SET @intFirstLevelMatch = (SELECT COUNT(*) 
									FROM @tblNetworkTaxMapping 
									WHERE strNetworkTaxCode = 'County Sales Tax Percentage Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND strState = @strTaxState 
									AND intItemCategoryId = @intItemCategoryId)

			-- NO STATE AND CATEGORY
		SET @intSecondLevelMatch = (SELECT COUNT(*) 
									FROM @tblNetworkTaxMapping 
									WHERE strNetworkTaxCode = 'County Sales Tax Percentage Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND (strState IS NULL OR strState = '')
									AND intItemCategoryId = @intItemCategoryId)
									
		-- STATE AND NO CATEGORY
		SET @intThirdLevelMatch = (SELECT COUNT(*) 
									FROM @tblNetworkTaxMapping 
									WHERE strNetworkTaxCode = 'County Sales Tax Percentage Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND strState = @strTaxState
									AND (intItemCategoryId IS NULL OR intItemCategoryId = 0)) 

		-- NO STATE AND NO CATEGORY							
		SET @intFourthLevelMatch = (SELECT COUNT(*) 
									FROM @tblNetworkTaxMapping 
									WHERE strNetworkTaxCode = 'County Sales Tax Percentage Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)
									AND (intItemCategoryId IS NULL OR intItemCategoryId = 0)
									AND (strState IS NULL OR strState = ''))

		IF(@intFirstLevelMatch > 0)
		BEGIN
			INSERT INTO @tblTaxTable(
				[intTransactionDetailTaxId],[intTransactionDetailId],[intTaxGroupMasterId],[intTaxGroupId],[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],[dblRate],[dblTax],[dblAdjustedTax],[intTaxAccountId],[ysnSeparateOnInvoice],[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],[strTaxGroup],[ysnInvalidSetup],[strNotes],[strReason]		
			)
			SELECT TOP 1
				 0,0,0,0,[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],@CountySalesTaxPercentageRate,0,0,[intSalesTaxAccountId],0,[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],'',[ysnInvalidSetup],[strNotes],''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'County Sales Tax Percentage Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND strState = @strTaxState 
									AND intItemCategoryId = @intItemCategoryId
		END
		ELSE IF (@intSecondLevelMatch > 0)
		BEGIN
			INSERT INTO @tblTaxTable(
				[intTransactionDetailTaxId],[intTransactionDetailId],[intTaxGroupMasterId],[intTaxGroupId],[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],[dblRate],[dblTax],[dblAdjustedTax],[intTaxAccountId],[ysnSeparateOnInvoice],[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],[strTaxGroup],[ysnInvalidSetup],[strNotes],[strReason]		
			)
			SELECT TOP 1
				 0,0,0,0,[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],@CountySalesTaxPercentageRate,0,0,[intSalesTaxAccountId],0,[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],'',[ysnInvalidSetup],[strNotes],''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'County Sales Tax Percentage Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND (strState IS NULL OR strState = '')
									AND intItemCategoryId = @intItemCategoryId
		END
		ELSE IF (@intThirdLevelMatch > 0)
		BEGIN
			INSERT INTO @tblTaxTable(
				[intTransactionDetailTaxId],[intTransactionDetailId],[intTaxGroupMasterId],[intTaxGroupId],[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],[dblRate],[dblTax],[dblAdjustedTax],[intTaxAccountId],[ysnSeparateOnInvoice],[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],[strTaxGroup],[ysnInvalidSetup],[strNotes],[strReason]		
			)
			SELECT TOP 1
				 0,0,0,0,[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],@CountySalesTaxPercentageRate,0,0,[intSalesTaxAccountId],0,[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],'',[ysnInvalidSetup],[strNotes],''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'County Sales Tax Percentage Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND strState = @strTaxState
									AND (intItemCategoryId IS NULL OR intItemCategoryId = 0)
		END
		ELSE IF (@intFourthLevelMatch > 0)
		BEGIN
			INSERT INTO @tblTaxTable(
				[intTransactionDetailTaxId],[intTransactionDetailId],[intTaxGroupMasterId],[intTaxGroupId],[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],[dblRate],[dblTax],[dblAdjustedTax],[intTaxAccountId],[ysnSeparateOnInvoice],[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],[strTaxGroup],[ysnInvalidSetup],[strNotes],[strReason]		
			)
			SELECT TOP 1
				 0,0,0,0,[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],@CountySalesTaxPercentageRate,0,0,[intSalesTaxAccountId],0,[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],'',[ysnInvalidSetup],[strNotes],''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'County Sales Tax Percentage Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)
									AND (intItemCategoryId IS NULL OR intItemCategoryId = 0)
									AND (strState IS NULL OR strState = '')
		END
		ELSE
		BEGIN
			INSERT INTO @tblTaxTable(
				 [ysnInvalidSetup]
				,[strReason]
			)
			VALUES(
				 1
				,'Unable to find match for ' + @strTaxState + ' state tax County Sales Tax Percentage Rate'
			)
		END
	END

	--------------------------------------
	-- County Sales Tax Percentage Rate --
	--------------------------------------

	
	
	
	
	------------------------------------
	-- City Sales Tax Percentage Rate --
	------------------------------------

	IF(@CitySalesTaxPercentageRate != 0)
	BEGIN
		-- STATE AND CATEGORY
		SET @intFirstLevelMatch = (SELECT COUNT(*) 
									FROM @tblNetworkTaxMapping 
									WHERE strNetworkTaxCode = 'City Sales Tax Percentage Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND strState = @strTaxState 
									AND intItemCategoryId = @intItemCategoryId)

		
			-- NO STATE AND CATEGORY
		SET @intSecondLevelMatch = (SELECT COUNT(*) 
									FROM @tblNetworkTaxMapping 
									WHERE strNetworkTaxCode = 'City Sales Tax Percentage Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND (strState IS NULL OR strState = '')
									AND intItemCategoryId = @intItemCategoryId)
									
		-- STATE AND NO CATEGORY
		SET @intThirdLevelMatch = (SELECT COUNT(*) 
									FROM @tblNetworkTaxMapping 
									WHERE strNetworkTaxCode = 'City Sales Tax Percentage Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND strState = @strTaxState
									AND (intItemCategoryId IS NULL OR intItemCategoryId = 0)) 

		-- NO STATE AND NO CATEGORY							
		SET @intFourthLevelMatch = (SELECT COUNT(*) 
									FROM @tblNetworkTaxMapping 
									WHERE strNetworkTaxCode = 'City Sales Tax Percentage Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)
									AND (intItemCategoryId IS NULL OR intItemCategoryId = 0)
									AND (strState IS NULL OR strState = ''))

		IF(@intFirstLevelMatch > 0)
		BEGIN
			INSERT INTO @tblTaxTable(
				[intTransactionDetailTaxId],[intTransactionDetailId],[intTaxGroupMasterId],[intTaxGroupId],[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],[dblRate],[dblTax],[dblAdjustedTax],[intTaxAccountId],[ysnSeparateOnInvoice],[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],[strTaxGroup],[ysnInvalidSetup],[strNotes],[strReason]		
			)
			SELECT TOP 1
				 0,0,0,0,[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],@CitySalesTaxPercentageRate,0,0,[intSalesTaxAccountId],0,[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],'',[ysnInvalidSetup],[strNotes],''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'City Sales Tax Percentage Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND strState = @strTaxState 
									AND intItemCategoryId = @intItemCategoryId
		END
		ELSE IF (@intSecondLevelMatch > 0)
		BEGIN
			INSERT INTO @tblTaxTable(
				[intTransactionDetailTaxId],[intTransactionDetailId],[intTaxGroupMasterId],[intTaxGroupId],[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],[dblRate],[dblTax],[dblAdjustedTax],[intTaxAccountId],[ysnSeparateOnInvoice],[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],[strTaxGroup],[ysnInvalidSetup],[strNotes],[strReason]		
			)
			SELECT TOP 1
				 0,0,0,0,[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],@CitySalesTaxPercentageRate,0,0,[intSalesTaxAccountId],0,[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],'',[ysnInvalidSetup],[strNotes],''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'City Sales Tax Percentage Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND (strState IS NULL OR strState = '')
									AND intItemCategoryId = @intItemCategoryId
		END
		ELSE IF (@intThirdLevelMatch > 0)
		BEGIN
			INSERT INTO @tblTaxTable(
				[intTransactionDetailTaxId],[intTransactionDetailId],[intTaxGroupMasterId],[intTaxGroupId],[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],[dblRate],[dblTax],[dblAdjustedTax],[intTaxAccountId],[ysnSeparateOnInvoice],[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],[strTaxGroup],[ysnInvalidSetup],[strNotes],[strReason]		
			)
			SELECT TOP 1
				 0,0,0,0,[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],@CitySalesTaxPercentageRate,0,0,[intSalesTaxAccountId],0,[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],'',[ysnInvalidSetup],[strNotes],''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'City Sales Tax Percentage Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND strState = @strTaxState
									AND (intItemCategoryId IS NULL OR intItemCategoryId = 0)
		END
		ELSE IF (@intFourthLevelMatch > 0)
		BEGIN
			INSERT INTO @tblTaxTable(
				[intTransactionDetailTaxId],[intTransactionDetailId],[intTaxGroupMasterId],[intTaxGroupId],[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],[dblRate],[dblTax],[dblAdjustedTax],[intTaxAccountId],[ysnSeparateOnInvoice],[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],[strTaxGroup],[ysnInvalidSetup],[strNotes],[strReason]		
			)
			SELECT TOP 1
				 0,0,0,0,[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],@CitySalesTaxPercentageRate,0,0,[intSalesTaxAccountId],0,[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],'',[ysnInvalidSetup],[strNotes],''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'City Sales Tax Percentage Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)
									AND (intItemCategoryId IS NULL OR intItemCategoryId = 0)
									AND (strState IS NULL OR strState = '')
		END
		ELSE
		BEGIN
			INSERT INTO @tblTaxTable(
				 [ysnInvalidSetup]
				,[strReason]
			)
			VALUES(
				 1
				,'Unable to find match for ' + @strTaxState + ' state tax City Sales Tax Percentage Rate'
			)
		END
	END

	
	------------------------------------
	-- City Sales Tax Percentage Rate --
	------------------------------------






	------------------------------------
	-- Other Sales Tax Percentage Rate--
	------------------------------------

	IF(@OtherSalesTaxPercentageRate != 0)
	BEGIN
		-- STATE AND CATEGORY
		SET @intFirstLevelMatch = (SELECT COUNT(*) 
									FROM @tblNetworkTaxMapping 
									WHERE strNetworkTaxCode = 'Other Sales Tax Percentage Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND strState = @strTaxState 
									AND intItemCategoryId = @intItemCategoryId)

			-- NO STATE AND CATEGORY
		SET @intSecondLevelMatch = (SELECT COUNT(*) 
									FROM @tblNetworkTaxMapping 
									WHERE strNetworkTaxCode = 'Other Sales Tax Percentage Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND (strState IS NULL OR strState = '')
									AND intItemCategoryId = @intItemCategoryId)
									
		-- STATE AND NO CATEGORY
		SET @intThirdLevelMatch = (SELECT COUNT(*) 
									FROM @tblNetworkTaxMapping 
									WHERE strNetworkTaxCode = 'Other Sales Tax Percentage Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND strState = @strTaxState
									AND (intItemCategoryId IS NULL OR intItemCategoryId = 0)) 

		-- NO STATE AND NO CATEGORY							
		SET @intFourthLevelMatch = (SELECT COUNT(*) 
									FROM @tblNetworkTaxMapping 
									WHERE strNetworkTaxCode = 'Other Sales Tax Percentage Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)
									AND (intItemCategoryId IS NULL OR intItemCategoryId = 0)
									AND (strState IS NULL OR strState = ''))

		IF(@intFirstLevelMatch > 0)
		BEGIN
			INSERT INTO @tblTaxTable(
				[intTransactionDetailTaxId],[intTransactionDetailId],[intTaxGroupMasterId],[intTaxGroupId],[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],[dblRate],[dblTax],[dblAdjustedTax],[intTaxAccountId],[ysnSeparateOnInvoice],[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],[strTaxGroup],[ysnInvalidSetup],[strNotes],[strReason]		
			)
			SELECT TOP 1
				 0,0,0,0,[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],@OtherSalesTaxPercentageRate,0,0,[intSalesTaxAccountId],0,[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],'',[ysnInvalidSetup],[strNotes],''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'Other Sales Tax Percentage Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND strState = @strTaxState 
									AND intItemCategoryId = @intItemCategoryId
		END
		ELSE IF (@intSecondLevelMatch > 0)
		BEGIN
			INSERT INTO @tblTaxTable(
				[intTransactionDetailTaxId],[intTransactionDetailId],[intTaxGroupMasterId],[intTaxGroupId],[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],[dblRate],[dblTax],[dblAdjustedTax],[intTaxAccountId],[ysnSeparateOnInvoice],[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],[strTaxGroup],[ysnInvalidSetup],[strNotes],[strReason]		
			)
			SELECT TOP 1
				 0,0,0,0,[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],@OtherSalesTaxPercentageRate,0,0,[intSalesTaxAccountId],0,[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],'',[ysnInvalidSetup],[strNotes],''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'Other Sales Tax Percentage Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND (strState IS NULL OR strState = '')
									AND intItemCategoryId = @intItemCategoryId
		END
		ELSE IF (@intThirdLevelMatch > 0)
		BEGIN
			INSERT INTO @tblTaxTable(
				[intTransactionDetailTaxId],[intTransactionDetailId],[intTaxGroupMasterId],[intTaxGroupId],[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],[dblRate],[dblTax],[dblAdjustedTax],[intTaxAccountId],[ysnSeparateOnInvoice],[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],[strTaxGroup],[ysnInvalidSetup],[strNotes],[strReason]		
			)
			SELECT TOP 1
				 0,0,0,0,[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],@OtherSalesTaxPercentageRate,0,0,[intSalesTaxAccountId],0,[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],'',[ysnInvalidSetup],[strNotes],''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'Other Sales Tax Percentage Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  
									AND strState = @strTaxState
									AND (intItemCategoryId IS NULL OR intItemCategoryId = 0)
		END
		ELSE IF (@intFourthLevelMatch > 0)
		BEGIN
			INSERT INTO @tblTaxTable(
				[intTransactionDetailTaxId],[intTransactionDetailId],[intTaxGroupMasterId],[intTaxGroupId],[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],[dblRate],[dblTax],[dblAdjustedTax],[intTaxAccountId],[ysnSeparateOnInvoice],[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],[strTaxGroup],[ysnInvalidSetup],[strNotes],[strReason]		
			)
			SELECT TOP 1
				 0,0,0,0,[intTaxCodeId],[intTaxClassId],[strTaxableByOtherTaxes],[strCalculationMethod],@OtherSalesTaxPercentageRate,0,0,[intSalesTaxAccountId],0,[ysnCheckoffTax],[strTaxCode],[ysnTaxExempt],'',[ysnInvalidSetup],[strNotes],''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'Other Sales Tax Percentage Rate' 
									AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)
									AND (intItemCategoryId IS NULL OR intItemCategoryId = 0)
									AND (strState IS NULL OR strState = '')
		END
		ELSE
		BEGIN
			INSERT INTO @tblTaxTable(
				 [ysnInvalidSetup]
				,[strReason]
			)
			VALUES(
				 1
				,'Unable to find match for ' + @strTaxState + ' state tax Other Sales Tax Percentage Rate'
			)
		END
	END

	------------------------------------
	-- Other Sales Tax Percentage Rate--
	------------------------------------



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
				--IF ((SELECT COUNT(*) FROM @tblNetworkTaxMapping ) != 0)
				BEGIN 
					INSERT INTO @tblTaxTable
					(
						 [intTransactionDetailTaxId]
						,[intTransactionDetailId]	
						,[intTaxGroupMasterId]		
						,[intTaxGroupId]			
						,[intTaxCodeId]				
						,[intTaxClassId]			
						,[strTaxableByOtherTaxes]	
						,[strCalculationMethod]		
						,[dblRate]					
						,[dblTax]					
						,[dblAdjustedTax]			
						,[intTaxAccountId]			
						,[ysnSeparateOnInvoice]		
						,[ysnCheckoffTax]			
						,[strTaxCode]				
						,[ysnTaxExempt]				
						,[strTaxGroup]				
						,[ysnInvalidSetup]			
						,[strNotes]					
						,[strReason]				
					)
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
						,0					
						,0			
						,[intSalesTaxAccountId]			
						,0		
						,[ysnCheckoffTax]			
						,[strTaxCode]				
						,[ysnTaxExempt]				
						,''				
						,[ysnInvalidSetup]				
						,[strNotes]		
						,[strNotes]			
					FROM
						@tblNetworkTaxMapping
					WHERE [intTaxCodeId] = @intCreatedInvoiceId
				END
				ELSE
				BEGIN
					INSERT INTO @tblTaxTable(
						 [ysnInvalidSetup]
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