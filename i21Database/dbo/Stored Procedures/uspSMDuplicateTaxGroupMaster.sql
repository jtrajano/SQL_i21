CREATE PROCEDURE [dbo].[uspSMDuplicateTaxGroupMaster]
	@taxGroupMasterId INT,
	@newTaxGroupMasterId int OUTPUT
AS
BEGIN

	DECLARE @intCount NVARCHAR

	SELECT @intCount = COUNT(*) FROM [tblSMTaxGroupMaster] WHERE [strTaxGroupMaster] LIKE 'DUP: ' + (SELECT [strTaxGroupMaster] FROM [dbo].[tblSMTaxGroupMaster] WHERE [intTaxGroupMasterId] = @taxGroupMasterId) + '%' 

	INSERT dbo.tblSMTaxGroupMaster([strTaxGroupMaster], [strDescription], [ysnSeparateOnInvoice])
	SELECT CASE @intCount WHEN 0 
		   THEN 'DUP: ' + [strTaxGroupMaster] 
		   ELSE 'DUP: ' + [strTaxGroupMaster] + ' (' + @intCount + ')' END,
	[strDescription], [ysnSeparateOnInvoice]
	FROM dbo.tblSMTaxGroupMaster 
	WHERE [intTaxGroupMasterId] = @taxGroupMasterId;
	
	SELECT @newTaxGroupMasterId = SCOPE_IDENTITY();
	
	INSERT INTO tblSMTaxGroupMasterGroup([intTaxGroupMasterId], [intTaxGroupId])
	SELECT @newTaxGroupMasterId, [intTaxGroupId]
	FROM dbo.tblSMTaxGroupMasterGroup
	WHERE [intTaxGroupMasterId] = @taxGroupMasterId
	
END
