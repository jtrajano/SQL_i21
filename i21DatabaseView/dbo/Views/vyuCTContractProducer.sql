CREATE VIEW [dbo].[vyuCTContractProducer]

AS

SELECT	CP.*,
		PR.strName  AS  strProducer,
		VR.strFLOId
FROM	tblCTContractProducer	CP
JOIN	tblEMEntity				PR	ON  PR.intEntityId	=   CP.intProducerId
JOIN	tblAPVendor				VR	ON  VR.intEntityId	=   CP.intProducerId
