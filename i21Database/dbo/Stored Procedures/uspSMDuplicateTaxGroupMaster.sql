CREATE PROCEDURE [dbo].[uspSMDuplicateTaxGroupMaster]
	@taxGroupMasterId INT,
	@newTaxGroupMasterId int OUTPUT
AS
BEGIN

	INSERT dbo.tblSMTaxGroupMaster([strTaxGroupMaster], [strDescription], [ysnSeparateOnInvoice])
	SELECT 'DUP: ' + [strTaxGroupMaster], [strDescription], [ysnSeparateOnInvoice]
	FROM dbo.tblSMTaxGroupMaster 
	WHERE [intTaxGroupMasterId] = @taxGroupMasterId;
	
	SELECT @newTaxGroupMasterId = SCOPE_IDENTITY();
	
	INSERT INTO tblSMTaxGroupMasterGroup([intTaxGroupMasterId], [intTaxGroupId])
	SELECT @newTaxGroupMasterId, [intTaxGroupId]
	FROM dbo.tblSMTaxGroupMasterGroup
	WHERE [intTaxGroupMasterId] = @taxGroupMasterId
	
END
