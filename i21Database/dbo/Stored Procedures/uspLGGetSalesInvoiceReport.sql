CREATE PROCEDURE uspLGGetSalesInvoiceReport 
	@xmlParam NVARCHAR(MAX) = NULL
AS
BEGIN
	DECLARE @intInvoiceId INT
		,@xmlDocumentId INT
		,@strContractDocuments NVARCHAR(MAX)
		,@strContractConditions NVARCHAR(MAX)
		,@strFreightConditions NVARCHAR(MAX)
		,@strFreightDescConditions NVARCHAR(MAX)
		,@strCompanyName NVARCHAR(100)
		,@strCompanyAddress NVARCHAR(100)
		,@strContactName NVARCHAR(50)
		,@strCounty NVARCHAR(25)
		,@strCity NVARCHAR(25)
		,@strState NVARCHAR(50)
		,@strZip NVARCHAR(12)
		,@strPaymentInfo NVARCHAR(MAX)
		,@strCountry NVARCHAR(25)
		,@strPhone NVARCHAR(50)
		,@intLaguageId			INT
		,@strExpressionLabelName	NVARCHAR(50) = 'Expression'
		,@strMonthLabelName		NVARCHAR(50) = 'Month'

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

	INSERT INTO @temp_xml_table
	SELECT	*  
	FROM	OPENXML(@xmlDocumentId, 'xmlparam/dummies/filter', 2)  
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

	SELECT @intInvoiceId = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intInvoiceId'  

	SELECT @intLaguageId = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intSrLanguageId'

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
	JOIN tblCTContractDetail COD ON COD.intContractDetailId = InvDet.intContractDetailId
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = COD.intContractHeaderId
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
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = InvDet.intContractDetailId
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	WHERE InvDet.intInvoiceId = @intInvoiceId

	SELECT @strFreightConditions = RTRIM(LTRIM(ISNULL(FT.strContractBasis, '') + ' ' + COALESCE(CT.strCity, CLSL.strSubLocationName, CN.strCountry, '') + ' ' + ISNULL(WG.strWeightGradeDesc, '')))
		,@strFreightDescConditions = RTRIM(LTRIM(ISNULL(FT.strDescription, '') + ' ' + ISNULL(CT.strCity, '') + ' ' + ISNULL(WG.strWeightGradeDesc, '')))
	FROM tblARInvoiceDetail InvDet
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = InvDet.intContractDetailId
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	LEFT JOIN tblSMFreightTerms FT ON CH.intFreightTermId = FT.intFreightTermId
	LEFT JOIN tblSMCity CT ON CT.intCityId = CH.intINCOLocationTypeId
	LEFT JOIN tblSMCountry CN ON CN.intCountryID = CH.intCountryId
	LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = CH.intWarehouseId AND FT.strINCOLocationType <> 'City'
	LEFT JOIN tblCTWeightGrade WG ON WG.intWeightGradeId = CH.intWeightId
	WHERE InvDet.intInvoiceId = @intInvoiceId

	SELECT TOP 1 @strCompanyName = tblSMCompanySetup.strCompanyName
		,@strCompanyAddress = tblSMCompanySetup.strAddress
		,@strContactName = tblSMCompanySetup.strContactName
		,@strCounty = ISNULL(tblSMCompanySetup.strCounty, '')
		,@strCity = ISNULL(tblSMCompanySetup.strCity, '')
		,@strState = ISNULL(tblSMCompanySetup.strState, '')
		,@strZip = ISNULL(tblSMCompanySetup.strZip, '')
		,@strCountry = isnull(rtCompanyTranslation.strTranslation, tblSMCompanySetup.strCountry)
		,@strPhone = tblSMCompanySetup.strPhone
	FROM tblSMCompanySetup
	left join tblSMCountry				rtCompanyCountry on lower(rtrim(ltrim(rtCompanyCountry.strCountry))) = lower(rtrim(ltrim(tblSMCompanySetup.strCountry)))
	left join tblSMScreen				rtCompanyScreen on rtCompanyScreen.strNamespace = 'i21.view.Country'
	left join tblSMTransaction			rtCompanyTransaction on rtCompanyTransaction.intScreenId = rtCompanyScreen.intScreenId and rtCompanyTransaction.intRecordId = rtCompanyCountry.intCountryID
	left join tblSMReportTranslation	rtCompanyTranslation on rtCompanyTranslation.intLanguageId = @intLaguageId and rtCompanyTranslation.intTransactionId = rtCompanyTransaction.intTransactionId and rtCompanyTranslation.strFieldName = 'Country'

	SELECT @strPaymentInfo = STUFF((
				SELECT CHAR(13) + CHAR(10) + PAY.strPaymentInfo
				FROM tblSMPayment PAY
				WHERE PAY.intTransactionId = I.intInvoiceId
					AND PAY.strScreen = 'AccountsReceivable.view.Invoice'
				FOR XML PATH('')
					,TYPE
				).value('.', 'varchar(max)'), 1, 2, '')
	FROM tblARInvoice I
	WHERE I.intInvoiceId = @intInvoiceId

	/*Declared variables for translating expression*/
	declare @per nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'per'),'per');
	declare @ref nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Ref.'),'Ref.');
	declare @from nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'from'),'from');
	declare @to nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'to'),'to');
	declare @dated nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'dated'),'dated');

	SELECT Inv.intInvoiceId
		,intSerialNo = ROW_NUMBER() OVER (ORDER BY InvDet.intInvoiceDetailId)
		,strInvoiceNumber = Inv.strInvoiceNumber
		,strPONumber = Inv.strPONumber
		,strCustomer = EN.strName
		,CUS.strVatNumber
		,Inv.strBillToAddress
		,Inv.strBillToCity
		,Inv.strBillToState
		,Inv.strBillToZipCode
		,strCityStateZip = CASE WHEN (ISNULL(Inv.strBillToCity, '') = '') THEN '' ELSE Inv.strBillToCity + ', ' END 
			+ CASE WHEN (ISNULL(Inv.strBillToState, '') = '') THEN '' ELSE Inv.strBillToState + ', ' END + Inv.strBillToZipCode
		,Inv.strBillToCountry
		,Inv.strComments
		,Inv.strFooterComments
		,Inv.strTransactionType
		,Inv.strType
		,strItemNo = Item.strItemNo
		,strBundleItemNo = Bun.strItemNo 
		,strItemDescription = InvDet.strItemDescription
		,strItemOrigin = OG.strDescription
		,InvDet.dblPrice
		,strPrice2Decimals = LTRIM(CAST(ROUND(InvDet.dblPrice, 2) AS NUMERIC(18, 2)))
		,strPrice4Decimals = LTRIM(CAST(ROUND(InvDet.dblPrice, 4) AS NUMERIC(18, 4)))
		,strCurrencyText = CASE WHEN (ISNULL(InvCur.strDescription, '') <> '') THEN InvCur.strDescription ELSE InvCur.strCurrency END + '.'
		,InvDet.dblQtyShipped
		,InvDet.dblShipmentGrossWt
		,InvDet.dblShipmentTareWt
		,InvDet.dblShipmentNetWt
		,strProvisionalInvoiceNumber = Prov.strInvoiceNumber
		,strProvisionalPONumber = Prov.strPONumber
		,dtmProvDate = Prov.dtmDate
		,strProvDate = dbo.fnConvertDateToReportDateFormat(Prov.dtmDate, 0)
		,dblProvQtyShipped = ProvDet.dblQtyShipped
		,dblProvGrossWt = ProvDet.dblShipmentGrossWt
		,dblProvTareWt = ProvDet.dblShipmentTareWt
		,dblProvNetWt = ProvDet.dblShipmentNetWt
		,dblProvPrice = ProvDet.dblPrice
		,dblProvTotal = ProvDet.dblTotal
		,dblProvInvoiceTotal = Inv.dblProvisionalAmount
		,dblProvAmountDue = Inv.dblAmountDue
		,blbHeaderLogo = dbo.fnSMGetCompanyLogo('Header') 
		,blbFooterLogo = dbo.fnSMGetCompanyLogo('Footer')
		,intReportLogoHeight = ISNULL(CP.intReportLogoHeight,0)
		,intReportLogoWidth = ISNULL(CP.intReportLogoWidth,0)
		,strCompanyName = @strCompanyName
		,strCompanyAddress = @strCompanyAddress
		,strCompanyContactName = @strContactName
		,strCompanyCounty = @strCounty
		,strCompanyCity = @strCity
		,strCompanyState = @strState
		,strCompanyZip = @strZip
		,strCompanyCountry = @strCountry
		,strCompanyPhone = @strPhone
		,strCityAndDate = @strCity + ', '+ DATENAME(dd,Inv.dtmDate) + ' ' + isnull(dbo.fnCTGetTranslatedExpression(@strMonthLabelName,@intLaguageId,LEFT(DATENAME(MONTH,Inv.dtmDate),3)),LEFT(DATENAME(MONTH,Inv.dtmDate),3)) + ' ' + DATENAME(yyyy,Inv.dtmDate)
		,strWtInfo = 'Gross ' + CHAR(9)+ LTRIM(dbo.fnRemoveTrailingZeroes(ROUND(InvDet.dblShipmentGrossWt, 2))) + ' ' + isnull(rtWUOMTranslation.strTranslation,WUOM.strUnitMeasure) + CHAR(13) + 'Tare ' + CHAR(9) + LTRIM(dbo.fnRemoveTrailingZeroes(ROUND(InvDet.dblShipmentTareWt, 2))) + ' ' + isnull(rtWUOMTranslation.strTranslation,WUOM.strUnitMeasure) + CHAR(13) + 'Net ' + CHAR(9) + CHAR(9) + LTRIM(dbo.fnRemoveTrailingZeroes(ROUND(InvDet.dblShipmentNetWt, 2))) + ' ' + isnull(rtWUOMTranslation.strTranslation,WUOM.strUnitMeasure)
		,dblGrossWt = ROUND(InvDet.dblShipmentGrossWt, 2) 
		,strGrossUOM = isnull(rtWUOMTranslation.strTranslation, WUOM.strUnitMeasure) 
		,dblTareWt = ROUND(InvDet.dblShipmentTareWt, 2) 
		,strTareUOM = isnull(rtWUOMTranslation.strTranslation, WUOM.strUnitMeasure) 
		,dblNetWt = ROUND(InvDet.dblShipmentNetWt, 2) 
		,strNetUOM = isnull(rtWUOMTranslation.strTranslation, WUOM.strUnitMeasure) 
		,strNetWtInfo = LTRIM(dbo.fnRemoveTrailingZeroes(ROUND(InvDet.dblShipmentNetWt, 2))) + ' ' + isnull(rtWUOMTranslation.strTranslation,WUOM.strUnitMeasure) 
		,strPriceInfo = LTRIM(CAST(ROUND(InvDet.dblPrice, 2) AS NUMERIC(18, 2))) + ' ' + InvDetPriceCur.strCurrency + ' '+@per+' ' + isnull(rtPriceUOMTranslation.strTranslation,InvDetPriceUOM.strUnitMeasure)
		,strPriceInfo2 = InvDetPriceCur.strCurrency + ' ' + LTRIM(CAST(ROUND(InvDet.dblPrice, 2) AS NUMERIC(18, 2))) + ' / ' + isnull(rtPriceUOMTranslation.strTranslation,InvDetPriceUOM.strUnitMeasure)
		,InvDet.dblTotal
		,strQtyOrderedInfo = LTRIM(dbo.fnRemoveTrailingZeroes(ROUND(InvDet.dblQtyOrdered, 2))) + ' ' + isnull(rtOUOMTranslation.strTranslation,OUOM.strUnitMeasure)
		,strQtyShippedInfo = LTRIM(dbo.fnRemoveTrailingZeroes(ROUND(InvDet.dblQtyShipped, 2))) + ' ' + isnull(rtSUOMTranslation.strTranslation,SUOM.strUnitMeasure)
		,strInvoiceCurrency = InvCur.strCurrency
		,strPriceCurrency = PriceCur.strCurrency
		,strPriceUOM = isnull(rtPriceUOMTranslation.strTranslation,PriceUOM.strUnitMeasure)
		,strWeightUOM = isnull(rtWtUOMTranslation.strTranslation,WtUOM.strUnitMeasure)
		,CH.strCustomerContract
		,strContractNumber = LTRIM(CH.strContractNumber) +'/'+ LTRIM(CD.intContractSeq)
		,strContractNumberOnly = LTRIM(CH.strContractNumber)
		,CD.strERPPONumber
		,CH.dtmContractDate
		,strContractDate = dbo.fnConvertDateToReportDateFormat(CH.dtmContractDate, 0)
		,CD.intContractSeq
		,strContainerNumber = CASE WHEN (L.intPurchaseSale = 3) THEN ISNULL(DSCont.strContainerNumber, Cont.strContainerNumber) ELSE Cont.strContainerNumber END
		,strMarks = CASE WHEN (L.intPurchaseSale = 3) THEN ISNULL(DSCont.strMarks, Cont.strMarks) ELSE Cont.strMarks END
		,Inv.dblInvoiceSubtotal
		,Inv.dblTax
		,Inv.dblInvoiceTotal
		,strTaxDescription = TaxG.strDescription
		,intLineCount = 1
		,FT.strFreightTerm
		,strMVessel = CASE WHEN L.intPurchaseSale = 2 THEN 
						CASE WHEN PL.strMVessel IS NOT NULL THEN
								CASE WHEN ISNULL(PL.strMVessel, '') = '' THEN PL.strVessel1 ELSE PL.strMVessel END
							ELSE
								CASE WHEN ISNULL(L.strMVessel, '') = '' THEN L.strVessel1 ELSE L.strMVessel END
							END
						ELSE CASE WHEN ISNULL(L.strMVessel, '') = '' THEN L.strVessel1 ELSE L.strMVessel END END
		,strTransshipmentVessel = UPPER(
									CASE WHEN L.intPurchaseSale = 2 THEN 
										CASE WHEN PL.strMVessel IS NOT NULL THEN
												CASE WHEN ISNULL(PL.strMVessel, '') = '' THEN PL.strVessel1 ELSE PL.strMVessel + ' VOY.' + PL.strMVoyageNumber END
											ELSE
												CASE WHEN ISNULL(L.strMVessel, '') = '' THEN L.strVessel1 ELSE L.strMVessel + ' VOY.' + L.strMVoyageNumber END
											END
										ELSE CASE WHEN ISNULL(L.strMVessel, '') = '' THEN L.strVessel1 ELSE L.strMVessel + ' VOY.' + L.strMVoyageNumber END 
									END
									+ CASE WHEN ISNULL(L.strVessel2, '') <> '' THEN ', ' + L.strVessel2 ELSE '' END 
									+ CASE WHEN ISNULL(L.strVessel3, '') <> '' THEN ', ' + L.strVessel3 ELSE '' END 
									+ CASE WHEN ISNULL(L.strVessel4, '') <> '' THEN ', ' + L.strVessel4 ELSE '' END)
		,strVesselDirection = CASE WHEN L.intPurchaseSale = 2 THEN
							  	COALESCE(PL.strMVessel, L.strMVessel, '') + CASE WHEN (COALESCE(PL.strOriginPort, L.strOriginPort, '') <>  '' AND COALESCE(PL.strDestinationPort, L.strDestinationPort, '') <> '') 
									THEN ' ' + @from + ' ' + ISNULL(PL.strOriginPort, L.strOriginPort) + ' ' + @to + ' ' + ISNULL(PL.strDestinationPort, L.strDestinationPort)  ELSE '' END
							  ELSE
								 ISNULL(L.strMVessel, '') + CASE WHEN (ISNULL(L.strOriginPort, '') <>  '' AND ISNULL(L.strDestinationPort, '') <> '') 
												THEN ' ' + @from + ' ' + L.strOriginPort + ' ' + @to + ' ' + L.strDestinationPort ELSE '' END
							  END
		,strBLNumber = CASE WHEN L.intPurchaseSale = 2 THEN ISNULL(PL.strBLNumber, L.strBLNumber) ELSE L.strBLNumber END
		,dtmBLDate = CASE WHEN L.intPurchaseSale = 2 THEN ISNULL(PL.dtmBLDate, L.dtmBLDate) ELSE L.dtmBLDate END
		,strBLDate = dbo.fnConvertDateToReportDateFormat(CASE WHEN L.intPurchaseSale = 2 THEN ISNULL(PL.dtmBLDate, L.dtmBLDate) ELSE L.dtmBLDate END, 0)
		,strBLNoDated = CASE WHEN L.intPurchaseSale = 2 THEN 
								ISNULL(PL.strBLNumber, L.strBLNumber) + ' ' + @dated + ' ' + CONVERT(NVARCHAR,ISNULL(PL.dtmBLDate, L.dtmBLDate),106) 
							ELSE 
								L.strBLNumber + ' ' + @dated + ' ' + CONVERT(NVARCHAR,L.dtmBLDate,106) 
							END
		,strForwardAgentLot = CASE WHEN (L.intPurchaseSale = 3) 
									THEN ISNULL(LFA.strName, '') + CASE WHEN COALESCE(DSCont.strLotNumber, Cont.strLotNumber, '') <> '' THEN ', -' + @ref + ' ' + COALESCE(DSCont.strLotNumber, Cont.strLotNumber, '') ELSE '' END
									ELSE ISNULL(PLFA.strName, '') + CASE WHEN ISNULL(Cont.strLotNumber, '') <> '' THEN ', -' + @ref + ' ' + ISNULL(Cont.strLotNumber, '') ELSE '' END 
								END
		,strDocument = @strContractDocuments 
		,strCondition = @strContractConditions 
		,strFreightCondition = @strFreightConditions
		,strFreightDescCondition = @strFreightDescConditions
		,TM.strTerm
		,Inv.dtmDueDate
		,dtmInvoiceDate = Inv.dtmDate
		,dtmPostDate = Inv.dtmPostDate
		,strInvoicePaymentInformation = @strPaymentInfo 
		,strWarehouse = SWH.strSubLocationName
		,strWarehouseCondition = (SELECT TOP 1 CASE WHEN ISNULL(ID.strItemDescription, '') = '' 
									THEN I.strDescription ELSE ID.strItemDescription END
								  FROM tblARInvoiceDetail ID
								  JOIN tblICItem I ON I.intItemId = ID.intItemId
								  WHERE intInvoiceId = Inv.intInvoiceId AND I.strType = 'Comment')
		,strPositionType = POS.strPositionType
	FROM tblARInvoice Inv
	JOIN tblEMEntity EN ON EN.intEntityId = Inv.intEntityCustomerId
	JOIN tblARCustomer CUS ON CUS.intEntityId = EN.intEntityId
	JOIN tblARInvoiceDetail InvDet ON InvDet.intInvoiceId = Inv.intInvoiceId
	JOIN tblICItem Item ON Item.intItemId = InvDet.intItemId AND Item.strType <> 'Comment'
	JOIN tblSMCurrency InvCur ON InvCur.intCurrencyID = Inv.intCurrencyId
	LEFT JOIN tblSMTaxGroup TaxG ON TaxG.intTaxGroupId = InvDet.intTaxGroupId
	LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = InvDet.intContractDetailId
	LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	LEFT JOIN tblICCommodityAttribute OG ON OG.intCommodityAttributeId = Item.intOriginId
	LEFT JOIN tblICItem Bun ON Bun.intItemId = CD.intItemBundleId
	LEFT JOIN tblSMFreightTerms CFT ON CH.intFreightTermId = CFT.intFreightTermId
	LEFT JOIN tblCTPosition POS ON POS.intPositionId = CH.intPositionId
	LEFT JOIN tblSMCity CT ON CT.intCityId = CH.intINCOLocationTypeId AND CFT.strINCOLocationType = 'City'
	LEFT JOIN tblSMCountry CN ON CN.intCountryID = CH.intCountryId
	LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = CH.intWarehouseId AND CFT.strINCOLocationType <> 'City'
	LEFT JOIN tblSMCompanyLocationSubLocation SWH ON SWH.intCompanyLocationSubLocationId = CD.intSubLocationId
	LEFT JOIN tblSMCurrency PriceCur ON PriceCur.intCurrencyID = CD.intCurrencyId
	LEFT JOIN tblSMCurrency InvDetPriceCur ON InvDetPriceCur.intCurrencyID = InvDet.intSubCurrencyId 
	LEFT JOIN tblICItemUOM OIM ON OIM.intItemUOMId = InvDet.intOrderUOMId
	LEFT JOIN tblICUnitMeasure OUOM ON OUOM.intUnitMeasureId = OIM.intUnitMeasureId
	LEFT JOIN tblICItemUOM SIM ON SIM.intItemUOMId = InvDet.intItemUOMId
	LEFT JOIN tblICUnitMeasure SUOM ON SUOM.intUnitMeasureId = SIM.intUnitMeasureId
	LEFT JOIN tblICItemUOM WIM ON WIM.intItemUOMId = InvDet.intItemWeightUOMId
	LEFT JOIN tblICUnitMeasure WUOM ON WUOM.intUnitMeasureId = WIM.intUnitMeasureId
	LEFT JOIN tblICItemUOM PriceItemUOM ON PriceItemUOM.intItemUOMId = CD.intPriceItemUOMId
	LEFT JOIN tblICUnitMeasure PriceUOM ON PriceUOM.intUnitMeasureId = PriceItemUOM.intUnitMeasureId
	LEFT JOIN tblICItemUOM InvDetPriceItemUOM ON InvDetPriceItemUOM.intItemUOMId = InvDet.intPriceUOMId
	LEFT JOIN tblICUnitMeasure InvDetPriceUOM ON InvDetPriceUOM.intUnitMeasureId = InvDetPriceItemUOM.intUnitMeasureId 
	LEFT JOIN tblICItemUOM WtItemUOM ON WtItemUOM.intItemUOMId = InvDet.intItemWeightUOMId
	LEFT JOIN tblICUnitMeasure WtUOM ON WtUOM.intUnitMeasureId = WtItemUOM.intUnitMeasureId
	LEFT JOIN tblARInvoice Prov ON Prov.intInvoiceId = Inv.intOriginalInvoiceId AND Prov.strType = 'Provisional'
	LEFT JOIN tblARInvoiceDetail ProvDet ON ProvDet.intInvoiceId = Prov.intInvoiceId
	LEFT JOIN tblLGLoad L ON L.intLoadId = ISNULL(Prov.intLoadId, Inv.intLoadId)
	LEFT JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
		AND LD.intLoadDetailId = InvDet.intLoadDetailId
	LEFT JOIN tblEMEntity LFA ON LFA.intEntityId = L.intForwardingAgentEntityId
	LEFT JOIN tblLGLoadDetailLot LDL ON LDL.intLoadDetailId = LD.intLoadDetailId
	LEFT JOIN tblICLot Lot ON Lot.intLotId = LDL.intLotId
	LEFT JOIN tblICInventoryReceiptItemLot ReceiptLot ON ReceiptLot.intParentLotId = Lot.intParentLotId
	LEFT JOIN tblICInventoryReceiptItem ReceiptItem ON ReceiptItem.intInventoryReceiptItemId = ReceiptLot.intInventoryReceiptItemId
	OUTER APPLY (SELECT TOP 1 strContainerNumber = Cont.strContainerNumber, strLotNumber = Cont.strLotNumber, strMarks = Cont.strMarks FROM tblLGLoadDetailContainerLink LDCLink
					LEFT JOIN tblLGLoadContainer Cont ON Cont.intLoadContainerId = LDCLink.intLoadContainerId
					WHERE LDCLink.intLoadDetailId = ReceiptItem.intSourceId) Cont
	OUTER APPLY (SELECT TOP 1 strContainerNumber = DSCont.strContainerNumber, strLotNumber = DSCont.strLotNumber, strMarks = DSCont.strMarks FROM tblLGLoadDetailContainerLink DSLDCLink 
					LEFT JOIN tblLGLoadContainer DSCont ON DSCont.intLoadContainerId = DSLDCLink.intLoadContainerId
					WHERE DSLDCLink.intLoadDetailId = LD.intLoadDetailId) DSCont
	LEFT JOIN tblLGLoadDetail PLD ON PLD.intLoadDetailId = ReceiptItem.intSourceId
	LEFT JOIN tblLGLoad PL ON PL.intLoadId = PLD.intLoadId
	LEFT JOIN tblCTContractDetail PCD ON PCD.intContractDetailId = PLD.intPContractDetailId
	LEFT JOIN tblSMCompanyLocationSubLocation PWH ON PWH.intCompanyLocationSubLocationId = PCD.intSubLocationId
	LEFT JOIN tblEMEntity PLFA ON PLFA.intEntityId = PL.intForwardingAgentEntityId
	LEFT JOIN tblSMFreightTerms FT ON FT.intFreightTermId = Inv.intFreightTermId
	LEFT JOIN tblSMTerm TM ON TM.intTermID = CH.intTermId

	CROSS APPLY tblLGCompanyPreference CP
	left join tblSMScreen				rtWUOMScreen on rtWUOMScreen.strNamespace = 'Inventory.view.ReportTranslation'
	left join tblSMTransaction			rtWUOMTransaction on rtWUOMTransaction.intScreenId = rtWUOMScreen.intScreenId and rtWUOMTransaction.intRecordId = WUOM.intUnitMeasureId
	left join tblSMReportTranslation	rtWUOMTranslation on rtWUOMTranslation.intLanguageId = @intLaguageId and rtWUOMTranslation.intTransactionId = rtWUOMTransaction.intTransactionId and rtWUOMTranslation.strFieldName = 'Name'
			
	left join tblSMScreen				rtPriceUOMScreen on rtPriceUOMScreen.strNamespace = 'Inventory.view.ReportTranslation'
	left join tblSMTransaction			rtPriceUOMTransaction on rtPriceUOMTransaction.intScreenId = rtPriceUOMScreen.intScreenId and rtPriceUOMTransaction.intRecordId = PriceUOM.intUnitMeasureId
	left join tblSMReportTranslation	rtPriceUOMTranslation on rtPriceUOMTranslation.intLanguageId = @intLaguageId and rtPriceUOMTranslation.intTransactionId = rtPriceUOMTransaction.intTransactionId and rtPriceUOMTranslation.strFieldName = 'Name'
				
	left join tblSMScreen				rtOUOMScreen on rtOUOMScreen.strNamespace = 'Inventory.view.ReportTranslation'
	left join tblSMTransaction			rtOUOMTransaction on rtOUOMTransaction.intScreenId = rtOUOMScreen.intScreenId and rtOUOMTransaction.intRecordId = OUOM.intUnitMeasureId
	left join tblSMReportTranslation	rtOUOMTranslation on rtOUOMTranslation.intLanguageId = @intLaguageId and rtOUOMTranslation.intTransactionId = rtOUOMTransaction.intTransactionId and rtOUOMTranslation.strFieldName = 'Name'

	left join tblSMScreen				rtSUOMScreen on rtSUOMScreen.strNamespace = 'Inventory.view.ReportTranslation'
	left join tblSMTransaction			rtSUOMTransaction on rtSUOMTransaction.intScreenId = rtSUOMScreen.intScreenId and rtSUOMTransaction.intRecordId = SUOM.intUnitMeasureId
	left join tblSMReportTranslation	rtSUOMTranslation on rtSUOMTranslation.intLanguageId = @intLaguageId and rtSUOMTranslation.intTransactionId = rtSUOMTransaction.intTransactionId and rtSUOMTranslation.strFieldName = 'Name'
					
	left join tblSMScreen				rtWtUOMScreen on rtWtUOMScreen.strNamespace = 'Inventory.view.ReportTranslation'
	left join tblSMTransaction			rtWtUOMTransaction on rtWtUOMTransaction.intScreenId = rtWtUOMScreen.intScreenId and rtWtUOMTransaction.intRecordId = WtUOM.intUnitMeasureId
	left join tblSMReportTranslation	rtWtUOMTranslation on rtWtUOMTranslation.intLanguageId = @intLaguageId and rtWtUOMTranslation.intTransactionId = rtSUOMTransaction.intTransactionId and rtWtUOMTranslation.strFieldName = 'Name'
	
	WHERE Inv.intInvoiceId = @intInvoiceId
END

GO