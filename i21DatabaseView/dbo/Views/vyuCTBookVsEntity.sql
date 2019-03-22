CREATE VIEW [dbo].[vyuCTBookVsEntity]

AS 

	SELECT  BE.*,
			BK.strBook,
			EY.strName  AS  strEntityName,
			MC.strCompanyName,
			SB.strSubBook
		   
	FROM	tblCTBookVsEntity			BE
			JOIN	tblCTBook			BK  ON  BK.intBookId			=   BE.intBookId
			JOIN	tblEMEntity			EY  ON  EY.intEntityId			=   BE.intEntityId
	LEFT	JOIN	tblSMMultiCompany	MC  ON  MC.intMultiCompanyId	=	BE.intMultiCompanyId
	LEFT	JOIN	tblCTSubBook		SB  ON  SB.intSubBookId			=	BE.intSubBookId