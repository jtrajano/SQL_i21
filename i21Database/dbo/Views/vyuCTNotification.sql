CREATE VIEW [dbo].[vyuCTNotification]

AS
	WITH Header AS
	(
		SELECT	CH.intContractHeaderId,	CH.dtmContractDate,		CT.strContractType,		CO.strCommodityCode,	CH.strContractNumber,
				CB.strContractBasis,	PO.strPosition,			CR.strCountry,			CH.strCustomerContract,	CH.dblQuantity			AS	dblHdrQuantity,		
				PT.strPricingType		AS	strHdrPricingType,	
				UM.strUnitMeasure		AS	strHdrUOM,	
				EY.strName				AS	strEntityName,		
				ISNULL(ysnSigned,0)		AS	ysnSigned,
				ISNULL(ysnMailSent,0)	AS	ysnMailSent,		
				CY.strEntityNo			AS	strCreatedByNo,	
				SP.strName				AS	strSalesperson,
				dbo.fnCTConvertQuantityToTargetCommodityUOM(CH.intCommodityUOMId,SU.intCommodityUnitMeasureId,CH.dblQuantity) dblQtyInStockUOM,

				CD.intCurrencyId,		CD.intBookId,			CD.intSubBookId,		CD.intCompanyLocationId, 
				CD.intContractSeq,		CD.dtmStartDate,		CD.dtmEndDate,			CD.strPurchasingGroup,
				CD.dblQuantity,			CD.dblFutures,			CD.dblBasis,			CD.dblCashPrice,
				CD.dblScheduleQty,		CD.dblNoOfLots,			CD.strItemNo,			CD.strPricingType,
				CD.strFutMarketName,	CD.strItemUOM,			CD.strLocationName,		CD.strPriceUOM,
				CD.strCurrency,			CD.strFutureMonth,		CD.strStorageLocation,	CD.strSubLocation,
				CD.strItemDescription,	CD.intContractDetailId,	CD.strProductType,		PW.intAllStatusId,
				BC.strBasisComponent COLLATE Latin1_General_CI_AS AS strBasisComponent,
				CD.intContractStatusId,	CD.strContractItemName,	CD.strContractItemNo,
				st.strSampleTypeName
				
		FROM	tblCTContractHeader			CH
		JOIN	tblICCommodity				CO	ON	CO.intCommodityId				=	CH.intCommodityId
		JOIN	tblCTPricingType			PT	ON	PT.intPricingTypeId				=	CH.intPricingTypeId
		JOIN	tblEMEntity					EY	ON	EY.intEntityId					=	CH.intEntityId
		JOIN	tblCTContractType			CT	ON	CT.intContractTypeId			=	CH.intContractTypeId
		JOIN	tblICCommodityUnitMeasure	CU	ON	CU.intCommodityUnitMeasureId	=	CH.intCommodityUOMId
		JOIN	tblICUnitMeasure			UM	ON	UM.intUnitMeasureId				=	CU.intUnitMeasureId
		JOIN	tblICCommodityUnitMeasure	SU	ON	SU.intCommodityId				=	CH.intCommodityId
												AND	SU.ysnStockUnit					=	1						LEFT
		JOIN	tblCTContractBasis			CB	ON	CB.intContractBasisId			=	CH.intContractBasisId	LEFT
		JOIN	tblCTPosition				PO	ON	PO.intPositionId				=	CH.intPositionId		LEFT
		JOIN	tblEMEntity					SP	ON	SP.intEntityId					=	CH.intSalespersonId		LEFT
		JOIN	tblSMCountry				CR	ON	CR.intCountryID					=	CH.intCountryId			LEFT
		JOIN	tblEMEntity					CY	ON	CY.intEntityId					=	CH.intCreatedById		LEFT
		JOIN	
		(
				SElECT * FROM
				(
					SELECT	intCurrencyId,					intBookId,					intSubBookId,					intCompanyLocationId, 
							intContractSeq,					dtmStartDate,				dtmEndDate,						strPurchasingGroup,
							dblQuantity,					dblFutures,					dblBasis,						dblCashPrice,
							dblScheduleQty,					dblNoOfLots,				strItemNo,						strPricingType,
							strFutMarketName,				strItemUOM,					strLocationName,				strPriceUOM,
							strCurrency,					strFutureMonth,				strStorageLocation,				strSubLocation,
							strItemDescription,				intContractDetailId,		strProductType,					ysnSubCurrency,
							intContractStatusId,			strContractItemName,		strContractItemNo,				intContractHeaderId,
							ROW_NUMBER() OVER (PARTITION BY intContractHeaderId ORDER BY intContractDetailId ASC) intRowNum
					FROM	vyuCTContractSequence 
					WHERE	ISNULL(intContractStatusId,1) NOT IN (3,5)
				)t	WHERE intRowNum = 1			

		)									CD	ON	CD.intContractHeaderId			=	CH.intContractHeaderId	LEFT
		JOIN
		(
				SELECT intContractDetailId, strBasisComponent = STUFF((
				SELECT ', ' + strItemNo + ' = ' + dbo.fnRemoveTrailingZeroes(dblRate) FROM vyuCTContractCostView
				WHERE intContractDetailId = x.intContractDetailId
				FOR XML PATH(''), TYPE).value('.[1]', 'nvarchar(max)'), 1, 2, '')
				FROM vyuCTContractCostView AS x
				GROUP BY intContractDetailId
		)									BC	ON	BC.intContractDetailId			=	CD.intContractDetailId	LEFT
		JOIN 
		(
				SELECT intContractHeaderId
				,SUM(POWER(2, intContractStatusId )) intAllStatusId
				FROM 
				(
					SELECT DISTINCT intContractHeaderId
					,intContractStatusId
					FROM tblCTContractDetail
				 ) t
				GROUP BY intContractHeaderId
		)									PW	ON	PW.intContractHeaderId			=	CD.intContractHeaderId
		left join tblQMSampleType st on st.intSampleTypeId = CH.intSampleTypeId
	)

	SELECT	CAST(ROW_NUMBER() OVER(ORDER BY intContractHeaderId DESC) AS INT) AS intUniqueId,
			*
	FROM 
	(
		SELECT	CD.intContractHeaderId,			CD.intContractSeq,				CD.dtmStartDate,					CD.dtmEndDate,
				CD.dblQuantity,					CD.dblFutures,					CD.dblBasis,						CD.dblCashPrice,
				CD.dblScheduleQty,				CD.dblNoOfLots,					CD.strItemNo,						CD.strPricingType,
				CD.strFutMarketName,			CD.strItemUOM,					CD.strLocationName,					CD.strPriceUOM,
				CD.strCurrency,					CD.strFutureMonth,				CD.strStorageLocation,				CD.strSubLocation,
				CD.strPurchasingGroup,			CD.strCreatedByNo,				CD.strContractNumber,				CD.dtmContractDate,
				CD.strContractType,				CD.strCommodityCode,			CD.strEntityName,					'Unconfirmed' COLLATE Latin1_General_CI_AS AS strNotificationType,
				CD.strItemDescription,			CH.dblQtyInStockUOM,			CD.intContractDetailId,				CD.strProductType,
				dbo.fnCTGetBasisComponentString(CD.intContractDetailId,'NOTIF') strBasisComponent,			
												CH.strPosition,					CH.strContractBasis,				CH.strCountry,			
				CH.strCustomerContract,			strSalesperson,					CD.intContractStatusId,				CD.strContractItemName,		
				CD.strContractItemNo,
				strCounterParty = CD.strEntityName,
				strSIRef = null,
				dtmSIDate = null,
				ysnShipped = null,
				dtmETSPol = null,
				strBookedShippingLine = null,
				strBookNumber = null,
				strETSDateStatus = null,
				strSampleType = null,
				strApprovalStatus = null

		FROM	vyuCTContractSequence	CD
		JOIN	Header					CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId
		WHERE	CD.intContractStatusId = 2
	
		UNION ALL

		SELECT	CH.intContractHeaderId,			NULL,							NULL,								NULL,
				CH.dblQuantity,					CH.dblFutures,					NULL,								NULL,
				NULL,							CH.dblNoOfLots,					NULL,								NULL,
				NULL,							UM.strUnitMeasure,				NULL,								NULL,
				NULL,							NULL,							NULL,								NULL,
				NULL,							CY.strEntityNo,					CH.strContractNumber,				CH.dtmContractDate,
				CT.strContractType,				CO.strCommodityCode,			EY.strName,							'Empty' AS strNotificationType,
				NULL,							dbo.fnCTConvertQuantityToTargetCommodityUOM(CH.intCommodityUOMId,SU.intCommodityUnitMeasureId,CH.dblQuantity) dblQtyInStockUOM,		NULL,			NULL,
				NULL,							PO.strPosition,					CB.strContractBasis,				CR.strCountry,			
				CH.strCustomerContract,			SP.strName,						CD.intContractStatusId,				'' AS strContractItemName,		
				'' AS strContractItemNo,
				strCounterParty = null,
				strSIRef = null,
				dtmSIDate = null,
				ysnShipped = null,
				dtmETSPol = null,
				strBookedShippingLine = null,
				strBookNumber = null,
				strETSDateStatus = null,
				strSampleType = null,
				strApprovalStatus = null

		FROM	tblCTContractHeader			CH
		JOIN	tblICCommodity				CO	ON	CO.intCommodityId				=	CH.intCommodityId
		JOIN	tblCTPricingType			PT	ON	PT.intPricingTypeId				=	CH.intPricingTypeId
		JOIN	tblEMEntity					EY	ON	EY.intEntityId					=	CH.intEntityId
		JOIN	tblCTContractType			CT	ON	CT.intContractTypeId			=	CH.intContractTypeId
		JOIN	tblICCommodityUnitMeasure	CU	ON	CU.intCommodityUnitMeasureId	=	CH.intCommodityUOMId
		JOIN	tblICUnitMeasure			UM	ON	UM.intUnitMeasureId				=	CU.intUnitMeasureId
		JOIN	tblICCommodityUnitMeasure	SU	ON	SU.intCommodityId				=	CH.intCommodityId
												AND	SU.ysnStockUnit					=	1						LEFT
		JOIN	tblCTContractBasis			CB	ON	CB.intContractBasisId			=	CH.intContractBasisId	LEFT
		JOIN	tblCTPosition				PO	ON	PO.intPositionId				=	CH.intPositionId		LEFT
		JOIN	tblEMEntity					SP	ON	SP.intEntityId					=	CH.intSalespersonId		LEFT
		JOIN	tblSMCountry				CR	ON	CR.intCountryID					=	CH.intCountryId			LEFT
		JOIN	tblEMEntity					CY	ON	CY.intEntityId					=	CH.intCreatedById		LEFT
		JOIN	tblCTContractDetail			CD	ON CD.intContractHeaderId = CH.intContractHeaderId
		WHERE intContractDetailId IS NULL

		UNION ALL

		SELECT	CH.intContractHeaderId,			CH.intContractSeq,			CH.dtmStartDate,				CH.dtmEndDate,
				CH.dblQuantity,					CH.dblFutures,				CH.dblBasis,					CH.dblCashPrice,
				CH.dblScheduleQty,				CH.dblNoOfLots,				CH.strItemNo,					CH.strPricingType,
				CH.strFutMarketName,			CH.strItemUOM,				CH.strLocationName,				CH.strPriceUOM,
				CH.strCurrency,					CH.strFutureMonth,			CH.strStorageLocation,			CH.strSubLocation,
				CH.strPurchasingGroup,			CH.strCreatedByNo,			CH.strContractNumber,			CH.dtmContractDate,
				CH.strContractType,				CH.strCommodityCode,		CH.strEntityName,				'Unsigned' AS strNotificationType,
				CH.strItemDescription,			CH.dblQtyInStockUOM,		CH.intContractDetailId,			CH.strProductType,
				CH.strBasisComponent,			CH.strPosition,				CH.strContractBasis,			CH.strCountry,			
				CH.strCustomerContract,			strSalesperson,				CH.intContractStatusId,			CH.strContractItemName,		
				CH.strContractItemNo,
				strCounterParty = null,
				strSIRef = null,
				dtmSIDate = null,
				ysnShipped = null,
				dtmETSPol = null,
				strBookedShippingLine = null,
				strBookNumber = null,
				strETSDateStatus = null,
				strSampleType = null,
				strApprovalStatus = null

		FROM Header CH
		WHERE ISNULL(ysnSigned,0) = 0 AND CH.intContractDetailId IS NOT NULL

		UNION ALL

		SELECT	CH.intContractHeaderId,			CH.intContractSeq,			CH.dtmStartDate,				CH.dtmEndDate,
				CH.dblQuantity,					CH.dblFutures,				CH.dblBasis,					CH.dblCashPrice,
				CH.dblScheduleQty,				CH.dblNoOfLots,				CH.strItemNo,					CH.strPricingType,
				CH.strFutMarketName,			CH.strItemUOM,				CH.strLocationName,				CH.strPriceUOM,
				CH.strCurrency,					CH.strFutureMonth,			CH.strStorageLocation,			CH.strSubLocation,
				CH.strPurchasingGroup,			CH.strCreatedByNo,			CH.strContractNumber,			CH.dtmContractDate,
				CH.strContractType,				CH.strCommodityCode,		CH.strEntityName,				'Late Shipment' AS strNotificationType,
				CH.strItemDescription,			CH.dblQtyInStockUOM,		CH.intContractDetailId,			CH.strProductType,
				CH.strBasisComponent,			CH.strPosition,				CH.strContractBasis,			CH.strCountry,			
				CH.strCustomerContract,			strSalesperson,				CH.intContractStatusId,			CH.strContractItemName,		
				CH.strContractItemNo,
				strCounterParty = CH.strEntityName,
				strSIRef = l.strSIRef,
				dtmSIDate = l.dtmSIDate,
				ysnShipped = l.ysnShipped,
				dtmETSPol = l.dtmETSPol,
				strBookedShippingLine = l.strBookedShippingLine,
				strBookNumber = l.strBookNumber,
				strETSDateStatus = case when l.dtmETSPol is null then null when l.dtmETSPol <= CH.dtmEndDate then 'OK' else 'Late' end,
				strSampleType = CH.strSampleTypeName,
				strApprovalStatus = txn.strApprovalStatus

		FROM Header CH
		cross join tblCTAction ac
		cross join tblCTEvent ev
		join tblCTEventRecipient er on er.intEventId = ev.intEventId
		left join (
			select
				intContractDetailId = isnull(dsi.intPContractDetailId,dsi.intSContractDetailId)
				,strSIRef = si.strLoadNumber
				,dtmSIDate = si.dtmScheduledDate
				,dtmETSPol = si.dtmETSPOL
				,strBookedShippingLine = sl.strName
				,strBookNumber = si.strBookingReference
				,ysnShipped = case when ls.intShipmentStatus in (6,11) then convert(bit,1) else convert(bit,0) end
			from
				tblLGLoad si
				join tblLGLoadDetail dsi on dsi.intLoadId = si.intLoadId
				left join tblLGLoad s on s.intLoadShippingInstructionId = si.intLoadId
				left join tblEMEntity sl on sl.intEntityId = si.intShippingLineEntityId
				left join tblLGLoad ls on ls.intLoadShippingInstructionId = si.intLoadId
			where
				si.intShipmentType = 2
				and isnull(dsi.intPContractDetailId,dsi.intSContractDetailId) is not null
		) l on l.intContractDetailId = CH.intContractDetailId
		left join tblSMTransaction txn on txn.intRecordId = CH.intContractHeaderId and txn.intScreenId = 15
		where
			CH.intContractStatusId in (1,4)
			and ac.strActionName = 'Late Shipment'
			and ev.intActionId = ac.intActionId
			and getdate() between
				(case when ev.strReminderCondition = 'day(s) before due date' then dateadd(day,ev.intDaysToRemind * -1,CH.dtmEndDate) else CH.dtmEndDate end)
				and
				(case when ev.strReminderCondition = 'day(s) before due date' then CH.dtmEndDate else dateadd(day,ev.intDaysToRemind,CH.dtmEndDate) end)

		UNION ALL

		SELECT	CH.intContractHeaderId,			CH.intContractSeq,			CH.dtmStartDate,				CH.dtmEndDate,
				CH.dblQuantity,					CH.dblFutures,				CH.dblBasis,					CH.dblCashPrice,
				CH.dblScheduleQty,				CH.dblNoOfLots,				CH.strItemNo,					CH.strPricingType,
				CH.strFutMarketName,			CH.strItemUOM,				CH.strLocationName,				CH.strPriceUOM,
				CH.strCurrency,					CH.strFutureMonth,			CH.strStorageLocation,			CH.strSubLocation,
				CH.strPurchasingGroup,			CH.strCreatedByNo,			CH.strContractNumber,			CH.dtmContractDate,
				CH.strContractType,				CH.strCommodityCode,		CH.strEntityName,				'Unsubmitted' AS strNotificationType,
				CH.strItemDescription,			CH.dblQtyInStockUOM,		CH.intContractDetailId,			CH.strProductType,
				CH.strBasisComponent,			CH.strPosition,				CH.strContractBasis,			CH.strCountry,			
				CH.strCustomerContract,			strSalesperson,				CH.intContractStatusId,			CH.strContractItemName,		
				CH.strContractItemNo,
				strCounterParty = null,
				strSIRef = null,
				dtmSIDate = null,
				ysnShipped = null,
				dtmETSPol = null,
				strBookedShippingLine = null,
				strBookNumber = null,
				strETSDateStatus = null,
				strSampleType = null,
				strApprovalStatus = null

		FROM	Header CH
		WHERE	
			--CH.strContractNumber 
			CH.intContractHeaderId
		NOT IN(
			--SELECT strTransactionNumber FROM tblSMApproval WHERE strStatus='Submitted'
			SELECT B.intRecordId FROM tblSMApproval A INNER JOIN tblSMTransaction B ON A.intTransactionId = B.intTransactionId WHERE strStatus='Submitted'
		)  AND 4 <> intAllStatusId & 4
		--AND		CH.intContractHeaderId	NOT IN (SELECT intContractHeaderId FROM tblCTContractDetail WHERE intContractStatusId = 2)
		AND		intContractDetailId IS NOT NULL

		UNION ALL

		SELECT	CH.intContractHeaderId,			CH.intContractSeq,			CH.dtmStartDate,				CH.dtmEndDate,
				CH.dblQuantity,					CH.dblFutures,				CH.dblBasis,					CH.dblCashPrice,
				CH.dblScheduleQty,				CH.dblNoOfLots,				CH.strItemNo,					CH.strPricingType,
				CH.strFutMarketName,			CH.strItemUOM,				CH.strLocationName,				CH.strPriceUOM,
				CH.strCurrency,					CH.strFutureMonth,			CH.strStorageLocation,			CH.strSubLocation,
				CH.strPurchasingGroup,			CH.strCreatedByNo,			CH.strContractNumber,			CH.dtmContractDate,
				CH.strContractType,				CH.strCommodityCode,		CH.strEntityName,				'Approved Not Sent' AS strNotificationType,
				CH.strItemDescription,			CH.dblQtyInStockUOM,		CH.intContractDetailId,			CH.strProductType,
				CH.strBasisComponent,			CH.strPosition,				CH.strContractBasis,			CH.strCountry,			
				CH.strCustomerContract,			strSalesperson,				CH.intContractStatusId,			CH.strContractItemName,		
				CH.strContractItemNo,
				strCounterParty = null,
				strSIRef = null,
				dtmSIDate = null,
				ysnShipped = null,
				dtmETSPol = null,
				strBookedShippingLine = null,
				strBookNumber = null,
				strETSDateStatus = null,
				strSampleType = null,
				strApprovalStatus = null

		FROM	Header CH
		JOIN	tblSMTransaction	TN	ON	TN.intRecordId	=	CH.intContractHeaderId AND ysnMailSent = 0 AND TN.ysnOnceApproved = 1 AND 2 = intAllStatusId & 2
		JOIN	tblSMScreen			SN	ON	SN.intScreenId	=	TN.intScreenId AND SN.strNamespace IN ('ContractManagement.view.Contract', 'ContractManagement.view.Amendments')
		--WHERE	CH.intContractHeaderId IN (SELECT intContractHeaderId FROM tblCTContractDetail WHERE intContractStatusId = 1)

	)t

	WHERE ISNULL(intContractStatusId,1) <> 3
