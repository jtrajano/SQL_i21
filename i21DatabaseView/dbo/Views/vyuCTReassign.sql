CREATE VIEW [dbo].[vyuCTReassign]

AS 

	SELECT	RN.intReassignId,
			RN.intContractTypeId,
			RN.intEntityId,
			RN.intDonorId,
			RN.intRecipientId,
			RN.intCreatedById,
			RN.dtmCreated,
			CT.strContractType,
			DH.strContractNumber + ' - ' + LTRIM(DO.intContractSeq) AS strDonor,
			RH.strContractNumber + ' - ' + LTRIM(RE.intContractSeq) AS strRecipient,
			EY.strName AS strEntityName,
			UR.strName AS strCreatedBy
	FROM	tblCTReassign RN
	JOIN	tblCTContractType	CT	ON	CT.intContractTypeId	=	RN.intContractTypeId
	JOIN	tblCTContractDetail DO	ON	DO.intContractDetailId	=	RN.intDonorId
	JOIN	tblCTContractHeader	DH	ON	DH.intContractHeaderId	=	DO.intContractHeaderId
	JOIN	tblCTContractDetail RE	ON	RE.intContractDetailId	=	RN.intRecipientId
	JOIN	tblCTContractHeader	RH	ON	RH.intContractHeaderId	=	RE.intContractHeaderId
	JOIN	tblEMEntity			EY	ON	EY.intEntityId			=	RN.intEntityId
	JOIN	tblEMEntity			UR	ON	UR.intEntityId			=	RN.intCreatedById
