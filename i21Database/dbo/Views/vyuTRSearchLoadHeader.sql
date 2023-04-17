CREATE VIEW vyuTRSearchLoadHeader

AS

SELECT LH.intLoadHeaderId
	, LH.intLoadId
	, strLoadSchedule = LG.strLoadNumber
	, LH.intDispatchOrderId
	, DS.strDispatchOrderNumber
	, LH.strTransaction
	, LH.dtmLoadDateTime
	, LH.intShipViaId
	, SV.strShipVia
	, LH.intSellerId
	, strSeller = SL.strShipVia
	, LH.intDriverId
	, strDriver = SP.strName
	, LH.intTruckId
	, SVT.strTruckNumber
	, LH.intTrailerId
	, SVR.strTrailerNumber
	, LH.ysnPosted
	, LH.ysnDiversion
	, LH.strDiversionNumber
	, LH.intStateId
	, strDiversionState = ST.strStateName
	, LH.strImportVerificationNumber
	, LH.strPurchaserSignedStatementNumber
	, LH.intFreightItemId
	, strFreightItem = IT.strItemNo
	, LH.intLongTruckLoadId
	, LH.intMobileLoadHeaderId
FROM tblTRLoadHeader LH
LEFT JOIN tblLGLoad LG ON LG.intLoadId = LH.intLoadId
LEFT JOIN tblLGDispatchOrder DS ON DS.intDispatchOrderId = LH.intDispatchOrderId
LEFT JOIN tblSMShipVia SV ON SV.intEntityId = LH.intShipViaId
LEFT JOIN tblSMShipVia SL ON SL.intEntityId = LH.intSellerId
LEFT JOIN tblICItem IT ON IT.intItemId = LH.intFreightItemId
LEFT JOIN tblEMEntity SP ON SP.intEntityId = LH.intDriverId
LEFT JOIN tblSMShipViaTruck SVT ON SVT.intEntityShipViaTruckId = LH.intTruckId
LEFT JOIN tblSMShipViaTrailer SVR ON SVR.intEntityShipViaTrailerId = LH.intTrailerId
LEFT JOIN tblTRState ST ON ST.intStateId = LH.intStateId