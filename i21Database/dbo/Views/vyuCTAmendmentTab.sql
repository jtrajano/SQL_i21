CREATE VIEW [dbo].[vyuCTAmendmentTab]
AS
SELECT 	ysnShow = convert(bit, count(*)),
		intContractHeaderId
FROM ( 	
		SELECT 	a.intContractHeaderId 		
				,a.ysnSigned 		
				,intAmmendment = count(b.intSequenceAmendmentLogId) 	
		FROM 	tblCTContractHeader a 		
		left join tblCTSequenceAmendmentLog b on b.intContractHeaderId = a.intContractHeaderId 					
		GROUP BY 		
		a.intContractHeaderId 		
		,a.ysnSigned 
	) as am 
cross apply (SELECT top 1 ysnStayAsDraftContractUntilApproved = isnull(ysnStayAsDraftContractUntilApproved,0) from tblCTCompanyPreference) pf where 	am.ysnSigned = (case when pf.ysnStayAsDraftContractUntilApproved = 0 then convert(bit,1) else am.ysnSigned end) 	or intAmmendment > (case when pf.ysnStayAsDraftContractUntilApproved = 0 then 0 else -1 end)
GROUP by intContractHeaderId