CREATE PROCEDURE [dbo].[uspSMDuplicateCommentMaintenance]
	 @intCommentMaintenanceId		INT		
	,@NewCommentMaintenanceId		INT = NULL OUTPUT
AS
	DECLARE @intCount NVARCHAR

	SELECT @intCount = COUNT(*) FROM [tblSMCommentMaintenance] WHERE [strCommentTitle] LIKE 'DUP: ' + (SELECT [strCommentTitle] FROM [tblSMCommentMaintenance] WHERE [intCommentMaintenanceId] = @intCommentMaintenanceId) + '%' 

	INSERT INTO [tblSMCommentMaintenance]
		  ([strCommentTitle]
		  ,[intCompanyLocationId]
		  ,[intLineOfBusinessId]
		  ,[intEntityCustomerId]
		  ,[strHeaderFooter]
		  ,[strSource]
		  ,[strType]
		  ,[ysnCopyAll])
	SELECT (SELECT CASE @intCount WHEN 0 
			THEN 'DUP: ' + [strCommentTitle] 
			ELSE 'DUP: ' + [strCommentTitle] + ' (' + @intCount + ')' END)		  
		  ,[intCompanyLocationId]
		  ,[intLineOfBusinessId]
		  ,[intEntityCustomerId]
		  ,[strHeaderFooter]
		  ,[strSource]
		  ,[strType]
		  ,[ysnCopyAll]
	FROM [tblSMCommentMaintenance]
	WHERE [intCommentMaintenanceId] = @intCommentMaintenanceId

	SET @NewCommentMaintenanceId = SCOPE_IDENTITY()

	INSERT INTO [tblSMCommentMaintenanceComment]
		  ([intCommentMaintenanceId]
		  ,[intCharacterLimit]
		  ,[strComment]
		  ,[ysnRecipe]
		  ,[ysnQoute]
		  ,[ysnSalesOrder]
		  ,[ysnPickList]
		  ,[ysnBOL]
		  ,[ysnInvoice]
		  ,[ysnScaleTicket])
	SELECT @NewCommentMaintenanceId
		  ,[intCharacterLimit]
		  ,[strComment]
		  ,[ysnRecipe]
		  ,[ysnQoute]
		  ,[ysnSalesOrder]
		  ,[ysnPickList]
		  ,[ysnBOL]
		  ,[ysnInvoice]
		  ,[ysnScaleTicket]
	FROM [tblSMCommentMaintenanceComment]
	WHERE [intCommentMaintenanceId] = @intCommentMaintenanceId

RETURN 