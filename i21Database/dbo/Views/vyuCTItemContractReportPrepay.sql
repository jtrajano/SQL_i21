CREATE VIEW [dbo].[vyuCTItemContractReportPrepay]
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
			UPPER(A.strLocationName) as strLocationName,			
			UPPER(B.strEntityNo) as strEntityNo,
			CONVERT(VARCHAR(10), A.dtmContractDate, 101) COLLATE Latin1_General_CI_AS as dtmContractDate,
			CONVERT(VARCHAR(10), E.dtmLastDeliveryDate, 101) COLLATE Latin1_General_CI_AS as dtmLineLastDeliveryDate,
			CONVERT(VARCHAR(10), E.dtmDeliveryDate, 101) COLLATE Latin1_General_CI_AS as dtmLineDeliveryDate,
			UPPER(E.strItemNo) as strLineItemNo,
			UPPER(E.strItemDescription) as strLineItemDescription,
			UPPER(E.strUnitMeasure) as strLineUnitMeasure,
			UPPER(E.strTaxGroup) as strLineTaxGroup,
			UPPER(G.strSymbol) as strSymbol,
			E.* 
			FROM vyuCTItemContractHeader A 
					LEFT JOIN tblEMEntity B ON B.intEntityId = A.intEntityId
					LEFT JOIN tblEMEntityLocation C ON C.intEntityId = A.intEntityId
					LEFT JOIN tblARCustomer D ON D.intEntityId = A.intEntityId
					LEFT JOIN vyuCTItemContractDetail E ON E.intItemContractHeaderId = A.intItemContractHeaderId
					LEFT JOIN tblICItemUOM	F ON F.intItemUOMId = E.intItemUOMId
					LEFT JOIN tblICUnitMeasure G ON G.intUnitMeasureId = F.intUnitMeasureId
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

  GO