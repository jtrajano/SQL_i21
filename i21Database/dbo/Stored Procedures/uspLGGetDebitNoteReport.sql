CREATE PROCEDURE uspLGGetDebitNoteReport 
	@xmlParam NVARCHAR(MAX) = NULL
AS
DECLARE @intWeightClaimId INT
DECLARE @xmlDocumentId INT
DECLARE @strUserName NVARCHAR(100)
DECLARE @intLoadId INT

IF LTRIM(RTRIM(@xmlParam)) = ''
	SET @xmlParam = NULL

DECLARE @temp_xml_table TABLE (
	[fieldname] NVARCHAR(50)
	,condition NVARCHAR(20)
	,[from] NVARCHAR(50)
	,[to] NVARCHAR(50)
	,[join] NVARCHAR(10)
	,[begingroup] NVARCHAR(50)
	,[endgroup] NVARCHAR(50)
	,[datatype] NVARCHAR(50)
	)

EXEC sp_xml_preparedocument @xmlDocumentId OUTPUT
	,@xmlParam

INSERT INTO @temp_xml_table
SELECT *
FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2) WITH (
		[fieldname] NVARCHAR(50)
		,condition NVARCHAR(20)
		,[from] NVARCHAR(50)
		,[to] NVARCHAR(50)
		,[join] NVARCHAR(10)
		,[begingroup] NVARCHAR(50)
		,[endgroup] NVARCHAR(50)
		,[datatype] NVARCHAR(50)
		)

SELECT @intWeightClaimId = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'intWeightClaimId'

SELECT @intLoadId = intLoadId
FROM tblLGWeightClaim
WHERE intWeightClaimId = @intWeightClaimId

SELECT DISTINCT WC.intWeightClaimId
	,WC.intLoadId
	,WC.strReferenceNumber AS strWeightClaimNumber
	,L.intLoadId
	,L.strLoadNumber
	,E.intEntityId
	,E.strName AS strCustomerName
	,EL.strAddress
	,EL.strZipCode
	,EL.strCity
	,EL.strState
	,EL.strCountry
	,E.strName + CHAR(13) + 
	 EL.strAddress + CHAR(13) + 
	 EL.strZipCode + ' ' + EL.strCity + CHAR(13) + 
	 EL.strState + ' ' + EL.strCountry AS strVendorAddress
	,B.strBillId
	,'via ' + ShippingLine.strName AS strShippingLine
	,L.strMVessel 
	,BA.strBankAccountNo
	,BA.strIBAN
	,BA.strSWIFT
	,BA.strBankName
	,B.strRemarks
	,ROUND(SUM(WCD.dblClaimAmount),2) dblTotalClaimAmount
	,INV.strInvoiceNumber
	,INV.strComments AS strInvoiceComments
	,CASE 
	 WHEN WCD.intBillId IS NOT NULL
	 	THEN 'Voucher'
	 WHEN WCD.intInvoiceId IS NOT NULL
	 	THEN 'Invoice'
	 END strMemoType
	,INV.strFooterComments
	,CASE 
		WHEN WCD.intBillId IS NOT NULL
			THEN 'Net cash against Debit-Note by swift transfer to our account with' + CHAR(13) + 
			      BA.strBankName + CHAR(13) + 
				  'IBAN : ' + ISNULL(BA.strIBAN, '') + CHAR(13) + 
				  'Swift : ' + ISNULL(BA.strSWIFT, '')
		WHEN WCD.intInvoiceId IS NOT NULL
			THEN INV.strFooterComments
		END AS strVoucherBankInfo
FROM tblLGWeightClaim WC
JOIN tblLGWeightClaimDetail WCD ON WC.intWeightClaimId = WCD.intWeightClaimId
JOIN tblEMEntity E ON E.intEntityId = WCD.intPartyEntityId
JOIN tblLGLoad L ON L.intLoadId = WC.intLoadId
JOIN (
	SELECT TOP 1 LOD.intPCompanyLocationId
		,LOD.intVendorEntityId
		,LOD.intVendorEntityLocationId
		,LOD.intLoadId
		,LOD.intCustomerEntityId
		,LOD.intCustomerEntityLocationId
	FROM tblLGLoadDetail LOD
	WHERE LOD.intLoadId = @intLoadId
	) LD ON ISNULL(LD.intVendorEntityId,LD.intCustomerEntityId) = E.intEntityId
LEFT JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = ISNULL(ISNULL(LD.intVendorEntityLocationId,LD.intCustomerEntityLocationId), E.intDefaultLocationId)
LEFT JOIN tblAPBill B ON B.intBillId = WCD.intBillId
LEFT JOIN tblARInvoice INV ON INV.intInvoiceId = WCD.intInvoiceId
LEFT JOIN vyuCMBankAccount BA ON BA.intBankAccountId = B.intBankInfoId
LEFT JOIN tblEMEntity ShippingLine ON ShippingLine.intEntityId = L.intShippingLineEntityId
WHERE WC.intWeightClaimId = @intWeightClaimId
GROUP BY
WC.intWeightClaimId
	,WC.intLoadId
	,WC.strReferenceNumber
	,L.intLoadId
	,L.strLoadNumber
	,E.intEntityId
	,E.strName 
	,EL.strAddress
	,EL.strZipCode
	,EL.strCity
	,EL.strState
	,EL.strCountry
	,B.strBillId
	,ShippingLine.strName
	,L.strMVessel 
	,BA.strBankAccountNo
	,BA.strSWIFT
	,BA.strIBAN
	,BA.strBankName
	,B.strRemarks
	,INV.strInvoiceNumber
	,INV.strComments 
	,WCD.intBillId
	,WCD.intInvoiceId
	,INV.strFooterComments