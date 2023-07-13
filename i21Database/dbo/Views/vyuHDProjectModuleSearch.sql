CREATE VIEW [dbo].[vyuHDProjectModuleSearch]
AS 

SELECT  intProjectModuleId			= ProjectModule.intProjectModuleId
	   ,intModuleId				    = ProjectModule.intModuleId
	   ,strModule				    = SMModule.strModule
	   ,intProjectId				= ProjectModule.intProjectId
	   ,strProjectName				= Project.strProjectName
	   ,intProjectManagerId			= ProjectModule.intProjectManagerId
	   ,strProjectManager			= ImplementationLead.strName
	   ,strDataConversionExpert		= DataConversionExpert.strName
	   ,strTrainer					= Trainer.strName
	   ,strCustomerSuperUser		= CustomerSuperUser.strName
	   ,strContact					= Contact.strName
	   ,dblQuotedHours				= ISNULL(ProjectTickets.dblQuotedHours, 0)
	   ,dblActualBillableHours		= ISNULL(ProjectTickets.dblActualHours, 0)
	   ,dblHoursOverShort			= ISNULL(ProjectTickets.dblQuotedHours,0) - ISNULL(ProjectTickets.dblActualHours,0)
	   ,intCustomerId				= Project.intCustomerId
	   ,strCustomerName				= Customer.strName
	   ,strPercentComplete			= CASE WHEN ProjectTicketsCount.intClosedTickets  IS NOT NULL
											THEN CONVERT(NVARCHAR(10), CONVERT(DECIMAL(5,2),(ProjectTicketsCount.intClosedTickets  * 100/ ProjectTicketsCount.intTotalTickets))) + '%'
											ELSE '0.00%'
									END
	   ,strPhase					= ProjectModule.strPhase
	   ,strComment					= ProjectModule.strComment
	   ,dtmStartDate				= ProjectTicketStartDate.dtmStartDate
	   ,dtmCompleted				= CASE WHEN ProjectTicketStatus.intTicketStatusId IS NOT NULL	
												THEN NULL
										   ELSE ProjectTicketCompletedDate.dtmCompleted
									  END
	   ,dtmDueDate					= ProjectTicketDueDate.dtmDueDate
FROM tblHDProjectModule ProjectModule
		INNER JOIN tblHDProject Project
ON ProjectModule.intProjectId = Project.intProjectId
		INNER JOIN tblHDModule Module
ON Module.intModuleId = ProjectModule.intModuleId
		INNER JOIN tblSMModule SMModule
ON SMModule.intModuleId = Module.intSMModuleId
		LEFT JOIN tblEMEntity ImplementationLead
ON ImplementationLead.intEntityId = ProjectModule.intProjectManagerId
		LEFT JOIN tblEMEntity DataConversionExpert
ON DataConversionExpert.intEntityId = ProjectModule.intDataConversionExpertId
		LEFT JOIN tblEMEntity Trainer
ON Trainer.intEntityId = ProjectModule.intTrainerId
		LEFT JOIN tblEMEntity CustomerSuperUser
