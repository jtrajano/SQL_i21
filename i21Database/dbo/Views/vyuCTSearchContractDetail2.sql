CREATE VIEW [dbo].[vyuCTSearchContractDetail2] AS with shipmentstatus as (
  select 
    * 
  from 
    (
      select 
        intContractDetailId = ggg.intPContractDetailId, 
        hhh.intShipmentType, 
        intId = convert(
          int, 
          ROW_NUMBER() over (
            partition by ggg.intPContractDetailId 
            ORDER BY 
              hhh.dtmScheduledDate, 
              ggg.intLoadDetailId DESC
          )
        ), 
        strShipmentStatus = CASE hhh.intShipmentStatus WHEN 1 THEN 'Scheduled' WHEN 2 THEN 'Dispatched' WHEN 3 THEN CASE WHEN (hhh.ysnCustomsReleased = 1) THEN 'Customs Released' WHEN (hhh.ysnDocumentsApproved = 1) THEN 'Documents Approved' WHEN (hhh.ysnArrivedInPort = 1) THEN 'Arrived in Port' ELSE 'Inbound Transit' END WHEN 4 THEN 'Received' WHEN 5 THEN CASE WHEN (hhh.ysnCustomsReleased = 1) THEN 'Customs Released' WHEN (hhh.ysnDocumentsApproved = 1) THEN 'Documents Approved' WHEN (hhh.ysnArrivedInPort = 1) THEN 'Arrived in Port' ELSE 'Outbound Transit' END WHEN 6 THEN CASE WHEN (hhh.ysnCustomsReleased = 1) THEN 'Customs Released' WHEN (hhh.ysnDocumentsApproved = 1) THEN 'Documents Approved' WHEN (hhh.ysnArrivedInPort = 1) THEN 'Arrived in Port' ELSE 'Delivered' END WHEN 7 THEN CASE WHEN (
          ISNULL(hhh.strBookingReference, '') <> ''
        ) THEN 'Booked' ELSE 'Shipping Instruction Created' END WHEN 8 THEN 'Partial Shipment Created' WHEN 9 THEN 'Full Shipment Created' WHEN 10 THEN 'Cancelled' WHEN 11 THEN 'Invoiced' ELSE 'Open' END COLLATE Latin1_General_CI_AS 
      from 
        tblLGLoadDetail ggg with (nolock), 
        tblLGLoad hhh  with (nolock)
      where 
        ggg.intPContractDetailId is not null 
        and hhh.intLoadId = ggg.intLoadId
    ) as ss 
  where 
    intId = 1 
    and (
      (
        intShipmentType = 2 
        AND strShipmentStatus <> 'Scheduled'
      ) 
      OR intShipmentType = 1
    )
), 
fixation as (
  select 
    aaa1.intContractDetailId,
    dblPricedQuantity = (case when aaa1.intPricingTypeId = 1 then aaa1.dblQuantity else sum(bbb.dblQuantity) end)
  from 
  tblCTContractDetail aaa1 with (nolock)
    left join tblCTPriceFixation aaa with (nolock) on aaa.intContractDetailId = aaa1.intContractDetailId
    left join tblCTPriceFixationDetail bbb with (nolock)  on bbb.intPriceFixationId = aaa.intPriceFixationId and bbb.intPriceFixationId = aaa.intPriceFixationId
  group by 
    aaa1.intContractDetailId
  ,aaa1.intPricingTypeId
  ,aaa1.dblQuantity

  /*
  select 
    aaa.intContractDetailId, 
    dblPricedQuantity = sum(bbb.dblQuantity) 
  from 
    tblCTPriceFixation aaa, 
    tblCTPriceFixationDetail bbb 
  where 
    bbb.intPriceFixationId = aaa.intPriceFixationId 
  group by 
    aaa.intContractDetailId
  */
), 
lgallocationS as (
  select 
    intSContractDetailId, 
    dblAllocatedQty = ISNULL(
      SUM(dblSAllocatedQty), 
      0
    ), 
    intAllocationUOMId = MIN(intSUnitMeasureId) 
  from 
    tblLGAllocationDetail  with (nolock)
  Group By 
    intSContractDetailId
), 
lgalloationP as (
  select 
    intContractDetailId = intPContractDetailId, 
    dblAllocatedQty = ISNULL(
      SUM(dblPAllocatedQty), 
      0
    ), 
    intAllocationUOMId = MIN(intPUnitMeasureId) 
  from 
    tblLGAllocationDetail  with (nolock)
  Group By 
    intPContractDetailId
), 
approved as (
  select 
    intContractDetailId, 
    dblRepresentingQty = sum(dblRepresentingQty) 
  from 
    (
      select 
        ccc.intContractDetailId, 
        dblRepresentingQty = (
          case when isnull(eee.dblUnitQty, 0) = 0 
          or isnull(fff.dblUnitQty, 0) = 0 then null when isnull(eee.dblUnitQty, 0) = isnull(fff.dblUnitQty, 0) then ddd.dblRepresentingQty else ddd.dblRepresentingQty * (
            isnull(eee.dblUnitQty, 0) / isnull(fff.dblUnitQty, 0)
          ) end
        ) 
      from 
        tblCTContractDetail ccc with (nolock), 
        tblQMSample ddd with (nolock), 
        tblICItemUOM eee with (nolock), 
        tblICItemUOM fff  with (nolock)
      where 
        ddd.intProductValueId = ccc.intContractDetailId 
        and intProductTypeId = 8 
        and intSampleStatusId = 3 
        and eee.intUnitMeasureId = ddd.intRepresentingUOMId 
        and eee.intItemId = ccc.intItemId 
        and fff.intUnitMeasureId = ccc.intUnitMeasureId 
        and fff.intItemId = ccc.intItemId
    ) as qasample 
  group by 
    intContractDetailId
), 
prepaid as (
  select 
    jjj.intContractHeaderId, 
    intRecordCount = count(*) 
  from 
    tblAPBillDetail jjj with (nolock), 
    tblAPBill kkk  with (nolock)
  where 
    kkk.intBillId = jjj.intBillId 
    and kkk.intTransactionType = 2 
  group by 
    jjj.intContractHeaderId
), 
hedge as (
  select 
    iii.intContractDetailId, 
    dblHedgedLots = sum(iii.dblHedgedLots) 
  from 
    tblRKAssignFuturesToContractSummary iii  with (nolock)
  group by 
    iii.intContractDetailId
), 
statuses as (
  select 
    intContractHeaderId, 
    strStatuses = CASE WHEN strStatus LIKE '%Incomplete%' THEN 'Incomplete' WHEN strStatus LIKE '%Open%' THEN 'Open' WHEN strStatus LIKE '%Complete%' THEN 'Complete' WHEN strStatus is null THEN 'Incomplete' ELSE strStatus END COLLATE Latin1_General_CI_AS 
  from 
    (
      SELECT 
        lll.intContractHeaderId, 
        strStatus = STUFF(
          (
            SELECT 
              DISTINCT ', ' + nnn.strContractStatus 
            FROM 
              tblCTContractDetail mmm  with (nolock)
              JOIN tblCTContractStatus nnn with (nolock) ON nnn.intContractStatusId = mmm.intContractStatusId 
            WHERE 
              mmm.intContractHeaderId = lll.intContractHeaderId FOR XML PATH('')
          ), 
          1, 
          2, 
          ''
        ) 
      FROM 
        tblCTContractHeader lll with (nolock)
    ) as ss
), 
reserved as (
  select 
    intContractDetailId, 
    dblReservedQuantity = ISNULL(
      SUM(dblReservedQuantity), 
      0
    ) 
  from 
    tblLGReservation  with (nolock)
  Group By 
    intContractDetailId
) 
select 
  a.intContractDetailId, 
  a.intContractHeaderId, 
  b.strContractNumber, 
  a.intContractSeq, 
  a.dtmStartDate, 
  a.dtmEndDate, 
  dblDetailQuantity = a.dblQuantity, 
  dblDetailApplied = a.dblQuantity - a.dblBalance, 
  dblAvailableQty = a.dblBalance - ISNULL(a.dblScheduleQty, 0), 
  a.dblFutures, 
  a.dblBasis, 
  a.dblRatio, 
  a.dblCashPrice, 
  a.dblBalance, 
  a.dtmEventStartDate, 
  a.dtmPlannedAvailabilityDate, 
  a.dtmUpdatedAvailabilityDate, 
  a.intItemId, 
  c.strItemNo, 
  a.intItemBundleId, 
  strBundleItemNo = d.strItemNo, 
  a.intShipViaId, 
  e.strShipVia, 
  a.intPricingTypeId, 
  f.strPricingType, 
  a.intItemUOMId, 
  g.intUnitMeasureId, 
  strItemUOM = h.strUnitMeasure, 
  a.intFutureMarketId, 
  i.strFutMarketName, 
  strFutureMonth = LEFT(
    CONVERT(DATE, '01 ' + j.strFutureMonth), 
    7
  ) + ' (' + j.strFutureMonth + ')', 
  a.intPriceItemUOMId, 
  intPriceUnitMeasureId = k.intUnitMeasureId, 
  strPriceUOM = l.strUnitMeasure, 
  m.strContractOptDesc, 
  n.strLocationName, 
  o.strCurrency, 
  p.strContractStatus, 
  strShipmentStatus = r.strShipmentStatus, 
  strFinancialStatus = CASE WHEN b.intContractTypeId = 1 THEN CASE WHEN a.ysnFinalPNL = 1 THEN 'Final P&L Created' WHEN a.ysnProvisionalPNL = 1 THEN 'Provisional P&L Created' ELSE CASE WHEN s.intContractDetailId IS NOT NULL THEN 'Purchase Invoice Received' ELSE null END END ELSE a.strFinancialStatus END, 
  dblPricedQty = case when a.intPricingTypeId = 2 or t.dblPricedQuantity is not null
                        then isnull(t.dblPricedQuantity, 0)
                      else a.dblQuantity
                  end,
  dblUnPricedQty = case when a.intPricingTypeId = 2 or t.dblPricedQuantity is not null
                          then a.dblQuantity - isnull(t.dblPricedQuantity, 0)
                        else 0.00
                   end,
  dblActualLots = (
    case when isnull(v.dblUnitQty, 0) = 0 
    or isnull(w.dblUnitQty, 0) = 0 then null when isnull(v.dblUnitQty, 0) = isnull(w.dblUnitQty, 0) then a.dblQuantity else a.dblQuantity * (
      isnull(v.dblUnitQty, 0) / isnull(w.dblUnitQty, 0)
    ) end
  ) / i.dblContractSize, 
  a.intAdjItemUOMId, 
  y.strUnitMeasure, 
  a.dblAdjustment, 
  z.dblAllocatedQty, 
  --strApprovalBasis = au.strWeightGradeDesc, 
  za.strApprovalBasis, 
  ysnApproved = ISNULL(TR.ysnOnceApproved,0), --convert(bit, 0), 
  dblApprovedQty = aa.dblRepresentingQty, 
  strAssociationName = zb.strName, 
  a.dblAssumedFX, 
  dblBalLotsToHedge = a.dblNoOfLots - ISNULL(ab.dblHedgedLots, 0), 
  dblBalQtyToHedge = (
    case when isnull(ad.dblUnitQty, 0) = 0 
    or isnull(ae.dblUnitQty, 0) = 0 then null when isnull(ad.dblUnitQty, 0) = isnull(ae.dblUnitQty, 0) then i.dblContractSize * (
      a.dblNoOfLots - ISNULL(ab.dblHedgedLots, 0)
    ) else (
      i.dblContractSize * (
        a.dblNoOfLots - ISNULL(ab.dblHedgedLots, 0)
      )
    ) * (
      isnull(ad.dblUnitQty, 0) / isnull(ae.dblUnitQty, 0)
    ) end
  ), 
  zc.strBook, 
  b.ysnBrokerage, 
  a.strBuyerSeller, 
  b.ysnCategory, 
  af.intCommodityId, 
  af.strCommodityCode, 
  strCommodityDescription = af.strDescription, 
  dblTotalAppliedQty = (
    case when isnull(ah.dblUnitQty, 0) = 0 
    or isnull(ai.dblUnitQty, 0) = 0 then null when isnull(ah.dblUnitQty, 0) = isnull(ai.dblUnitQty, 0) then (a.dblQuantity - a.dblBalance) else (
      (a.dblQuantity - a.dblBalance) * isnull(ah.dblUnitQty, 0)
    ) / isnull(ai.dblUnitQty, 0) end
  ), 
  dblTotalBallance = (
    case when isnull(ah.dblUnitQty, 0) = 0 
    or isnull(ai.dblUnitQty, 0) = 0 then null when isnull(ah.dblUnitQty, 0) = isnull(ai.dblUnitQty, 0) then a.dblBalance else (
      a.dblBalance * isnull(ah.dblUnitQty, 0)
    ) / isnull(ai.dblUnitQty, 0) end
  ), 
  strHeaderPricingType = u.strPricingType, 
  dblHeaderQuantity = b.dblQuantity, 
  b.dtmContractDate, 
  aj.strContractPlan, 
  ak.strContractType, 
  al.strCountry, 
  strCreatedBy = am.strName, 
  b.dtmCreated, 
  an.strCropYear, 
  strCounterParty = ao.strName, 
  b.strCPContract, 
  b.dtmSigned, 
  b.dtmDeferPayDate, 
  b.dblDeferPayRate, 
  strDestinationPoint = ap.strCity, 
  a.strERPBatchNumber, 
  a.strERPItemNumber, 
  a.strERPPONumber, 
  intCustomerVendorEntityId = b.intEntityId, 
  strCustomerVendor = aq.strName, 
  b.strCustomerContract,
  b.ysnExported, 
  b.dtmExported, 
  a.strFXRemarks, 
  a.dtmFXValidFrom, 
  a.dtmFXValidTo, 
  a.strFixationBy, 
  a.strFobBasis, 
  intDetailFreightTermId = a.intFreightTermId, 
  strDetailFreightTerm = ar.strFreightTerm, 
  b.intGradeId, 
  strGrade = au.strWeightGradeDesc, 
  dblHedgeQty = (
    case when isnull(ad.dblUnitQty, 0) = 0 
    or isnull(ae.dblUnitQty, 0) = 0 then null when isnull(ad.dblUnitQty, 0) = isnull(ae.dblUnitQty, 0) then i.dblContractSize * ISNULL(ab.dblHedgedLots, 0) else (
      i.dblContractSize * ISNULL(ab.dblHedgedLots, 0)
    ) * (
      isnull(ad.dblUnitQty, 0) / isnull(ae.dblUnitQty, 0)
    ) end
  ), 
  ab.dblHedgedLots, 
  strINCOLocation = CASE WHEN av.strINCOLocationType = 'City' THEN aw.strCity ELSE ax.strSubLocationName END, 
  ay.strIndex, 
  az.strInsuranceBy, 
  b.strInternalComment, 
  a.dblIntransitQty, 
  a.strInvoiceNo, 
  ba.strInvoiceNumber, 
  bb.strInvoiceType, 
  strItemDescription = c.strDescription, 
  strItemShortName = c.strShortName, 
  b.intLastModifiedById, 
  strLastModifiedBy = bc.strName, 
  a.dtmLastPricingDate, 
  b.ysnLoad, 
  strLoadUnitMeasure = be.strUnitMeasure, 
  strLoadingPoint = bf.strCity, 
  c.strLotTracking, 
  bg.strMarketZoneCode, 
  b.ysnMaxPrice, 
  b.ysnMultiplePriceFixation, 
  a.dblNetWeight, 
  b.intNoOfLoad, 
  a.dblNoOfLots, 
  a.intNumberOfContainers, 
  strOrigin = ISNULL(bi.strCountry, bk.strCountry), 
  strOriginDest = bl.strOrigin + ' - ' + bl.strDest, 
  a.dblOriginalQty, 
  bm.strPosition, 
  ysnPrepaid = case when isnull(bn.intRecordCount, 0) > 0 then convert(bit, 1) else convert(bit, 0) end, 
  bo.strPricingLevelName, 
  b.strPrintableRemarks, 
  b.ysnPrinted, 
  strProducer = bp2.strName, 
  strProductType = bq.strDescription, 
  b.ysnProvisional, 
  b.dblProvisionalInvoicePct, 
  strPurchasingGroup = br.strName, 
  dblQtyInCommodityDefaultUOM = (
    case when isnull(v.dblUnitQty, 0) = 0 
    or isnull(bt.dblUnitQty, 0) = 0 then null when isnull(v.dblUnitQty, 0) = isnull(bt.dblUnitQty, 0) then a.dblQuantity else a.dblQuantity * (
      isnull(v.dblUnitQty, 0) / isnull(bt.dblUnitQty, 0)
    ) end
  ), 
  --strQualityApproval = QA.strSampleStatus,
  strQualityApproval = bh.strGrade, 
  dblQtyInCommodityStockUOM = (
    case when isnull(v.dblUnitQty, 0) = 0 
    or isnull(bu.dblUnitQty, 0) = 0 then null when isnull(v.dblUnitQty, 0) = isnull(bu.dblUnitQty, 0) then a.dblQuantity else a.dblQuantity * (
      isnull(v.dblUnitQty, 0) / isnull(bu.dblUnitQty, 0)
    ) end
  ), 
  b.dblQuantityPerLoad, 
  bv.strRailGrade, 
  a.dblRate, 
  b.ysnReceivedSignedFixationLetter, 
  a.strReference, 
  a.strRemark, 
  a.dblReservedQty, 
  strSalesperson = bw.strName, 
  a.dblScheduleQty, 
  strSeqBook = bx.strBook, 
  strSeqSubBook = bz.strSubBook, 
  a.strShippingTerm, 
  b.ysnSigned, 
  strStatuses = ca.strStatuses, 
  strStockCommodityUnitMeasure = cb.strUnitMeasure, 
  strStorageLocationName = cc.strName, 
  cd.strSubBook, 
  ce.strSubLocationName, 
  b.ysnSubstituteItem, 
  cf.strTerm, 
  cg.strTextCode, 
  b.dblTolerancePct, 
  a.dblTotalCost, 
  strHeaderUnitMeasure = case when b.ysnLoad = convert(bit, 1) then ci.strUnitMeasure + '/Load' else ci.strUnitMeasure end, 
  dblUnAllocatedQty = ISNULL(a.dblQuantity, 0) - ISNULL(z.dblAllocatedQty, 0) - ISNULL(co.dblAllocatedQty, 0), 
  b.ysnUnlimitedQuantity, 
  dblUnReservedQuantity = ISNULL(a.dblQuantity, 0) - ISNULL(cj.dblReservedQuantity, 0), 
  ck.strVendorId, 
  a.strVendorLotID, 
  a.strVessel, 
  strWeight = cl.strWeightGradeDesc, 
  strWeightUOM = cn.strUnitMeasure, 
  aq.intEntityId ,
  b.intBookId as intHeaderBookId,
  b.intSubBookId as intHeaderSubBookId,
  a.intBookId as intDetailBookId,
  a.intSubBookId as intDetailSubBookId
