﻿CREATE PROCEDURE uspLGGetSalesInvoiceReport 
	@xmlParam NVARCHAR(MAX) = NULL
AS
BEGIN
	DECLARE @intInvoiceId INT
		,@xmlDocumentId INT
		,@strContractDocuments NVARCHAR(MAX)
		,@strContractConditions NVARCHAR(MAX)
	DECLARE @strCompanyName NVARCHAR(100)
		,@strCompanyAddress NVARCHAR(100)
		,@strContactName NVARCHAR(50)
		,@strCounty NVARCHAR(25)
		,@strCity NVARCHAR(25)
		,@strState NVARCHAR(50)
		,@strZip NVARCHAR(12)
		,@strCountry NVARCHAR(25)
		,@strPhone NVARCHAR(50)
		,@intLaguageId INT

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

	SELECT @intInvoiceId = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intInvoiceId'  
	
	SELECT	@intLaguageId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intLaguageId' 

	SELECT @strContractDocuments = STUFF((
				SELECT CHAR(13) + CHAR(10) + DM.strDocumentName
				FROM tblCTContractDocument CD
				JOIN tblICDocument DM ON DM.intDocumentId = CD.intDocumentId
				WHERE CD.intContractHeaderId = CH.intContractHeaderId
				ORDER BY DM.strDocumentName
				FOR XML PATH('')
					,TYPE
				).value('.', 'varchar(max)'), 1, 2, '')
	FROM tblARInvoiceDetail InvDet
	LEFT JOIN tblCTContractDetail COD ON COD.intContractDetailId = InvDet.intContractDetailId
	LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = COD.intContractHeaderId
	WHERE InvDet.intInvoiceId = @intInvoiceId

	SELECT @strContractConditions = STUFF((
				SELECT CHAR(13) + CHAR(10) + DM.strConditionDesc
				FROM tblCTContractCondition CD
				JOIN tblCTCondition DM ON DM.intConditionId = CD.intConditionId
				WHERE CD.intContractHeaderId = CH.intContractHeaderId
				ORDER BY DM.strConditionName
				FOR XML PATH('')
					,TYPE
				).value('.', 'varchar(max)'), 1, 2, '')
	FROM tblARInvoiceDetail InvDet
	LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = InvDet.intContractDetailId
	LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	WHERE InvDet.intInvoiceId = @intInvoiceId

	SELECT TOP 1 @strCompanyName = tblSMCompanySetup.strCompanyName
		,@strCompanyAddress = tblSMCompanySetup.strAddress
		,@strContactName = tblSMCompanySetup.strContactName
		,@strCounty = tblSMCompanySetup.strCounty
		,@strCity = tblSMCompanySetup.strCity
		,@strState = tblSMCompanySetup.strState
		,@strZip = tblSMCompanySetup.strZip
		,@strCountry = isnull(rtrt9.strTranslation, tblSMCompanySetup.strCountry)
		,@strPhone = tblSMCompanySetup.strPhone
	FROM tblSMCompanySetup
	LEFT JOIN tblSMCountry rtc9 ON lower(rtrim(ltrim(rtc9.strCountry))) = lower(rtrim(ltrim(tblSMCompanySetup.strCountry)))
	LEFT JOIN tblSMScreen rts9 ON rts9.strNamespace = 'i21.view.Country'
	LEFT JOIN tblSMTransaction rtt9 ON rtt9.intScreenId = rts9.intScreenId
		AND rtt9.intRecordId = rtc9.intCountryID
	LEFT JOIN tblSMReportTranslation rtrt9 ON rtrt9.intLanguageId = @intLaguageId
		AND rtrt9.intTransactionId = rtt9.intTransactionId
		AND rtrt9.strFieldName = 'Country'

	SELECT Inv.intInvoiceId
		,intSerialNo = ROW_NUMBER() OVER (
			ORDER BY InvDet.intInvoiceDetailId
			)
		,Inv.strInvoiceNumber
		,strCustomer = EN.strName
		,Inv.strBillToAddress
		,Inv.strBillToCity
		,Inv.strBillToState
		,Inv.strBillToZipCode
		,Inv.strBillToCity + ', ' + Inv.strBillToState + ', ' + Inv.strBillToZipCode AS strCityStateZip
		,Inv.strBillToCountry
		,Inv.strComments
		,Inv.strFooterComments
		,Inv.strTransactionType
		,Inv.strType
		,Item.strItemNo
		,InvDet.strItemDescription
		,InvDet.dblPrice
		,strPrice2Decimals = LTRIM(CAST(ROUND(InvDet.dblPrice, 2) AS NUMERIC(18, 2)))
		,strPrice4Decimals = LTRIM(CAST(ROUND(InvDet.dblPrice, 4) AS NUMERIC(18, 4)))
		,InvDet.dblQtyShipped
		,InvDet.dblShipmentGrossWt
		,InvDet.dblShipmentTareWt
		,InvDet.dblShipmentNetWt
		,dbo.fnSMGetCompanyLogo('Header') AS blbHeaderLogo
		,dbo.fnSMGetCompanyLogo('Footer') AS blbFooterLogo
		,@strCompanyName AS strCompanyName
		,@strCompanyAddress AS strCompanyAddress
		,@strContactName AS strCompanyContactName
		,@strCounty AS strCompanyCounty
		,@strCity AS strCompanyCity
		,@strState AS strCompanyState
		,@strZip AS strCompanyZip
		,@strCountry AS strCompanyCountry
		,@strPhone AS strCompanyPhone
		,LTRIM(dbo.fnRemoveTrailingZeroes(ROUND(InvDet.dblShipmentGrossWt, 2))) + '' + WUOM.strUnitMeasure + CHAR(13) + LTRIM(dbo.fnRemoveTrailingZeroes(ROUND(InvDet.dblShipmentTareWt, 2))) + '' + WUOM.strUnitMeasure + CHAR(13) + LTRIM(dbo.fnRemoveTrailingZeroes(ROUND(InvDet.dblShipmentNetWt, 2))) + '' + WUOM.strUnitMeasure AS strWtInfo
		,LTRIM(CAST(ROUND(InvDet.dblPrice, 2) AS NUMERIC(18, 2))) + ' ' + PriceCur.strCurrency + ' per ' + PriceUOM.strUnitMeasure AS strPriceInfo
		,InvDet.dblTotal
		,LTRIM(dbo.fnRemoveTrailingZeroes(ROUND(InvDet.dblQtyShipped, 2))) + ' ' + SUOM.strUnitMeasure AS strQtyShippedInfo
		,strInvoiceCurrency = InvCur.strCurrency
		,strPriceCurrency = PriceCur.strCurrency
		,strPriceUOM = PriceUOM.strUnitMeasure
		,strWeightUOM = WtUOM.strUnitMeasure
		,CH.strCustomerContract
		,CH.strContractNumber
		,CD.intContractSeq
		,Cont.strContainerNumber
		,Cont.strMarks
		,Inv.dblInvoiceSubtotal
		,Inv.dblTax
		,Inv.dblInvoiceTotal
		,strTaxDescription = TaxG.strDescription
		,intLineCount = 1
		,FT.strFreightTerm
		,L.strMVessel
		,L.strBLNumber
		,L.dtmBLDate
		,@strContractDocuments strDocument
		,@strContractConditions strCondition
		,Inv.dtmDate AS dtmInvoiceDate
	FROM tblARInvoice Inv
	JOIN tblEMEntity EN ON EN.intEntityId = Inv.intEntityCustomerId
	JOIN tblARInvoiceDetail InvDet ON InvDet.intInvoiceId = Inv.intInvoiceId
	JOIN tblICItem Item ON Item.intItemId = InvDet.intItemId
	JOIN tblSMCurrency InvCur ON InvCur.intCurrencyID = Inv.intCurrencyId
	LEFT JOIN tblSMTaxGroup TaxG ON TaxG.intTaxGroupId = InvDet.intTaxGroupId
	LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = InvDet.intContractDetailId
	LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	LEFT JOIN tblSMCurrency PriceCur ON PriceCur.intCurrencyID = CD.intCurrencyId
	LEFT JOIN tblICItemUOM SIM ON SIM.intItemUOMId = InvDet.intItemUOMId
	LEFT JOIN tblICUnitMeasure SUOM ON SUOM.intUnitMeasureId = SIM.intUnitMeasureId
	LEFT JOIN tblICItemUOM WIM ON WIM.intItemUOMId = InvDet.intItemWeightUOMId
	LEFT JOIN tblICUnitMeasure WUOM ON WUOM.intUnitMeasureId = WIM.intUnitMeasureId
	LEFT JOIN tblICItemUOM PriceItemUOM ON PriceItemUOM.intItemUOMId = CD.intPriceItemUOMId
	LEFT JOIN tblICUnitMeasure PriceUOM ON PriceUOM.intUnitMeasureId = PriceItemUOM.intUnitMeasureId
	LEFT JOIN tblICItemUOM WtItemUOM ON WtItemUOM.intItemUOMId = InvDet.intItemWeightUOMId
	LEFT JOIN tblICUnitMeasure WtUOM ON WtUOM.intUnitMeasureId = WtItemUOM.intUnitMeasureId
	LEFT JOIN tblLGLoad L ON L.intLoadId = Inv.intLoadId
	LEFT JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
		AND LD.intLoadDetailId = InvDet.intLoadDetailId
	LEFT JOIN tblLGLoadDetailLot LDL ON LDL.intLoadDetailId = LD.intLoadDetailId
	LEFT JOIN tblICLot Lot ON Lot.intLotId = LDL.intLotId
	LEFT JOIN tblICInventoryReceiptItemLot ReceiptLot ON ReceiptLot.intParentLotId = Lot.intParentLotId
	LEFT JOIN tblICInventoryReceiptItem ReceiptItem ON ReceiptItem.intInventoryReceiptItemId = ReceiptLot.intInventoryReceiptItemId
	LEFT JOIN tblLGLoadDetailContainerLink LDCLink ON LDCLink.intLoadDetailId = ISNULL(LD.intLoadDetailId, ReceiptItem.intSourceId) --AND LDCLink.intLoadContainerId = ReceiptItem.intContainerId
	LEFT JOIN tblLGLoadContainer Cont ON Cont.intLoadContainerId = LDCLink.intLoadContainerId
	LEFT JOIN tblSMFreightTerms FT ON FT.intFreightTermId = Inv.intFreightTermId
	WHERE Inv.intInvoiceId = @intInvoiceId
END