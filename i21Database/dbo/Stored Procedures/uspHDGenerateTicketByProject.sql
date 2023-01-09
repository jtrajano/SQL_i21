CREATE PROCEDURE [dbo].[uspHDGenerateTicketByProject]
	  @ProjectId			INT
	 ,@ModuleIds		    NVARCHAR(250) = NULL
	 ,@LineOfBusinessIds	NVARCHAR(250) = NULL
	 ,@RaiseError			BIT
	 ,@ErrorMessage			NVARCHAR(250)	= NULL	OUTPUT
AS

BEGIN

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET ANSI_WARNINGS OFF

IF @RaiseError = 1
	SET XACT_ABORT ON


DECLARE @InitTranCount INT
		,@Savepoint NVARCHAR(32)

SET @InitTranCount = @@TRANCOUNT
SET @Savepoint = SUBSTRING(('HDGenerateProjectTickets' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)

IF ISNULL(@RaiseError,0) = 0	
BEGIN
	IF @InitTranCount = 0
		BEGIN TRANSACTION
	ELSE
		SAVE TRANSACTION @Savepoint
END

BEGIN TRY

DECLARE @intModuleId INT
       ,@intLineOfBusinessId INT
	   ,@intProjectId INT = @ProjectId
	   ,@ysnHasGeneratedTickets bit = CONVERT(BIT, 0)
	   ,@strModule				NVARCHAR(100)
	   ,@strModuleIds		    NVARCHAR(250) = @ModuleIds
	   ,@strLineOfBusinessIds	NVARCHAR(250) = @LineOfBusinessIds


IF ISNULL(@strModuleIds, '') = ''
BEGIN
	SET @ErrorMessage = 'Please select a module.'
	RETURN
END

IF ISNULL(@strLineOfBusinessIds, '') = ''
BEGIN
	SET @ErrorMessage = 'Please select a line of business.'
	RETURN
END

DECLARE ProjectTickets CURSOR 
LOCAL STATIC READ_ONLY FORWARD_ONLY
FOR 

SELECT       intModuleId		 =  ProjectModule.intModuleId
			,intLineOfBusinessId =  CONVERT(INT, ProjectLineOfBusiness.Item)
FROM tblHDProject Project
	INNER JOIN tblHDProjectModule ProjectModule 
ON ProjectModule.intProjectId = Project.intProjectId
OUTER APPLY
(
	SELECT * 
	FROM [dbo].fnSplitStringWithTrim(Project.strLinesOfBusinessId, ',')
	WHERE ISNULL(Item, '') != ''
) ProjectLineOfBusiness
	INNER JOIN [dbo].fnSplitStringWithTrim(@strModuleIds, ',') SelectedModule
ON CONVERT(INT,SelectedModule.Item) = ProjectModule.intModuleId
	INNER JOIN [dbo].fnSplitStringWithTrim(@strLineOfBusinessIds, ',') SelectedLineOfBusiness
ON CONVERT(INT,SelectedLineOfBusiness.Item) = CONVERT(INT,ProjectLineOfBusiness.Item)
WHERE Project.intProjectId = @intProjectId
GROUP BY ProjectModule.intModuleId
		,CONVERT(INT, ProjectLineOfBusiness.Item)



OPEN ProjectTickets
FETCH NEXT FROM ProjectTickets INTO @intModuleId , @intLineOfBusinessId
WHILE @@FETCH_STATUS = 0 
BEGIN 

	SELECT TOP 1 @strModule = strSMModuleName
	FROM vyuHDModule
	WHERE intModuleId = @intModuleId

	IF EXISTS 
	(
		SELECT TOP 1 a.intTicketId
		FROM vyuHDTicketProjection a
			INNER JOIN tblHDTicketType b
		ON a.intTicketTypeId = b.intTicketTypeId
			OUTER APPLY
			(
				SELECT TOP 1 intProjectTaskId 
				FROM tblHDProjectTask
				WHERE intProjectId = @intProjectId AND
					  intTemplateTicketId = a.intTicketId
			) ProjectTask
			CROSS APPLY
			(
				SELECT TOP 1 TicketStatus.strStatus
				FROM tblHDTicketStatus TicketStatus
				WHERE TicketStatus.intTicketStatusId = a.intTicketStatusId AND
				      TicketStatus.strStatus <> 'Closed'		
			) TicketStatus
		WHERE a.strProjectionModule = @strModule  AND
			  a.strType != 'CRM' AND
			  b.strType = 'Template'  AND
			  a.intLineOfBusinessId = @intLineOfBusinessId AND
			  ProjectTask.intProjectTaskId IS NULL
		GROUP BY a.intTicketId
	)
	BEGIN
		EXEC uspHDGenerateTicketByModuleAndLOB @intModuleId, @intLineOfBusinessId, @intProjectId, @RaiseError, @ErrorMessage OUTPUT		
		SET @ysnHasGeneratedTickets = 1
	END


	FETCH NEXT FROM ProjectTickets INTO @intModuleId , @intLineOfBusinessId
END
CLOSE ProjectTickets
DEALLOCATE ProjectTickets

IF @ysnHasGeneratedTickets = CONVERT(BIT, 0)
BEGIN
	SET @ErrorMessage = 'No Tickets to generate.'

END



END TRY
BEGIN CATCH
			IF ISNULL(@RaiseError,0) = 0
			BEGIN
				IF @InitTranCount = 0
					IF (XACT_STATE()) <> 0
						ROLLBACK TRANSACTION
				ELSE
					IF (XACT_STATE()) <> 0
						ROLLBACK TRANSACTION @Savepoint
			END

			SET @ErrorMessage = ERROR_MESSAGE();
			IF ISNULL(@RaiseError,0) = 1
				RAISERROR(@ErrorMessage, 16, 1);
			RETURN
END CATCH

IF ISNULL(@RaiseError,0) = 0
BEGIN

	IF @InitTranCount = 0
		BEGIN
			IF (XACT_STATE()) = -1
				ROLLBACK TRANSACTION
			IF (XACT_STATE()) = 1
				COMMIT TRANSACTION
		END		
	ELSE
		BEGIN
			IF (XACT_STATE()) = -1
				ROLLBACK TRANSACTION  @Savepoint
			--IF (XACT_STATE()) = 1
			--	COMMIT TRANSACTION  @Savepoint
		END	
END
	
RETURN 1;

END

GO