﻿CREATE FUNCTION [dbo].[fnCFRemoteTaxes] 
    (   
		 @strTaxState					NVARCHAR(MAX)   = 'ALL'
		,@strTaxCodeId					NVARCHAR(MAX)	= ''
		,@FET							NUMERIC(18,6)	= 0.000000
		,@SET							NUMERIC(18,6)	= 0.000000
		,@SST							NUMERIC(18,6)	= 0.000000
		,@LC1							NUMERIC(18,6)	= 0.000000
		,@LC2							NUMERIC(18,6)	= 0.000000
		,@LC3							NUMERIC(18,6)	= 0.000000
		,@LC4							NUMERIC(18,6)	= 0.000000
		,@LC5							NUMERIC(18,6)	= 0.000000
		,@LC6							NUMERIC(18,6)	= 0.000000
		,@LC7							NUMERIC(18,6)	= 0.000000
		,@LC8							NUMERIC(18,6)	= 0.000000
		,@LC9							NUMERIC(18,6)	= 0.000000
		,@LC10							NUMERIC(18,6)	= 0.000000
		,@LC11							NUMERIC(18,6)	= 0.000000
		,@LC12							NUMERIC(18,6)	= 0.000000
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
		,[strTaxExemptReason]			NVARCHAR(MAX)
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
		,strTaxExemptReason				NVARCHAR(MAX)
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
		,strTaxExemptReason = E.strExemptionNotes
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


	IF(@FET != 0)
	BEGIN
		IF ((SELECT COUNT(*) FROM @tblNetworkTaxMapping WHERE strNetworkTaxCode = 'FET' AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  AND (strState = @strTaxState OR strState IS NULL OR strState = '')) != 0)
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
				,@FET					
				,null					
				,null			
				,[intSalesTaxAccountId]			
				,0		
				,[ysnCheckoffTax]			
				,[strTaxCode]				
				,[ysnTaxExempt]				
				,''				
				,0				
				,[strTaxExemptReason]		
				,''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'FET'
		END
		ELSE
		BEGIN
			INSERT INTO @tblTaxTable(
				 [ysnInvalid]
				,[strReason]
			)
			VALUES(
				 1
				,'Unable to find match for ' + @strTaxState + ' state tax FET'
			)
		END
	END

	IF(@SET != 0)
	BEGIN
		IF ((SELECT COUNT(*) FROM @tblNetworkTaxMapping WHERE strNetworkTaxCode = 'SET' AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  AND (strState = @strTaxState OR strState IS NULL OR strState = '')) != 0)
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
				,@SET					
				,null					
				,null			
				,[intSalesTaxAccountId]			
				,0		
				,[ysnCheckoffTax]			
				,[strTaxCode]				
				,[ysnTaxExempt]				
				,''				
				,0				
				,[strTaxExemptReason]		
				,''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'SET'
		END
		ELSE
		BEGIN
			INSERT INTO @tblTaxTable(
				 [ysnInvalid]
				,[strReason]
			)
			VALUES(
				 1
				,'Unable to find match for ' + @strTaxState + ' state tax SET'
			)
		END
	END

	IF(@SST != 0)
	BEGIN
		IF ((SELECT COUNT(*) FROM @tblNetworkTaxMapping WHERE strNetworkTaxCode = 'SST' AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  AND (strState = @strTaxState OR strState IS NULL OR strState = '')) != 0)
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
				,@SST					
				,null					
				,null			
				,[intSalesTaxAccountId]			
				,0		
				,[ysnCheckoffTax]			
				,[strTaxCode]				
				,[ysnTaxExempt]				
				,''				
				,0				
				,[strTaxExemptReason]		
				,''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'SST'
		END
		ELSE
		BEGIN
			INSERT INTO @tblTaxTable(
				 [ysnInvalid]
				,[strReason]
			)
			VALUES(
				 1
				,'Unable to find match for ' + @strTaxState + ' state tax SST'
			)
		END
	END

	IF(@LC1 != 0)
	BEGIN
		IF ((SELECT COUNT(*) FROM @tblNetworkTaxMapping WHERE strNetworkTaxCode = 'LC1' AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  AND (strState = @strTaxState OR strState IS NULL OR strState = '')) != 0)
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
				,@LC1					
				,null					
				,null			
				,[intSalesTaxAccountId]			
				,0		
				,[ysnCheckoffTax]			
				,[strTaxCode]				
				,[ysnTaxExempt]				
				,''				
				,0				
				,[strTaxExemptReason]		
				,''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'LC1'
		END
		ELSE
		BEGIN
			INSERT INTO @tblTaxTable(
				 [ysnInvalid]
				,[strReason]
			)
			VALUES(
				 1
				,'Unable to find match for ' + @strTaxState + ' state tax LC1'
			)
		END
	END

	IF(@LC2 != 0)
	BEGIN
		IF ((SELECT COUNT(*) FROM @tblNetworkTaxMapping WHERE strNetworkTaxCode = 'LC2' AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  AND (strState = @strTaxState OR strState IS NULL OR strState = '')) != 0)
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
				,@LC2					
				,null					
				,null			
				,[intSalesTaxAccountId]			
				,0		
				,[ysnCheckoffTax]			
				,[strTaxCode]				
				,[ysnTaxExempt]				
				,''				
				,0				
				,[strTaxExemptReason]		
				,''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'LC2'
		END
		ELSE
		BEGIN
			INSERT INTO @tblTaxTable(
				 [ysnInvalid]
				,[strReason]
			)
			VALUES(
				 1
				,'Unable to find match for ' + @strTaxState + ' state tax LC2'
			)
		END
	END

	IF(@LC3 != 0)
	BEGIN
		IF ((SELECT COUNT(*) FROM @tblNetworkTaxMapping WHERE strNetworkTaxCode = 'LC3' AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  AND (strState = @strTaxState OR strState IS NULL OR strState = '')) != 0)
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
				,@LC3					
				,null					
				,null			
				,[intSalesTaxAccountId]			
				,0		
				,[ysnCheckoffTax]			
				,[strTaxCode]				
				,[ysnTaxExempt]				
				,''				
				,0				
				,[strTaxExemptReason]		
				,''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'LC3'
		END
		ELSE
		BEGIN
			INSERT INTO @tblTaxTable(
				 [ysnInvalid]
				,[strReason]
			)
			VALUES(
				 1
				,'Unable to find match for ' + @strTaxState + ' state tax LC3'
			)
		END
	END

	IF(@LC4 != 0)
	BEGIN
		IF ((SELECT COUNT(*) FROM @tblNetworkTaxMapping WHERE strNetworkTaxCode = 'LC4' AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  AND (strState = @strTaxState OR strState IS NULL OR strState = '')) != 0)
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
				,@LC4					
				,null					
				,null			
				,[intSalesTaxAccountId]			
				,0		
				,[ysnCheckoffTax]			
				,[strTaxCode]				
				,[ysnTaxExempt]				
				,''				
				,0				
				,[strTaxExemptReason]		
				,''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'LC4'
		END
		ELSE
		BEGIN
			INSERT INTO @tblTaxTable(
				 [ysnInvalid]
				,[strReason]
			)
			VALUES(
				 1
				,'Unable to find match for ' + @strTaxState + ' state tax LC4'
			)
		END
	END

	IF(@LC5 != 0)
	BEGIN
		IF ((SELECT COUNT(*) FROM @tblNetworkTaxMapping WHERE strNetworkTaxCode = 'LC5' AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  AND (strState = @strTaxState OR strState IS NULL OR strState = '')) != 0)
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
				,@LC5					
				,null					
				,null			
				,[intSalesTaxAccountId]			
				,0		
				,[ysnCheckoffTax]			
				,[strTaxCode]				
				,[ysnTaxExempt]				
				,''				
				,0				
				,[strTaxExemptReason]		
				,''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'LC5'
		END
		ELSE
		BEGIN
			INSERT INTO @tblTaxTable(
				 [ysnInvalid]
				,[strReason]
			)
			VALUES(
				 1
				,'Unable to find match for ' + @strTaxState + ' state tax LC5'
			)
		END
	END

	IF(@LC6 != 0)
	BEGIN
		IF ((SELECT COUNT(*) FROM @tblNetworkTaxMapping WHERE strNetworkTaxCode = 'LC6' AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  AND (strState = @strTaxState OR strState IS NULL OR strState = '')) != 0)
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
				,@LC6					
				,null					
				,null			
				,[intSalesTaxAccountId]			
				,0		
				,[ysnCheckoffTax]			
				,[strTaxCode]				
				,[ysnTaxExempt]				
				,''				
				,0				
				,[strTaxExemptReason]		
				,''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'LC6'
		END
		ELSE
		BEGIN
			INSERT INTO @tblTaxTable(
				 [ysnInvalid]
				,[strReason]
			)
			VALUES(
				 1
				,'Unable to find match for ' + @strTaxState + ' state tax LC6'
			)
		END
	END

	IF(@LC7 != 0)
	BEGIN
		IF ((SELECT COUNT(*) FROM @tblNetworkTaxMapping WHERE strNetworkTaxCode = 'LC7' AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  AND (strState = @strTaxState OR strState IS NULL OR strState = '')) != 0)
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
				,@LC7					
				,null					
				,null			
				,[intSalesTaxAccountId]			
				,0		
				,[ysnCheckoffTax]			
				,[strTaxCode]				
				,[ysnTaxExempt]				
				,''				
				,0				
				,[strTaxExemptReason]		
				,''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'LC7'
		END
		ELSE
		BEGIN
			INSERT INTO @tblTaxTable(
				 [ysnInvalid]
				,[strReason]
			)
			VALUES(
				 1
				,'Unable to find match for ' + @strTaxState + ' state tax LC7'
			)
		END
	END

	IF(@LC8 != 0)
	BEGIN
		IF ((SELECT COUNT(*) FROM @tblNetworkTaxMapping WHERE strNetworkTaxCode = 'LC8' AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  AND (strState = @strTaxState OR strState IS NULL OR strState = '')) != 0)
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
				,@LC8					
				,null					
				,null			
				,[intSalesTaxAccountId]			
				,0		
				,[ysnCheckoffTax]			
				,[strTaxCode]				
				,[ysnTaxExempt]				
				,''				
				,0				
				,[strTaxExemptReason]		
				,''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'LC8'
		END
		ELSE
		BEGIN
			INSERT INTO @tblTaxTable(
				 [ysnInvalid]
				,[strReason]
			)
			VALUES(
				 1
				,'Unable to find match for ' + @strTaxState + ' state tax LC8'
			)
		END
	END

	IF(@LC9 != 0)
	BEGIN
		IF ((SELECT COUNT(*) FROM @tblNetworkTaxMapping WHERE strNetworkTaxCode = 'LC9' AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  AND (strState = @strTaxState OR strState IS NULL OR strState = '')) != 0)
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
				,@LC9					
				,null					
				,null			
				,[intSalesTaxAccountId]			
				,0		
				,[ysnCheckoffTax]			
				,[strTaxCode]				
				,[ysnTaxExempt]				
				,''				
				,0				
				,[strTaxExemptReason]		
				,''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'LC9'
		END
		ELSE
		BEGIN
			INSERT INTO @tblTaxTable(
				 [ysnInvalid]
				,[strReason]
			)
			VALUES(
				 1
				,'Unable to find match for ' + @strTaxState + ' state tax LC9'
			)
		END
	END

	IF(@LC10 != 0)
	BEGIN
		IF ((SELECT COUNT(*) FROM @tblNetworkTaxMapping WHERE strNetworkTaxCode = 'LC10' AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  AND (strState = @strTaxState OR strState IS NULL OR strState = '')) != 0)
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
				,@LC10					
				,null					
				,null			
				,[intSalesTaxAccountId]			
				,0		
				,[ysnCheckoffTax]			
				,[strTaxCode]				
				,[ysnTaxExempt]				
				,''				
				,0				
				,[strTaxExemptReason]		
				,''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'LC10'
		END
		ELSE
		BEGIN
			INSERT INTO @tblTaxTable(
				 [ysnInvalid]
				,[strReason]
			)
			VALUES(
				 1
				,'Unable to find match for ' + @strTaxState + ' state tax LC10'
			)
		END
	END

	IF(@LC11 != 0)
	BEGIN
		IF ((SELECT COUNT(*) FROM @tblNetworkTaxMapping WHERE strNetworkTaxCode = 'LC11' AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  AND (strState = @strTaxState OR strState IS NULL OR strState = '')) != 0)
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
				,@LC11					
				,null					
				,null			
				,[intSalesTaxAccountId]			
				,0		
				,[ysnCheckoffTax]			
				,[strTaxCode]				
				,[ysnTaxExempt]				
				,''				
				,0				
				,[strTaxExemptReason]		
				,''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'LC11'
		END
		ELSE
		BEGIN
			INSERT INTO @tblTaxTable(
				 [ysnInvalid]
				,[strReason]
			)
			VALUES(
				 1
				,'Unable to find match for ' + @strTaxState + ' state tax LC11'
			)
		END
	END

	IF(@LC12 != 0)
	BEGIN
		IF ((SELECT COUNT(*) FROM @tblNetworkTaxMapping WHERE strNetworkTaxCode = 'LC12' AND (intTaxCodeId IS NOT NULL AND intTaxCodeId > 0)  AND (strState = @strTaxState OR strState IS NULL OR strState = '')) != 0)
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
				,@LC12					
				,null					
				,null			
				,[intSalesTaxAccountId]			
				,0		
				,[ysnCheckoffTax]			
				,[strTaxCode]				
				,[ysnTaxExempt]				
				,''				
				,0				
				,[strTaxExemptReason]		
				,''			
			FROM
				@tblNetworkTaxMapping
			WHERE strNetworkTaxCode = 'LC12'
		END
		ELSE
		BEGIN
			INSERT INTO @tblTaxTable(
				 [ysnInvalid]
				,[strReason]
			)
			VALUES(
				 1
				,'Unable to find match for ' + @strTaxState + ' state tax LC12'
			)
		END
	END


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
						,@LC12					
						,null					
						,null			
						,[intSalesTaxAccountId]			
						,0		
						,[ysnCheckoffTax]			
						,[strTaxCode]				
						,[ysnTaxExempt]				
						,''				
						,0				
						,[strTaxExemptReason]		
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
