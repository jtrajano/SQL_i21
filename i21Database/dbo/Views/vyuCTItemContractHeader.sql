CREATE VIEW [dbo].[vyuCTItemContractHeader]
	
AS 

	SELECT	*
	FROM	(
				SELECT	
						CP.strContractPlan,
						TP.strContractType,
						EY.strName					AS	strEntityName,						
						FT.strFreightTerm,
						CO.strCountry,						
						TM.strTerm,						
						TM.strTermCode,
						SP.strName					AS	strSalesperson,
						TX.strTextCode,
						CR.strCurrency				AS	strCurrency,						
						
						CR.ysnSubCurrency			AS	ysnMarketSubCurrency,						
						LB.strLineOfBusiness,
						CL.strLocationName,
						OP.strName					AS strOpportunityName,
						ysnIsUsed = CONVERT(BIT, CASE WHEN (SELECT TOP 1 1 FROM tblARInvoiceDetail WHERE intItemContractHeaderId = CH.intItemContractHeaderId) = 1 THEN 1 ELSE 0 END),
						ysnPrepaid = CAST(CASE WHEN ISNULL(dbo.fnCTGetPrepaidIdsItemContract(CH.intItemContractHeaderId),'') = '' THEN 0 ELSE 1 END AS BIT),
						strPrepaidIds = ISNULL(dbo.fnCTGetPrepaidIdsItemContract(CH.intItemContractHeaderId),'') COLLATE Latin1_General_CI_AS,  
						CH.*						
						

					FROM	tblCTItemContractHeader				CH	
				
					JOIN	tblEMEntity							EY	ON	EY.intEntityId						=		CH.intEntityId							
			LEFT	JOIN	tblEMEntity							SP	ON	SP.intEntityId						=		CH.intSalespersonId									
			LEFT	JOIN	tblEMEntityLocation					EL	ON	EL.intEntityId						=		CH.intEntityId 
																	AND EL.ysnDefaultLocation				=		1
						
			LEFT	JOIN	tblSMTerm							TM	ON	TM.intTermID						=		CH.intTermId									
			LEFT	JOIN	tblCTContractType					TP	ON	TP.intContractTypeId				=		CH.intContractTypeId				
			LEFT	JOIN	tblCTContractText					TX	ON	TX.intContractTextId				=		CH.intContractTextId										
			LEFT	JOIN	tblSMCountry						CO	ON	CO.intCountryID						=		CH.intCountryId	
				
			LEFT	JOIN	tblSMCurrency						CR	ON	CR.intCurrencyID					=		CH.intCurrencyId					
			LEFT	JOIN	tblCTContractPlan					CP	ON	CP.intContractPlanId				=		CH.intContractPlanId											
				
			LEFT	JOIN	tblSMFreightTerms					FT	ON	FT.intFreightTermId					=		CH.intFreightTermId
			LEFT	JOIN	tblSMLineOfBusiness					LB	ON	LB.intLineOfBusinessId				=		CH.intLineOfBusinessId
			LEFT	JOIN	tblSMCompanyLocation				CL	ON	CL.intCompanyLocationId				=		CH.intCompanyLocationId
			LEFT	JOIN	tblCRMOpportunity					OP	ON	OP.intOpportunityId					=		CH.intOpportunityId

			) tblX
