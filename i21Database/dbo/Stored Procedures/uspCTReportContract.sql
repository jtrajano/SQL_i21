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
			@strContractDocuments	NVARCHAR(MAX)
			
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
					JOIN tblICDocument DM ON DM.intDocumentId = CD.intContractDocumentId	
					WHERE CD.intContractHeaderId=CH.intContractHeaderId	
					ORDER BY DM.strDocumentName		
					FOR XML PATH(''), TYPE				
			   ).value('.','varchar(max)')
			   ,1,2, ''						
		  )  				
	FROM tblCTContractHeader CH						
	WHERE CH.intContractHeaderId = @intContractHeaderId


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

			SQ.srtLoadingPoint,
			SQ.strLoadingPointName,
			SQ.strShipper,
			SQ.srtDestinationPoint,
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
			ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityCountry)) END,'')
			AS	strOtherPartyAddress,
			CASE WHEN CH.intContractTypeId = 1 THEN @strCompanyName ELSE EY.strEntityName END AS strBuyer,
			CASE WHEN CH.intContractTypeId = 2 THEN @strCompanyName ELSE EY.strEntityName END AS strSeller,
			CH.dblQuantity,
			SQ.strCurrency,
			'To be covered by ' + IB.strInsuranceBy AS strInsuranceBy,
			CH.strPrintableRemarks,
			AN.strComment	AS strArbitrationComment
			

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
	JOIN	(
				SELECT		ROW_NUMBER() OVER (PARTITION BY CD.intContractHeaderId ORDER BY CD.intContractSeq ASC) AS intRowNum, 
							CD.intContractHeaderId,
							CL.strLocationName,
							'Loading ' + CD.strLoadingPointType		AS	srtLoadingPoint,
							LP.strCity								AS	strLoadingPointName,
							'Destination ' + CD.strLoadingPointType AS	srtDestinationPoint,
							DP.strCity								AS	strDestinationPointName,
							TT.strName								AS	strShipper,
							CY.strCurrency

				FROM		tblCTContractDetail		CD
				JOIN		tblSMCompanyLocation	CL	ON	CL.intCompanyLocationId		=	CD.intCompanyLocationId		LEFT
				JOIN		tblSMCity				LP	ON	LP.intCityId				=	CD.intLoadingPortId			LEFT
				JOIN		tblSMCity				DP	ON	DP.intCityId				=	CD.intDestinationPortId		LEFT
				JOIN		tblEntity				TT	ON	TT.intEntityId				=	CD.intShipperId				LEFT
				JOIN		tblSMCurrency			CY	ON	CY.intCurrencyID			=	CD.intCurrencyId
			)					SQ	ON	SQ.intContractHeaderId	=	CH.intContractHeaderId	AND  SQ.intRowNum = 1			
	WHERE	CH.intContractHeaderId	=	@intContractHeaderId
	
	UPDATE tblCTContractHeader SET ysnPrinted = 1 WHERE intContractHeaderId	= @intContractHeaderId

END TRY

BEGIN CATCH

	SET @ErrMsg = 'uspCTReportContractPrintGrain - ' + ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO