CREATE VIEW [dbo].[vyuHDRoughCountCapacity]
	AS
		select
			intRoughCountCapacityId = convert(int,row_number() over (order by intTicketId))
			,intSourceEntityId
			,strSourceName
			,intTicketId
			,strTicketNumber
			,intCustomerEntityId
			,strCustomerName
			,dblFirstWeek
			,dblSecondWeek
			,dblThirdWeek
			,dblForthWeek
			,dblFifthWeek
			,dblSixthWeek
			,dblSeventhWeek
			,dtmPlanDate
			,strFilterKey
		from
		(
		select distinct
			intSourceEntityId
			,strSourceName
			,intTicketId
			,strTicketNumber
			,intCustomerEntityId
			,strCustomerName
			,dblFirstWeek
			,dblSecondWeek
			,dblThirdWeek
			,dblForthWeek
			,dblFifthWeek
			,dblSixthWeek
			,dblSeventhWeek
			,dtmPlanDate
			,strFilterKey
		from tblHDRoughCountCapacity
		) as rawResult
