CREATE VIEW [dbo].[vyuCTSearchContractDetail2]

AS

WITH shipmentstatus AS (
	SELECT DISTINCT intContractDetailId
		, strShipmentStatus = ISNULL(strShipmentStatus,'Open')
	FROM (
		SELECT ROW_NUMBER() OVER(PARTITION BY intPContractDetailId ORDER BY dtmScheduledDate DESC) AS intNumberId
			, intContractDetailId = intPContractDetailId
			, strShipmentStatus
			, intPriorityId = CASE WHEN strShipmentStatus = 'Cancelled' THEN 2 ELSE 1 END
		FROM vyuCTShipmentStatus
		WHERE ((intShipmentType = 2 AND strShipmentStatus <> 'Scheduled') OR intShipmentType = 1)
			AND intPContractDetailId IS NOT NULL

		UNION SELECT ROW_NUMBER() OVER(PARTITION BY intSContractDetailId ORDER BY dtmScheduledDate DESC) AS intNumberId
			, intContractDetailId = intSContractDetailId
			, strShipmentStatus
			, intPriorityId = CASE WHEN strShipmentStatus = 'Cancelled' THEN 2 ELSE 1 END
		FROM vyuCTShipmentStatus
		WHERE ((intShipmentType = 2 AND strShipmentStatus <> 'Scheduled') OR intShipmentType = 1)
			AND intSContractDetailId IS NOT NULL
	) tbl
	WHERE intNumberId = 1 AND ISNULL(intContractDetailId, 0) <> 0)

, fixation AS (
	SELECT aaa1.intContractDetailId
		, dblPricedQuantity = (CASE WHEN aaa1.intPricingTypeId = 1 THEN aaa1.dblQuantity
									ELSE SUM(bbb.dblQuantity) END)
	FROM tblCTContractDetail aaa1 WITH(NOLOCK)
	LEFT JOIN tblCTPriceFixation aaa WITH(NOLOCK) ON aaa.intContractDetailId = aaa1.intContractDetailId
	LEFT JOIN tblCTPriceFixationDetail bbb WITH(NOLOCK) ON bbb.intPriceFixationId = aaa.intPriceFixationId AND bbb.intPriceFixationId = aaa.intPriceFixationId
	GROUP BY aaa1.intContractDetailId
		, aaa1.intPricingTypeId
		, aaa1.dblQuantity)

, lgallocationS AS (
	SELECT intSContractDetailId
		, dblAllocatedQty = ISNULL(SUM(dblSAllocatedQty), 0)
		, intAllocationUOMId = MIN(intSUnitMeasureId)
	FROM tblLGAllocationDetail WITH(NOLOCK)
	GROUP BY intSContractDetailId)

, lgalloationP AS (
	SELECT intContractDetailId = intPContractDetailId
		, dblAllocatedQty = ISNULL(SUM(dblPAllocatedQty), 0)
		, intAllocationUOMId = MIN(intPUnitMeasureId)
	FROM tblLGAllocationDetail WITH(NOLOCK)
	GROUP BY intPContractDetailId)

, approved AS (
	SELECT intContractDetailId
		, dblRepresentingQty = CASE WHEN SUM(dblRepresentingQty) > dblQuantity THEN dblQuantity ELSE SUM(dblRepresentingQty) END
	FROM (
		SELECT ccc.intContractDetailId
			,ccc.dblQuantity
			, dblRepresentingQty = (CASE WHEN ISNULL(eee.dblUnitQty, 0) = 0 OR ISNULL(fff.dblUnitQty, 0) = 0 THEN NULL
										WHEN ISNULL(eee.dblUnitQty, 0) = ISNULL(fff.dblUnitQty, 0) THEN ddd.dblRepresentingQty
										ELSE ddd.dblRepresentingQty * (ISNULL(eee.dblUnitQty, 0) / ISNULL(fff.dblUnitQty, 0)) END)
		FROM tblCTContractDetail ccc WITH(NOLOCK)
			inner join tblQMSample ddd WITH(NOLOCK) on ddd.intProductValueId = ccc.intContractDetailId
			inner join tblICItemUOM eee WITH(NOLOCK) on eee.intUnitMeasureId = ddd.intRepresentingUOMId
			inner join tblICItemUOM fff WITH(NOLOCK) on fff.intItemId = ccc.intItemId and fff.intUnitMeasureId = ccc.intUnitMeasureId
			
		WHERE 
			intProductTypeId = 8
			AND intSampleStatusId = 3
			AND eee.intItemId = ccc.intItemId
	) AS qasample
	GROUP BY intContractDetailId, dblQuantity)

