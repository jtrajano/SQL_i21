------------------------uspCTReportIdealContractBuyer
CREATE PROCEDURE [dbo].[uspCTReportIdealContractBuyer]
@xmlParam NVARCHAR(MAX) = NULL  
	
AS

BEGIN TRY
	
	DECLARE @ErrMsg NVARCHAR(MAX)
	
	 

	DECLARE @strCompanyName			     NVARCHAR(500),
			@strAddress				     NVARCHAR(500),
			@strCounty				     NVARCHAR(500),
			@strCity				     NVARCHAR(500),
			@strState				     NVARCHAR(500),
			@strZip					     NVARCHAR(500),
			@strCountry				     NVARCHAR(500),
			@strLanguage				 NVARCHAR(50),
			@xmlDocumentId			     INT,
			@intContractHeaderId		 INT,
			@intLaguageId			INT,
			@strExpressionLabelName	NVARCHAR(50) = 'Expression',
			@strMonthLabelName		NVARCHAR(50) = 'Month'
			
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
	
	SELECT @intContractHeaderId = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intContractHeaderId'
    
	SELECT	@intLaguageId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intSrLanguageId'

	if (@intLaguageId is null)
	begin
		set @intLaguageId = 0;
	end

	/*Declared variables for translating expression*/
	declare @Messrs nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Messrs'),'Messrs');
	declare @strHeaderLabelText nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Confirmation of Sale'),'Confirmation of Sale');
	declare @strHeaderText1 nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Re today phone conversation we confirm to you the following sale at the conditions'),'Re today phone conversation we confirm to you the following sale at the conditions');
	declare @strHeaderText2 nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'latest edition'),'latest edition');
	declare @strQuantity1 nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'net'),'net');
	declare @strQuantity2 nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Container'),'Container');
	declare @strThanksText nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'We thank you for your collaboration'),'We thank you for your collaboration');

	SELECT	@strCompanyName	=	CASE WHEN LTRIM(RTRIM(tblSMCompanySetup.strCompanyName)) = '' THEN NULL ELSE LTRIM(RTRIM(tblSMCompanySetup.strCompanyName)) END,
			@strAddress		=	CASE WHEN LTRIM(RTRIM(tblSMCompanySetup.strAddress)) = '' THEN NULL ELSE LTRIM(RTRIM(tblSMCompanySetup.strAddress)) END,
			@strCounty		=	CASE WHEN LTRIM(RTRIM(tblSMCompanySetup.strCounty)) = '' THEN NULL ELSE LTRIM(RTRIM(isnull(rtrt9.strTranslation,tblSMCompanySetup.strCounty))) END,
			@strCity		=	CASE WHEN LTRIM(RTRIM(tblSMCompanySetup.strCity)) = '' THEN NULL ELSE LTRIM(RTRIM(tblSMCompanySetup.strCity)) END,
			@strState		=	CASE WHEN LTRIM(RTRIM(tblSMCompanySetup.strState)) = '' THEN NULL ELSE LTRIM(RTRIM(tblSMCompanySetup.strState)) END,
			@strZip			=	CASE WHEN LTRIM(RTRIM(tblSMCompanySetup.strZip)) = '' THEN NULL ELSE LTRIM(RTRIM(tblSMCompanySetup.strZip)) END,
			@strCountry		=	CASE WHEN LTRIM(RTRIM(tblSMCompanySetup.strCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(isnull(rtrt9.strTranslation,tblSMCompanySetup.strCountry))) END
	FROM	tblSMCompanySetup
	left join tblSMCountry				rtc9 on lower(rtrim(ltrim(rtc9.strCountry))) = lower(rtrim(ltrim(tblSMCompanySetup.strCountry)))
	left join tblSMScreen				rts9 on rts9.strNamespace = 'i21.view.Country'
	left join tblSMTransaction			rtt9 on rtt9.intScreenId = rts9.intScreenId and rtt9.intRecordId = rtc9.intCountryID
	left join tblSMReportTranslation	rtrt9 on rtrt9.intLanguageId = @intLaguageId and rtrt9.intTransactionId = rtt9.intTransactionId and rtrt9.strFieldName = 'Country'


	SELECT
		blbHeaderLogo				= dbo.fnSMGetCompanyLogo('Header')

		,strCustomerAddress			=  @Messrs + CHAR(13)+CHAR(10) +
										LTRIM(RTRIM(EC.strEntityName)) + ', ' + CHAR(13)+CHAR(10) +
										ISNULL(LTRIM(RTRIM(EC.strEntityAddress)),'') + ', ' + CHAR(13)+CHAR(10) +
										ISNULL(LTRIM(RTRIM(EC.strEntityCity)),'') + 
										ISNULL(', '+CASE WHEN LTRIM(RTRIM(EC.strEntityState)) = '' THEN NULL ELSE LTRIM(RTRIM(EC.strEntityState)) END,'') + 
										ISNULL(', '+CASE WHEN LTRIM(RTRIM(EC.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EC.strEntityZipCode)) END,'') + 
										ISNULL(', '+CASE WHEN LTRIM(RTRIM(EC.strEntityCountry)) = '' THEN NULL ELSE isnull(rtrt10.strTranslation,LTRIM(RTRIM(EC.strEntityCountry))) END,'')

		,strHeaderLabelText         =  @strHeaderLabelText + ' '+LTRIM(CH.strContractNumber)   
		,strHeaderText		        =  @strHeaderText1 + ' '+ isnull(rtrt.strTranslation,AN.strComment) + ' ('+isnull(rtrt1.strTranslation,AN.strName)+')'+' '+@strHeaderText2+'.'
				
		,strSeller			        =  LTRIM(RTRIM(EV.strEntityName)) + ', ' + CHAR(13)+CHAR(10) +
										ISNULL(LTRIM(RTRIM(EV.strEntityAddress)),'') + ', ' + CHAR(13)+CHAR(10) +
										ISNULL(LTRIM(RTRIM(EV.strEntityCity)),'') + 
										ISNULL(', '+CASE WHEN LTRIM(RTRIM(EV.strEntityState)) = '' THEN NULL ELSE LTRIM(RTRIM(EV.strEntityState)) END,'') + 
										ISNULL(', '+CASE WHEN LTRIM(RTRIM(EV.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EV.strEntityZipCode)) END,'') + 
										ISNULL(', '+CASE WHEN LTRIM(RTRIM(EV.strEntityCountry)) = '' THEN NULL ELSE isnull(rtrt11.strTranslation,LTRIM(RTRIM(EV.strEntityCountry))) END,'')

		,strBuyer			        =  LTRIM(RTRIM(EC.strEntityName)) + ', ' + CHAR(13)+CHAR(10) +
										ISNULL(LTRIM(RTRIM(EC.strEntityAddress)),'') + ', ' + CHAR(13)+CHAR(10) +
										ISNULL(LTRIM(RTRIM(EC.strEntityCity)),'') + 
										ISNULL(', '+CASE WHEN LTRIM(RTRIM(EC.strEntityState)) = '' THEN NULL ELSE LTRIM(RTRIM(EC.strEntityState)) END,'') + 
										ISNULL(', '+CASE WHEN LTRIM(RTRIM(EC.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EC.strEntityZipCode)) END,'') + 
										ISNULL(', '+CASE WHEN LTRIM(RTRIM(EC.strEntityCountry)) = '' THEN NULL ELSE isnull(rtrt10.strTranslation,LTRIM(RTRIM(EC.strEntityCountry))) END,'')

		,strQuality			        =  isnull(rtrt3.strTranslation,IM.strDescription)+' , '+CD.strItemSpecification		 
		,strSample			        =  '-'
		,strQuantity			    =  LTRIM(CH.dblQuantity)+''+isnull(rtrt2.strTranslation,UOM.strUnitMeasure)+' '+@strQuantity1+'-( '+ LTRIM(CD.intNumberOfContainers)+' '+@strQuantity2+')'
		,strShipment			    =  isnull(dbo.fnCTGetTranslatedExpression(@strMonthLabelName,@intLaguageId,DATENAME(MONTH, CD.dtmStartDate)), DATENAME(MONTH, CD.dtmStartDate)) +'('+ RIGHT(YEAR(CD.dtmStartDate), 2)+')'
		,strPrice			        =  isnull(rtrt4.strTranslation,Market.strFutMarketName)+' '+isnull(rtrt5.strTranslation,FuturesMonth.strFutureMonth)+' '+ LTRIM(CD.dblBasis)+' '+CY.strCurrency+'/'+isnull(rtrt6.strTranslation,BasisUOM.strUnitMeasure)
		,strConditions			    =  CB.strContractBasis+' '+isnull(rtrt8.strTranslation,W.strWeightGradeDesc)	---> Need to Know
		,strPayment			        =  isnull(rtrt7.strTranslation,TM.strTerm)
		,strArbitration			    =  ''	---> Need to Know
		,strSpecialConditions		=  CH.strPrintableRemarks
		,strThanksText				=  @strThanksText + '.'
		,strSignature				=  @strCompanyName
		,dtmContractDate			=  Convert(Nvarchar,GetDATE(),101)
		,strContractNumber			= CH.strContractNumber		
		

	FROM	     tblCTContractHeader					CH 
	JOIN	     vyuCTEntity							EV				ON	EV.intEntityId				  = CH.intEntityId        AND EV.strEntityType ='Vendor'			
	JOIN	     vyuCTEntity							EC				ON	EC.intEntityId				  = CH.intCounterPartyId  AND EC.strEntityType ='Customer'
	JOIN         tblCTContractDetail					CD				ON  CD.intContractHeaderId		  = CH.intContractHeaderId
	JOIN         tblICUnitMeasure						UOM				ON  UOM.intUnitMeasureId		  = CH.intCommodityUOMId
	LEFT JOIN	tblCTAssociation						AN				ON	AN.intAssociationId			  =	CH.intAssociationId
	LEFT JOIN	tblICItem								IM				ON	IM.intItemId				  =	CD.intItemId
	LEFT JOIN   tblRKFutureMarket						Market			ON  Market.intFutureMarketId	  = CD.intFutureMarketId			
	LEFT JOIN   tblRKFuturesMonth						FuturesMonth	ON  FuturesMonth.intFutureMonthId = CD.intFutureMonthId
	LEFT JOIN   tblICItemUOM							ItemUOM			ON  ItemUOM.intItemUOMId		  = CD.intBasisUOMId
	LEFT JOIN   tblICUnitMeasure						BasisUOM		ON  BasisUOM.intUnitMeasureId	  = ItemUOM.intUnitMeasureId
	LEFT JOIN	tblSMCurrency							CY				ON	CY.intCurrencyID			  =	CD.intBasisCurrencyId
	LEFT JOIN	tblCTContractBasis						CB				ON	CB.intContractBasisId		  =	CH.intContractBasisId
	LEFT JOIN   tblCTWeightGrade						W				ON	W.intWeightGradeId			  =	CH.intWeightId
	LEFT JOIN	tblSMTerm								TM				ON	TM.intTermID				  =	CH.intTermId
	
														
	left join tblSMScreen				rts on rts.strNamespace = 'ContractManagement.view.Associations'
	left join tblSMTransaction			rtt on rtt.intScreenId = rts.intScreenId and rtt.intRecordId = AN.intAssociationId
	left join tblSMReportTranslation	rtrt on rtrt.intLanguageId = @intLaguageId and rtrt.intTransactionId = rtt.intTransactionId and rtrt.strFieldName = 'Printable Contract Text'
	
	left join tblSMScreen				rts1 on rts1.strNamespace = 'ContractManagement.view.Associations'
	left join tblSMTransaction			rtt1 on rtt1.intScreenId = rts1.intScreenId and rtt1.intRecordId = AN.intAssociationId
	left join tblSMReportTranslation	rtrt1 on rtrt1.intLanguageId = @intLaguageId and rtrt1.intTransactionId = rtt1.intTransactionId and rtrt1.strFieldName = 'Name'
	
	left join tblSMScreen				rts2 on rts2.strNamespace = 'Inventory.view.ReportTranslation'
	left join tblSMTransaction			rtt2 on rtt2.intScreenId = rts2.intScreenId and rtt2.intRecordId = UOM.intUnitMeasureId
	left join tblSMReportTranslation	rtrt2 on rtrt2.intLanguageId = @intLaguageId and rtrt2.intTransactionId = rtt2.intTransactionId and rtrt2.strFieldName = 'Name'
	
	left join tblSMScreen				rts3 on rts3.strNamespace = 'Inventory.view.Item'
	left join tblSMTransaction			rtt3 on rtt3.intScreenId = rts3.intScreenId and rtt3.intRecordId = IM.intItemId
	left join tblSMReportTranslation	rtrt3 on rtrt3.intLanguageId = @intLaguageId and rtrt3.intTransactionId = rtt3.intTransactionId and rtrt3.strFieldName = 'Description'
	
	left join tblSMScreen				rts4 on rts4.strNamespace = 'RiskManagement.view.FuturesMarket'
	left join tblSMTransaction			rtt4 on rtt4.intScreenId = rts4.intScreenId and rtt4.intRecordId = Market.intFutureMarketId
	left join tblSMReportTranslation	rtrt4 on rtrt4.intLanguageId = @intLaguageId and rtrt4.intTransactionId = rtt4.intTransactionId and rtrt4.strFieldName = 'Market Name'
	
	left join tblSMScreen				rts5 on rts5.strNamespace = 'RiskManagement.view.FuturesTradingMonths'
	left join tblSMTransaction			rtt5 on rtt5.intScreenId = rts5.intScreenId and rtt5.intRecordId = FuturesMonth.intFutureMonthId
	left join tblSMReportTranslation	rtrt5 on rtrt5.intLanguageId = @intLaguageId and rtrt5.intTransactionId = rtt5.intTransactionId and rtrt5.strFieldName = 'Future Trading Month'
	
	left join tblSMScreen				rts6 on rts6.strNamespace = 'Inventory.view.ReportTranslation'
	left join tblSMTransaction			rtt6 on rtt6.intScreenId = rts6.intScreenId and rtt6.intRecordId = BasisUOM.intUnitMeasureId
	left join tblSMReportTranslation	rtrt6 on rtrt6.intLanguageId = @intLaguageId and rtrt6.intTransactionId = rtt6.intTransactionId and rtrt6.strFieldName = 'Name'
	
	left join tblSMScreen				rts7 on rts7.strNamespace = 'i21.view.Term'
	left join tblSMTransaction			rtt7 on rtt7.intScreenId = rts7.intScreenId and rtt7.intRecordId = TM.intTermID
	left join tblSMReportTranslation	rtrt7 on rtrt7.intLanguageId = @intLaguageId and rtrt7.intTransactionId = rtt7.intTransactionId and rtrt7.strFieldName = 'Terms'
	
	left join tblSMScreen				rts8 on rts8.strNamespace = 'ContractManagement.view.WeightGrades'
	left join tblSMTransaction			rtt8 on rtt8.intScreenId = rts8.intScreenId and rtt8.intRecordId = W.intWeightGradeId
	left join tblSMReportTranslation	rtrt8 on rtrt8.intLanguageId = @intLaguageId and rtrt8.intTransactionId = rtt8.intTransactionId and rtrt8.strFieldName = 'Name'

	left join tblSMCountry				rtc10 on lower(rtrim(ltrim(rtc10.strCountry))) = lower(rtrim(ltrim(EC.strEntityCountry)))
	left join tblSMScreen				rts10 on rts10.strNamespace = 'i21.view.Country'
	left join tblSMTransaction			rtt10 on rtt10.intScreenId = rts10.intScreenId and rtt10.intRecordId = rtc10.intCountryID
	left join tblSMReportTranslation	rtrt10 on rtrt10.intLanguageId = @intLaguageId and rtrt10.intTransactionId = rtt10.intTransactionId and rtrt10.strFieldName = 'Country'

	left join tblSMCountry				rtc11 on lower(rtrim(ltrim(rtc11.strCountry))) = lower(rtrim(ltrim(EV.strEntityCountry)))
	left join tblSMScreen				rts11 on rts11.strNamespace = 'i21.view.Country'
	left join tblSMTransaction			rtt11 on rtt11.intScreenId = rts11.intScreenId and rtt11.intRecordId = rtc11.intCountryID
	left join tblSMReportTranslation	rtrt11 on rtrt11.intLanguageId = @intLaguageId and rtrt11.intTransactionId = rtt11.intTransactionId and rtrt11.strFieldName = 'Country'

	WHERE CH.intContractHeaderId = @intContractHeaderId

	/*
	IF ISNULL(@strLanguage,'English') ='English'
	BEGIN
			SELECT
				 blbHeaderLogo				= dbo.fnSMGetCompanyLogo('Header')

				,strCustomerAddress			=  'Messrs'+ CHAR(13)+CHAR(10) +
											   LTRIM(RTRIM(EC.strEntityName)) + ', ' + CHAR(13)+CHAR(10) +
											   ISNULL(LTRIM(RTRIM(EC.strEntityAddress)),'') + ', ' + CHAR(13)+CHAR(10) +
											   ISNULL(LTRIM(RTRIM(EC.strEntityCity)),'') + 
											   ISNULL(', '+CASE WHEN LTRIM(RTRIM(EC.strEntityState)) = '' THEN NULL ELSE LTRIM(RTRIM(EC.strEntityState)) END,'') + 
											   ISNULL(', '+CASE WHEN LTRIM(RTRIM(EC.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EC.strEntityZipCode)) END,'') + 
											   ISNULL(', '+CASE WHEN LTRIM(RTRIM(EC.strEntityCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(EC.strEntityCountry)) END,'')

				,strHeaderLabelText         =  'Confirmation of Sale '+LTRIM(CH.strContractNumber)   
				,strHeaderText		        =  'Re today phone conversation we confirm to you the following sale at the conditions '+ AN.strComment + ' ('+AN.strName+')'+' latest edition.'
				
				,lblSeller			        =  'Seller'
				,strSeller			        =  LTRIM(RTRIM(EV.strEntityName)) + ', ' + CHAR(13)+CHAR(10) +
											   ISNULL(LTRIM(RTRIM(EV.strEntityAddress)),'') + ', ' + CHAR(13)+CHAR(10) +
											   ISNULL(LTRIM(RTRIM(EV.strEntityCity)),'') + 
											   ISNULL(', '+CASE WHEN LTRIM(RTRIM(EV.strEntityState)) = '' THEN NULL ELSE LTRIM(RTRIM(EV.strEntityState)) END,'') + 
											   ISNULL(', '+CASE WHEN LTRIM(RTRIM(EV.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EV.strEntityZipCode)) END,'') + 
											   ISNULL(', '+CASE WHEN LTRIM(RTRIM(EV.strEntityCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(EV.strEntityCountry)) END,'')

				,lblBuyer			        =  'Buyer'
				,strBuyer			        =  LTRIM(RTRIM(EC.strEntityName)) + ', ' + CHAR(13)+CHAR(10) +
											   ISNULL(LTRIM(RTRIM(EC.strEntityAddress)),'') + ', ' + CHAR(13)+CHAR(10) +
											   ISNULL(LTRIM(RTRIM(EC.strEntityCity)),'') + 
											   ISNULL(', '+CASE WHEN LTRIM(RTRIM(EC.strEntityState)) = '' THEN NULL ELSE LTRIM(RTRIM(EC.strEntityState)) END,'') + 
											   ISNULL(', '+CASE WHEN LTRIM(RTRIM(EC.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EC.strEntityZipCode)) END,'') + 
											   ISNULL(', '+CASE WHEN LTRIM(RTRIM(EC.strEntityCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(EC.strEntityCountry)) END,'')

				,lblQuality			        =  'Quality'
				,strQuality			        =  IM.strDescription+' , '+CD.strItemSpecification		 
				,lblSample			        =  'Sample'
				,strSample			        =  '-'
				,lblQuantity			    =  'Quantity'
				,strQuantity			    =  LTRIM(CH.dblQuantity)+''+UOM.strUnitMeasure+' net-( '+ LTRIM(CD.intNumberOfContainers)+' Container)'
				,lblShipment			    =  'Shipment'
				,strShipment			    =  DATENAME(MONTH, CD.dtmStartDate) +'('+ RIGHT(YEAR(CD.dtmStartDate), 2)+')'
				,lblPrice			        =  'Price'
				,strPrice			        =  Market.strFutMarketName+' '+FuturesMonth.strFutureMonth+' '+ LTRIM(CD.dblBasis)+' '+CY.strCurrency+'/'+BasisUOM.strUnitMeasure
				,lblConditions			    =  'Conditions'
				,strConditions			    =  CB.strContractBasis+' '+W.strWeightGradeDesc	---> Need to Know
				,lblPayment			        =  'Payment'
				,strPayment			        =  TM.strTerm
				,lblArbitration			    =  'Arbitration'
				,strArbitration			    =  ''	---> Need to Know
				,lblSpecialConditions		=  'Special Conditions'
				,strSpecialConditions		=  CH.strPrintableRemarks
				,strThanksText				=  'We thank you for your collaboration.'
				,strSignature				=  @strCompanyName
				,dtmContractDate			=  Convert(Nvarchar,GetDATE(),101)
				,strContractNumber			= CH.strContractNumber		
		

			FROM	     tblCTContractHeader					CH 
			JOIN	     vyuCTEntity							EV				ON	EV.intEntityId				  = CH.intEntityId        AND EV.strEntityType ='Vendor'			
			JOIN	     vyuCTEntity							EC				ON	EC.intEntityId				  = CH.intCounterPartyId  AND EC.strEntityType ='Customer'
			JOIN         tblCTContractDetail					CD				ON  CD.intContractHeaderId		  = CH.intContractHeaderId
			JOIN         tblICUnitMeasure						UOM				ON  UOM.intUnitMeasureId		  = CH.intCommodityUOMId
			LEFT JOIN	tblCTAssociation						AN				ON	AN.intAssociationId			  =	CH.intAssociationId
			LEFT JOIN	tblICItem								IM				ON	IM.intItemId				  =	CD.intItemId
			LEFT JOIN   tblRKFutureMarket						Market			ON  Market.intFutureMarketId	  = CD.intFutureMarketId			
			LEFT JOIN   tblRKFuturesMonth						FuturesMonth	ON  FuturesMonth.intFutureMonthId = CD.intFutureMonthId
			LEFT JOIN   tblICItemUOM							ItemUOM			ON  ItemUOM.intItemUOMId		  = CD.intBasisUOMId
			LEFT JOIN   tblICUnitMeasure						BasisUOM		ON  BasisUOM.intUnitMeasureId	  = ItemUOM.intUnitMeasureId
			LEFT JOIN	tblSMCurrency							CY				ON	CY.intCurrencyID			  =	CD.intBasisCurrencyId
			LEFT JOIN	tblCTContractBasis						CB				ON	CB.intContractBasisId		  =	CH.intContractBasisId
			LEFT JOIN   tblCTWeightGrade						W				ON	W.intWeightGradeId			  =	CH.intWeightId
			LEFT JOIN	tblSMTerm								TM				ON	TM.intTermID				  =	CH.intTermId
			WHERE CH.intContractHeaderId = @intContractHeaderId
	END
	ELSE IF @strLanguage ='Italian'
	BEGIN
		
				 SELECT
				 blbHeaderLogo				= dbo.fnSMGetCompanyLogo('Header')

				,strCustomerAddress			=  dbo.fnConvertEnglishToItalian('Messrs')+ CHAR(13)+CHAR(10) +
											   LTRIM(RTRIM(EC.strEntityName)) + ', ' + CHAR(13)+CHAR(10) +
											   ISNULL(LTRIM(RTRIM(EC.strEntityAddress)),'') + ', ' + CHAR(13)+CHAR(10) +
											   ISNULL(LTRIM(RTRIM(EC.strEntityCity)),'') + 
											   ISNULL(', '+CASE WHEN LTRIM(RTRIM(EC.strEntityState)) = '' THEN NULL ELSE LTRIM(RTRIM(EC.strEntityState)) END,'') + 
											   ISNULL(', '+CASE WHEN LTRIM(RTRIM(EC.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EC.strEntityZipCode)) END,'') + 
											   ISNULL(', '+CASE WHEN LTRIM(RTRIM(EC.strEntityCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(EC.strEntityCountry)) END,'')

				,strHeaderLabelText         =   dbo.fnConvertEnglishToItalian('Confirmation')+' '
											  + dbo.fnConvertEnglishToItalian('of')+' '
											  + dbo.fnConvertEnglishToItalian('Sale')+' '
											  + LTRIM(CH.strContractNumber)   
				
				,strHeaderText		        =   dbo.fnConvertEnglishToItalian('Re')+' ' 
											  +'conversazione telefonica odierna, confermiamo avere effettuato la seguente vendita alle condizioni '
											  + AN.strName+' ' 
											  + dbo.fnConvertEnglishToItalian('latest edition.')
				
				,lblSeller			        =  dbo.fnConvertEnglishToItalian('Seller')
				,strSeller			        =  LTRIM(RTRIM(EV.strEntityName)) + ', ' + CHAR(13)+CHAR(10) +
											   ISNULL(LTRIM(RTRIM(EV.strEntityAddress)),'') + ', ' + CHAR(13)+CHAR(10) +
											   ISNULL(LTRIM(RTRIM(EV.strEntityCity)),'') + 
											   ISNULL(', '+CASE WHEN LTRIM(RTRIM(EV.strEntityState)) = '' THEN NULL ELSE LTRIM(RTRIM(EV.strEntityState)) END,'') + 
											   ISNULL(', '+CASE WHEN LTRIM(RTRIM(EV.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EV.strEntityZipCode)) END,'') + 
											   ISNULL(', '+CASE WHEN LTRIM(RTRIM(EV.strEntityCountry)) = '' THEN NULL ELSE dbo.fnConvertEnglishToItalian(LTRIM(RTRIM(EV.strEntityCountry))) END,'')

				,lblBuyer			        =  dbo.fnConvertEnglishToItalian('Buyer')
				,strBuyer			        =  LTRIM(RTRIM(EC.strEntityName)) + ', ' + CHAR(13)+CHAR(10) +
											   ISNULL(LTRIM(RTRIM(EC.strEntityAddress)),'') + ', ' + CHAR(13)+CHAR(10) +
											   ISNULL(LTRIM(RTRIM(EC.strEntityCity)),'') + 
											   ISNULL(', '+CASE WHEN LTRIM(RTRIM(EC.strEntityState)) = '' THEN NULL ELSE LTRIM(RTRIM(EC.strEntityState)) END,'') + 
											   ISNULL(', '+CASE WHEN LTRIM(RTRIM(EC.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EC.strEntityZipCode)) END,'') + 
											   ISNULL(', '+CASE WHEN LTRIM(RTRIM(EC.strEntityCountry)) = '' THEN NULL ELSE dbo.fnConvertEnglishToItalian(LTRIM(RTRIM(EC.strEntityCountry))) END,'')

				,lblQuality			        =  dbo.fnConvertEnglishToItalian('Quality')
				,strQuality			        =  dbo.fnConvertEnglishToItalian(IM.strDescription)+' , '+dbo.fnConvertEnglishToItalian(CD.strItemSpecification)		 
				,lblSample			        =  dbo.fnConvertEnglishToItalian('Sample')
				,strSample			        =  '-'
				,lblQuantity			    =  dbo.fnConvertEnglishToItalian('Quantity')
				,strQuantity			    =  LTRIM(CH.dblQuantity)+''+dbo.fnConvertEnglishToItalian(UOM.strUnitMeasure)+' '+dbo.fnConvertEnglishToItalian('net')+'-( '+ LTRIM(CD.intNumberOfContainers)+' Container)'
				,lblShipment			    =  dbo.fnConvertEnglishToItalian('Shipment')
				,strShipment			    =  dbo.fnConvertEnglishToItalian(DATENAME(MONTH, CD.dtmStartDate)) +'('+ RIGHT(YEAR(CD.dtmStartDate), 2)+')'
				,lblPrice			        =  dbo.fnConvertEnglishToItalian('Price')
				,strPrice			        =  Market.strFutMarketName+' '+dbo.fnConvertEnglishToItalian(FuturesMonth.strFutureMonth)+' '+ LTRIM(CD.dblBasis)+' '+CY.strCurrency+'/'+dbo.fnConvertEnglishToItalian(BasisUOM.strUnitMeasure)
				,lblConditions			    =  dbo.fnConvertEnglishToItalian('Conditions')
				,strConditions			    =  CB.strContractBasis+' '+W.strWeightGradeDesc	---> Need to Know
				,lblPayment			        =  dbo.fnConvertEnglishToItalian('Payment')
				,strPayment			        =  dbo.fnConvertEnglishToItalian(TM.strTerm)
				,lblArbitration			    =  dbo.fnConvertEnglishToItalian('Arbitration')
				,strArbitration			    =  ''	---> Need to Know
				,lblSpecialConditions		=  dbo.fnConvertEnglishToItalian('Special Conditions')
				,strSpecialConditions		=  CH.strPrintableRemarks
				,strThanksText				=  dbo.fnConvertEnglishToItalian('We thank you for your collaboration.')
				,strSignature				=  @strCompanyName
				,dtmContractDate			=  Convert(Nvarchar,GetDATE(),101)
				,strContractNumber			= CH.strContractNumber		
		

			FROM	     tblCTContractHeader					CH 
			JOIN	     vyuCTEntity							EV				ON	EV.intEntityId				  = CH.intEntityId        AND EV.strEntityType ='Vendor'			
			JOIN	     vyuCTEntity							EC				ON	EC.intEntityId				  = CH.intCounterPartyId  AND EC.strEntityType ='Customer'
			JOIN         tblCTContractDetail					CD				ON  CD.intContractHeaderId		  = CH.intContractHeaderId
			JOIN         tblICUnitMeasure						UOM				ON  UOM.intUnitMeasureId		  = CH.intCommodityUOMId
			LEFT JOIN	tblCTAssociation						AN				ON	AN.intAssociationId			  =	CH.intAssociationId
			LEFT JOIN	tblICItem								IM				ON	IM.intItemId				  =	CD.intItemId
			LEFT JOIN   tblRKFutureMarket						Market			ON  Market.intFutureMarketId	  = CD.intFutureMarketId			
			LEFT JOIN   tblRKFuturesMonth						FuturesMonth	ON  FuturesMonth.intFutureMonthId = CD.intFutureMonthId
			LEFT JOIN   tblICItemUOM							ItemUOM			ON  ItemUOM.intItemUOMId		  = CD.intBasisUOMId
			LEFT JOIN   tblICUnitMeasure						BasisUOM		ON  BasisUOM.intUnitMeasureId	  = ItemUOM.intUnitMeasureId
			LEFT JOIN	tblSMCurrency							CY				ON	CY.intCurrencyID			  =	CD.intBasisCurrencyId
			LEFT JOIN	tblCTContractBasis						CB				ON	CB.intContractBasisId		  =	CH.intContractBasisId
			LEFT JOIN   tblCTWeightGrade						W				ON	W.intWeightGradeId			  =	CH.intWeightId
			LEFT JOIN	tblSMTerm								TM				ON	TM.intTermID				  =	CH.intTermId
			WHERE CH.intContractHeaderId = @intContractHeaderId
	END
	*/
END TRY

BEGIN CATCH

	SET @ErrMsg = 'uspCTReportIdealContractBuyer - ' + ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH