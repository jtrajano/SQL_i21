﻿CREATE PROCEDURE [dbo].[uspSMComputeItemTaxes]
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
		,intTaxDetailId			INT 
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

-- Calculate the tax for the base taxes. 
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
	WHERE	ISNULL(strTaxableByOtherTaxes, '') = ''
END 

-- Calculate the AddOn Taxes. Loop until all are calculated. 
BEGIN 
	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpComputeItemTaxes WHERE ISNULL(ysnCalculated, 0) = 0)
	BEGIN 
		UPDATE	AddOnTaxes
		SET		dblCalculatedTaxAmount = ISNULL(dblCalculatedTaxAmount, 0) + 
					CASE	WHEN strCalculationMethod = @CALC_METHOD_Percentage THEN 						
								(AddOnTaxes.numRate / 100) * 
								(
									SELECT	ISNULL(SUM(dblCalculatedTaxAmount), 0)
									FROM	#tmpComputeItemTaxes SourceTaxes INNER JOIN dbo.fnGetRowsFromDelimitedValues(AddOnTaxes.strTaxableByOtherTaxes) AddOnTaxClass
												ON SourceTaxes.intTaxClassId = AddOnTaxClass.intID
									WHERE	SourceTaxes.intId <> AddOnTaxes.intId
											AND SourceTaxes.intHeaderId = AddOnTaxes.intHeaderId	
											AND SourceTaxes.intDetailId = AddOnTaxes.intDetailId
								)
							ELSE 						
								AddOnTaxes.numRate * 
								(
									SELECT	ISNULL(SUM(dblQty), 0)
									FROM	#tmpComputeItemTaxes SourceTaxes INNER JOIN dbo.fnGetRowsFromDelimitedValues(AddOnTaxes.strTaxableByOtherTaxes) AddOnTaxClass
												ON SourceTaxes.intTaxClassId = AddOnTaxClass.intID
									WHERE	SourceTaxes.intId <> AddOnTaxes.intId
											AND SourceTaxes.intHeaderId = AddOnTaxes.intHeaderId	
											AND SourceTaxes.intDetailId = AddOnTaxes.intDetailId
								)
					END 
				,ysnCalculated = 1
		FROM	#tmpComputeItemTaxes AddOnTaxes 
		WHERE	ISNULL(AddOnTaxes.strTaxableByOtherTaxes, '') <> ''
				AND AddOnTaxes.dblCalculatedTaxAmount IS NULL 
				AND EXISTS (
						SELECT	TOP 1 1 
						FROM	#tmpComputeItemTaxes SourceTaxes INNER JOIN dbo.fnGetRowsFromDelimitedValues(AddOnTaxes.strTaxableByOtherTaxes) AddOnTaxClass
									ON SourceTaxes.intTaxClassId = AddOnTaxClass.intID
						WHERE	SourceTaxes.intId <> AddOnTaxes.intId
								AND dblCalculatedTaxAmount IS NOT NULL
					)

		-- Detect an endless loop
		BEGIN 
			-- Decrement the loop counter if no records was updated. 
			IF @@ROWCOUNT = 0 
			BEGIN 
				SET @endlessLoopLimit -= 1
			END 

			-- If counter is beyond the threshold, throw an error. 
			IF @endlessLoopLimit <= 0 
			BEGIN 
				DECLARE @strItemNo AS NVARCHAR(50)
						,@strTaxCode AS NVARCHAR(50)

				SELECT TOP 1 
						@strItemNo = Item.strItemNo
						,@strTaxCode = TaxCode.strTaxCode
				FROM	#tmpComputeItemTaxes FailedTaxes LEFT JOIN dbo.tblICItem Item
							ON FailedTaxes.intItemId = Item.intItemId
						LEFT JOIN dbo.tblSMTaxCode TaxCode
							ON TaxCode.intTaxCodeId = FailedTaxes.intTaxCodeId
				WHERE	ISNULL(ysnCalculated, 0) = 0				

				-- 'Unable to calculate the tax for {tax code} used in {Item}.'
				RAISERROR(51176, 11, 1, @strTaxCode, @strItemNo) 
				GOTO _Exit;
			END 
		END 
	END
END 

-- Process the final result
UPDATE	Result
SET		dblTax =	dblCalculatedTaxAmount * 
					CASE	WHEN ISNULL(ysnCheckoffTax, 0) = 1 THEN -1 
							ELSE 1 
					END 				
FROM	#tmpComputeItemTaxes Result

_Exit: 
