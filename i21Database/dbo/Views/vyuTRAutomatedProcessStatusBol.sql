CREATE VIEW [dbo].[vyuTRAutomatedProcessStatusBol]
AS
SELECT        
	  ILD.intImportLoadDetailId
	, IL.intImportLoadId
	, ILD.intTruckId
	, ILD.strTruck
	, ILD.intTerminalId
	, ILD.strTerminal
	, ILD.strBillOfLading
	, ILD.intCarrierId
	, ILD.strCarrier
	, ILD.intDriverId
	, ILD.strDriver
	, ILD.intTrailerId
	, ILD.strTrailer
	, ILD.strSupplier
	, ILD.intVendorId
	, ILD.intSupplyPointId
	, ILD.intVendorCompanyLocationId
	, ILD.strDestination
	, ILD.intCustomerId
	, ILD.intShipToId
	, ILD.intCustomerCompanyLocationId
	, ILD.dtmPullDate
	, ILD.intPullProductId
	, ILD.strPullProduct
	, ILD.intDropProductId
	, ILD.strDropProduct
	, ILD.dblDropGross
	, ILD.dblDropNet
	, ILD.dtmInvoiceDate
	, ILD.dtmDropDate
	, ILD.ysnValid
	, ILD.strMessage
	, ILD.strPONumber
	, ILD.intConcurrencyId
	, IL.strSource
	, IL.dtmImportDate
	, ILD.ysnProcess
	, IL.intUserId
	, EM.strName AS strUserName
	, IL.guidImportIdentifier
	, IL.strFileName
	, IL.strFileExtension
	, ILD.ysnDelete
	, ILD.intLoadHeaderId
	, TM.strName AS strVendorName
	, EL.strLocationName AS strSupplyPoint
	, IT.strItemNo

FROM            
	dbo.tblTRImportLoadDetail AS ILD 
	INNER JOIN dbo.tblTRImportLoad AS IL ON IL.intImportLoadId = ILD.intImportLoadId 
	INNER JOIN dbo.tblEMEntity AS EM ON EM.intEntityId = IL.intUserId
	LEFT JOIN tblTRLoadReceipt LR on ILD.intLoadReceiptId = LR.intLoadReceiptId
	LEFT JOIN vyuTRTerminal TM on TM.intEntityVendorId = LR.intTerminalId
	LEFT JOIN tblTRSupplyPoint SP on LR.intSupplyPointId = SP.intSupplyPointId
	LEFT JOIN tblEMEntityLocation EL on EL.intEntityLocationId = SP.intEntityLocationId
	LEFT JOIN tblICItem IT on ILD.intPullProductId = IT.intItemId