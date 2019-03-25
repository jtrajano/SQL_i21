CREATE PROCEDURE [dbo].[uspLGGetSalesInvoiceHeaderReport]
		@xmlParam NVARCHAR(MAX) = NULL  
AS
BEGIN
	DECLARE @intInvoiceId		INT,
			@xmlDocumentId		INT 

	IF	LTRIM(RTRIM(@xmlParam)) = ''   
		SET @xmlParam = NULL   
      
	DECLARE @temp_xml_table TABLE 
	(  
			[fieldname]		NVARCHAR(50),  
			condition		NVARCHAR(20),        
			[from]			NVARCHAR(50), 
			[to]			NVARCHAR(50),  
			[join]			NVARCHAR(10),  
			[begingroup]	NVARCHAR(50),  
			[endgroup]		NVARCHAR(50),  
			[datatype]		NVARCHAR(50) 
	)
  	DECLARE @strDocumentNumber NVARCHAR(100)
	DECLARE @ysnDisplayPIInfo BIT = 0
	DECLARE @strReportName NVARCHAR(100)	  
  
	EXEC sp_xml_preparedocument @xmlDocumentId output, @xmlParam  
  
	INSERT INTO @temp_xml_table  
	SELECT	*  
	FROM	OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2)  
	WITH (  
				[fieldname]		NVARCHAR(50),  
				condition		NVARCHAR(20),        
				[from]			NVARCHAR(50), 
				[to]			NVARCHAR(50),  
				[join]			NVARCHAR(10),  
				[begingroup]	NVARCHAR(50),  
				[endgroup]		NVARCHAR(50),  
				[datatype]		NVARCHAR(50)  
	)  
    
	SELECT	@intInvoiceId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intInvoiceId' 
 
 	SELECT @strDocumentNumber = strDocumentNumber
	FROM tblARInvoiceDetail
	WHERE intInvoiceId = @intInvoiceId

	SELECT @strReportName = CASE 
			WHEN strType = 'Provisional'
				THEN 'Provisional Invoice'
			ELSE CASE 
					WHEN strType = 'Standard'
						THEN strTransactionType
					END
			END
	FROM tblARInvoice I
	JOIN tblARInvoiceDetail ID ON I.intInvoiceId = ID.intInvoiceId
	WHERE I.intInvoiceId = @intInvoiceId

	IF EXISTS (
			SELECT TOP 1 1
			FROM tblARInvoice Inv
			JOIN tblARInvoiceDetail InvDet ON Inv.intInvoiceId = InvDet.intInvoiceId
			WHERE Inv.strType = 'Provisional'
				AND Inv.strInvoiceNumber = @strDocumentNumber
			)
	BEGIN
		SET @ysnDisplayPIInfo = 1
	END
    
	SELECT Top(1)
		intInvoiceId = Inv.intInvoiceId,
		dtmDate = Inv.dtmDate,
		dtmDueDate = Inv.dtmDueDate,
		strInvoiceNumber = Inv.strInvoiceNumber,
		strCustomer = EN.strEntityName,
		strBillToAddress = Inv.strBillToAddress,
		strBillToCity = Inv.strBillToCity,
		strBillToState = Inv.strBillToState,
		strBillToZipCode = Inv.strBillToZipCode,
		strBillToCountry = Inv.strBillToCountry,
		strShipToAddress = Inv.strShipToAddress,
		strShipToCity = Inv.strShipToCity,
		strShipToCountry = Inv.strShipToCountry,
		strShipToState = Inv.strShipToState,
		strShipToZipCode = Inv.strShipToZipCode,
		strShipToLocationName = Inv.strShipToLocationName,
		strComments = Inv.strComments,
		strFooterComments = Inv.strFooterComments,
		strTransactionType = Inv.strTransactionType,
		strType = Inv.strType,
		strInvoiceCurrency = InvCur.strCurrency,
		strTerm = Term.strTerm,
		strCompanyName = Comp.strLocationName,
		strLoadNumber = L.strLoadNumber,
		dtmScheduledDate = L.dtmScheduledDate,
		dtmDeliveredDate = L.dtmDeliveredDate,
		strContractBasis = CB.strContractBasis,
		strFLOId = C.strFLOId,
		dblInvoiceTotal = CASE WHEN strTransactionType = 'Credit Memo' THEN ABS(Inv.dblInvoiceTotal - ISNULL(Inv.dblProvisionalAmount,0)) ELSE Inv.dblInvoiceTotal END,
		strTransactionType = Inv.strTransactionType,
		strBLNumber = CASE WHEN (ISNULL(IR.strBillOfLading, '') <> '') THEN IR.strBillOfLading ELSE L.strBLNumber END,
		dtmBLDate = L.dtmBLDate,
		strOriginPort = L.strOriginPort,
		strDestinationPort = L.strDestinationPort,
		strShippingMode = L.strShippingMode,
		strMVessel = L.strMVessel,
		dtmETAPOD = L.dtmETAPOD,
		intNumberOfContainers = L.intNumberOfContainers,
		strShippingLineName = ShippingLine.strName,
		ysnDisplayPIInfo = CASE WHEN @ysnDisplayPIInfo = 0 THEN 'False' ELSE 'True' END,
		strShipmentType = CASE WHEN L.intPurchaseSale = 2 THEN 'OUTBOUND' WHEN L.intPurchaseSale = 3 THEN 'DROP SHIP' END,
		strReportName = @strReportName,
		dbo.fnSMGetCompanyLogo('Header') AS blbHeaderLogo,
		dbo.fnSMGetCompanyLogo('Footer') AS blbFooterLogo,
		intReportLogoHeight = ISNULL(CP.intReportLogoHeight,0),
		intReportLogoWidth = ISNULL(CP.intReportLogoWidth,0),
		strOurVATNo = '',
		strYourVATNo = C.strVatNumber,
		strOurRef = CH.strContractNumber + '/' + CAST(CD.intContractSeq AS NVARCHAR(10)),
		strBuyerRef = PCH.strCustomerContract,
		strBrokerReferenceNo = '',
		strRemarks = '',
		strICTDesc = ICT.strICTDesc,
		strInvoiceText = CP.strInvoiceText,
		strCarrier = (SELECT TOP 1 E.strName FROM tblLGLoadWarehouse LW JOIN tblEMEntity E ON E.intEntityId = LW.intHaulerEntityId WHERE LW.intLoadId = L.intLoadId)
	FROM tblARInvoice Inv
	JOIN vyuCTEntity EN ON EN.intEntityId = Inv.intEntityCustomerId
	JOIN tblARCustomer C ON C.intEntityId = Inv.intEntityCustomerId
	JOIN tblSMCurrency InvCur ON InvCur.intCurrencyID = Inv.intCurrencyId
	JOIN tblSMTerm Term ON Term.intTermID = Inv.intTermId
	JOIN tblSMCompanyLocation Comp ON Comp.intCompanyLocationId = Inv.intCompanyLocationId
	JOIN tblARInvoiceDetail InvDet ON InvDet.intInvoiceId = Inv.intInvoiceId
	LEFT JOIN tblARICT ICT ON ICT.intICTId = Inv.intICTId
	LEFT JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = InvDet.intLoadDetailId
	LEFT JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
	LEFT JOIN tblCTContractDetail CD on CD.intContractDetailId = LD.intSContractDetailId
	LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	LEFT JOIN tblSMFreightTerms CB ON CB.intFreightTermId = CH.intFreightTermId
	LEFT JOIN tblCTContractDetail PCD ON PCD.intContractDetailId = InvDet.intContractDetailId 
	LEFT JOIN tblCTContractHeader PCH ON PCH.intContractHeaderId = PCD.intContractHeaderId 
	LEFT JOIN tblEMEntity ShippingLine ON ShippingLine.intEntityId = L.intShippingLineEntityId
	CROSS APPLY tblLGCompanyPreference CP
	OUTER APPLY (SELECT TOP 1 IR.strBillOfLading 
					FROM tblARInvoiceDetailLot IDL 
					JOIN tblICInventoryReceiptItemLot IRIL ON IDL.intLotId = IRIL.intLotId AND IDL.intInvoiceDetailId = InvDet.intInvoiceDetailId
					JOIN tblICInventoryReceiptItem IRI ON IRI.intInventoryReceiptItemId = IRIL.intInventoryReceiptItemId 
					JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId) IR
	WHERE Inv.intInvoiceId = @intInvoiceId
END