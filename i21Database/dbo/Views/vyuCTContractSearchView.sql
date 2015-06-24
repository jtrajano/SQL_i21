CREATE VIEW [dbo].[vyuCTContractSearchView]

AS

	SELECT	CH.intContractHeaderId,
			CH.dtmContractDate,
			CH.strEntityName AS strCustomerVendor,
			CH.strContractType,
			CH.dblHeaderQuantity,
			CH.intContractNumber,
			CH.strCustomerContract,
			CH.ysnSigned,
			CH.ysnPrinted,
			SUM(CD.dblBalance) AS dblBalance
			
	FROM	vyuCTContractHeaderView		CH	LEFT
	JOIN	tblCTContractDetail			CD	ON	CD.intContractHeaderId	=	CH.intContractHeaderId	GROUP
	
	BY		CH.intContractHeaderId,
			CH.dtmContractDate,
			CH.strEntityName,
			CH.strContractType,
			CH.dblHeaderQuantity,
			CH.intContractNumber,
			CH.strCustomerContract,
			CH.ysnSigned,
			CH.ysnPrinted