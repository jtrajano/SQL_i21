CREATE PROCEDURE [dbo].[uspSMDuplicateTaxGroupMaster]
	@taxGroupMasterId int,
	@strTaxGroupMaster NVARCHAR(100) OUTPUT
AS
BEGIN

	DECLARE @newTaxGroupMasterId INT
	DECLARE @newName VARCHAR(100) = CONVERT(nvarchar(MAX), GETDATE(), 20);

	INSERT dbo.tblSMTaxGroupMaster([strTaxGroupMaster], [strDescription], [ysnSeparateOnInvoice])
	SELECT [strTaxGroupMaster] + ' ' + @newName, [strDescription], [ysnSeparateOnInvoice]
	FROM dbo.tblSMTaxGroupMaster 
	WHERE [intTaxGroupMasterId] = @taxGroupMasterId;
	
	SELECT @newTaxGroupMasterId = SCOPE_IDENTITY();
	
	INSERT INTO tblSMTaxGroupMasterGroup([intTaxGroupMasterId], [intTaxGroupId])
	SELECT @newTaxGroupMasterId, [intTaxGroupId]
	FROM dbo.tblSMTaxGroupMasterGroup
	WHERE [intTaxGroupMasterId] = @taxGroupMasterId

	SELECT @strTaxGroupMaster = [strTaxGroupMaster] FROM  dbo.tblSMTaxGroupMaster WHERE [intTaxGroupMasterId] = @newTaxGroupMasterId

	--Return @strTaxGroupMaster

END
