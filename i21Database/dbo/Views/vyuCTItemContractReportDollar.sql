CREATE VIEW [dbo].[vyuCTItemContractReportDollar]
	AS 
	
	SELECT	UPPER(tblSMCompanySetup.strCompanyName) as strCompanyName,
			UPPER(tblSMCompanySetup.strCompanyAddress) as strCompanyAddress,
			UPPER(tblSMCompanySetup.strCompanyStateAddress) as strCompanyStateAddress,
			UPPER(tblSMCompanySetup.strCompanyCity) as strCompanyCity,
			UPPER(tblSMCompanySetup.strCompanyState) as strCompanyState,
			UPPER(tblSMCompanySetup.strCompanyZip) as strCompanyZip,
			UPPER(B.strName) as strCustomerName,
			UPPER(C.strAddress) as strCustomerAddress,
			UPPER(C.strCity + ' ' + C.strState + ' ' +C.strZipCode) as strCustomerStateAddress,
			UPPER(C.strCity) as strCustomerCity,
			UPPER(C.strState) as strCustomerState,
			UPPER(C.strZipCode) as strCustomerZipCode,
			UPPER(A.strContractNumber) as strContractNumber,			
			UPPER(A.strLocationName) as strLocationName,			
			UPPER(B.strEntityNo) as strEntityNo,
			CONVERT(VARCHAR(10), A.dtmContractDate, 101) COLLATE Latin1_General_CI_AS as dtmContractDate,
			CONVERT(VARCHAR(10), A.dtmContractDate, 101) COLLATE Latin1_General_CI_AS as dtmLineShipDate,
			CONVERT(VARCHAR(10), A.dtmExpirationDate, 101) COLLATE Latin1_General_CI_AS as dtmLineDueDate,
			UPPER(E.strCategoryCode + ' CATEGORY') as strLineCategoryCode,
			CAST(ROUND(F.dblTotal,2) as NUMERIC(36,2)) as dblLineTotal,
			E.* 
			FROM vyuCTItemContractHeader A 
					LEFT JOIN tblEMEntity B ON A.intEntityId = B.intEntityId
					LEFT JOIN tblEMEntityLocation C ON A.intEntityId = C.intEntityId
					LEFT JOIN tblARCustomer D ON A.intEntityId = D.intEntityId
					LEFT JOIN vyuCTItemContractHeaderCategory E ON A.intItemContractHeaderId = E.intItemContractHeaderId
					LEFT JOIN tblARInvoiceDetail F ON E.intItemContractHeaderId = F.intItemContractHeaderId and E.intItemCategoryId = F.intItemCategoryId
			,(SELECT TOP 1
					strCompanyName
					,strAddress AS strCompanyAddress
					,strCity + ' ' + strState + ' ' + strZip AS strCompanyStateAddress
					,strCity AS strCompanyCity
					,strState AS strCompanyState
					,strZip AS strCompanyZip
				FROM tblSMCompanySetup
			) tblSMCompanySetup
		WHERE C.intEntityLocationId = CASE
										WHEN D.intShipToId IS NOT NULL
											THEN D.intShipToId
										WHEN C.ysnDefaultLocation = 1
											THEN C.intEntityLocationId
										ELSE 0
									END
			AND A.strContractCategoryId = 'Dollar'

  GO