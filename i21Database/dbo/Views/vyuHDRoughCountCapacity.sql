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
			,dblPlanFirstWeek
			,dblPlanSecondWeek
			,dblPlanThirdWeek
			,dblPlanForthWeek
			,dblPlanFifthWeek
			,dblPlanSixthWeek
			,dblPlanSeventhWeek
			,dblPlanEighthWeek
			,dblPlanNinthWeek
			,dblPlanTenthWeek
			,dblPlanEleventhWeek
			,dblPlanTwelfthWeek
			,dblEstimateFirstWeek
			,dblEstimateSecondWeek
			,dblEstimateThirdWeek
			,dblEstimateForthWeek
			,dblEstimateFifthWeek
			,dblEstimateSixthWeek
			,dblEstimateSeventhWeek
			,dblEstimateEighthWeek
			,dblEstimateNinthWeek
			,dblEstimateTenthWeek
			,dblEstimateEleventhWeek
			,dblEstimateTwelfthWeek
			,dblFirstWeek
			,dblSecondWeek
			,dblThirdWeek
			,dblForthWeek
			,dblFifthWeek
			,dblSixthWeek
			,dblSeventhWeek
			,dblEighthWeek
			,dblNinthWeek
			,dblTenthWeek
			,dblEleventhWeek
			,dblTwelfthWeek
			,dtmPlanDate = getdate()
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
			,dblPlanFirstWeek
			,dblPlanSecondWeek
			,dblPlanThirdWeek
			,dblPlanForthWeek
			,dblPlanFifthWeek
			,dblPlanSixthWeek
			,dblPlanSeventhWeek
			,dblPlanEighthWeek
			,dblPlanNinthWeek
			,dblPlanTenthWeek
			,dblPlanEleventhWeek
			,dblPlanTwelfthWeek
			,dblEstimateFirstWeek
			,dblEstimateSecondWeek
			,dblEstimateThirdWeek
			,dblEstimateForthWeek
			,dblEstimateFifthWeek
			,dblEstimateSixthWeek
			,dblEstimateSeventhWeek
			,dblEstimateEighthWeek
			,dblEstimateNinthWeek
			,dblEstimateTenthWeek
			,dblEstimateEleventhWeek
			,dblEstimateTwelfthWeek
			,dblFirstWeek
			,dblSecondWeek
			,dblThirdWeek
			,dblForthWeek
			,dblFifthWeek
			,dblSixthWeek
			,dblSeventhWeek
			,dblEighthWeek
			,dblNinthWeek
			,dblTenthWeek
			,dblEleventhWeek
			,dblTwelfthWeek
			,dtmPlanDate = getdate()
			,strFilterKey
		from tblHDRoughCountCapacity
		where 
			dblPlanFirstWeek is not null
			or dblPlanSecondWeek is not null
			or dblPlanThirdWeek is not null
			or dblPlanForthWeek is not null
			or dblPlanFifthWeek is not null
			or dblPlanSixthWeek is not null
			or dblPlanSeventhWeek is not null
			or dblPlanEighthWeek is not null
			or dblPlanNinthWeek is not null
			or dblPlanTenthWeek is not null
			or dblPlanEleventhWeek is not null
			or dblPlanTwelfthWeek is not null
			or dblEstimateFirstWeek is not null
			or dblEstimateSecondWeek is not null
			or dblEstimateThirdWeek is not null
			or dblEstimateForthWeek is not null
			or dblEstimateFifthWeek is not null
			or dblEstimateSixthWeek is not null
			or dblEstimateSeventhWeek is not null
			or dblEstimateEighthWeek is not null
			or dblEstimateNinthWeek is not null
			or dblEstimateTenthWeek is not null
			or dblEstimateEleventhWeek is not null
			or dblEstimateTwelfthWeek is not null
			or dblFirstWeek is not null
			or dblSecondWeek is not null
			or dblThirdWeek is not null
			or dblForthWeek is not null
			or dblFifthWeek is not null
			or dblSixthWeek is not null
			or dblSeventhWeek is not null
			or dblEighthWeek is not null
			or dblNinthWeek is not null
			or dblTenthWeek is not null
			or dblEleventhWeek is not null
			or dblTwelfthWeek is not null
		) as rawResult