from 
  tblCTContractDetail a  with (nolock)
  join tblCTContractHeader b with (nolock) on b.intContractHeaderId = a.intContractHeaderId 
  left join tblICItem c  with (nolock) on c.intItemId = a.intItemId 
  left join tblICItem d  with (nolock) on d.intItemId = a.intItemBundleId 
  left join tblSMShipVia e  with (nolock) on e.intEntityId = a.intShipViaId 
  left join tblCTPricingType f  with (nolock) on f.intPricingTypeId = a.intPricingTypeId 
  left join tblICItemUOM g  with (nolock) on g.intItemUOMId = a.intItemUOMId 
  left join tblICUnitMeasure h  with (nolock) on h.intUnitMeasureId = g.intUnitMeasureId 
  left join tblRKFutureMarket i  with (nolock) on i.intFutureMarketId = a.intFutureMarketId 
  left join tblRKFuturesMonth j  with (nolock) on j.intFutureMonthId = a.intFutureMonthId 
  left join tblICItemUOM k  with (nolock) on k.intItemUOMId = a.intPriceItemUOMId 
  left join tblICUnitMeasure l  with (nolock) on l.intUnitMeasureId = k.intUnitMeasureId 
  left join tblCTContractOptHeader m  with (nolock) on m.intContractOptHeaderId = a.intContractOptHeaderId 
  left join tblSMCompanyLocation n  with (nolock) on n.intCompanyLocationId = a.intCompanyLocationId 
  left join tblSMCurrency o  with (nolock) on o.intCurrencyID = a.intCurrencyId 
  left join tblCTContractStatus p  with (nolock) on p.intContractStatusId = a.intContractStatusId 
  left join shipmentstatus r on r.intContractDetailId = a.intContractDetailId 
  outer apply
  (
    select top 1 intContractDetailId
    from tblAPBillDetail with (nolock)
    where intContractDetailId = a.intContractDetailId
  ) s
  left join fixation t on t.intContractDetailId = a.intContractDetailId 
  left join tblCTPricingType u  with (nolock) on u.intPricingTypeId = b.intPricingTypeId 
  left join tblICItemUOM v  with (nolock) on v.intItemId = a.intItemId 
  						   and v.intUnitMeasureId = g.intUnitMeasureId 
  left join tblICItemUOM w  with (nolock) on w.intItemId = a.intItemId 
  						   and w.intUnitMeasureId = i.intUnitMeasureId 
  left join tblICItemUOM x  with (nolock) on x.intItemUOMId = a.intAdjItemUOMId 
  left join tblICUnitMeasure y  with (nolock) on y.intUnitMeasureId = x.intUnitMeasureId 
  left join lgalloationP z on z.intContractDetailId = a.intContractDetailId 
  left join tblCTApprovalBasis za  with (nolock) on za.intApprovalBasisId = b.intApprovalBasisId 
  left join approved aa on aa.intContractDetailId = a.intContractDetailId 
  left join tblCTAssociation zb  with (nolock) on zb.intAssociationId = b.intAssociationId 
  left join hedge ab on ab.intContractDetailId = a.intContractDetailId 
  left join tblICCommodityUnitMeasure ac  with (nolock) on ac.intCommodityId = b.intCommodityId 
  										 and ac.ysnStockUnit = 1 
  left join tblICItemUOM ad  with (nolock) on ad.intItemId = a.intItemId 
  							and ad.intUnitMeasureId = i.intUnitMeasureId 
  left join tblICItemUOM ae  with (nolock) on ae.intItemId = a.intItemId 
  							and ae.intUnitMeasureId = ac.intUnitMeasureId 
  left join tblCTBook zc  with (nolock) on zc.intBookId = b.intBookId 
  left join tblICCommodity af  with (nolock) on af.intCommodityId = b.intCommodityId 
  left join tblICCommodityUnitMeasure ag  with (nolock) on ag.intCommodityUnitMeasureId = b.intCommodityUOMId 
  left join tblICItemUOM ah  with (nolock) on ah.intItemId = a.intItemId 
  							and ah.intUnitMeasureId = a.intUnitMeasureId 
  left join tblICItemUOM ai  with (nolock) on ai.intItemId = a.intItemId 
  							and ai.intUnitMeasureId = ag.intUnitMeasureId 
  left join tblCTContractPlan aj  with (nolock) on aj.intContractPlanId = b.intContractPlanId 
  left join tblCTContractType ak  with (nolock) on ak.intContractTypeId = b.intContractTypeId 
  left join tblSMCountry al  with (nolock) on al.intCountryID = b.intCountryId 
  left join tblEMEntity am  with (nolock) on am.intEntityId = b.intCreatedById 
  left join tblCTCropYear an  with (nolock) on an.intCropYearId = b.intCropYearId 
  left join tblEMEntity ao  with (nolock) on ao.intEntityId = b.intCounterPartyId 
  left join tblSMCity ap  with (nolock) on ap.intCityId = a.intDestinationPortId 
  left join tblEMEntity aq  with (nolock) on aq.intEntityId = b.intEntityId 
  left join tblSMFreightTerms ar  with (nolock) on ar.intFreightTermId = a.intFreightTermId 
  left join tblCTWeightGrade au  with (nolock) on au.intWeightGradeId = b.intGradeId 
  left join tblCTContractBasis av  with (nolock) on av.intContractBasisId = b.intContractBasisId 
  left join tblSMCity aw  with (nolock) on aw.intCityId = b.intINCOLocationTypeId 
  left join tblSMCompanyLocationSubLocation ax  with (nolock) on ax.intCompanyLocationSubLocationId = b.intWarehouseId 
  left join tblCTIndex ay  with (nolock) on ay.intIndexId = a.intIndexId 
  left join tblCTInsuranceBy az  with (nolock) on az.intInsuranceById = b.intInsuranceById 
  left join tblCTContractInvoice ba  with (nolock) on ba.intContractDetailId = a.intContractDetailId 
  left join tblCTInvoiceType bb  with (nolock) on bb.intInvoiceTypeId = b.intInvoiceTypeId 
  left join tblEMEntity bc  with (nolock) on bc.intEntityId = b.intLastModifiedById 
  left join tblICCommodityUnitMeasure bd  with (nolock) on bd.intCommodityUnitMeasureId = b.intLoadUOMId 
  left join tblICUnitMeasure be  with (nolock) on be.intUnitMeasureId = bd.intUnitMeasureId 
  left join tblSMCity bf  with (nolock) on bf.intCityId = a.intLoadingPortId 
  left join tblARMarketZone bg  with (nolock) on bg.intMarketZoneId = a.intMarketZoneId 
  left join tblICItemContract bh  with (nolock) on bh.intItemContractId = a.intItemContractId 
  left join tblSMCountry bi  with (nolock) on bi.intCountryID = bh.intCountryId 
  left join tblICCommodityAttribute bj  with (nolock) on bj.intCommodityAttributeId = c.intOriginId 
  left join tblSMCountry bk  with (nolock) on bk.intCountryID = bj.intCountryID 
  left join tblCTFreightRate bl  with (nolock) on bl.intFreightRateId = a.intFreightRateId 
  left join tblCTPosition bm  with (nolock) on bm.intPositionId = b.intPositionId 
  left join prepaid bn on bn.intContractHeaderId = b.intContractHeaderId 
  left join tblSMCompanyLocationPricingLevel bo  with (nolock) on bo.intCompanyLocationPricingLevelId = b.intCompanyLocationPricingLevelId 
  left join tblEMEntity bp  with (nolock) on bp.intEntityId = b.intProducerId 
  LEFT JOIN tblEMEntity bp2 WITH(NOLOCK) ON bp2.intEntityId = a.intProducerId
  left join tblICCommodityAttribute bq  with (nolock) on bq.intCommodityAttributeId = c.intProductTypeId 
  									   and bq.strType = 'ProductType' 
  left join tblSMPurchasingGroup br  with (nolock) on br.intPurchasingGroupId = a.intPurchasingGroupId 
  left join tblICCommodityUnitMeasure bs  with (nolock) on bs.intCommodityId = b.intCommodityId 
  										 and bs.ysnDefault = 1 
  left join tblICItemUOM bt  with (nolock) on bt.intItemId = a.intItemId 
  							and bt.intUnitMeasureId = bs.intUnitMeasureId 
  left join tblICItemUOM bu  with (nolock) on bu.intItemId = a.intItemId 
  							and bu.intUnitMeasureId = ac.intUnitMeasureId 
  left join tblCTRailGrade bv  with (nolock) on bv.intRailGradeId = a.intRailGradeId 
  left join tblEMEntity bw  with (nolock) on bw.intEntityId = b.intSalespersonId 
  left join tblCTBook bx  with (nolock) on bx.intBookId = a.intBookId 
  left join tblCTSubBook bz  with (nolock) on bz.intSubBookId = a.intSubBookId 
  left join statuses ca on ca.intContractHeaderId = b.intContractHeaderId 
  left join tblICUnitMeasure cb  with (nolock) on cb.intUnitMeasureId = ac.intUnitMeasureId 
  left join tblICStorageLocation cc  with (nolock) on cc.intStorageLocationId = a.intStorageLocationId 
  left join tblCTSubBook cd  with (nolock) on cd.intSubBookId = b.intSubBookId 
  left join tblSMCompanyLocationSubLocation ce  with (nolock) on ce.intCompanyLocationSubLocationId = a.intSubLocationId 
  left join tblSMTerm cf  with (nolock) on cf.intTermID = b.intTermId 
  left join tblCTContractText cg  with (nolock) on cg.intContractTextId = b.intContractTextId 
  left join tblICUnitMeasure ci  with (nolock) on ci.intUnitMeasureId = ag.intUnitMeasureId 
  left join reserved cj on cj.intContractDetailId = a.intContractDetailId 
  left join tblAPVendor ck  with (nolock) on ck.intEntityId = a.intBillTo 
  left join tblCTWeightGrade cl  with (nolock) on cl.intWeightGradeId = b.intWeightId 
  left join tblICItemUOM cm  with (nolock) on cm.intItemUOMId = a.intNetWeightUOMId 
  left join tblICUnitMeasure cn  with (nolock) on cn.intUnitMeasureId = cm.intUnitMeasureId 
  left join lgallocationS co on co.intSContractDetailId = a.intContractDetailId
  left join
  (
		SELECT * FROM 
		(
			SELECT	ROW_NUMBER() OVER (PARTITION BY TR.intRecordId ORDER BY TR.intRecordId ASC) intRowNum,
					TR.intRecordId, TR.ysnOnceApproved 
			FROM	tblSMTransaction	TR with (nolock) 
			JOIN	tblSMScreen			SC	 with (nolock) ON	SC.intScreenId		=	TR.intScreenId
			WHERE	SC.strNamespace IN( 'ContractManagement.view.Contract',
										'ContractManagement.view.Amendments')
		) t
		WHERE intRowNum = 1
  ) TR ON TR.intRecordId = b.intContractHeaderId
  /*
  OUTER APPLY 
  (
    SELECT TOP 1 strSampleStatus = 
      CASE 
        WHEN s.intSampleStatusId = 3 THEN (CASE WHEN SUM(dbo.fnCTConvertQuantityToTargetItemUOM(c.intItemId,s.intRepresentingUOMId,c.intUnitMeasureId,s.dblRepresentingQty)) >= 100 THEN 'Approved' ELSE 'Partially Approved' END) 
        WHEN s.intSampleStatusId = 4 THEN (CASE WHEN SUM(dbo.fnCTConvertQuantityToTargetItemUOM(c.intItemId,s.intRepresentingUOMId,c.intUnitMeasureId, s.dblRepresentingQty)) >= 100 THEN 'Rejected' ELSE 'Partially Rejected' END)
      END 
    FROM tblQMSample s
    INNER JOIN tblCTContractDetail c ON s.intContractDetailId = c.intContractDetailId
    WHERE c.intContractDetailId = a.intContractDetailId
    GROUP BY s.intSampleId,s.intSampleStatusId
    ORDER BY s.intSampleId DESC
  ) QA
  */