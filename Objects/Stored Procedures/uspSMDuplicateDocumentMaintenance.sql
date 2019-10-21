CREATE PROCEDURE [dbo].[uspSMDuplicateDocumentMaintenance]
	 @intDocumentMaintenanceId		INT		
	,@NewDocumentMaintenanceId		INT = NULL OUTPUT
AS
	DECLARE @intCount NVARCHAR

	SELECT @intCount = COUNT(*) FROM [tblSMDocumentMaintenance] WHERE [strTitle] LIKE 'DUP: ' + (SELECT [strTitle] FROM [tblSMDocumentMaintenance] WHERE [intDocumentMaintenanceId] = @intDocumentMaintenanceId) + '%' 

	INSERT INTO [tblSMDocumentMaintenance]
		  ([strTitle]
		  ,[intCompanyLocationId]
		  ,[intLineOfBusinessId]
		  ,[intEntityCustomerId]
		  ,[strSource]
		  ,[strType]
		  ,[ysnCopyAll])
	SELECT (SELECT CASE @intCount WHEN 0 
			THEN 'DUP: ' + [strTitle] 
			ELSE 'DUP: ' + [strTitle] + ' (' + @intCount + ')' END)		  
		  ,[intCompanyLocationId]
		  ,[intLineOfBusinessId]
		  ,[intEntityCustomerId]
		  ,[strSource]
		  ,[strType]
		  ,[ysnCopyAll]
	FROM [tblSMDocumentMaintenance]
	WHERE [intDocumentMaintenanceId] = @intDocumentMaintenanceId

	SET @NewDocumentMaintenanceId = SCOPE_IDENTITY()

	INSERT INTO [tblSMDocumentMaintenanceMessage]
		  ([intDocumentMaintenanceId]
  		  ,[strHeaderFooter]
		  ,[intCharacterLimit]
		  ,[strMessage]
		  ,[blbMessage]
		  ,[ysnRecipe]
		  ,[ysnQuote]
		  ,[ysnSalesOrder]
		  ,[ysnPickList]
		  ,[ysnBOL]
		  ,[ysnInvoice]
		  ,[ysnScaleTicket]
		  ,[ysnInventoryTransfer])
	SELECT @NewDocumentMaintenanceId
  		  ,[strHeaderFooter]
		  ,[intCharacterLimit]
		  ,[strMessage]
		  ,[blbMessage]
		  ,[ysnRecipe]
		  ,[ysnQuote]
		  ,[ysnSalesOrder]
		  ,[ysnPickList]
		  ,[ysnBOL]
		  ,[ysnInvoice]
		  ,[ysnScaleTicket]
		  ,[ysnInventoryTransfer]
	FROM [tblSMDocumentMaintenanceMessage]
	WHERE [intDocumentMaintenanceId] = @intDocumentMaintenanceId

RETURN 