CREATE VIEW [dbo].[vyuCTSearchAOP]

AS

		SELECT		AO.*,
					BK.strBook,
					SB.strSubBook,
					CO.strCommodityCode,
					LO.strLocationName

			FROM	tblCTAOP				AO
	LEFT	JOIN	tblCTBook				BK  ON	BK.intBookId			=	AO.intBookId
	LEFT	JOIN	tblCTSubBook			SB  ON	SB.intSubBookId			=	AO.intSubBookId
	LEFT	JOIN	tblICCommodity			CO  ON	CO.intCommodityId		=	AO.intCommodityId
	LEFT	JOIN	tblSMCompanyLocation	LO  ON	LO.intCompanyLocationId	=	AO.intCompanyLocationId