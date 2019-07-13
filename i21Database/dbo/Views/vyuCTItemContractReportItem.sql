CREATE VIEW [dbo].[vyuCTItemContractReportItem]
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
			CONVERT(VARCHAR(10), A.dtmContractDate, 101) as dtmContractDate,
			CONVERT(VARCHAR(10), E.dtmLastDeliveryDate, 101) as dtmLineLastDeliveryDate,
			CONVERT(VARCHAR(10), E.dtmDeliveryDate, 101) as dtmLineDeliveryDate,
			UPPER(E.strItemNo) as strLineItemNo,
			UPPER(E.strItemDescription) as strLineItemDescription,
			UPPER(E.strUnitMeasure) as strLineUnitMeasure,
			UPPER(E.strTaxGroup) as strLineTaxGroup,
			UPPER(F.strSymbol) as strSymbol,
			E.*,
			UPPER(I.strTaxCode) as strLineTaxCode,
			UPPER(H.dblRate) as dblLineRate,
			(ISNULL(H.dblRate,0) * ISNULL(E.dblContracted,0))  as dblLineTotal

			FROM vyuCTItemContractHeader A 
					LEFT JOIN tblEMEntity B ON A.intEntityId = B.intEntityId
					LEFT JOIN tblEMEntityLocation C ON A.intEntityId = C.intEntityId
					LEFT JOIN tblARCustomer D ON A.intEntityId = D.intEntityId
					LEFT JOIN vyuCTItemContractDetail E ON A.intItemContractHeaderId = E.intItemContractHeaderId
					LEFT JOIN tblICUnitMeasure F ON E.intItemUOMId = F.intUnitMeasureId

					LEFT JOIN tblARInvoiceDetail G ON E.intItemContractHeaderId = G.intItemContractHeaderId and E.intItemContractDetailId = G.intItemContractDetailId
					LEFT JOIN tblARInvoiceDetailTax H ON G.intInvoiceDetailId = H.intInvoiceDetailId
					LEFT JOIN tblSMTaxCode I ON I.intTaxCodeId = H.intTaxCodeId

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
			AND A.strContractCategoryId = 'Item'

  GO