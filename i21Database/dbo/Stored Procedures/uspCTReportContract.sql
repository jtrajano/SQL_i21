﻿CREATE PROCEDURE [dbo].[uspCTReportContract]
	
	@xmlParam NVARCHAR(MAX) = NULL  
	
AS

BEGIN TRY
	
	DECLARE @ErrMsg NVARCHAR(MAX)
	
	 

	DECLARE @strCompanyName			NVARCHAR(500),
			@strAddress				NVARCHAR(500),
			@strCounty				NVARCHAR(500),
			@strCity				NVARCHAR(500),
			@strState				NVARCHAR(500),
			@strZip					NVARCHAR(500),
			@strCountry				NVARCHAR(500),
			@intContractHeaderId	INT,
			@xmlDocumentId			INT,
			@strContractDocuments	NVARCHAR(MAX),
			@strContractConditions	NVARCHAR(MAX)
			
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
    
	SELECT	@intContractHeaderId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intContractHeaderId' 

	SELECT	@strCompanyName	=	CASE WHEN LTRIM(RTRIM(strCompanyName)) = '' THEN NULL ELSE LTRIM(RTRIM(strCompanyName)) END,
			@strAddress		=	CASE WHEN LTRIM(RTRIM(strAddress)) = '' THEN NULL ELSE LTRIM(RTRIM(strAddress)) END,
			@strCounty		=	CASE WHEN LTRIM(RTRIM(strCounty)) = '' THEN NULL ELSE LTRIM(RTRIM(strCounty)) END,
			@strCity		=	CASE WHEN LTRIM(RTRIM(strCity)) = '' THEN NULL ELSE LTRIM(RTRIM(strCity)) END,
			@strState		=	CASE WHEN LTRIM(RTRIM(strState)) = '' THEN NULL ELSE LTRIM(RTRIM(strState)) END,
			@strZip			=	CASE WHEN LTRIM(RTRIM(strZip)) = '' THEN NULL ELSE LTRIM(RTRIM(strZip)) END,
			@strCountry		=	CASE WHEN LTRIM(RTRIM(strCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(strCountry)) END
	FROM	tblSMCompanySetup

	SELECT	@strContractDocuments = STUFF(								
			   (SELECT			
					CHAR(13)+CHAR(10) + DM.strDocumentName	
					FROM tblCTContractDocument CD	
					JOIN tblICDocument DM ON DM.intDocumentId = CD.intDocumentId	
					WHERE CD.intContractHeaderId=CH.intContractHeaderId	
					ORDER BY DM.strDocumentName		
					FOR XML PATH(''), TYPE				
			   ).value('.','varchar(max)')
			   ,1,2, ''						
		  )  				
	FROM tblCTContractHeader CH						
	WHERE CH.intContractHeaderId = @intContractHeaderId

	SELECT	@strContractConditions = STUFF(								
			(
					SELECT	CHAR(13)+CHAR(10) + DM.strConditionDesc
					FROM	tblCTContractCondition	CD	
					JOIN	tblCTCondition			DM	ON DM.intConditionId = CD.intConditionId	
					WHERE	CD.intContractHeaderId	=	CH.intContractHeaderId	
					ORDER BY DM.strConditionName		
					FOR XML PATH(''), TYPE				
			   ).value('.','varchar(max)')
			   ,1,2, ''						
			)  				
	FROM	tblCTContractHeader CH						
	WHERE	CH.intContractHeaderId = @intContractHeaderId

	SELECT	CH.intContractHeaderId,

			TP.strContractType + ' Contract:- ' + CH.strContractNumber AS strCaption,
			@strCompanyName + ' - '+TP.strContractType+' Contract' AS strTeaCaption,

			CH.dtmContractDate,
			'The contract has been closed on the conditions of the '+ AN.strComment + '('+AN.strName+')'+' latest edition.' strAssociation,
			CASE WHEN CH.intContractTypeId = 1 THEN CH.strContractNumber ELSE CH.strCustomerContract END AS strBuyerRefNo,
			CASE WHEN CH.intContractTypeId = 2 THEN CH.strContractNumber ELSE CH.strCustomerContract END AS strSellerRefNo,
			CH.strContractNumber,
			CH.strCustomerContract,
			CB.strContractBasis,
			SQ.strLocationName,			
			CY.strCropYear,
			SQ.srtLoadingPoint + ' :' srtLoadingPoint,
			SQ.strLoadingPointName,
			SQ.strShipper,
			SQ.srtDestinationPoint + ' :' srtDestinationPoint,
			SQ.strDestinationPointName,
			SQ.strLoadingPointName + ' to ' + SQ.strDestinationPointName AS strLoadingAndDestinationPointName,

			W1.strWeightGradeDesc AS	strWeight,
			TM.strTerm,
			W2.strWeightGradeDesc AS	strGrade,
			'Quality as per approved sample ' + ' - ' + W2.strWeightGradeDesc + ' and subject to consignment conforming to ' + @strCompanyName + '''s standard quality criteria.' AS strQaulityAndInspection,

			@strContractDocuments strContractDocuments,
			'Rules of arbitration of '+ AN.strComment + '  as per latest edition for quality and principle.' + CHAR(13)+CHAR(10) +
			'Place of jurisdiction is ' + AB.strState +', '+RY.strCountry AS strArbitration,
			@strCompanyName + ', '  + CHAR(13)+CHAR(10) +
			ISNULL(@strAddress,'') + ', ' + CHAR(13)+CHAR(10) +
			ISNULL(@strCity,'') + ISNULL(', '+@strState,'') + ISNULL(', '+@strZip,'') + ISNULL(', '+@strCountry,'')
			AS	strCompanyAddress,
			LTRIM(RTRIM(EY.strEntityName)) + ', ' + CHAR(13)+CHAR(10) +
			ISNULL(LTRIM(RTRIM(EY.strEntityAddress)),'') + ', ' + CHAR(13)+CHAR(10) +
			ISNULL(LTRIM(RTRIM(EY.strEntityCity)),'') + 
			ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityState)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityState)) END,'') + 
			ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityZipCode)) END,'') + 
			ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityCountry)) END,'') +
			ISNULL( CHAR(13)+CHAR(10) +'FLO ID: '+CASE WHEN LTRIM(RTRIM(ISNULL(VR.strFLOId,CR.strFLOId))) = '' THEN NULL ELSE LTRIM(RTRIM(ISNULL(VR.strFLOId,CR.strFLOId))) END,'')
			AS	strOtherPartyAddress,
			CASE WHEN CH.intContractTypeId = 1 THEN @strCompanyName ELSE EY.strEntityName END AS strBuyer,
			CASE WHEN CH.intContractTypeId = 2 THEN @strCompanyName ELSE EY.strEntityName END AS strSeller,
			CH.dblQuantity,
			SQ.strCurrency,
			'To be covered by ' + IB.strInsuranceBy AS strInsuranceBy,			
			CH.strPrintableRemarks,			
			AN.strComment	AS strArbitrationComment,
			dbo.fnSMGetCompanyLogo('Header') AS blbHeaderLogo,
			PR.strName AS strProducer,
			PO.strPosition,
			CASE WHEN LTRIM(RTRIM(SQ.strFixationBy)) = '' THEN NULL ELSE SQ.strFixationBy END+'''s Call ('+SQ.strFutMarketName+')' strCaller,
			@strContractConditions AS strContractConditions,
			CASE WHEN ISNULL(CB.strContractBasis,'') <>'' THEN 'Condition :' ELSE NULL END AS lblCondition,
			CASE WHEN ISNULL(PR.strName,'') <>'' THEN 'Producer :' ELSE NULL END AS lblProducer,
			CASE WHEN ISNULL(SQ.strLoadingPointName,'') <>'' THEN SQ.srtLoadingPoint + ' :'  ELSE NULL END AS lblLoadingPoint,
			CASE WHEN ISNULL(PO.strPosition,'') <>'' THEN 'Position :' ELSE NULL END AS lblPosition,			
			CASE WHEN (CH.intContractTypeId = 2 AND ISNULL(CH.strContractNumber,'') <>'') OR (CH.intContractTypeId <> 2 AND ISNULL(CH.strCustomerContract,'') <>'') THEN  'Seller Ref No. :' ELSE NULL END AS lblSellerRefNo,
			CASE WHEN ISNULL(CY.strCropYear,'') <>'' THEN 'Crop Year :' ELSE NULL END AS lblCropYear,
			CASE WHEN ISNULL(SQ.strShipper,'') <>'' THEN 'Shipper :' ELSE NULL END AS lblShipper,
			CASE WHEN ISNULL(SQ.strDestinationPointName,'') <>'' THEN SQ.srtDestinationPoint + ' :'  ELSE NULL END AS lblDestinationPoint,			
			CASE WHEN ISNULL(SQ.strFixationBy,'') <>'' AND ISNULL(SQ.strFutMarketName,'') <>'' THEN 'Pricing :' ELSE NULL END AS lblPricing,
			CASE WHEN ISNULL(W1.strWeightGradeDesc,'') <>'' THEN 'Weighing:' ELSE NULL END AS lblWeighing,
			CASE WHEN ISNULL(TM.strTerm,'') <>'' THEN 'Payment Term:' ELSE NULL END AS lblTerm,
			CASE WHEN ISNULL(IB.strInsuranceBy,'') <>'' THEN 'Insurance:' ELSE NULL END AS lblInsurance,
			CASE WHEN ISNULL(AN.strComment,'') <>'' AND ISNULL(AB.strState,'') <>'' AND ISNULL(RY.strCountry,'') <>'' THEN 'Arbitration:' ELSE NULL END AS lblArbitration,
			CASE WHEN ISNULL(@strContractConditions,'') <>'' THEN 'Conditions:' ELSE NULL END AS lblContractCondition,
			SQ.strLocationName+', '+CONVERT(CHAR(11),CH.dtmContractDate,13) AS strLocationWithDate,
	        'The contract has been closed on the conditions of the '+ AN.strComment + '('+AN.strName+')'+' latest edition and the particular conditions mentioned below.' strCondition,
		    PO.strPosition +'('+SQ.strPackingDescription +')' AS strPositionWithPackDesc,
			TX.strText+' '+CH.strPrintableRemarks AS strText,
			SQ.strContractCompanyName,
			SQ.strContractPrintSignOff,
			LTRIM(RTRIM(EY.strEntityName))AS strCompanyName


	FROM	tblCTContractHeader CH
	JOIN	tblCTContractType	TP	ON	TP.intContractTypeId	=	CH.intContractTypeId
	JOIN	vyuCTEntity			EY	ON	EY.intEntityId			=	CH.intEntityId	AND
										EY.strEntityType		=	(CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END)	LEFT
	JOIN	tblCTCropYear		CY	ON	CY.intCropYearId		=	CH.intCropYearId		LEFT
	JOIN	tblCTContractBasis	CB	ON	CB.intContractBasisId	=	CH.intContractBasisId	LEFT
	JOIN	tblCTWeightGrade	W1	ON	W1.intWeightGradeId		=	CH.intWeightId			LEFT
	JOIN	tblCTWeightGrade	W2	ON	W2.intWeightGradeId		=	CH.intGradeId			LEFT
	JOIN	tblCTContractText	TX	ON	TX.intContractTextId	=	CH.intContractTextId	LEFT
	JOIN	tblCTAssociation	AN	ON	AN.intAssociationId		=	CH.intAssociationId		LEFT
	JOIN	tblSMTerm			TM	ON	TM.intTermID			=	CH.intTermId			LEFT
	JOIN	tblSMCity			AB	ON	AB.intCityId			=	CH.intArbitrationId		LEFT
	JOIN	tblSMCountry		RY	ON	RY.intCountryID			=	AB.intCountryId			LEFT
	JOIN	tblCTInsuranceBy	IB	ON	IB.intInsuranceById		=	CH.intInsuranceById		LEFT	
	JOIN	tblEMEntity			PR	ON	PR.intEntityId			=	CH.intProducerId		LEFT
	JOIN	tblCTPosition		PO	ON	PO.intPositionId		=	CH.intPositionId		LEFT
	JOIN	tblSMCountry		CO	ON	CO.intCountryID			=	CH.intCountryId			LEFT
	JOIN	tblAPVendor			VR	ON	VR.intEntityVendorId	=	CH.intEntityId			LEFT
	JOIN	tblARCustomer		CR	ON	CR.intEntityCustomerId	=	CH.intEntityId			LEFT
	JOIN	tblSMCompanyLocationSubLocation		SL	ON	SL.intCompanyLocationSubLocationId	=		CH.intINCOLocationTypeId LEFT
	JOIN	(
				SELECT		ROW_NUMBER() OVER (PARTITION BY CD.intContractHeaderId ORDER BY CD.intContractSeq ASC) AS intRowNum, 
							CD.intContractHeaderId,
							CL.strLocationName,
							'Loading ' + CD.strLoadingPointType		AS	srtLoadingPoint,
							LP.strCity								AS	strLoadingPointName,
							'Destination ' + CD.strLoadingPointType AS	srtDestinationPoint,
							DP.strCity								AS	strDestinationPointName,
							TT.strName								AS	strShipper,
							CY.strCurrency,
							CD.strFixationBy,
							MA.strFutMarketName,
							CD.strPackingDescription				AS strPackingDescription,
							CL.strContractCompanyName				AS strContractCompanyName,
						    CL.strContractPrintSignOff              AS strContractPrintSignOff

				FROM		tblCTContractDetail		CD
				JOIN		tblSMCompanyLocation	CL	ON	CL.intCompanyLocationId		=	CD.intCompanyLocationId		LEFT
				JOIN		tblSMCity				LP	ON	LP.intCityId				=	CD.intLoadingPortId			LEFT
				JOIN		tblSMCity				DP	ON	DP.intCityId				=	CD.intDestinationPortId		LEFT
				JOIN		tblEMEntity				TT	ON	TT.intEntityId				=	CD.intShipperId				LEFT
				JOIN		tblSMCurrency			CY	ON	CY.intCurrencyID			=	CD.intCurrencyId			LEFT
				JOIN		tblRKFutureMarket		MA	ON	MA.intFutureMarketId		=	CD.intFutureMarketId		
			)					SQ	ON	SQ.intContractHeaderId	=	CH.intContractHeaderId	AND  SQ.intRowNum = 1 
	WHERE	CH.intContractHeaderId	=	@intContractHeaderId
	
	UPDATE tblCTContractHeader SET ysnPrinted = 1 WHERE intContractHeaderId	= @intContractHeaderId

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO