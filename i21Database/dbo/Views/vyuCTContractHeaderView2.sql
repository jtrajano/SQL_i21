CREATE VIEW [dbo].[vyuCTContractHeaderView2]
AS
SELECT	CH.intContractHeaderId,			
		CH.strContractNumber,			
		CH.dtmContractDate,				
		CH.dblQuantity				AS	dblHeaderQuantity,		
		CH.ysnSigned,							
		CH.strCustomerContract,			
		CH.ysnPrinted,							
		CH.dtmCreated,				
		CH.ysnLoad,	
		CH.dtmSigned,		
		U2.strUnitMeasure			AS	strHeaderUnitMeasure,
		TP.strContractType,				
		EY.strName AS strEntityName,					
		EY.intEntityId
FROM	tblCTContractHeader					CH	
JOIN	tblCTContractType					TP	ON	TP.intContractTypeId				=		CH.intContractTypeId
JOIN	tblEMEntity							EY	ON	EY.intEntityId						=		CH.intEntityId
JOIN	tblICCommodityUnitMeasure			CM	ON	CM.intCommodityUnitMeasureId		=		CH.intCommodityUOMId				LEFT
JOIN	tblICUnitMeasure					U2	ON	U2.intUnitMeasureId					=		CM.intUnitMeasureId	