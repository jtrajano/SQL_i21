CREATE VIEW [dbo].[vyuCTGetContractForScaleTicket]

AS 

	SELECT	CD.intContractDetailId,
			CD.intContractHeaderId,
			CD.intCompanyLocationId,	
			CD.dtmStartDate,				
			CD.intItemId,																			
			CD.dtmEndDate,																										
			CD.dblBasis,																				
			CD.dblCashPrice,																						
			CD.intContractStatusId,																			
			IM.strItemNo,										
			IM.strDescription				AS	strItemDescription,											
			PT.strPricingType,																				
			CL.strLocationName,																					
			EF.strFieldNumber,																					
			ISNULL(IM.ysnUseWeighScales,0)		ysnUseWeighScales,																								
			ISNULL(CD.dblBalance,0)		-	ISNULL(CD.dblScheduleQty,0)	AS	dblAvailableQty,											
			CASE	WHEN	CH.ysnLoad = 1 
					THEN	dbo.fnCTConvertQtyToTargetItemUOM(	CD.intItemUOMId,SK.intStockUOMId,CD.dblQuantityPerLoad * (ISNULL(CD.dblBalanceLoad,0) - ISNULL(CD.dblScheduleLoad,0)))		
					ELSE	dbo.fnCTConvertQtyToTargetItemUOM(	CD.intItemUOMId,SK.intStockUOMId,ISNULL(CD.dblBalance,0) - ISNULL(CD.dblScheduleQty,0))			
			END		AS		dblAvailableQtyInItemStockUOM,			
			CD.dblQuantityPerLoad,
			dbo.fnCTConvertQtyToTargetItemUOM(	CD.intItemUOMId,SK.intStockUOMId,CD.dblQuantityPerLoad) dblQtyPerLoadInItemStockUOM,
			CD.intNoOfLoad,										
			CS.strContractStatus,																	
			CAST(CASE WHEN CD.intContractStatusId IN (1,4) THEN 1 ELSE 0 END AS BIT) AS	ysnAllowedToShow,																		
			CAST(																										
				CASE	WHEN	DATEADD(d, 0, DATEDIFF(d, 0, GETDATE())) >= DATEADD(dd,-ISNULL(CP.intEarlyDaysPurchase,0),CD.dtmStartDate) AND CH.intContractTypeId = 1 																							
						THEN	1																						
						WHEN	DATEADD(d, 0, DATEDIFF(d, 0, GETDATE())) >= DATEADD(dd,-ISNULL(CP.intEarlyDaysSales,0),CD.dtmStartDate) AND CH.intContractTypeId = 2																						
						THEN	1																						
						ELSE	0																						
				END		AS BIT																							
			)	AS		ysnEarlyDayPassed,																							
			CH.intContractTypeId,																				
			CT.strContractType,					
			CH.intEntityId,
			EY.strName AS strEntityName,
			CH.strContractNumber,
			CH.ysnUnlimitedQuantity,
			CD.intContractSeq,
			CD.intPricingTypeId,
			CH.ysnLoad
																												
	FROM	tblCTContractDetail				CD	
	CROSS																						
	JOIN	tblCTCompanyPreference			CP																									
	JOIN	tblSMCompanyLocation			CL	ON	CL.intCompanyLocationId		=	CD.intCompanyLocationId																			
	JOIN	tblCTContractHeader				CH	ON	CH.intContractHeaderId		=	CD.intContractHeaderId		LEFT
	JOIN	tblCTContractStatus				CS	ON	CS.intContractStatusId		=	CD.intContractStatusId		LEFT
	JOIN	tblCTContractType				CT	ON	CT.intContractTypeId		=	CH.intContractTypeId		LEFT
	JOIN	tblEMEntity						EY	ON	EY.intEntityId				=	CH.intEntityId				LEFT
	JOIN	tblCTPricingType				PT	ON	PT.intPricingTypeId			=	CD.intPricingTypeId			LEFT
	JOIN	tblICItem						IM	ON	IM.intItemId				=	CD.intItemId				LEFT
	JOIN	tblICItemUOM					IU	ON	IU.intItemUOMId				=	CD.intItemUOMId				LEFT
	JOIN	tblICUnitMeasure				U1	ON	U1.intUnitMeasureId			=	IU.intUnitMeasureId			LEFT
	JOIN	tblEMEntityFarm					EF	ON	EF.intFarmFieldId			=	CD.intFarmFieldId			LEFT
	JOIN	(
					SELECT  intItemUOMId AS intStockUOMId,strUnitMeasure AS strStockUnitMeasure,IU.intItemId,IU.intUnitMeasureId AS intStockUnitMeasureId
					FROM	tblICItemUOM		IU	 
					JOIN	tblICUnitMeasure	UM	ON	UM.intUnitMeasureId			=	IU.intUnitMeasureId 
					WHERE	IU.ysnStockUnit = 1
				)								SK	ON	SK.intItemId				=	CD.intItemId																					

