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
	 , ISNULL(dbo.fnICConvertUOMtoStockUnit(intItemId, intItemUOMId, dblAvailableQty), 0) AS dblContractDemandBalanceQty
	 , strStockItemUOM
	 , intStockUOMId
	 , intItemUOMId
	 , 'Open'							AS strPurchaseType
	 , ''								AS strLoadNumber		
FROM vyuCTContractDetailView
OUTER APPLY (SELECT TOP 1 intItemBundleId
			 FROM tblCTContractDetail AS CDContractDetail
			 WHERE CDContractDetail.intContractDetailId = vyuCTContractDetailView.intContractDetailId) AS BundleItem
OUTER APPLY (SELECT TOP 1 strItemNo
			 FROM tblICItem AS ICItem
			 WHERE ICItem.intItemId = BundleItem.intItemBundleId) AS BundleItemNo
WHERE intContractStatusId IN (1, 4) 
--  AND (dblDetailQuantity - ISNULL(NULLIF(dblAppliedQty, 0), ISNULL(dblScheduleQty,0)) > 0) 
    AND dblAvailableQty > 0
UNION 

/* Sceheduled */
SELECT CTDetailView.intContractDetailId
	 , strSequenceNumber
	 , CTDetailView.strLocationName 
	 , strEntityName
	 , dblAvailableQty
	 , CTDetailView.dtmStartDate
	 , CTDetailView.dtmEndDate
	 , CTDetailView.dtmPlannedAvailabilityDate
	 , CASE WHEN DemandPosition.intPositionByETADemandReport = 1 THEN dtmUpdatedAvailabilityDate
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
	 , LGTransit.dblLoadScheduleQty		AS dblContractDemandBalanceQty
	 , strStockItemUOM	
	 , intStockUOMId
	 , CTDetailView.intItemUOMId
	 , CASE WHEN DemandPosition.intPositionByETADemandReport = 3  THEN 'Open - Schedule'
			ELSE 'In-Transit' 
	   END AS strPurchaseType
	 , LGTransit.strLoadNumber			AS strLoadNumber
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
OUTER APPLY (SELECT SUM(dbo.fnICConvertUOMtoStockUnit(OALoadDetail.intItemId, OALoadDetail.intItemUOMId, ISNULL(OAContainerLink.dblQuantity, OALoadDetail.dblQuantity) - (CASE WHEN (OAContainerLink.intLoadDetailContainerLinkId IS NOT NULL) THEN ISNULL(OAContainerLink.dblReceivedQty, 0)
																																											   ELSE OALoadDetail.dblDeliveredQuantity
			      																																							END))) AS dblLoadScheduleQty
				  , OALoad.strLoadNumber			
			 FROM tblLGLoadDetail AS OALoadDetail 
			 LEFT JOIN tblLGLoad AS OALoad ON OALoad.intLoadId = OALoadDetail.intLoadId 
			 LEFT JOIN tblLGLoadDetailContainerLink AS OAContainerLink ON OALoadDetail.intLoadDetailId = OAContainerLink.intLoadDetailId
			 WHERE OALoadDetail.intPContractDetailId = CTDetailView.intContractDetailId 
			   AND OALoadDetail.intLoadDetailId = LoadDetail.intLoadDetailId
			   AND OALoad.intPurchaseSale = 1 
			   AND OALoad.intShipmentType = 1 
			   AND (
					(SELECT intPositionByETADemandReport FROM tblMFCompanyPreference) = 3 AND OALoad.ysnPosted = 0
				 OR (SELECT intPositionByETADemandReport FROM tblMFCompanyPreference) != 3 AND 1 = 1
				   )
			   AND ISNULL(OAContainerLink.dblQuantity, OALoadDetail.dblQuantity) - (CASE WHEN (OAContainerLink.intLoadDetailContainerLinkId IS NOT NULL) THEN ISNULL(OAContainerLink.dblReceivedQty, 0)
																						 ELSE OALoadDetail.dblDeliveredQuantity
																					END) > 0
			GROUP BY OALoad.strLoadNumber) AS LGTransit
LEFT JOIN tblSMCity AS City ON City.strCity = LGLoad.strDestinationPort
OUTER APPLY (SELECT TOP 1 intPositionByETADemandReport 
			 FROM tblMFCompanyPreference) AS DemandPosition
WHERE intContractStatusId IN (1, 4) 
  AND LGTransit.dblLoadScheduleQty > 0
GROUP BY CTDetailView.intContractDetailId
	   , strSequenceNumber
	   , CTDetailView.strLocationName 
	   , strEntityName
	   , dblAvailableQty
	   , CTDetailView.dtmStartDate
	   , CTDetailView.dtmEndDate
	   , CTDetailView.dtmPlannedAvailabilityDate
	   , CASE WHEN DemandPosition.intPositionByETADemandReport = 1 THEN dtmUpdatedAvailabilityDate
	  		WHEN LGLoad.intTransportationMode = 2 THEN ISNULL(DATEADD(DAY, ISNULL(City.intLeadTime, 0), LGLoad.dtmETAPOD), dtmUpdatedAvailabilityDate)
	  	    ELSE LGLoad.dtmETAPOD
	     END 
	   , CTDetailView.intBookId
	   , CTDetailView.intSubBookId
	   , CTDetailView.intItemId
	   , CTDetailView.intCompanyLocationId
	   , dblQtyInStockUOM
	   , intContractStatusId
	   , DAY(dtmUpdatedAvailabilityDate)	
	   , strBook
	   , strSubBook
	   , BundleItem.intItemBundleId
	   , BundleItemNo.strItemNo			
	   , dblDetailQuantity
	   , dblAppliedQty
	   , LGTransit.dblLoadScheduleQty			
	   , strStockItemUOM	
	   , intStockUOMId
	   , CTDetailView.intItemUOMId
	   , LGTransit.strLoadNumber	
	   , CASE WHEN DemandPosition.intPositionByETADemandReport = 3  THEN 'Open - Schedule'
			ELSE 'In-Transit' 
	     END

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
	 , CASE WHEN DemandPosition.intPositionByETADemandReport = 1 THEN dtmUpdatedAvailabilityDate
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
	 , InTransit.dblIntrasitQty			AS dblContractDemandBalanceQty
	 , strStockItemUOM	
	 , intStockUOMId
	 , CTDetailView.intItemUOMId
	 , 'In-Transit'						AS strPurchaseType
	 , InTransit.strLoadNumber			AS strLoadNumber
