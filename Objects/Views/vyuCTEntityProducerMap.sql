CREATE VIEW [dbo].[vyuCTEntityProducerMap]

AS

	SELECT	EP.* ,
			EY.strName	AS	strEntityName,
			PR.strName	AS	strProducer

	FROM	tblCTEntityProducerMap	EP
	JOIN	tblEMEntity				EY	ON	EY.intEntityId	=	EP.intEntityId
	JOIN	tblEMEntity				PR	ON	PR.intEntityId	=	EP.intProducerId