, prepaid AS (
	SELECT jjj.intContractHeaderId
		, intRecordCount = COUNT(*)
	FROM tblAPBillDetail jjj WITH(NOLOCK)
		inner join tblAPBill kkk WITH(NOLOCK) on kkk.intBillId = jjj.intBillId
	WHERE 
		kkk.intTransactionType = 2
	GROUP BY jjj.intContractHeaderId)

, hedge AS (
	SELECT iii.intContractDetailId
		, dblHedgedLots = SUM(iii.dblHedgedLots)
	FROM tblRKAssignFuturesToContractSummary iii WITH(NOLOCK)
	GROUP BY iii.intContractDetailId)
	
, statuses AS (
	SELECT intContractHeaderId
		, strStatuses = CASE WHEN strStatus LIKE '%Incomplete%' THEN 'Incomplete'
							WHEN strStatus LIKE '%Open%' THEN 'Open'
							WHEN strStatus LIKE '%Complete%' THEN 'Complete'
							WHEN strStatus IS NULL THEN 'Incomplete'
							ELSE strStatus END COLLATE Latin1_General_CI_AS
	FROM (
		SELECT lll.intContractHeaderId
			, strStatus = STUFF((
                 SELECT DISTINCT ', ' + nnn.strContractStatus
				 FROM tblCTContractDetail mmm WITH(NOLOCK)
				 JOIN tblCTContractStatus nnn WITH(NOLOCK) ON nnn.intContractStatusId = mmm.intContractStatusId
				 WHERE mmm.intContractHeaderId = lll.intContractHeaderId FOR XML PATH('')
			), 1, 2, '')
		FROM tblCTContractHeader lll WITH(NOLOCK)
	) AS ss)
	
, reserved AS (
	SELECT intContractDetailId
		, dblReservedQuantity = ISNULL(SUM(dblReservedQuantity), 0)
	FROM tblLGReservation WITH(NOLOCK)
	GROUP BY intContractDetailId)


