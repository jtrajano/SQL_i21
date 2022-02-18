CREATE VIEW [dbo].[vyuTRLoadReceiptInfo]
	AS 
SELECT LR.intLoadReceiptId
	, LR.intLoadHeaderId
	, LR.intTerminalId
	, TM.strName strTerminalName
	, TM.strVendorId strTerminalId
	, LR.intSupplyPointId
	, SP.strSupplyPoint strSupplyPoint
	, SP.intEntityLocationId 
	, SP.strGrossOrNet
	, LR.intCompanyLocationId
	, CL.strLocationName
	, LR.intItemId
	, I.strItemNo
	, LR.intContractDetailId
	, CD.strContractNumber
	, LR.intTaxGroupId
	, TG.strTaxGroup
	, dblFreight = CASE WHEN SP.strGrossOrNet = 'Gross' THEN LR.dblGross * LR.dblFreightRate ELSE LR.dblNet * LR.dblFreightRate END
	, LR.intLoadDetailId
	, LD.strLoadNumber
	, strZipCode = (CASE WHEN ISNULL(LR.intSupplyPointId, '') <> '' THEN ISNULL(SP.strZipCode, CL.strZipPostalCode) ELSE CL.strZipPostalCode END)
	, SP.strFreightSalesUnit
FROM tblTRLoadReceipt LR 
LEFT JOIN vyuTRTerminal TM ON TM.intEntityVendorId = LR.intTerminalId
LEFT JOIN vyuTRSupplyPointView SP ON SP.intSupplyPointId = LR.intSupplyPointId
LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = LR.intCompanyLocationId
LEFT JOIN tblICItem I ON I.intItemId = LR.intItemId
LEFT JOIN vyuCTContractDetailView CD ON CD.intContractDetailId = LR.intContractDetailId
LEFT JOIN tblSMTaxGroup TG ON TG.intTaxGroupId = LR.intTaxGroupId
LEFT JOIN vyuLGLoadDetailView LD ON LD.intLoadDetailId = LR.intLoadDetailId
