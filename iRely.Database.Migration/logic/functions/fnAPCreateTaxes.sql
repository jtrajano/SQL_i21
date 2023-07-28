--liquibase formatted sql

-- changeset Von:fnAPCreateTaxes.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER FUNCTION [dbo].[fnAPCreateTaxes]
(
	--@taxMasterId INT,
	@country NVARCHAR(100) = NULL,
	@state NVARCHAR(100) = NULL,
	@county NVARCHAR(100) = NULL,
	@city NVARCHAR(100) = NULL,
	@transactionDate DATETIME
)
RETURNS @returntable TABLE
(
	--[intTaxGroupMasterId] INT NOT NULL, 
    [intTaxGroupId] INT NOT NULL, 
    [intTaxCodeId] INT NOT NULL, 
    [intTaxClassId] INT NOT NULL, 
	[strTaxableByOtherTaxes] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [strCalculationMethod] NVARCHAR(15) COLLATE Latin1_General_CI_AS NULL, 
	[strTaxCode] NVARCHAR(15) COLLATE Latin1_General_CI_AS NULL, 
    [dblRate] NUMERIC(18, 6) NULL, 
    [intAccountId] INT NULL, 
    [dblTax] NUMERIC(18, 6) NULL, 
    [dblAdjustedTax] NUMERIC(18, 6) NULL, 
	[ysnTaxAdjusted] BIT NULL DEFAULT ((0)), 
	[ysnSeparateOnBill] BIT NULL DEFAULT ((0)), 
	[ysnCheckoffTax] BIT NULL DEFAULT ((0))
)
AS
BEGIN

	DECLARE @TaxGroups TABLE(intTaxGroupId INT)

	INSERT INTO @TaxGroups
	SELECT DISTINCT TG.[intTaxGroupId]
	FROM tblSMTaxCode TC	
		INNER JOIN tblSMTaxGroupCode TGC ON TC.[intTaxCodeId] = TGC.[intTaxCodeId] 
		INNER JOIN tblSMTaxGroup TG ON TGC.[intTaxGroupId] = TG.[intTaxGroupId]
		INNER JOIN tblSMTaxGroupMasterGroup TGTM ON TG.[intTaxGroupId] = TGTM.[intTaxGroupId]
		--INNER JOIN tblSMTaxGroupMaster TGM ON TGTM.[intTaxGroupMasterId] = TGM.[intTaxGroupMasterId]
	/*WHERE 
		TGM.[intTaxGroupMasterId] = @taxMasterId*/

	IF (SELECT COUNT(1) FROM @TaxGroups) > 1
				BEGIN
					DELETE FROM @TaxGroups
					WHERE
						[intTaxGroupId] NOT IN
						(
							SELECT DISTINCT
								TG.[intTaxGroupId] 
							FROM tblSMTaxCode TC	
								INNER JOIN tblSMTaxGroupCode TGC ON TC.[intTaxCodeId] = TGC.[intTaxCodeId] 
								INNER JOIN tblSMTaxGroup TG ON TGC.[intTaxGroupId] = TG.[intTaxGroupId]
								INNER JOIN tblSMTaxGroupMasterGroup TGTM ON TG.[intTaxGroupId] = TGTM.[intTaxGroupId]
								--INNER JOIN tblSMTaxGroupMaster TGM ON TGTM.[intTaxGroupMasterId] = TGM.[intTaxGroupMasterId]
							WHERE 
								--TGM.[intTaxGroupMasterId] = @taxMasterId
								 LOWER(dbo.fnTrim(TC.[strCountry])) = LOWER(dbo.fnTrim(@country))
						)				
				END
				
			--State
			IF (SELECT COUNT(1) FROM @TaxGroups) > 1
				BEGIN
					DELETE FROM @TaxGroups
					WHERE
						[intTaxGroupId] NOT IN
						(
							SELECT DISTINCT
								TG.[intTaxGroupId] 
							FROM tblSMTaxCode TC	
								INNER JOIN tblSMTaxGroupCode TGC ON TC.[intTaxCodeId] = TGC.[intTaxCodeId] 
								INNER JOIN tblSMTaxGroup TG ON TGC.[intTaxGroupId] = TG.[intTaxGroupId]
								INNER JOIN tblSMTaxGroupMasterGroup TGTM ON TG.[intTaxGroupId] = TGTM.[intTaxGroupId]
								--INNER JOIN tblSMTaxGroupMaster TGM ON TGTM.[intTaxGroupMasterId] = TGM.[intTaxGroupMasterId]
							WHERE 
								--TGM.[intTaxGroupMasterId] = @taxMasterId
								LOWER(dbo.fnTrim(TC.[strCountry])) = LOWER(dbo.fnTrim(@country))
								AND LOWER(dbo.fnTrim(TC.[strState])) = LOWER(dbo.fnTrim(@state))
						)				
				END
				
			--County
			IF (SELECT COUNT(1) FROM @TaxGroups) > 1
				BEGIN
					DELETE FROM @TaxGroups
					WHERE
						[intTaxGroupId] NOT IN
						(
							SELECT DISTINCT
								TG.[intTaxGroupId] 
							FROM tblSMTaxCode TC	
								INNER JOIN tblSMTaxGroupCode TGC ON TC.[intTaxCodeId] = TGC.[intTaxCodeId] 
								INNER JOIN tblSMTaxGroup TG ON TGC.[intTaxGroupId] = TG.[intTaxGroupId]
								INNER JOIN tblSMTaxGroupMasterGroup TGTM ON TG.[intTaxGroupId] = TGTM.[intTaxGroupId]
								--INNER JOIN tblSMTaxGroupMaster TGM ON TGTM.[intTaxGroupMasterId] = TGM.[intTaxGroupMasterId]
							WHERE 
								--TGM.[intTaxGroupMasterId] = @taxMasterId
								LOWER(dbo.fnTrim(TC.[strCountry])) = LOWER(dbo.fnTrim(@country))
								AND LOWER(dbo.fnTrim(TC.[strState])) = LOWER(dbo.fnTrim(@state))
								AND LOWER(dbo.fnTrim(TC.[strCounty])) = LOWER(dbo.fnTrim(@county))
						)				
				END	
				
			--City
			IF (SELECT COUNT(1) FROM @TaxGroups) > 1
				BEGIN
					DELETE FROM @TaxGroups
					WHERE
						[intTaxGroupId] NOT IN
						(
							SELECT DISTINCT
								TG.[intTaxGroupId] 
							FROM tblSMTaxCode TC	
								INNER JOIN tblSMTaxGroupCode TGC ON TC.[intTaxCodeId] = TGC.[intTaxCodeId] 
								INNER JOIN tblSMTaxGroup TG ON TGC.[intTaxGroupId] = TG.[intTaxGroupId]
								INNER JOIN tblSMTaxGroupMasterGroup TGTM ON TG.[intTaxGroupId] = TGTM.[intTaxGroupId]
								--INNER JOIN tblSMTaxGroupMaster TGM ON TGTM.[intTaxGroupMasterId] = TGM.[intTaxGroupMasterId]
							WHERE 
								--TGM.[intTaxGroupMasterId] = @taxMasterId
								LOWER(dbo.fnTrim(TC.[strCountry])) = LOWER(dbo.fnTrim(@country))
								AND LOWER(dbo.fnTrim(TC.[strState])) = LOWER(dbo.fnTrim(@state))
								AND LOWER(dbo.fnTrim(TC.[strCounty])) = LOWER(dbo.fnTrim(@county))
								AND LOWER(dbo.fnTrim(TC.[strCity])) = LOWER(dbo.fnTrim(@city))
						)				
				END		

	INSERT @returntable
	SELECT
		--TGM.[intTaxGroupMasterId] 
		TG.[intTaxGroupId] 
		,TC.[intTaxCodeId]
		,TC.[intTaxClassId]				
		,TC.[strTaxableByOtherTaxes]
		,ISNULL((SELECT TOP 1 tblSMTaxCodeRate.[strCalculationMethod] 
						FROM tblSMTaxCodeRate WHERE tblSMTaxCodeRate.[intTaxCodeId] = TC.[intTaxCodeId] 
						AND  CAST(tblSMTaxCodeRate.[dtmEffectiveDate]  AS DATE) <= CAST(@transactionDate AS DATE) 
						ORDER BY tblSMTaxCodeRate.[dtmEffectiveDate]ASC ,tblSMTaxCodeRate.[dblRate] DESC), 'Unit') AS [strCalculationMethod]
		,TC.strTaxCode
		,ISNULL((SELECT TOP 1 tblSMTaxCodeRate.[dblRate] 
						FROM tblSMTaxCodeRate WHERE tblSMTaxCodeRate.[intTaxCodeId] = TC.[intTaxCodeId] 
						AND  CAST(tblSMTaxCodeRate.[dtmEffectiveDate]  AS DATE) <= CAST(@transactionDate AS DATE) 
						ORDER BY tblSMTaxCodeRate.[dtmEffectiveDate]ASC ,tblSMTaxCodeRate.[dblRate] DESC), 0.00) AS [dblRate]
		,TC.[intPurchaseTaxAccountId]		
		,0.00 AS [dblTax]
		,0.00 AS [dblAdjustedTax]	
		,0			
		,0
		,TC.[ysnCheckoffTax]
	FROM
		tblSMTaxCode TC
	INNER JOIN
		tblSMTaxGroupCode TGC
			ON TC.[intTaxCodeId] = TGC.[intTaxCodeId] 
	INNER JOIN
		tblSMTaxGroup TG
			ON TGC.[intTaxGroupId] = TG.[intTaxGroupId]
	INNER JOIN
		tblSMTaxGroupMasterGroup TGTM
			ON TG.[intTaxGroupId] = TGTM.[intTaxGroupId]
	/*INNER JOIN
		tblSMTaxGroupMaster TGM
			ON TGTM.[intTaxGroupMasterId] = TGM.[intTaxGroupMasterId] */
	INNER JOIN
		(
			SELECT DISTINCT TOP 1  [intTaxGroupId] FROM @TaxGroups ORDER BY [intTaxGroupId]
		)
		FG
			ON TG.[intTaxGroupId] = FG.[intTaxGroupId]
	WHERE
		--TGM.[intTaxGroupMasterId] = @taxMasterId
		 ((TC.[intPurchaseTaxAccountId] IS NOT NULL
			AND TC.[intPurchaseTaxAccountId] <> 0))

	RETURN
END



