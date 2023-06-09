CREATE PROCEDURE [dbo].[uspHDGenerateTicketByModuleAndLOB]
	  @ModuleId			    INT 
	 ,@LineOfBusinessId		INT 
	 ,@ProjectId				INT 
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



DECLARE  @intModuleId		  INT	  = @ModuleId
		,@intLineOfBusinessId INT	  = @LineOfBusinessId
		,@intTicketId		  INT 
		,@intProjectId		  INT     = @ProjectId
		,@strStartingNumber   NVARCHAR(30)
		,@strModule				NVARCHAR(100)
		,@intNewTicketId		  INT 
		,@intDefaultTicketType	  INT 
		,@ysnHasGeneratedTickets bit = CONVERT(BIT, 0)
		,@strCustomerNumber			NVARCHAR(250)
		,@intCustomerContactId		INT	  
		,@intCustomerId				INT	    


SELECT TOP 1 @strModule = strSMModuleName
FROM vyuHDModule
WHERE intModuleId = @intModuleId

SELECT TOP 1 @intDefaultTicketType = intTicketTypeId
FROM tblHDTicketType
WHERE ysnDefaultTicket = 1

DECLARE TemplateTickets CURSOR 
	LOCAL STATIC READ_ONLY FORWARD_ONLY
FOR 


SELECT a.intTicketId
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

