CREATE PROCEDURE [dbo].[uspSMDuplicateTaxGroup]
	@taxGroupId int,
	@strTaxGroup NVARCHAR(100) OUTPUT
AS
BEGIN

	DECLARE @newTaxGroupId INT
	DECLARE @newName VARCHAR(100) = CONVERT(nvarchar(MAX), GETDATE(), 20);

	INSERT dbo.tblSMTaxGroup([strTaxGroup], [strDescription])
	SELECT [strTaxGroup] + ' ' + @newName, [strDescription]
	FROM dbo.tblSMTaxGroup 
	WHERE [intTaxGroupId] = @taxGroupId;
	
	SELECT @newTaxGroupId = SCOPE_IDENTITY();
	
	INSERT INTO tblSMTaxGroupCode([intTaxGroupId], [intTaxCodeId])
	SELECT @newTaxGroupId, [intTaxCodeId]
	FROM dbo.tblSMTaxGroupCode
	WHERE [intTaxGroupId] = @taxGroupId

	SELECT @strTaxGroup = [strTaxGroup] FROM  dbo.tblSMTaxGroup WHERE [intTaxGroupId] = @newTaxGroupId

END