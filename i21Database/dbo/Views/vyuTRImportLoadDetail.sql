﻿CREATE VIEW [dbo].[vyuTRImportLoadDetail]
	AS 
SELECT ILD.[intImportLoadDetailId]
      ,IL.[intImportLoadId]
      ,ILD.[intTruckId]
      ,ILD.[strTruck]
      ,ILD.[intTerminalId]
      ,ILD.[strTerminal]
      ,ILD.[strBillOfLading]
      ,ILD.[intCarrierId]
      ,ILD.[strCarrier]
      ,ILD.[intDriverId]
      ,ILD.[strDriver]
      ,ILD.[intTrailerId]
      ,ILD.[strTrailer]
      ,ILD.[strSupplier]
      ,ILD.[intVendorId]
      ,ILD.[intSupplyPointId]
      ,ILD.[intVendorCompanyLocationId]
      ,ILD.[strDestination]
      ,ILD.[intCustomerId]
      ,ILD.[intShipToId]
      ,ILD.[intCustomerCompanyLocationId]
      ,ILD.[dtmPullDate]
      ,ILD.[intPullProductId]
      ,ILD.[strPullProduct]
      ,ILD.[intDropProductId]
      ,ILD.[strDropProduct]
      ,ILD.[dblDropGross]
      ,ILD.[dblDropNet]
      ,ILD.[dtmInvoiceDate]
      ,ILD.[dtmDropDate]
      ,ILD.[ysnValid]
      ,ILD.[strMessage]
      ,ILD.[strPONumber]
	,ILD.[intConcurrencyId]
	,IL.[strSource]
	,IL.[dtmImportDate]
	,ISNULL(ILD.[ysnProcess], 0) ysnProcess
	,IL.[intUserId]
	,EM.[strName] strUserName
      ,IL.guidImportIdentifier
FROM tblTRImportLoadDetail ILD
INNER JOIN tblTRImportLoad IL
	ON IL.intImportLoadId = ILD.intImportLoadId
INNER JOIN tblEMEntity EM
	ON EM.intEntityId = IL.intUserId
