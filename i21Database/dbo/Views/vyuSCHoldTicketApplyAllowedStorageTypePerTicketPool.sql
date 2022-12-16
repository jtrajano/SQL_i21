CREATE VIEW [dbo].[vyuSCHoldTicketApplyAllowedStorageTypePerTicketPool]
	AS


SELECT DISTINCT 

	STORAGE_TYPE.strStorageTypeCode as strDistributionOption
	, DISTRIBUTION_OPTION.intStorageScheduleTypeId
	, DISTRIBUTION_OPTION.intTicketPoolId
	, DISTRIBUTION_OPTION.intDistributionOptionId 
	, STORAGE_SCHEDULE.intCommodity
	, STORAGE_SCHEDULE.strScheduleId
	, STORAGE_SCHEDULE.strScheduleDescription
	, STORAGE_SCHEDULE.intCompanyLocationId
	, STORAGE_SCHEDULE.intStorageScheduleRuleId AS intStorageScheduleId
	, STORAGE_TYPE.ysnCustomerStorage 
FROM tblSCDistributionOption DISTRIBUTION_OPTION

	JOIN tblSCTicketType TICKET_TYPE
		ON DISTRIBUTION_OPTION.intTicketTypeId = TICKET_TYPE.intTicketTypeId
			AND intListTicketTypeId = 1			
			AND DISTRIBUTION_OPTION.intTicketPoolId = TICKET_TYPE.intTicketPoolId

	JOIN vyuGRGetStorageSchedule STORAGE_SCHEDULE
		ON DISTRIBUTION_OPTION.intStorageScheduleTypeId = STORAGE_SCHEDULE.intStorageType
	JOIN tblGRStorageType STORAGE_TYPE
		ON STORAGE_SCHEDULE.intStorageType = STORAGE_TYPE.intStorageScheduleTypeId
			
WHERE DISTRIBUTION_OPTION.intStorageScheduleTypeId > 0
	AND DISTRIBUTION_OPTION.ysnDistributionAllowed = 1

GO
