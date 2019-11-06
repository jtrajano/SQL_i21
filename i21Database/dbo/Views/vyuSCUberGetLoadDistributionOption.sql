CREATE VIEW [dbo].[vyuSCUberGetLoadDistributionOption]
AS 
	SELECT 
		DO.intDistributionOptionId
		, LT.strTicketType
		, LSS.intEntityId 
		, LSS.intScaleSetupId
		, TP.intTicketPoolId
		, SS.strStationShortDescription
		, SS.strStationDescription
		, TP.strTicketPool
		, DO.strDistributionOption
		, DO.ysnDistributionAllowed
		, DO.ysnDefaultDistribution
	from 
		tblSCLastScaleSetup LSS
		inner join tblSCScaleSetup SS on LSS.intScaleSetupId = SS.intScaleSetupId
		inner join tblSCDistributionOption DO on SS.intTicketPoolId = DO.intTicketPoolId
		inner join tblSCTicketPool TP on DO.intTicketPoolId = TP.intTicketPoolId
		inner join tblSCTicketType TY on TY.intTicketTypeId = DO.intTicketTypeId 
		inner join tblSCListTicketTypes LT on LT.intTicketTypeId = TY.intListTicketTypeId
	where 
		DO.strDistributionOption = 'LOD'