FROM vyuCTContractDetailView AS CTDetailView
LEFT JOIN tblLGLoadDetail AS LoadDetail ON CTDetailView.intContractDetailId = LoadDetail.intPContractDetailId
LEFT JOIN tblLGLoad AS LGLoad ON LGLoad.intLoadId = LoadDetail.intLoadId
						AND LGLoad.intPurchaseSale = 1
						AND LGLoad.intShipmentType = 1
OUTER APPLY (SELECT TOP 1 intItemBundleId
			 FROM tblCTContractDetail AS CDContractDetail
			 WHERE CDContractDetail.intContractDetailId = CTDetailView.intContractDetailId) AS BundleItem
OUTER APPLY (SELECT TOP 1 strItemNo
			 FROM tblICItem AS ICItem
			 WHERE ICItem.intItemId = BundleItem.intItemBundleId) AS BundleItemNo
OUTER APPLY (SELECT SUM(dbo.fnICConvertUOMtoStockUnit(OALoadDetail.intItemId, OALoadDetail.intItemUOMId, ISNULL(OAContainerLink.dblQuantity, OALoadDetail.dblQuantity) - (CASE WHEN (OAContainerLink.intLoadDetailContainerLinkId IS NOT NULL) THEN ISNULL(OAContainerLink.dblReceivedQty, 0)
																																											   ELSE OALoadDetail.dblDeliveredQuantity
			      																																			  END))) AS dblIntrasitQty
				  , OALoad.strLoadNumber			
			 FROM tblLGLoadDetail AS OALoadDetail 
			 LEFT JOIN tblLGLoad AS OALoad ON OALoad.intLoadId = OALoadDetail.intLoadId 
			 LEFT JOIN tblLGLoadDetailContainerLink AS OAContainerLink ON OALoadDetail.intLoadDetailId = OAContainerLink.intLoadDetailId
			 WHERE OALoadDetail.intPContractDetailId = CTDetailView.intContractDetailId 
			   AND OALoadDetail.intLoadDetailId = LoadDetail.intLoadDetailId
			   AND OALoad.intPurchaseSale = 1 
			   AND OALoad.intShipmentType = 1 
			   AND (
					(SELECT intPositionByETADemandReport FROM tblMFCompanyPreference) = 3 AND OALoad.ysnPosted = 1
				 OR (SELECT intPositionByETADemandReport FROM tblMFCompanyPreference) != 3 AND 1 = 1
				   )
			   AND ISNULL(OAContainerLink.dblQuantity, OALoadDetail.dblQuantity) - (CASE WHEN (OAContainerLink.intLoadDetailContainerLinkId IS NOT NULL) THEN ISNULL(OAContainerLink.dblReceivedQty, 0)
																						 ELSE OALoadDetail.dblDeliveredQuantity
																					END) > 0
			GROUP BY OALoad.strLoadNumber) AS InTransit
LEFT JOIN tblSMCity AS City ON City.strCity = LGLoad.strDestinationPort
OUTER APPLY (SELECT TOP 1 intPositionByETADemandReport 
			 FROM tblMFCompanyPreference) AS DemandPosition
WHERE intContractStatusId IN (1, 4) 
  AND InTransit.dblIntrasitQty > 0
GROUP BY CTDetailView.intContractDetailId
	   , strSequenceNumber
	   , CTDetailView.strLocationName 
	   , strEntityName
	   , dblAvailableQty
	   , CTDetailView.dtmStartDate
	   , CTDetailView.dtmEndDate
	   , CTDetailView.dtmPlannedAvailabilityDate
	   , CASE WHEN DemandPosition.intPositionByETADemandReport = 1 THEN dtmUpdatedAvailabilityDate
	  		WHEN LGLoad.intTransportationMode = 2 THEN ISNULL(DATEADD(DAY, ISNULL(City.intLeadTime, 0), LGLoad.dtmETAPOD), dtmUpdatedAvailabilityDate)
	  	    ELSE LGLoad.dtmETAPOD
	     END 
	   , CTDetailView.intBookId
	   , CTDetailView.intSubBookId
	   , CTDetailView.intItemId
	   , CTDetailView.intCompanyLocationId
	   , dblQtyInStockUOM
	   , intContractStatusId
	   , DAY(dtmUpdatedAvailabilityDate)	
	   , strBook
	   , strSubBook
	   , BundleItem.intItemBundleId
	   , BundleItemNo.strItemNo			
	   , dblDetailQuantity
	   , dblAppliedQty
	   , InTransit.dblIntrasitQty			
	   , strStockItemUOM	
	   , intStockUOMId
	   , CTDetailView.intItemUOMId
	   , InTransit.strLoadNumber			
GO


