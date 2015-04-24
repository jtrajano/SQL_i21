CREATE PROCEDURE [dbo].[uspSMDuplicateTaxGroup]
	@taxGroupId INT,
	@newTaxGroupId INT OUTPUT
AS
BEGIN

	INSERT dbo.tblSMTaxGroup([strTaxGroup], [strDescription])
	SELECT 'Duplicate of ' + [strTaxGroup], [strDescription]
	FROM dbo.tblSMTaxGroup 
	WHERE [intTaxGroupId] = @taxGroupId;
	
	SELECT @newTaxGroupId = SCOPE_IDENTITY();
	
	INSERT INTO tblSMTaxGroupCode([intTaxGroupId], [intTaxCodeId])
	SELECT @newTaxGroupId, [intTaxCodeId]
	FROM dbo.tblSMTaxGroupCode
	WHERE [intTaxGroupId] = @taxGroupId

END