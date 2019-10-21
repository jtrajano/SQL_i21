﻿CREATE VIEW [dbo].[vyuCTAmendmentHistory]
AS
SELECT 
	 intSequenceAmendmentLogId      =  SAL.intSequenceAmendmentLogId
	,intContractHeaderId            =  SAL.intContractHeaderId
	,intContractDetailId            =  SAL.intContractDetailId
	,dtmHistoryCreated	            =  SAL.dtmHistoryCreated
	,strContractNumber              =  CH.strContractNumber
	,intContractSeq                 =  CD.intContractSeq
	,intEntityId		            =  CH.intEntityId
	,strEntityName		            =  EY.strName
	,intContractTypeId              =  CH.intContractTypeId
	,strContractType	            =  TP.strContractType
	,strItemChanged		            =  SAL.strItemChanged
	--,strOldValue		            =  SAL.strOldValue
	,strOldValue = (
			case
			when
				SAL.strItemChanged in ('Partial Price Qty','Full Price Qty','Partial Price Fixation','Full Price Fixation') and SAL.strOldValue = '0'
			then
					isnull(
						(
							select
								top 1 b.strNewValue
							from
								tblCTSequenceAmendmentLog b
							where
								b.intContractHeaderId = SAL.intContractHeaderId
								and b.intContractDetailId = SAL.intContractDetailId
								and b.strItemChanged = SAL.strItemChanged
								and b.intSequenceAmendmentLogId < SAL.intSequenceAmendmentLogId
							order by
								b.intSequenceAmendmentLogId desc
						),
					'0')
			else
				SAL.strOldValue
			end
		)
	,strNewValue		            =  SAL.strNewValue
	,intCommodityId		            =  CH.intCommodityId
	,strCommodityCode	            =  CO.strCommodityCode
	,ysnPrinted			            =  CASE WHEN ISNULL(SAL.strAmendmentNumber,'') <>'' THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
	,intCompanyLocationId           =  CD.intCompanyLocationId
	,strLocationName                =  CL.strLocationName
	,strAmendmentNumber		        =  SAL.strAmendmentNumber
	,ysnSigned						=  SAL.ysnSigned
	,dtmSigned					    =  SAL.dtmSigned
	,intSalesPersonId				=  CH.intSalespersonId
	,strSalesPerson					=  CS.strName
	,intConcurrencyId				=  SAL.intConcurrencyId
FROM tblCTSequenceAmendmentLog	   SAL
JOIN tblCTContractHeader		   CH  ON CH.intContractHeaderId     = SAL.intContractHeaderId
JOIN tblEMEntity				   EY  ON EY.intEntityId		     = CH.intEntityId
JOIN tblCTContractType			   TP  ON TP.intContractTypeId       = CH.intContractTypeId
JOIN tblCTAmendmentApproval        AMP ON AMP.intAmendmentApprovalId = SAL.intAmendmentApprovalId  AND ISNULL(AMP.ysnAmendment,0) = 1
LEFT JOIN tblCTContractDetail	   CD  ON CD.intContractDetailId     = SAL.intContractDetailId
LEFT JOIN tblICCommodity	       CO  ON CO.intCommodityId			 = CH.intCommodityId
LEFT JOIN tblSMCompanyLocation	   CL  ON CL.intCompanyLocationId    = CD.intCompanyLocationId
LEFT JOIN vyuEMEntity			   CS  ON CS.intEntityId	 		= CH.intSalespersonId