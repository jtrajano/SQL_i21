CREATE VIEW [dbo].[vyuCTSearchAOP]

AS

		SELECT		AO.*,
					BK.strBook,
					SB.strSubBook

			FROM	tblCTAOP		AO
	LEFT	JOIN	tblCTBook		BK  ON	BK.intBookId	=	AO.intBookId
	LEFT	JOIN	tblCTSubBook	SB  ON	SB.intSubBookId	=	AO.intSubBookId