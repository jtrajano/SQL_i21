CREATE VIEW [dbo].[vyuMFDemandDetailContract]
AS 
/****************************************************************
	Title: Demand Detail
	Description: Return Contract Detail for Demand Analysis View
	JIRA: MFG-4545
	Created By: Jonathan Valenzuela
	Date: 05/03/2023
*****************************************************************/
SELECT intContractDetailId
	 , strSequenceNumber
	 , strLocationName 
	 , strEntityName
	 , dblAvailableQty
	 , dtmStartDate
	 , dtmEndDate
	 , dtmPlannedAvailabilityDate
	 , dtmUpdatedAvailabilityDate
	 , intBookId
	 , intSubBookId
	 , intItemId
	 , intCompanyLocationId
	 , dblQtyInStockUOM
	 , intContractStatusId
	 , DAY(dtmUpdatedAvailabilityDate)	AS intUADDay
	 , strBook
	 , strSubBook
	 , BundleItem.intItemBundleId
	 , BundleItemNo.strItemNo			AS strBundleItemNo
	 , 0.00 AS dblDemandQty
	 , dblDetailQuantity
	 , dblAppliedQty
	 , dbo.fnCTConvertQtyToTargetItemUOM(intItemUOMId, intStockUOMId, dblDetailQuantity - ISNULL(NULLIF(dblAppliedQty, 0), ISNULL(dblScheduleQty,0))) AS dblContractDemandBalanceQty
	 , strStockItemUOM
	 , intStockUOMId
	 , intItemUOMId
FROM vyuCTContractDetailView
OUTER APPLY (SELECT TOP 1 intItemBundleId
			 FROM tblCTContractDetail AS CDContractDetail
			 WHERE CDContractDetail.intContractDetailId = vyuCTContractDetailView.intContractDetailId) AS BundleItem
OUTER APPLY (SELECT TOP 1 strItemNo
			 FROM tblICItem AS ICItem
			 WHERE ICItem.intItemId = BundleItem.intItemBundleId) AS BundleItemNo
WHERE intContractStatusId IN (1, 4) 
  AND (dblDetailQuantity - ISNULL(NULLIF(dblAppliedQty, 0), ISNULL(dblScheduleQty,0)) > 0) 
UNION 
/* In-Transit */
SELECT CTDetailView.intContractDetailId
	 , strSequenceNumber
	 , CTDetailView.strLocationName 
	 , strEntityName
	 , dblAvailableQty
	 , CTDetailView.dtmStartDate
	 , CTDetailView.dtmEndDate
	 , CTDetailView.dtmPlannedAvailabilityDate
	 , CASE WHEN (SELECT TOP 1 intPositionByETADemandReport FROM tblMFCompanyPreference) = 1 THEN dtmUpdatedAvailabilityDate
			WHEN LGLoad.intTransportationMode = 2 THEN ISNULL(DATEADD(DAY, ISNULL(City.intLeadTime, 0), LGLoad.dtmETAPOD), dtmUpdatedAvailabilityDate)
		    ELSE LGLoad.dtmETAPOD
	   END AS dtmUpdatedAvailabilityDate
	 , CTDetailView.intBookId
	 , CTDetailView.intSubBookId
	 , CTDetailView.intItemId
	 , CTDetailView.intCompanyLocationId
	 , dblQtyInStockUOM
	 , intContractStatusId
	 , DAY(dtmUpdatedAvailabilityDate)	AS intUADDay
	 , strBook
	 , strSubBook
	 , BundleItem.intItemBundleId
	 , BundleItemNo.strItemNo			AS strBundleItemNo
	 , 0.00 AS dblDemandQty
	 , dblDetailQuantity
	 , dblAppliedQty
	 , CASE WHEN dblAppliedQty < 1 THEN   dbo.fnCTConvertQtyToTargetItemUOM(CTDetailView.intItemUOMId, intStockUOMId, ISNULL(dblScheduleQty, 0))
			ELSE  dbo.fnCTConvertQtyToTargetItemUOM(CTDetailView.intItemUOMId, intStockUOMId, dblDetailQuantity - dblAppliedQty)
	   END AS dblContractDemandBalanceQty
	 , strStockItemUOM
	 , intStockUOMId
	 , CTDetailView.intItemUOMId
FROM vyuCTContractDetailView AS CTDetailView
LEFT JOIN  tblLGLoadDetail AS LoadDetail ON CTDetailView.intContractDetailId = LoadDetail.intPContractDetailId
LEFT JOIN tblLGLoad AS LGLoad ON LGLoad.intLoadId = LoadDetail.intLoadId
						AND LGLoad.intPurchaseSale = 1
						AND LGLoad.intShipmentType = 1
OUTER APPLY (SELECT TOP 1 intItemBundleId
			 FROM tblCTContractDetail AS CDContractDetail
			 WHERE CDContractDetail.intContractDetailId = CTDetailView.intContractDetailId) AS BundleItem
OUTER APPLY (SELECT TOP 1 strItemNo
			 FROM tblICItem AS ICItem
			 WHERE ICItem.intItemId = BundleItem.intItemBundleId) AS BundleItemNo
LEFT JOIN tblSMCity AS City ON City.strCity = LGLoad.strDestinationPort
WHERE intContractStatusId IN (1, 4) 
  AND (CASE WHEN dblAppliedQty < 1 THEN   dbo.fnCTConvertQtyToTargetItemUOM(CTDetailView.intItemUOMId, intStockUOMId, ISNULL(dblScheduleQty, 0))
			ELSE  dbo.fnCTConvertQtyToTargetItemUOM(CTDetailView.intItemUOMId, intStockUOMId, dblDetailQuantity - dblAppliedQty)
	   END) > 0
GO


