CREATE VIEW [dbo].[vyuCTAOPComponent]

AS 

	SELECT	AC.*,
			IM.strItemNo AS strBasisItemNo
	FROM	tblCTAOPComponent	AC
	JOIN	tblICItem			IM	ON	IM.intItemId	=	AC.intBasisItemId
