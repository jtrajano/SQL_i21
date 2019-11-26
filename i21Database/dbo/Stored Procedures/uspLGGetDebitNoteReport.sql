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
	,strWeightClaimNumber = WC.strReferenceNumber
	,strCompanyName = CS.strCompanyName
	,strCompanyAddress = CS.strAddress
	,strCompanyContactName = CS.strContactName 
	,strCompanyCounty = CS.strCounty 
	,strCompanyCity = CS.strCity
	,strCompanyState = CS.strState
	,strCompanyZip = CS.strZip
	,strCompanyCountry = CS.strCountry 
	,strCompanyPhone = CS.strPhone
	,strCityStateZip = CS.strCity + ', ' + CS.strState + ', ' + CS.strZip + ', '
	,L.intLoadId
	,L.strLoadNumber
	,E.intEntityId
	,strCustomerName = E.strName
	,EL.strAddress
	,EL.strZipCode
	,EL.strCity
	,EL.strState
	,EL.strCountry
	,strVendorAddress = E.strName + CHAR(13) + 
		EL.strAddress + CHAR(13) + 
		EL.strZipCode + ' ' + EL.strCity + CHAR(13) + 
		EL.strState + ' ' + EL.strCountry
	,B.strBillId
	,strShippingLine = 'via ' + ShippingLine.strName
	,L.strMVessel 
	,BA.strBankAccountNo
	,BA.strIBAN
	,BA.strSWIFT
	,BA.strBankName
	,B.strRemarks
	,dblTotalClaimAmount = ROUND(SUM(WCD.dblClaimAmount),2)
	,dblTotalOtherChargeAmount = ROUND((SELECT SUM(dblAmount) FROM tblLGWeightClaimOtherCharges OC WHERE OC.intWeightClaimId = WC.intWeightClaimId),2)
	,INV.strInvoiceNumber
	,strInvoiceComments = INV.strComments
	,strMemoType = CASE 
		 WHEN WCD.intBillId IS NOT NULL
	 		THEN 'Voucher'
		 WHEN WCD.intInvoiceId IS NOT NULL
	 		THEN 'Invoice'
		 END 
	,INV.strFooterComments
	,strVoucherBankInfo = CASE 
		WHEN WCD.intBillId IS NOT NULL
			THEN 'Net cash against Debit-Note by swift transfer to our account with' + CHAR(13) + 
			      BA.strBankName + CHAR(13) + 
				  'IBAN : ' + ISNULL(BA.strIBAN, '') + CHAR(13) + 
				  'Swift : ' + ISNULL(BA.strSWIFT, '')
		WHEN WCD.intInvoiceId IS NOT NULL
			THEN INV.strFooterComments
		END
	,PM.strPaymentMethod
	,strPaymentComment = PM.strComment
	,CL.strVatNo
	,blbFullHeaderLogo = dbo.fnSMGetCompanyLogo('FullHeaderLogo')
	,blbFullFooterLogo = dbo.fnSMGetCompanyLogo('FullFooterLogo')
	,blbHeaderLogo = dbo.fnSMGetCompanyLogo('Header')
	,blbFooterLogo = dbo.fnSMGetCompanyLogo('Footer')
	,ysnPrintLogo = CASE WHEN ISNULL(CP.ysnPrintLogo,0) = 1 THEN 'true' else 'false' END
	,ysnFullHeaderLogo = CASE WHEN CP.ysnFullHeaderLogo = 1 THEN 'true' else 'false' END	
	,intReportLogoHeight = ISNULL(CP.intReportLogoHeight,0)
	,intReportLogoWidth = ISNULL(CP.intReportLogoWidth,0)	
FROM tblLGWeightClaim WC
	JOIN tblLGWeightClaimDetail WCD ON WC.intWeightClaimId = WCD.intWeightClaimId
	JOIN tblEMEntity E ON E.intEntityId = WCD.intPartyEntityId
	JOIN tblLGLoad L ON L.intLoadId = WC.intLoadId
	OUTER APPLY (
		SELECT TOP 1 LOD.intPCompanyLocationId
			,LOD.intVendorEntityId
			,LOD.intVendorEntityLocationId
			,LOD.intLoadId
			,LOD.intCustomerEntityId
			,LOD.intCustomerEntityLocationId
		FROM tblLGLoadDetail LOD
		WHERE LOD.intLoadId = WC.intLoadId
		AND ISNULL(LOD.intVendorEntityId,LOD.intCustomerEntityId) = E.intEntityId) LD
	LEFT JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = ISNULL(ISNULL(LD.intVendorEntityLocationId,LD.intCustomerEntityLocationId), E.intDefaultLocationId)
	LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = WCD.intContractDetailId
	LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
	LEFT JOIN tblAPBill B ON B.intBillId = WCD.intBillId
	LEFT JOIN tblARInvoice INV ON INV.intInvoiceId = WCD.intInvoiceId
	LEFT JOIN vyuCMBankAccount BA ON BA.intBankAccountId = B.intBankInfoId
	LEFT JOIN tblEMEntity ShippingLine ON ShippingLine.intEntityId = L.intShippingLineEntityId
	LEFT JOIN tblSMPaymentMethod PM ON PM.intPaymentMethodID = WC.intPaymentMethodId
	CROSS APPLY tblSMCompanySetup CS
	CROSS APPLY tblLGCompanyPreference CP
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
	,CS.strCompanyName
	,CS.strAddress
	,CS.strContactName 
	,CS.strCounty 
	,CS.strCity
	,CS.strState
	,CS.strZip
	,CS.strCountry 
	,CS.strPhone
	,CP.ysnFullHeaderLogo
	,CP.intReportLogoHeight
	,CP.intReportLogoWidth
	,CP.ysnPrintLogo
	,PM.strPaymentMethod
	,PM.strComment
	,CL.strVatNo