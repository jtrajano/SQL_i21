CREATE PROCEDURE [dbo].[uspSMComputeItemTaxes]
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Constants 
DECLARE @CALC_METHOD_Percentage AS NVARCHAR(50) = 'Percentage'
		,@CALC_METHOD_Unit AS NVARCHAR(50) = 'Unit'

DECLARE @currentRowsUpdated AS INT
		,@endlessLoopLimit AS INT = 5

-- Create the temp table if it does not exists. 
IF NOT EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpComputeItemTaxes')) 
BEGIN 
	CREATE TABLE #tmpComputeItemTaxes (
		intId					INT IDENTITY(1, 1) PRIMARY KEY 

		-- Integration fields. Foreign keys. 
		,intHeaderId			INT
		,intDetailId			INT 
		,dtmDate				DATETIME 
		,intItemId				INT

		-- Taxes fields
		,intTaxCodeId			INT
		,intTaxClassId			INT
		,strTaxableByOtherTaxes NVARCHAR(MAX) 
		,strCalculationMethod	NVARCHAR(50)
		,numRate				NUMERIC(18,6)
		,dblTax					NUMERIC(18,6)
		,dblAdjustedTax			NUMERIC(18,6)
		,ysnCheckoffTax			BIT

		-- Fields used in the calculation of the taxes
		,dblAmount				NUMERIC(18,6) 
		,dblQty					NUMERIC(18,6) 		
		
		-- Internal fields
		,ysnCalculated			BIT 
		,dblCalculatedTaxAmount	NUMERIC(18,6) 
	)
END 

-- Calculate the base tax. 
BEGIN 
	UPDATE	ItemTaxes
	SET		dblCalculatedTaxAmount =	
				CASE	WHEN dblAdjustedTax IS NOT NULL THEN 
							dblAdjustedTax
						WHEN strCalculationMethod = @CALC_METHOD_Percentage THEN 						
							ISNULL(dblAmount, 0) * ISNULL(dblQty, 0) * (numRate / 100)
						ELSE 						
							ISNULL(dblQty, 0) * ISNULL(numRate, 0) 
				END 
			,ysnCalculated = 1
	FROM	#tmpComputeItemTaxes ItemTaxes
	--WHERE	ISNULL(TaxableOtherTaxes.strTaxableByOtherTaxes, '') = ''
END 

-- Calculate the 'Taxable Other Taxes'
-- TODO: Replace this part with the commented code below when 'Taxable by Other Taxes' are going to be computed from the 'tax code' instead of the 'tax class'. 
BEGIN 
	UPDATE	TaxableOtherTaxes
	SET		dblCalculatedTaxAmount = 
				ISNULL(dblCalculatedTaxAmount, 0) 
				
				-- Sub Query if the cost method is 'Percentage'
				+ (
					TaxableOtherTaxes.dblCalculatedTaxAmount 
					* (
						SELECT	ISNULL( SUM (OtherTaxRate.numRate / 100), 0)
						FROM	dbo.tblSMTaxCode OtherTax INNER JOIN dbo.tblSMTaxCodeRate OtherTaxRate
									ON OtherTax.intTaxCodeId = OtherTaxRate.intTaxCodeId
								INNER JOIN dbo.fnGetRowsFromDelimitedValues(TaxableOtherTaxes.strTaxableByOtherTaxes) AddOnTaxClass
									ON AddOnTaxClass.intID = OtherTax.intTaxClassId
						WHERE	OtherTax.intTaxCodeId <> TaxableOtherTaxes.intTaxCodeId
								AND ISNULL(OtherTaxRate.numRate, 0) <> 0 
								AND dbo.fnDateLessThanEquals(OtherTaxRate.dtmEffectiveDate, TaxableOtherTaxes.dtmDate) = 1
								AND ISNULL(OtherTax.strZipCode, '') = ISNULL(TaxCode.strZipCode, '')
								AND ISNULL(OtherTax.strCity, '') = ISNULL(TaxCode.strCity, '')
								AND ISNULL(OtherTax.strState, '') = ISNULL(TaxCode.strState, '')
								AND ISNULL(OtherTax.strCounty, '') = ISNULL(TaxCode.strCounty, '')
								AND ISNULL(OtherTax.strCountry, '') = ISNULL(TaxCode.strCountry, '')
								AND OtherTaxRate.strCalculationMethod = @CALC_METHOD_Percentage
					)
				)

				-- Sub Query if the cost method is 'Unit'
				+ (
					TaxableOtherTaxes.dblCalculatedTaxAmount 
					* (
						SELECT	ISNULL( SUM (OtherTaxRate.numRate), 0)
						FROM	dbo.tblSMTaxCode OtherTax INNER JOIN dbo.tblSMTaxCodeRate OtherTaxRate
									ON OtherTax.intTaxCodeId = OtherTaxRate.intTaxCodeId
								INNER JOIN dbo.fnGetRowsFromDelimitedValues(TaxableOtherTaxes.strTaxableByOtherTaxes) AddOnTaxClass
									ON AddOnTaxClass.intID = OtherTax.intTaxClassId
						WHERE	OtherTax.intTaxCodeId <> TaxableOtherTaxes.intTaxCodeId
								AND ISNULL(OtherTaxRate.numRate, 0) <> 0 
								AND dbo.fnDateLessThanEquals(OtherTaxRate.dtmEffectiveDate, TaxableOtherTaxes.dtmDate) = 1
								AND ISNULL(OtherTax.strZipCode, '') = ISNULL(TaxCode.strZipCode, '')
								AND ISNULL(OtherTax.strCity, '') = ISNULL(TaxCode.strCity, '')
								AND ISNULL(OtherTax.strState, '') = ISNULL(TaxCode.strState, '')
								AND ISNULL(OtherTax.strCounty, '') = ISNULL(TaxCode.strCounty, '')
								AND ISNULL(OtherTax.strCountry, '') = ISNULL(TaxCode.strCountry, '')
								AND OtherTaxRate.strCalculationMethod = @CALC_METHOD_Unit
					)
				)
			,ysnCalculated = 1
	FROM	#tmpComputeItemTaxes TaxableOtherTaxes INNER JOIN dbo.tblSMTaxCode TaxCode
				ON TaxableOtherTaxes.intTaxCodeId = TaxCode.intTaxCodeId
	WHERE	ISNULL(TaxableOtherTaxes.strTaxableByOtherTaxes, '') <> ''

