CREATE VIEW [dbo].[vyuCTContractCertification]

AS 

	SELECT	CC.*,
			PR.strName  AS  strProducer,
			VR.strFLOId,
			CF.strCertificationName 
			FROM	 tblCTContractCertification	CC
	LEFT	JOIN	tblEMEntity					PR	ON  PR.intEntityId			=   CC.intProducerId
	LEFT	JOIN	tblAPVendor					VR	ON  VR.intEntityId			=   CC.intProducerId
	LEFT	JOIN	tblICCertification			CF	ON  CF.intCertificationId	=	CC.intCertificationId
