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
			@intContractHeaderId		 INT
			
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
	
	SELECT @strLanguage = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'strLanguage'
	
	SELECT @intContractHeaderId = [from]
	FROM @temp_xml_table
	WHERE [fieldname] = 'intContractHeaderId'

	SELECT	@strCompanyName	=	CASE WHEN LTRIM(RTRIM(strCompanyName)) = '' THEN NULL ELSE LTRIM(RTRIM(strCompanyName)) END,
			@strAddress		=	CASE WHEN LTRIM(RTRIM(strAddress)) = '' THEN NULL ELSE LTRIM(RTRIM(strAddress)) END,
			@strCounty		=	CASE WHEN LTRIM(RTRIM(strCounty)) = '' THEN NULL ELSE LTRIM(RTRIM(strCounty)) END,
			@strCity		=	CASE WHEN LTRIM(RTRIM(strCity)) = '' THEN NULL ELSE LTRIM(RTRIM(strCity)) END,
			@strState		=	CASE WHEN LTRIM(RTRIM(strState)) = '' THEN NULL ELSE LTRIM(RTRIM(strState)) END,
			@strZip			=	CASE WHEN LTRIM(RTRIM(strZip)) = '' THEN NULL ELSE LTRIM(RTRIM(strZip)) END,
			@strCountry		=	CASE WHEN LTRIM(RTRIM(strCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(strCountry)) END
	FROM	tblSMCompanySetup

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

END TRY

BEGIN CATCH

	SET @ErrMsg = 'uspCTReportIdealContractBuyer - ' + ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH