CREATE VIEW [dbo].[vyuSCUberGetLoadDistributionOption]
AS 
	SELECT 
		DO.intDistributionOptionId
		, LT.strTicketType
		, SS.intScaleSetupId
		, TP.intTicketPoolId
		, SS.strStationShortDescription
		, SS.strStationDescription
		, TP.strTicketPool
		, DO.strDistributionOption
		, DO.ysnDistributionAllowed
		, DO.ysnDefaultDistribution
	from 
		tblSCScaleSetup SS 
		inner join tblSCDistributionOption DO on SS.intTicketPoolId = DO.intTicketPoolId
		inner join tblSCTicketPool TP on DO.intTicketPoolId = TP.intTicketPoolId
		inner join tblSCTicketType TY on TY.intTicketTypeId = DO.intTicketTypeId 
		inner join tblSCListTicketTypes LT on LT.intTicketTypeId = TY.intListTicketTypeId
	where 
		DO.strDistributionOption = 'LOD'