OPEN TemplateTickets
FETCH NEXT FROM TemplateTickets INTO @intTicketId
WHILE @@FETCH_STATUS = 0 
BEGIN 

	SELECT TOP 1 @strStartingNumber = strPrefix + CONVERT(NVARCHAR(20), intNumber)
	FROM tblSMStartingNumber
	WHERE strModule = 'Help Desk' AND
		  strTransactionType = 'Ticket Number'

    UPDATE tblSMStartingNumber
    SET intNumber = intNumber + 1
    WHERE strModule = 'Help Desk' AND
		  strTransactionType = 'Ticket Number'

	SET @ysnHasGeneratedTickets = CONVERT(BIT, 1)

	SELECT TOP 1 @strCustomerNumber    = Customer.strCustomerNumber
				,@intCustomerId		   = Project.intCustomerId
				,@intCustomerContactId = Project.intCustomerContactId
	FROM tblHDProject Project
			INNER JOIN tblARCustomer Customer
	ON Customer.intEntityId = Project.intCustomerId
	WHERE Project.intProjectId = @intProjectId

	INSERT INTO tblHDTicket
	(
			 strTicketNumber				   
			,strSubject						   
			,strCustomerNumber				   
			,intCustomerContactId			   
			,intCustomerId					   
			,intMilestoneId 				   
			,intTicketTypeId 				   
			,intTicketStatusId 				   
			,intTicketPriorityId 			   
			,intTicketProductId 			   
			,intModuleId 					   
			,intVersionId 					   
			,intAssignedTo 					   
			,intAssignedToEntity 			   
			,intCreatedUserId 				   
			,intCreatedUserEntityId 		   
		    ,dtmCreated 					   
			,dtmDueDate 					   
			,intLastModifiedUserId 			   
			,intLastModifiedUserEntityId	   
			,dtmLastModified 				   
			,dblQuotedHours 				   
			,dblActualHours 				   
			,dblNonBillableHours 			   
			,strJiraKey 					   
			,strCompany						   
			,strOperatingSystem 			   
			,strAcuVersion 					   
			,strDatabase 					   
			,strType 						   
			,dtmCompleted 					   
			,intLineOfBusinessId 			   
			,strLineOfBusinessId 			   
			,intOpportunityCampaignId 		   
			,dtmLastCommented					
			,intLastCommentedByEntityId 		
			,strSubjectOverride					
			,ysnSendLink 						
			,strMultipleActivityId 				
			,intCompanyLocationId 				
			,intEntityLocationId 				
			,intSequenceInProject				
			,intCurrencyId 						
			,intCurrencyExchangeRateId 			
			,intCurrencyExchangeRateTypeId		
			,dtmExchangeRateDate 				
			,dblCurrencyRate 					
			,intFeedbackWithSolutionId			
			,intFeedbackWithRepresentativeId 	
			,strFeedbackComment 				
			,strDescription 					
			,strResolution 						
			,strResolutionHelpManualLink 		
			,strResolutionYoutubeLink 			
			,strImageId 						
												
			,intUpgradeTypeId 					
			,strUpgradeEnvironmentId 			
			,strUpgradeEnvironment 				
			,intUpgradeTargetVersionId 			
			,strUpgradeCompany 					
			,strUpgradeCustomerContactId 		
			,strUpgradeCustomerContact 			
			,dtmUpgradeStartTime				
			,strUpgradeCustomerTimeZone			
			,dtmUpgradeEndTime 					
			,intUpgradeTimeTook 				
			,strUpgradeCopyDataFrom 			
			,strUpgradeCopyDataTo 				
			,strUpgradeSpecialInstruction		
			,intRootCauseId 					
			,intSubcauseId						
			,strRootCauseReason					
			,strResolutionTrainingManualLink 	
			,strResolutionTrainingAgendaLink   
			,strResolutionSOPLink 				
			,dtmStartDate 						
			,strNote 							
	
	)

	SELECT   strTicketNumber				    = @strStartingNumber
			,strSubject						    = Ticket.strSubject
			,strCustomerNumber				    = @strCustomerNumber
			,intCustomerContactId			    = @intCustomerContactId
			,intCustomerId					    = @intCustomerId				
			,intMilestoneId 				    = Ticket.intMilestoneId 
			,intTicketTypeId 				    = @intDefaultTicketType 
			,intTicketStatusId 				    = Ticket.intTicketStatusId 
			,intTicketPriorityId 			    = Ticket.intTicketPriorityId 
			,intTicketProductId 			    = Ticket.intTicketProductId 
			,intModuleId 					    = Ticket.intModuleId 
			,intVersionId 					    = Ticket.intVersionId 
			,intAssignedTo 					    = GroupUserConfig.intUserSecurityEntityId 
			,intAssignedToEntity 			    = GroupUserConfig.intUserSecurityEntityId 
			,intCreatedUserId 				    = Ticket.intCreatedUserId 
			,intCreatedUserEntityId 		    = Ticket.intCreatedUserEntityId 
		    ,dtmCreated 					    = Ticket.dtmCreated 
			,dtmDueDate 					    = Ticket.dtmDueDate 
			,intLastModifiedUserId 			    = Ticket.intLastModifiedUserId 
			,intLastModifiedUserEntityId	    = Ticket.intLastModifiedUserEntityId
			,dtmLastModified 				    = Ticket.dtmLastModified 
			,dblQuotedHours 				    = Ticket.dblQuotedHours 
			,dblActualHours 				    = Ticket.dblActualHours 
			,dblNonBillableHours 			    = Ticket.dblNonBillableHours 
			,strJiraKey 					    = Ticket.strJiraKey 
			,strCompany						    = Ticket.strCompany
			,strOperatingSystem 			    = Ticket.strOperatingSystem 
			,strAcuVersion 					    = Ticket.strAcuVersion 
			,strDatabase 					    = Ticket.strDatabase 
			,strType 						    = Ticket.strType 
			,dtmCompleted 					    = Ticket.dtmCompleted 
			,intLineOfBusinessId 			    = Ticket.intLineOfBusinessId 
			,strLineOfBusinessId 			    = Ticket.strLineOfBusinessId 
			,intOpportunityCampaignId 		    = Ticket.intOpportunityCampaignId 
			,dtmLastCommented					= Ticket.dtmLastCommented 
			,intLastCommentedByEntityId 		= Ticket.intLastCommentedByEntityId 
			,strSubjectOverride					= Ticket.strSubjectOverride
			,ysnSendLink 						= Ticket.ysnSendLink 
			,strMultipleActivityId 				= Ticket.strMultipleActivityId 
			,intCompanyLocationId 				= Ticket.intCompanyLocationId 
			,intEntityLocationId 				= Ticket.intEntityLocationId 
			,intSequenceInProject				= ISNULL(ProjectCount.intProjectTaskIdCount, 1)
			,intCurrencyId 						= Ticket.intCurrencyId 
			,intCurrencyExchangeRateId 			= Ticket.intCurrencyExchangeRateId 
			,intCurrencyExchangeRateTypeId		= Ticket.intCurrencyExchangeRateTypeId
			,dtmExchangeRateDate 				= Ticket.dtmExchangeRateDate 
			,dblCurrencyRate 					= Ticket.dblCurrencyRate 
			,intFeedbackWithSolutionId			= Ticket.intFeedbackWithSolutionId
			,intFeedbackWithRepresentativeId 	= Ticket.intFeedbackWithRepresentativeId 
			,strFeedbackComment 				= Ticket.strFeedbackComment 
			,strDescription 					= Ticket.strDescription 
			,strResolution 						= Ticket.strResolution 
			,strResolutionHelpManualLink 		= Ticket.strResolutionHelpManualLink 
			,strResolutionYoutubeLink 			= Ticket.strResolutionYoutubeLink 
			,strImageId 						= Ticket.strImageId 
												
			,intUpgradeTypeId 					= Ticket.intUpgradeTypeId 
			,strUpgradeEnvironmentId 			= Ticket.strUpgradeEnvironmentId 
			,strUpgradeEnvironment 				= Ticket.strUpgradeEnvironment 
			,intUpgradeTargetVersionId 			= Ticket.intUpgradeTargetVersionId 
			,strUpgradeCompany 					= Ticket.strUpgradeCompany 
			,strUpgradeCustomerContactId 		= Ticket.strUpgradeCustomerContactId 
			,strUpgradeCustomerContact 			= Ticket.strUpgradeCustomerContact 
			,dtmUpgradeStartTime				= Ticket.dtmUpgradeStartTime
			,strUpgradeCustomerTimeZone			= Ticket.strUpgradeCustomerTimeZone
			,dtmUpgradeEndTime 					= Ticket.dtmUpgradeEndTime 
			,intUpgradeTimeTook 				= Ticket.intUpgradeTimeTook 
			,strUpgradeCopyDataFrom 			= Ticket.strUpgradeCopyDataFrom 
			,strUpgradeCopyDataTo 				= Ticket.strUpgradeCopyDataTo 
			,strUpgradeSpecialInstruction		= Ticket.strUpgradeSpecialInstruction
			,intRootCauseId 					= Ticket.intRootCauseId 
			,intSubcauseId						= Ticket.intSubcauseId
			,strRootCauseReason					= Ticket.strRootCauseReason
			,strResolutionTrainingManualLink 	= Ticket.strResolutionTrainingManualLink 
			,strResolutionTrainingAgendaLink    = Ticket.strResolutionTrainingAgendaLink
			,strResolutionSOPLink 				= Ticket.strResolutionSOPLink 
			,dtmStartDate 						= Ticket.dtmStartDate 
			,strNote 							= Ticket.strNote 
	FROM tblHDTicket Ticket
	OUTER APPLY
	(
		SELECT intProjectTaskIdCount = COUNT(intProjectTaskId)
		FROM tblHDProjectTask
		WHERE intProjectId = @intProjectId
	) ProjectCount
		INNER JOIN tblHDModule Module
	ON Module.intModuleId = Ticket.intModuleId
	CROSS APPLY
	(
	 SELECT TOP 1 y.intUserSecurityEntityId
	 FROM tblHDGroupUserConfig y
	 WHERE y.intTicketGroupId = Module.intTicketGroupId
	 ORDER BY y.ysnOwner DESC,
		   y.ysnEscalation DESC
	) GroupUserConfig
	WHERE Ticket.intTicketId = @intTicketId

	SET @intNewTicketId = SCOPE_IDENTITY()

	INSERT INTO tblHDProjectTask
	(
		 intProjectId
		,intTicketId
		,ysnClosed
		,intTemplateTicketId
		,intConcurrencyId
	)
	SELECT 	
	     intProjectId			= @intProjectId
		,intTicketId			= @intNewTicketId
		,ysnClosed				= CONVERT(BIT, 0)
		,intTemplateTicketId	= @intTicketId
		,intConcurrencyId		= 1
		


	FETCH NEXT FROM TemplateTickets INTO @intTicketId
END
CLOSE TemplateTickets
DEALLOCATE TemplateTickets

IF @ysnHasGeneratedTickets = 0
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