SELECT a.intContractDetailId
	, a.intContractHeaderId
	, b.strContractNumber
	, a.intContractSeq
	, a.dtmStartDate
	, a.dtmEndDate
	, dblDetailQuantity = a.dblQuantity
	, dblDetailApplied = a.dblQuantity - a.dblBalance
	, dblAvailableQty = a.dblBalance - ISNULL(a.dblScheduleQty, 0)
	, a.dblFutures
	, a.dblBasis
	, a.dblRatio
	, a.dblCashPrice
	, a.dblBalance
	, a.dtmEventStartDate
	, a.dtmPlannedAvailabilityDate
	, a.dtmUpdatedAvailabilityDate
	, a.intItemId
	, c.strItemNo
	, a.intItemBundleId
	, strBundleItemNo = d.strItemNo
	, a.intShipViaId
	, e.strShipVia
	, a.intPricingTypeId
	, f.strPricingType
	, a.intItemUOMId
	, g.intUnitMeasureId
	, strItemUOM = h.strUnitMeasure
	, a.intFutureMarketId
	, i.strFutMarketName
	, strFutureMonth = LEFT(CONVERT(DATE, '01 ' + j.strFutureMonth), 7) + ' (' + j.strFutureMonth + ')'
	, a.intPriceItemUOMId
	, intPriceUnitMeasureId = k.intUnitMeasureId
	, strPriceUOM = l.strUnitMeasure
	, m.strContractOptDesc
	, n.strLocationName
	, o.strCurrency
	, p.strContractStatus
	, strShipmentStatus = r.strShipmentStatus
	, strFinancialStatus = CASE WHEN b.intContractTypeId = 1 THEN CASE WHEN a.ysnFinalPNL = 1 THEN 'Final P&L Created'
																	WHEN a.ysnProvisionalPNL = 1 THEN 'Provisional P&L Created'
																	ELSE CASE WHEN s.intContractDetailId IS NOT NULL THEN 'Purchase Invoice Received'
																			ELSE NULL END END
								ELSE a.strFinancialStatus END
	, dblPricedQty = CASE WHEN a.intPricingTypeId = 2 OR t.dblPricedQuantity IS NOT NULL THEN ISNULL(t.dblPricedQuantity, 0)
						ELSE a.dblQuantity END
	, dblUnPricedQty = CASE WHEN a.intPricingTypeId = 2 OR t.dblPricedQuantity IS NOT NULL THEN a.dblQuantity - ISNULL(t.dblPricedQuantity, 0)
							ELSE 0.00 END
	, dblActualLots = (CASE WHEN ISNULL(v.dblUnitQty, 0) = 0 OR ISNULL(w.dblUnitQty, 0) = 0 THEN NULL
							WHEN ISNULL(v.dblUnitQty, 0) = ISNULL(w.dblUnitQty, 0) THEN a.dblQuantity
							ELSE a.dblQuantity * (ISNULL(v.dblUnitQty, 0) / ISNULL(w.dblUnitQty, 0)) END) / i.dblContractSize
	, a.intAdjItemUOMId
	, y.strUnitMeasure
	, a.dblAdjustment
	, z.dblAllocatedQty
	, za.strApprovalBasis
	--, strApprovalBasis = au.strWeightGradeDesc
	, ysnApproved = ISNULL(TR.ysnOnceApproved, 0)
	, dblApprovedQty = QA.dblApprovedQty
	, strAssociationName = zb.strName
	, a.dblAssumedFX
	, dblBalLotsToHedge = a.dblNoOfLots - ISNULL(ab.dblHedgedLots, 0)
	, dblBalQtyToHedge = (CASE WHEN ISNULL(ad.dblUnitQty, 0) = 0 OR ISNULL(ae.dblUnitQty, 0) = 0 THEN NULL
							WHEN ISNULL(ad.dblUnitQty, 0) = ISNULL(ae.dblUnitQty, 0) THEN i.dblContractSize * (a.dblNoOfLots - ISNULL(ab.dblHedgedLots, 0))
							ELSE(i.dblContractSize * (a.dblNoOfLots - ISNULL(ab.dblHedgedLots, 0))) * (ISNULL(ad.dblUnitQty, 0) / ISNULL(ae.dblUnitQty, 0)) END)
	, zc.strBook
	, b.ysnBrokerage
	, a.strBuyerSeller
	, b.ysnCategory
	, af.intCommodityId
	, af.strCommodityCode
	, strCommodityDescription = af.strDescription
	, dblTotalAppliedQty = (CASE WHEN ISNULL(ah.dblUnitQty, 0) = 0 OR ISNULL(ai.dblUnitQty, 0) = 0 THEN NULL
								WHEN ISNULL(ah.dblUnitQty, 0) = ISNULL(ai.dblUnitQty, 0) THEN(a.dblQuantity - a.dblBalance)
								ELSE((a.dblQuantity - a.dblBalance) * ISNULL(ah.dblUnitQty, 0)) / ISNULL(ai.dblUnitQty, 0) END)
	, dblTotalBallance = (CASE WHEN ISNULL(ah.dblUnitQty, 0) = 0 OR ISNULL(ai.dblUnitQty, 0) = 0 THEN NULL
								WHEN ISNULL(ah.dblUnitQty, 0) = ISNULL(ai.dblUnitQty, 0) THEN a.dblBalance
								ELSE(a.dblBalance * ISNULL(ah.dblUnitQty, 0)) / ISNULL(ai.dblUnitQty, 0) END)
	, strHeaderPricingType = u.strPricingType
	, dblHeaderQuantity = b.dblQuantity
	, b.dtmContractDate
	, aj.strContractPlan
	, ak.strContractType
	, al.strCountry
	, strCreatedBy = am.strName
	, b.dtmCreated
	, an.strCropYear
	, strCounterParty = ao.strName
	, b.strCPContract
	, b.dtmSigned
	, b.dtmDeferPayDate
	, b.dblDeferPayRate
	, strDestinationPoint = ap.strCity
	, a.strERPBatchNumber
	, a.strERPItemNumber
	, a.strERPPONumber
	, intCustomerVendorEntityId = b.intEntityId
	, strCustomerVendor = aq.strName
	, b.strCustomerContract
	, b.ysnExported
	, b.dtmExported
	, a.strFXRemarks
	, a.dtmFXValidFrom
	, a.dtmFXValidTo
	, a.strFixationBy
	, a.strFobBasis
	, intDetailFreightTermId = a.intFreightTermId
	, strDetailFreightTerm = ar.strFreightTerm
	, b.intGradeId
	, strGrade = au.strWeightGradeDesc
	, dblHedgeQty = (CASE WHEN ISNULL(ad.dblUnitQty, 0) = 0 OR ISNULL(ae.dblUnitQty, 0) = 0 THEN NULL
						WHEN ISNULL(ad.dblUnitQty, 0) = ISNULL(ae.dblUnitQty, 0) THEN i.dblContractSize * ISNULL(ab.dblHedgedLots, 0)
						ELSE(i.dblContractSize * ISNULL(ab.dblHedgedLots, 0)) * (ISNULL(ad.dblUnitQty, 0) / ISNULL(ae.dblUnitQty, 0)) END)
	, ab.dblHedgedLots
	, strINCOLocation = CASE WHEN av.strINCOLocationType = 'City' THEN aw.strCity
							ELSE ax.strSubLocationName END
	, ay.strIndex
	, az.strInsuranceBy
	, b.strInternalComment
	, a.dblIntransitQty
	, a.strInvoiceNo
	, ba.strInvoiceNumber
	, bb.strInvoiceType
	, strItemDescription = c.strDescription
	, strItemShortName = c.strShortName
	, b.intLastModifiedById
	, strLastModifiedBy = bc.strName
	, a.dtmLastPricingDate
	, b.ysnLoad
	, strLoadUnitMeasure = be.strUnitMeasure
	, strLoadingPoint = bf.strCity
	, c.strLotTracking
	, bg.strMarketZoneCode
	, b.ysnMaxPrice
	, b.ysnMultiplePriceFixation
	, a.dblNetWeight
	, a.intNoOfLoad
	, a.dblNoOfLots
	, a.intNumberOfContainers
	, strOrigin = ISNULL(bi.strCountry, bk.strCountry)
	, strOriginDest = bl.strOrigin + ' - ' + bl.strDest
	, a.dblOriginalQty
	, bm.strPosition
	, ysnPrepaid = CASE WHEN ISNULL(bn.intRecordCount, 0) > 0 THEN CONVERT(BIT, 1)
						ELSE CONVERT(BIT, 0) END
	, bo.strPricingLevelName
	, b.strPrintableRemarks
	, b.ysnPrinted
	, strProducer = bp2.strName
	, strProductType = bq.strDescription
	, b.ysnProvisional
	, b.dblProvisionalInvoicePct
	, strPurchasingGroup = br.strName
	, dblQtyInCommodityDefaultUOM = (CASE WHEN ISNULL(v.dblUnitQty, 0) = 0 OR ISNULL(bt.dblUnitQty, 0) = 0 THEN NULL
										WHEN ISNULL(v.dblUnitQty, 0) = ISNULL(bt.dblUnitQty, 0) THEN a.dblQuantity
										ELSE a.dblQuantity * (ISNULL(v.dblUnitQty, 0) / ISNULL(bt.dblUnitQty, 0)) END)
	, strQualityApproval = bh.strGrade
	--, strQualityApproval = QA.strSampleStatus
	, dblQtyInCommodityStockUOM = (CASE WHEN ISNULL(v.dblUnitQty, 0) = 0 OR ISNULL(bu.dblUnitQty, 0) = 0 THEN NULL
										WHEN ISNULL(v.dblUnitQty, 0) = ISNULL(bu.dblUnitQty, 0) THEN a.dblQuantity
										ELSE a.dblQuantity * (ISNULL(v.dblUnitQty, 0) / ISNULL(bu.dblUnitQty, 0)) END)
	, b.dblQuantityPerLoad
	, bv.strRailGrade
	, a.dblRate
	, b.ysnReceivedSignedFixationLetter
	, a.strReference
	, a.strRemark
	, a.dblReservedQty
	, strSalesperson = bw.strName
	, a.dblScheduleQty
	, strSeqBook = bx.strBook
	, strSeqSubBook = bz.strSubBook
	, a.strShippingTerm
	, b.ysnSigned
	, strStatuses = ca.strStatuses
	, strStockCommodityUnitMeasure = cb.strUnitMeasure
	, strStorageLocationName = cc.strName
	, cd.strSubBook
	, ce.strSubLocationName
	, b.ysnSubstituteItem
	, cf.strTerm
	, cg.strTextCode
	, b.dblTolerancePct
	, a.dblTotalCost
	, strHeaderUnitMeasure = CASE WHEN b.ysnLoad = CONVERT(BIT, 1) THEN ci.strUnitMeasure + '/Load'
								ELSE ci.strUnitMeasure END
	, dblUnAllocatedQty = ISNULL(a.dblQuantity, 0) - ISNULL(z.dblAllocatedQty, 0) - ISNULL(co.dblAllocatedQty, 0)
	, b.ysnUnlimitedQuantity
	, dblUnReservedQuantity = ISNULL(a.dblQuantity, 0) - ISNULL(cj.dblReservedQuantity, 0)
	, ck.strVendorId
	, a.strVendorLotID
	, a.strVessel
	, strWeight = cl.strWeightGradeDesc
	, strWeightUOM = cn.strUnitMeasure
	, aq.intEntityId
	, intHeaderBookId = b.intBookId
	, intHeaderSubBookId = b.intSubBookId
	, intDetailBookId = a.intBookId
	, intDetailSubBookId = a.intSubBookId
