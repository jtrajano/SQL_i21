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
    
	SELECT Top(1)
		Inv.intInvoiceId,
		Inv.dtmDate,
		Inv.dtmDueDate,
		Inv.strInvoiceNumber,
		strCustomer = EN.strEntityName,
		Inv.strBillToAddress,
		Inv.strBillToCity,
		Inv.strBillToState,
		Inv.strBillToZipCode,
		Inv.strBillToCountry,
		Inv.strShipToAddress,
		Inv.strShipToCity,
		Inv.strShipToCountry,
		Inv.strShipToState,
		Inv.strShipToZipCode,
		Inv.strShipToLocationName,
		Inv.strComments,
		Inv.strFooterComments,
		Inv.strTransactionType,
		Inv.strType,
		strInvoiceCurrency = InvCur.strCurrency,
		Term.strTerm,
		strCompanyName = Comp.strLocationName,
		L.strLoadNumber,
		L.dtmScheduledDate,
		L.dtmDeliveredDate,
		CB.strContractBasis,
		C.strFLOId,
		Inv.dblInvoiceTotal,
		Inv.strTransactionType,
		L.strBLNumber,
		L.dtmBLDate,
		L.strOriginPort,
		L.strDestinationPort,
		L.strShippingMode,
		L.strMVessel,
		L.dtmETAPOD,
		L.intNumberOfContainers,
		ShippingLine.strName AS strShippingLineName,
		CASE WHEN L.intPurchaseSale = 2 THEN 'OUTBOUND' WHEN L.intPurchaseSale = 3 THEN 'DROP SHIP' END AS strShipmentType
	FROM tblARInvoice Inv
	JOIN vyuCTEntity EN ON EN.intEntityId = Inv.intEntityCustomerId
	JOIN tblARCustomer C ON C.intEntityId = Inv.intEntityCustomerId
	JOIN tblSMCurrency InvCur ON InvCur.intCurrencyID = Inv.intCurrencyId
	JOIN tblSMTerm Term ON Term.intTermID = Inv.intTermId
	JOIN tblSMCompanyLocation Comp ON Comp.intCompanyLocationId = Inv.intCompanyLocationId
	LEFT JOIN tblLGLoad L ON L.intLoadId = Inv.intLoadId
	LEFT JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
	LEFT JOIN tblCTContractDetail CD on CD.intContractDetailId = LD.intSContractDetailId
	LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	LEFT JOIN tblCTContractBasis CB ON CB.intContractBasisId = CH.intContractBasisId
	LEFT JOIN tblEMEntity ShippingLine ON ShippingLine.intEntityId = L.intShippingLineEntityId
	WHERE Inv.intInvoiceId = @intInvoiceId
END