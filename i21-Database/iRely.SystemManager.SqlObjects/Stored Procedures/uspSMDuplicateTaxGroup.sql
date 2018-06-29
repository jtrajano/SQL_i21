CREATE PROCEDURE [dbo].[uspSMDuplicateTaxGroup]
	@taxGroupId INT,
	@newTaxGroupId INT OUTPUT
AS
BEGIN

	DECLARE @intCount NVARCHAR

	SELECT @intCount = COUNT(*) FROM [tblSMTaxGroup] WHERE [strTaxGroup] LIKE 'DUP: ' + (SELECT [strTaxGroup] FROM [dbo].[tblSMTaxGroup] WHERE [intTaxGroupId] = @taxGroupId) + '%' 

	INSERT dbo.tblSMTaxGroup([strTaxGroup], [strDescription])
	SELECT CASE @intCount WHEN 0 
			THEN 'DUP: ' + [strTaxGroup] 
			ELSE 'DUP: ' + [strTaxGroup] + ' (' + @intCount + ')' END,
	[strDescription]
	FROM dbo.tblSMTaxGroup 
	WHERE [intTaxGroupId] = @taxGroupId;
	
	-- GET LAST INSERTED ID
	SELECT @newTaxGroupId = SCOPE_IDENTITY();

	-- Tax Code
	DECLARE @currentRow INT
	DECLARE @totalRows INT

	SET @currentRow = 1
	SELECT @totalRows = Count(*) FROM [tblSMTaxGroupCode] WHERE intTaxGroupId = @taxGroupId

	WHILE (@currentRow <= @totalRows)
	BEGIN

	Declare @taxGroupCodeId INT
	SELECT @taxGroupCodeId = intTaxGroupCodeId FROM (  
		SELECT ROW_NUMBER() OVER(ORDER BY intTaxGroupCodeId ASC) AS 'ROWID', *
		FROM [tblSMTaxGroupCode] WHERE intTaxGroupId = @taxGroupId
	) a
	WHERE ROWID = @currentRow

		-- INSERT STATEMENT
		INSERT INTO tblSMTaxGroupCode([intTaxGroupId], [intTaxCodeId])
		SELECT @newTaxGroupId, [intTaxCodeId]
		FROM dbo.tblSMTaxGroupCode
		WHERE [intTaxGroupCodeId] = @taxGroupCodeId

		DECLARE @newTaxGroupCodeId INT
		-- GET LAST INSERTED ID
		SELECT @newTaxGroupCodeId = SCOPE_IDENTITY();

		-- Category Exemption
		DECLARE @currentRow1 INT
		DECLARE @totalRows1 INT

		SET @currentRow1 = 1
		SELECT @totalRows1 = Count(*) FROM [tblSMTaxGroupCodeCategoryExemption] WHERE intTaxGroupCodeId = @taxGroupCodeId

		WHILE (@currentRow1 <= @totalRows1)
		BEGIN

		Declare @taxGroupCodeCategoryExemptionId INT
		SELECT @taxGroupCodeCategoryExemptionId = intTaxGroupCodeCategoryExemptionId FROM (  
			SELECT ROW_NUMBER() OVER(ORDER BY intTaxGroupCodeCategoryExemptionId ASC) AS 'ROWID', *
			FROM [tblSMTaxGroupCodeCategoryExemption] WHERE intTaxGroupCodeId = @taxGroupCodeId
		) a
		WHERE ROWID = @currentRow1
			-- Category Exemption
			-- INSERT STATEMENT
			INSERT INTO tblSMTaxGroupCodeCategoryExemption([intTaxGroupCodeId], [intCategoryId])
			SELECT @newTaxGroupCodeId, [intCategoryId] 
			FROM tblSMTaxGroupCodeCategoryExemption 
			WHERE intTaxGroupCodeCategoryExemptionId = @taxGroupCodeCategoryExemptionId

		SET @currentRow1 = @currentRow1 + 1
		END

	SET @currentRow = @currentRow + 1

	END
END