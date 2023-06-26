CREATE VIEW [dbo].[vyuTRLoadHeaderInfo]

AS

SELECT TH.intLoadHeaderId
	, TH.intShipViaId
	, SV.strShipVia strShipViaName
	, TH.intSellerId
	, SS.strShipVia strSellerName
	, TH.intDriverId
	, SP.strName strDriverName
	, TH.intStateId
	, S.strStateName strStateName
	, TH.intTruckDriverReferenceId
	, SVTR.strTruckNumber strTractorName
	, TH.intFreightItemId
	, F.strItemNo strFreightItemNo
	, TH.intLoadId
	, L.strLoadNumber strLoadNumber
	, TH.intTrailerId
	, ST.strTrailerNumber
	, strDispatchId = LGD.strDispatchOrderNumber
	, F.strCostMethod strCostMethodFreight
FROM tblTRLoadHeader TH
LEFT JOIN tblSMShipVia SV ON SV.intEntityId = TH.intShipViaId
LEFT JOIN tblSMShipVia SS ON SS.intEntityId = TH.intSellerId
LEFT JOIN tblSCTruckDriverReference TDR ON TDR.intTruckDriverReferenceId =  TH.intTruckDriverReferenceId
LEFT JOIN vyuEMSalesperson SP ON SP.intEntityId = TH.intDriverId
LEFT JOIN tblTRState S ON S.intStateId = TH.intStateId
LEFT JOIN tblICItem F ON F.intItemId = TH.intFreightItemId
LEFT JOIN tblLGLoad L ON L.intLoadId = TH.intLoadId
LEFT JOIN tblSMShipViaTrailer ST ON ST.intEntityShipViaTrailerId = TH.intTrailerId
LEFT JOIN tblSMShipViaTruck SVTR ON SVTR.intEntityShipViaTruckId = TH.intTruckId
LEFT JOIN tblLGDispatchOrder LGD ON LGD.intDispatchOrderId = TH.intDispatchOrderId