END

------------------------------------------------------------------------------------------------------------------------------------------------
-- DO NOT REMOVE THE CODE BELOW. IT CAN BE WHEN 'Taxable by Other Taxes' IS MOVED FROM 'Tax Class' TO 'Tax Code'.
------------------------------------------------------------------------------------------------------------------------------------------------
---- Calculate the AddOn Taxes. Loop until all are calculated. 
--BEGIN 
--	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpComputeItemTaxes WHERE ISNULL(ysnCalculated, 0) = 0)
--	BEGIN 
--		UPDATE	AddOnTaxes
--		SET		dblCalculatedTaxAmount = ISNULL(dblCalculatedTaxAmount, 0) + 
--					CASE	WHEN strCalculationMethod = @CALC_METHOD_Percentage THEN 						
--								(AddOnTaxes.numRate / 100) * 
--								(
--									SELECT	ISNULL(SUM(dblCalculatedTaxAmount), 0)
--									FROM	#tmpComputeItemTaxes SourceTaxes INNER JOIN dbo.fnGetRowsFromDelimitedValues(AddOnTaxes.strTaxableByOtherTaxes) AddOnTaxClass
--												ON SourceTaxes.intTaxClassId = AddOnTaxClass.intID
--									WHERE	SourceTaxes.intId <> AddOnTaxes.intId
--											AND SourceTaxes.intHeaderId = AddOnTaxes.intHeaderId	
--											AND SourceTaxes.intDetailId = AddOnTaxes.intDetailId
--								)
--							ELSE 						
--								AddOnTaxes.numRate * 
--								(
--									SELECT	ISNULL(SUM(dblQty), 0)
--									FROM	#tmpComputeItemTaxes SourceTaxes INNER JOIN dbo.fnGetRowsFromDelimitedValues(AddOnTaxes.strTaxableByOtherTaxes) AddOnTaxClass
--												ON SourceTaxes.intTaxClassId = AddOnTaxClass.intID
--									WHERE	SourceTaxes.intId <> AddOnTaxes.intId
--											AND SourceTaxes.intHeaderId = AddOnTaxes.intHeaderId	
--											AND SourceTaxes.intDetailId = AddOnTaxes.intDetailId
--								)
--					END 
--				,ysnCalculated = 1
--		FROM	#tmpComputeItemTaxes AddOnTaxes 
--		WHERE	ISNULL(AddOnTaxes.strTaxableByOtherTaxes, '') <> ''
--				AND AddOnTaxes.dblCalculatedTaxAmount IS NULL 
--				AND EXISTS (
--						SELECT	TOP 1 1 
--						FROM	#tmpComputeItemTaxes SourceTaxes INNER JOIN dbo.fnGetRowsFromDelimitedValues(AddOnTaxes.strTaxableByOtherTaxes) AddOnTaxClass
--									ON SourceTaxes.intTaxClassId = AddOnTaxClass.intID
--						WHERE	SourceTaxes.intId <> AddOnTaxes.intId
--								AND dblCalculatedTaxAmount IS NOT NULL
--					)

--		-- Detect an endless loop
--		BEGIN 
--			-- Decrement the loop counter if no records was updated. 
--			IF @@ROWCOUNT = 0 
--			BEGIN 
--				SET @endlessLoopLimit -= 1
--			END 

--			-- If counter is beyond the threshold, throw an error. 
--			IF @endlessLoopLimit <= 0 
--			BEGIN 
--				DECLARE @strItemNo AS NVARCHAR(50)
--						,@strTaxCode AS NVARCHAR(50)

--				SELECT TOP 1 
--						@strItemNo = Item.strItemNo
--						,@strTaxCode = TaxCode.strTaxCode
--				FROM	#tmpComputeItemTaxes FailedTaxes LEFT JOIN dbo.tblICItem Item
--							ON FailedTaxes.intItemId = Item.intItemId
--						LEFT JOIN dbo.tblSMTaxCode TaxCode
--							ON TaxCode.intTaxCodeId = FailedTaxes.intTaxCodeId
--				WHERE	ISNULL(ysnCalculated, 0) = 0				

--				-- 'Unable to calculate the tax for {tax code} used in {Item}.'
--				RAISERROR(51179, 11, 1, @strTaxCode, @strItemNo) 
--				GOTO _Exit;
--			END 
--		END 
--	END
--END 

-- Process the final result
UPDATE	Result
SET		dblTax =	dblCalculatedTaxAmount * 
					CASE	WHEN ISNULL(ysnCheckoffTax, 0) = 1 THEN -1 
							ELSE 1 
					END 				
FROM	#tmpComputeItemTaxes Result

_Exit: 