FROM tblCTContractDetail a WITH(NOLOCK)
JOIN tblCTContractHeader b WITH(NOLOCK) ON b.intContractHeaderId = a.intContractHeaderId
LEFT JOIN tblICItem c WITH(NOLOCK) ON c.intItemId = a.intItemId
LEFT JOIN tblICItem d WITH(NOLOCK) ON d.intItemId = a.intItemBundleId
LEFT JOIN tblSMShipVia e WITH(NOLOCK) ON e.intEntityId = a.intShipViaId
LEFT JOIN tblCTPricingType f WITH(NOLOCK) ON f.intPricingTypeId = a.intPricingTypeId
LEFT JOIN tblICItemUOM g WITH(NOLOCK) ON g.intItemUOMId = a.intItemUOMId
LEFT JOIN tblICUnitMeasure h WITH(NOLOCK) ON h.intUnitMeasureId = g.intUnitMeasureId
LEFT JOIN tblRKFutureMarket i WITH(NOLOCK) ON i.intFutureMarketId = a.intFutureMarketId
LEFT JOIN tblRKFuturesMonth j WITH(NOLOCK) ON j.intFutureMonthId = a.intFutureMonthId
LEFT JOIN tblICItemUOM k WITH(NOLOCK) ON k.intItemUOMId = a.intPriceItemUOMId
LEFT JOIN tblICUnitMeasure l WITH(NOLOCK) ON l.intUnitMeasureId = k.intUnitMeasureId
LEFT JOIN tblCTContractOptHeader m WITH(NOLOCK) ON m.intContractOptHeaderId = a.intContractOptHeaderId
LEFT JOIN tblSMCompanyLocation n WITH(NOLOCK) ON n.intCompanyLocationId = a.intCompanyLocationId
LEFT JOIN tblSMCurrency o WITH(NOLOCK) ON o.intCurrencyID = a.intCurrencyId
LEFT JOIN tblCTContractStatus p WITH(NOLOCK) ON p.intContractStatusId = a.intContractStatusId
LEFT JOIN shipmentstatus r ON r.intContractDetailId = a.intContractDetailId
OUTER APPLY (
    SELECT TOP 1 intContractDetailId
    FROM tblAPBillDetail WITH(NOLOCK)
    WHERE intContractDetailId = a.intContractDetailId
) s
LEFT JOIN fixation t ON t.intContractDetailId = a.intContractDetailId
LEFT JOIN tblCTPricingType u WITH(NOLOCK) ON u.intPricingTypeId = b.intPricingTypeId
LEFT JOIN tblICItemUOM v WITH(NOLOCK) ON v.intItemId = a.intItemId AND v.intUnitMeasureId = g.intUnitMeasureId
LEFT JOIN tblICItemUOM w WITH(NOLOCK) ON w.intItemId = a.intItemId AND w.intUnitMeasureId = i.intUnitMeasureId
LEFT JOIN tblICItemUOM x WITH(NOLOCK) ON x.intItemUOMId = a.intAdjItemUOMId
LEFT JOIN tblICUnitMeasure y WITH(NOLOCK) ON y.intUnitMeasureId = x.intUnitMeasureId
LEFT JOIN lgalloationP z ON z.intContractDetailId = a.intContractDetailId
left join tblCTApprovalBasis za  with (nolock) on za.intApprovalBasisId = b.intApprovalBasisId 
LEFT JOIN approved aa ON aa.intContractDetailId = a.intContractDetailId
LEFT JOIN tblCTAssociation zb WITH(NOLOCK) ON zb.intAssociationId = b.intAssociationId
LEFT JOIN hedge ab ON ab.intContractDetailId = a.intContractDetailId
LEFT JOIN tblICCommodityUnitMeasure ac WITH(NOLOCK) ON ac.intCommodityId = b.intCommodityId AND ac.ysnStockUnit = 1
LEFT JOIN tblICItemUOM ad WITH(NOLOCK) ON ad.intItemId = a.intItemId AND ad.intUnitMeasureId = i.intUnitMeasureId
LEFT JOIN tblICItemUOM ae WITH(NOLOCK) ON ae.intItemId = a.intItemId AND ae.intUnitMeasureId = ac.intUnitMeasureId
LEFT JOIN tblCTBook zc WITH(NOLOCK) ON zc.intBookId = b.intBookId
LEFT JOIN tblICCommodity af WITH(NOLOCK) ON af.intCommodityId = b.intCommodityId
LEFT JOIN tblICCommodityUnitMeasure ag WITH(NOLOCK) ON ag.intCommodityUnitMeasureId = b.intCommodityUOMId
LEFT JOIN tblICItemUOM ah WITH(NOLOCK) ON ah.intItemId = a.intItemId AND ah.intUnitMeasureId = a.intUnitMeasureId
LEFT JOIN tblICItemUOM ai WITH(NOLOCK) ON ai.intItemId = a.intItemId AND ai.intUnitMeasureId = ag.intUnitMeasureId
LEFT JOIN tblCTContractPlan aj WITH(NOLOCK) ON aj.intContractPlanId = b.intContractPlanId
LEFT JOIN tblCTContractType ak WITH(NOLOCK) ON ak.intContractTypeId = b.intContractTypeId
LEFT JOIN tblSMCountry al WITH(NOLOCK) ON al.intCountryID = b.intCountryId
LEFT JOIN tblEMEntity am WITH(NOLOCK) ON am.intEntityId = b.intCreatedById
LEFT JOIN tblCTCropYear an WITH(NOLOCK) ON an.intCropYearId = b.intCropYearId
LEFT JOIN tblEMEntity ao WITH(NOLOCK) ON ao.intEntityId = b.intCounterPartyId
LEFT JOIN tblSMCity ap WITH(NOLOCK) ON ap.intCityId = a.intDestinationPortId
LEFT JOIN tblEMEntity aq WITH(NOLOCK) ON aq.intEntityId = b.intEntityId
LEFT JOIN tblSMFreightTerms ar WITH(NOLOCK) ON ar.intFreightTermId = a.intFreightTermId
LEFT JOIN tblCTWeightGrade au WITH(NOLOCK) ON au.intWeightGradeId = b.intGradeId
LEFT JOIN tblCTContractBasis av WITH(NOLOCK) ON av.intContractBasisId = b.intContractBasisId
LEFT JOIN tblSMCity aw WITH(NOLOCK) ON aw.intCityId = b.intINCOLocationTypeId
LEFT JOIN tblSMCompanyLocationSubLocation ax WITH(NOLOCK) ON ax.intCompanyLocationSubLocationId = b.intWarehouseId
LEFT JOIN tblCTIndex ay WITH(NOLOCK) ON ay.intIndexId = a.intIndexId
LEFT JOIN tblCTInsuranceBy az WITH(NOLOCK) ON az.intInsuranceById = b.intInsuranceById
LEFT JOIN tblCTContractInvoice ba WITH(NOLOCK) ON ba.intContractDetailId = a.intContractDetailId
LEFT JOIN tblCTInvoiceType bb WITH(NOLOCK) ON bb.intInvoiceTypeId = b.intInvoiceTypeId
LEFT JOIN tblEMEntity bc WITH(NOLOCK) ON bc.intEntityId = b.intLastModifiedById
LEFT JOIN tblICCommodityUnitMeasure bd WITH(NOLOCK) ON bd.intCommodityUnitMeasureId = b.intLoadUOMId
LEFT JOIN tblICUnitMeasure be WITH(NOLOCK) ON be.intUnitMeasureId = bd.intUnitMeasureId
LEFT JOIN tblSMCity bf WITH(NOLOCK) ON bf.intCityId = a.intLoadingPortId
LEFT JOIN tblARMarketZone bg WITH(NOLOCK) ON bg.intMarketZoneId = a.intMarketZoneId
LEFT JOIN tblICItemContract bh WITH(NOLOCK) ON bh.intItemContractId = a.intItemContractId
LEFT JOIN tblSMCountry bi WITH(NOLOCK) ON bi.intCountryID = bh.intCountryId
LEFT JOIN tblICCommodityAttribute bj WITH(NOLOCK) ON bj.intCommodityAttributeId = c.intOriginId
LEFT JOIN tblSMCountry bk WITH(NOLOCK) ON bk.intCountryID = bj.intCountryID
LEFT JOIN tblCTFreightRate bl WITH(NOLOCK) ON bl.intFreightRateId = a.intFreightRateId
LEFT JOIN tblCTPosition bm WITH(NOLOCK) ON bm.intPositionId = b.intPositionId
LEFT JOIN prepaid bn ON bn.intContractHeaderId = b.intContractHeaderId
LEFT JOIN tblSMCompanyLocationPricingLevel bo WITH(NOLOCK) ON bo.intCompanyLocationPricingLevelId = b.intCompanyLocationPricingLevelId
LEFT JOIN tblEMEntity bp WITH(NOLOCK) ON bp.intEntityId = b.intProducerId
LEFT JOIN tblEMEntity bp2 WITH(NOLOCK) ON bp2.intEntityId = a.intProducerId
LEFT JOIN tblICCommodityAttribute bq WITH(NOLOCK) ON bq.intCommodityAttributeId = c.intProductTypeId AND bq.strType = 'ProductType'
LEFT JOIN tblSMPurchasingGroup br WITH(NOLOCK) ON br.intPurchasingGroupId = a.intPurchasingGroupId
LEFT JOIN tblICCommodityUnitMeasure bs WITH(NOLOCK) ON bs.intCommodityId = b.intCommodityId AND bs.ysnDefault = 1
LEFT JOIN tblICItemUOM bt WITH(NOLOCK) ON bt.intItemId = a.intItemId AND bt.intUnitMeasureId = bs.intUnitMeasureId
LEFT JOIN tblICItemUOM bu WITH(NOLOCK) ON bu.intItemId = a.intItemId AND bu.intUnitMeasureId = ac.intUnitMeasureId
LEFT JOIN tblCTRailGrade bv WITH(NOLOCK) ON bv.intRailGradeId = a.intRailGradeId
LEFT JOIN tblEMEntity bw WITH(NOLOCK) ON bw.intEntityId = b.intSalespersonId
LEFT JOIN tblCTBook bx WITH(NOLOCK) ON bx.intBookId = a.intBookId
LEFT JOIN tblCTSubBook bz WITH(NOLOCK) ON bz.intSubBookId = a.intSubBookId
LEFT JOIN statuses ca ON ca.intContractHeaderId = b.intContractHeaderId
LEFT JOIN tblICUnitMeasure cb WITH(NOLOCK) ON cb.intUnitMeasureId = ac.intUnitMeasureId
LEFT JOIN tblICStorageLocation cc WITH(NOLOCK) ON cc.intStorageLocationId = a.intStorageLocationId
LEFT JOIN tblCTSubBook cd WITH(NOLOCK) ON cd.intSubBookId = b.intSubBookId
LEFT JOIN tblSMCompanyLocationSubLocation ce WITH(NOLOCK) ON ce.intCompanyLocationSubLocationId = a.intSubLocationId
LEFT JOIN tblSMTerm cf WITH(NOLOCK) ON cf.intTermID = b.intTermId
LEFT JOIN tblCTContractText cg WITH(NOLOCK) ON cg.intContractTextId = b.intContractTextId
LEFT JOIN tblICUnitMeasure ci WITH(NOLOCK) ON ci.intUnitMeasureId = ag.intUnitMeasureId
LEFT JOIN reserved cj ON cj.intContractDetailId = a.intContractDetailId
LEFT JOIN tblAPVendor ck WITH(NOLOCK) ON ck.intEntityId = a.intBillTo
LEFT JOIN tblCTWeightGrade cl WITH(NOLOCK) ON cl.intWeightGradeId = b.intWeightId
LEFT JOIN tblICItemUOM cm WITH(NOLOCK) ON cm.intItemUOMId = a.intNetWeightUOMId
LEFT JOIN tblICUnitMeasure cn WITH(NOLOCK) ON cn.intUnitMeasureId = cm.intUnitMeasureId
LEFT JOIN lgallocationS co ON co.intSContractDetailId = a.intContractDetailId
OUTER	APPLY	dbo.fnCTGetSampleDetail(a.intContractDetailId)	QA
LEFT JOIN (
    SELECT *
    FROM
    (
        SELECT intRowNum = ROW_NUMBER() OVER(PARTITION BY TR.intRecordId ORDER BY TR.intRecordId ASC)
			, TR.intRecordId
			, TR.ysnOnceApproved
		FROM tblSMTransaction TR WITH(NOLOCK)
		JOIN tblSMScreen SC WITH(NOLOCK) ON SC.intScreenId = TR.intScreenId
		WHERE SC.strNamespace IN('ContractManagement.view.Contract', 'ContractManagement.view.Amendments')
	) t WHERE intRowNum = 1
) TR ON TR.intRecordId = b.intContractHeaderId
/*
OUTER APPLY (
	SELECT TOP 1 strSampleStatus = CASE WHEN s.intSampleStatusId = 3 THEN (CASE WHEN SUM(dbo.fnCTConvertQuantityToTargetItemUOM(c.intItemId, s.intRepresentingUOMId, c.intUnitMeasureId, s.dblRepresentingQty)) >= 100 THEN 'Approved'
																				ELSE 'Partially Approved' END)
										WHEN s.intSampleStatusId = 4 THEN (CASE WHEN SUM(dbo.fnCTConvertQuantityToTargetItemUOM(c.intItemId, s.intRepresentingUOMId, c.intUnitMeasureId, s.dblRepresentingQty)) >= 100 THEN 'Rejected'
																				ELSE 'Partially Rejected' END) END
	FROM tblQMSample s
	INNER JOIN tblCTContractDetail c ON s.intContractDetailId = c.intContractDetailId
	WHERE c.intContractDetailId = a.intContractDetailId
	GROUP BY s.intSampleId
		, s.intSampleStatusId
	ORDER BY s.intSampleId DESC
) QA
*/