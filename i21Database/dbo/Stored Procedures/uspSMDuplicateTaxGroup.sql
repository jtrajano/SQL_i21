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
	
	SELECT @newTaxGroupId = SCOPE_IDENTITY();
	
	INSERT INTO tblSMTaxGroupCode([intTaxGroupId], [intTaxCodeId])
	SELECT @newTaxGroupId, [intTaxCodeId]
	FROM dbo.tblSMTaxGroupCode
	WHERE [intTaxGroupId] = @taxGroupId

END