ON CustomerSuperUser.intEntityId = ProjectModule.intCustomerSuperUserId
		OUTER APPLY
		( 
		  SELECT TOP 1 strName
		  FROM vyuHDProjectCustomerContact
		  WHERE intEntityId = ProjectModule.intContactId

        ) Contact
		OUTER APPLY(

			SELECT     dblActualHours		= SUM(ISNULL(ProjectTicketsPerStatus.dblActualHours, 0))
					  ,dblQuotedHours		= SUM(ISNULL(ProjectTicketsPerStatus.dblQuotedHours, 0))
					  ,dblBillablehours     = SUM(ISNULL(ProjectTicketsPerStatus.dblBillablehours, 0))
			FROM (
				SELECT dblActualHours		= SUM(ISNULL(ProjectTickets.dblActualHours, 0))
					  ,dblQuotedHours		= SUM(ISNULL(ProjectTickets.dblQuotedHours, 0))
					  ,dblBillablehours     = CASE WHEN ProjectTickets.intTicketStatusId = 2
													THEN SUM(ISNULL(ProjectTickets.dblQuotedHours, 0))
													ELSE SUM(ISNULL(ProjectTickets.dblActualHours, 0))
											  END
				FROM tblHDProjectTask ProjectTask
						INNER JOIN vyuHDProjectTickets ProjectTickets
				ON ProjectTickets.intTicketId = ProjectTask.intTicketId
				WHERE ProjectTask.intProjectId = Project.intProjectId AND
					  ProjectTickets.strModule = SMModule.strModule	
				GROUP BY ProjectTickets.intTicketStatusId
				) ProjectTicketsPerStatus
		) ProjectTickets
		OUTER APPLY(

			SELECT	   TOP 1 dtmStartDate = ProjectTickets.dtmStartDate
			FROM tblHDProjectTask ProjectTask
					INNER JOIN vyuHDProjectTickets ProjectTickets
			ON ProjectTickets.intTicketId = ProjectTask.intTicketId
			WHERE ProjectTask.intProjectId = Project.intProjectId AND
				  ProjectTickets.strModule = SMModule.strModule	AND
				  ProjectTickets.dtmStartDate IS NOT NULL
			ORDER BY ProjectTickets.dtmStartDate
		) ProjectTicketStartDate
		OUTER APPLY(

			SELECT	   TOP 1 dtmDueDate = ProjectTickets.dtmDueDate
			FROM tblHDProjectTask ProjectTask
					INNER JOIN vyuHDProjectTickets ProjectTickets
			ON ProjectTickets.intTicketId = ProjectTask.intTicketId
			WHERE ProjectTask.intProjectId = Project.intProjectId AND
				  ProjectTickets.strModule = SMModule.strModule	AND
				  ProjectTickets.dtmDueDate IS NOT NULL
			ORDER BY ProjectTickets.dtmDueDate DESC
		) ProjectTicketDueDate
		OUTER APPLY(

			SELECT	   TOP 1 dtmCompleted = ProjectTickets.dtmCompleted
			FROM tblHDProjectTask ProjectTask
					INNER JOIN vyuHDProjectTickets ProjectTickets
			ON ProjectTickets.intTicketId = ProjectTask.intTicketId
			WHERE ProjectTask.intProjectId = Project.intProjectId AND
				  ProjectTickets.strModule = SMModule.strModule	AND 
				  ProjectTickets.dtmCompleted IS NOT NULL
			ORDER BY ProjectTickets.dtmCompleted DESC
		) ProjectTicketCompletedDate
			OUTER APPLY(
				SELECT Project.strProjectName,								
				       intClosedTickets		= SUM(CASE WHEN ProjectTickets.strStatus = 'Closed' 
													THEN 1
													ELSE 0
													END),
					   intTotalTickets  =      count(ProjectTask.intTicketId)																	  
				FROM tblHDProjectTask ProjectTask
						INNER JOIN vyuHDProjectTickets ProjectTickets
				ON ProjectTickets.intTicketId = ProjectTask.intTicketId
				WHERE ProjectTask.intProjectId = Project.intProjectId AND
					  ProjectTickets.strModule = SMModule.strModule	
				GROUP BY ProjectTask.intProjectId			
		) ProjectTicketsCount
		OUTER APPLY(

			SELECT	   TOP 1 intTicketStatusId = ProjectTickets.intTicketStatusId
			FROM tblHDProjectTask ProjectTask
					INNER JOIN vyuHDProjectTickets ProjectTickets
			ON ProjectTickets.intTicketId = ProjectTask.intTicketId
			WHERE ProjectTask.intProjectId = Project.intProjectId AND
				  ProjectTickets.strModule = SMModule.strModule	AND
				  ProjectTickets.intTicketStatusId <> 2					
		) ProjectTicketStatus
		INNER JOIN tblEMEntity Customer
ON Customer.intEntityId = Project.intCustomerId
WHERE Project.strType = 'HD'

GO