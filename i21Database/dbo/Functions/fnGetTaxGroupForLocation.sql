CREATE FUNCTION [dbo].[fnGetTaxGroupForLocation]
(
	 @TaxGroupMasterId	INT
	,@Country			NVARCHAR(MAX)
	,@County			NVARCHAR(MAX)
	,@City				NVARCHAR(MAX)
	,@State				NVARCHAR(MAX)
)
RETURNS INT
AS
BEGIN

	DECLARE	 @TaxGroupId INT
						
	DECLARE @TaxGroups TABLE(intTaxGroupId INT)				
	DECLARE @ValidTaxGroups TABLE(intTaxGroupId INT)				
	DECLARE @TaxCodes TABLE(
		intTaxGroupMasterId INT
		,intTaxGroupId INT
		,intTaxCodeId INT
		,strCountry NVARCHAR(500)
		,strState NVARCHAR(500)
		,strCounty NVARCHAR(500)
		,strCity NVARCHAR(500))			
	
	INSERT INTO @TaxCodes
	SELECT DISTINCT 
		TGM.[intTaxGroupMasterId]
		,TG.[intTaxGroupId]
		,TC.[intTaxCodeId]
		,UPPER(RTRIM(LTRIM(TC.[strCountry])))
		,UPPER(RTRIM(LTRIM(TC.[strState])))
		,UPPER(RTRIM(LTRIM(TC.[strCounty])))
		,UPPER(RTRIM(LTRIM(TC.[strCity])))
	FROM tblSMTaxCode TC	
		INNER JOIN tblSMTaxGroupCode TGC ON TC.[intTaxCodeId] = TGC.[intTaxCodeId] 
		INNER JOIN tblSMTaxGroup TG ON TGC.[intTaxGroupId] = TG.[intTaxGroupId]
		INNER JOIN tblSMTaxGroupMasterGroup TGTM ON TG.[intTaxGroupId] = TGTM.[intTaxGroupId]
		INNER JOIN tblSMTaxGroupMaster TGM ON TGTM.[intTaxGroupMasterId] = TGM.[intTaxGroupMasterId]
	WHERE 
		TGM.[intTaxGroupMasterId] = @TaxGroupMasterId
		AND TC.[intTaxCodeId] NOT IN
			(
				SELECT DISTINCT TC.intTaxCodeId
				FROM tblSMTaxCode TC	
					INNER JOIN tblSMTaxGroupCode TGC ON TC.[intTaxCodeId] = TGC.[intTaxCodeId] 
					INNER JOIN tblSMTaxGroup TG ON TGC.[intTaxGroupId] = TG.[intTaxGroupId]
					INNER JOIN tblSMTaxGroupMasterGroup TGTM ON TG.[intTaxGroupId] = TGTM.[intTaxGroupId]
					INNER JOIN tblSMTaxGroupMaster TGM ON TGTM.[intTaxGroupMasterId] = TGM.[intTaxGroupMasterId]
				WHERE 
					TGM.[intTaxGroupMasterId] = @TaxGroupMasterId
				GROUP BY
					TC.intTaxCodeId
				HAVING COUNT(TC.intTaxCodeId) > 1
			)
			
	IF (SELECT COUNT(1) FROM @TaxCodes) < 1
		BEGIN
			INSERT INTO @TaxCodes
			SELECT DISTINCT 
				TGM.[intTaxGroupMasterId]
				,TG.[intTaxGroupId]
				,TC.[intTaxCodeId]
				,UPPER(RTRIM(LTRIM(TC.[strCountry])))
				,UPPER(RTRIM(LTRIM(TC.[strState])))
				,UPPER(RTRIM(LTRIM(TC.[strCounty])))
				,UPPER(RTRIM(LTRIM(TC.[strCity])))
			FROM tblSMTaxCode TC	
				INNER JOIN tblSMTaxGroupCode TGC ON TC.[intTaxCodeId] = TGC.[intTaxCodeId] 
				INNER JOIN tblSMTaxGroup TG ON TGC.[intTaxGroupId] = TG.[intTaxGroupId]
				INNER JOIN tblSMTaxGroupMasterGroup TGTM ON TG.[intTaxGroupId] = TGTM.[intTaxGroupId]
				INNER JOIN tblSMTaxGroupMaster TGM ON TGTM.[intTaxGroupMasterId] = TGM.[intTaxGroupMasterId]
			WHERE 
				TGM.[intTaxGroupMasterId] = @TaxGroupMasterId
		END
									
	
	INSERT INTO @TaxGroups
	SELECT DISTINCT [intTaxGroupId]
	FROM @TaxCodes
	
	DECLARE @TaxGroupCount INT
			,@ValidTaxGroupCount INT
	
	--Country
	INSERT INTO @ValidTaxGroups
	SELECT DISTINCT
		[intTaxGroupId] 
	FROM 
		@TaxCodes
	WHERE
		[strCountry] = @Country
		
	SELECT @TaxGroupCount = COUNT(1) FROM @TaxGroups
	SELECT @ValidTaxGroupCount = COUNT(1) FROM @ValidTaxGroups
		
	IF @TaxGroupCount >= 1 AND @ValidTaxGroupCount >= 1 AND (@TaxGroupCount - @ValidTaxGroupCount >= 1)
		BEGIN
			DELETE FROM @TaxGroups
			WHERE [intTaxGroupId] NOT IN (SELECT DISTINCT [intTaxGroupId] FROM @ValidTaxGroups)				
		END
		
		
	DELETE FROM @ValidTaxGroups				
	--State
	INSERT INTO @ValidTaxGroups
	SELECT DISTINCT
		[intTaxGroupId] 
	FROM 
		@TaxCodes
	WHERE 
		[strState] = @State 																			
		
	SELECT @TaxGroupCount = COUNT(1) FROM @TaxGroups
	SELECT @ValidTaxGroupCount = COUNT(1) FROM @ValidTaxGroups
		
	IF @TaxGroupCount >= 1 AND @ValidTaxGroupCount >= 1 AND (@TaxGroupCount - @ValidTaxGroupCount >= 1)
		BEGIN
			DELETE FROM @TaxGroups
			WHERE [intTaxGroupId] NOT IN (SELECT DISTINCT [intTaxGroupId] FROM @ValidTaxGroups)
		END
		
	DELETE FROM @ValidTaxGroups				
	--County
	INSERT INTO @ValidTaxGroups
	SELECT DISTINCT
		[intTaxGroupId] 
	FROM 
		@TaxCodes
	WHERE 
		[strCounty] = @County	
		
	SELECT @TaxGroupCount = COUNT(1) FROM @TaxGroups
	SELECT @ValidTaxGroupCount = COUNT(1) FROM @ValidTaxGroups
		
	IF @TaxGroupCount >= 1 AND @ValidTaxGroupCount >= 1 AND (@TaxGroupCount - @ValidTaxGroupCount >= 1)
		BEGIN
			DELETE FROM @TaxGroups
			WHERE [intTaxGroupId] NOT IN (SELECT DISTINCT [intTaxGroupId] FROM @ValidTaxGroups)			
		END	
		
	DELETE FROM @ValidTaxGroups				
	--City
	INSERT INTO @ValidTaxGroups
	SELECT DISTINCT
		[intTaxGroupId] 
	FROM 
		@TaxCodes
	WHERE 
		[strCity] = @City																					
		
	SELECT @TaxGroupCount = COUNT(1) FROM @TaxGroups
	SELECT @ValidTaxGroupCount = COUNT(1) FROM @ValidTaxGroups
		
	IF @TaxGroupCount >= 1 AND @ValidTaxGroupCount >= 1 AND (@TaxGroupCount - @ValidTaxGroupCount >= 1)
		BEGIN
			DELETE FROM @TaxGroups
			WHERE [intTaxGroupId] NOT IN (SELECT DISTINCT [intTaxGroupId] FROM @ValidTaxGroups)				
		END	
		
	SELECT TOP 1 @TaxGroupId = [intTaxGroupId] FROM @TaxGroups ORDER BY [intTaxGroupId]
				
	RETURN @TaxGroupId		
END
