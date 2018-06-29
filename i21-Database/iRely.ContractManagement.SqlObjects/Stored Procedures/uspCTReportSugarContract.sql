CREATE PROCEDURE [dbo].[uspCTReportSugarContract]
	
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
			
			DECLARE 
			@intWeightConditionId	   INT			  ,@strWeightConditionDesc		NVARCHAR(MAX),
			@intDestinationConditionId INT			  ,@strDestinationDesc			NVARCHAR(MAX),
			@intContainerclauseId      INT            ,@strContainerclauseDesc      NVARCHAR(MAX),  
			@intPaymentId			   INT			  ,@strPaymentDesc			    NVARCHAR(MAX),
			@intInsuranceId			   INT			  ,@strInsuranceDesc			NVARCHAR(MAX),
			@intForcemajeureId		   INT			  ,@strForcemajeureDesc			NVARCHAR(MAX),
			@intTaxationId			   INT			  ,@strTaxationDesc				NVARCHAR(MAX),
			@intLicencesId			   INT			  ,@strLicencesDesc				NVARCHAR(MAX),
			@intArbitrationId		   INT			  ,@strArbitrationDesc			NVARCHAR(MAX),
			@intRulesId				   INT			  ,@strRulesDesc				NVARCHAR(MAX),
			@intGeneralId			   INT			  ,@strGeneralDesc				NVARCHAR(MAX)			

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
			@strAddress		=	CASE WHEN LTRIM(RTRIM(strAddress)) = ''		THEN NULL ELSE LTRIM(RTRIM(strAddress))		END,
			@strCounty		=	CASE WHEN LTRIM(RTRIM(strCounty)) = ''		THEN NULL ELSE LTRIM(RTRIM(strCounty))		END,
			@strCity		=	CASE WHEN LTRIM(RTRIM(strCity)) = ''		THEN NULL ELSE LTRIM(RTRIM(strCity))		END,
			@strState		=	CASE WHEN LTRIM(RTRIM(strState)) = ''		THEN NULL ELSE LTRIM(RTRIM(strState))		END,
			@strZip			=	CASE WHEN LTRIM(RTRIM(strZip)) = ''			THEN NULL ELSE LTRIM(RTRIM(strZip))			END,
			@strCountry		=	CASE WHEN LTRIM(RTRIM(strCountry)) = ''		THEN NULL ELSE LTRIM(RTRIM(strCountry))		END
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

	SELECT  @intWeightConditionId	 = ISNULL(CC.intConditionId,0)
			,@strWeightConditionDesc = strConditionDesc 
	FROM 
	tblCTContractCondition CC 
	JOIN tblCTCondition C ON C.intConditionId =CC.intConditionId 
	WHERE  CC.intContractHeaderId    = @intContractHeaderId 
	   AND UPPER(C.strConditionName) = 'WEIGHT QUALITY AND PACKING'
	
	
	SELECT  @intDestinationConditionId	 = ISNULL(CC.intConditionId,0)
			,@strDestinationDesc		 = strConditionDesc 
	FROM 
	tblCTContractCondition CC 
	JOIN tblCTCondition C ON C.intConditionId =CC.intConditionId 
	WHERE  CC.intContractHeaderId    = @intContractHeaderId 
	   AND UPPER(strConditionName)	 = 'DESTINATION'
	
	SELECT  @intContainerclauseId	 = ISNULL(CC.intConditionId,0)
			,@strContainerclauseDesc = strConditionDesc 
	FROM 
	tblCTContractCondition CC 
	JOIN tblCTCondition C ON C.intConditionId =CC.intConditionId 
	WHERE  CC.intContractHeaderId    = @intContractHeaderId 
	   AND UPPER(strConditionName)	 ='CONTAINER CLAUSE'
	
	SELECT  @intPaymentId	 = ISNULL(CC.intConditionId,0)
			,@strPaymentDesc = strConditionDesc 
	FROM 
	tblCTContractCondition CC 
	JOIN tblCTCondition C ON C.intConditionId =CC.intConditionId 
	WHERE  CC.intContractHeaderId    = @intContractHeaderId 
	   AND UPPER(strConditionName)   ='PAYMENT'
	
	SELECT  @intInsuranceId	 = ISNULL(CC.intConditionId,0)
			,@strInsuranceDesc = strConditionDesc 
	FROM 
	tblCTContractCondition CC 
	JOIN tblCTCondition C ON C.intConditionId =CC.intConditionId 
	WHERE  CC.intContractHeaderId    = @intContractHeaderId 
	   AND UPPER(strConditionName)	 ='INSURANCE'
	
	SELECT  @intForcemajeureId	 = ISNULL(CC.intConditionId,0)
			,@strForcemajeureDesc = strConditionDesc 
	FROM 
	tblCTContractCondition CC 
	JOIN tblCTCondition C ON C.intConditionId =CC.intConditionId 
	WHERE  CC.intContractHeaderId    = @intContractHeaderId 
	   AND UPPER(strConditionName)	 ='FORCE MAJEURE'
	
	SELECT  @intTaxationId	 = ISNULL(CC.intConditionId,0)
			,@strTaxationDesc = strConditionDesc 
	FROM 
	tblCTContractCondition CC 
	JOIN tblCTCondition C ON C.intConditionId =CC.intConditionId 
	WHERE  CC.intContractHeaderId    = @intContractHeaderId 
	   AND UPPER(strConditionName)	 ='TAXATION'
	
	SELECT  @intLicencesId	  = ISNULL(CC.intConditionId,0)
			,@strLicencesDesc = strConditionDesc 
	FROM 
	tblCTContractCondition CC 
	JOIN tblCTCondition C ON C.intConditionId =CC.intConditionId 
	WHERE  CC.intContractHeaderId    = @intContractHeaderId 
	   AND UPPER(strConditionName)	 ='LICENCES'
	
	SELECT  @intArbitrationId	 = ISNULL(CC.intConditionId,0)
			,@strArbitrationDesc = strConditionDesc 
	FROM 
	tblCTContractCondition CC 
	JOIN tblCTCondition C ON C.intConditionId =CC.intConditionId 
	WHERE  CC.intContractHeaderId    = @intContractHeaderId 
	   AND UPPER(strConditionName)	 ='ARBITRATION'
	
	SELECT  @intRulesId	 = ISNULL(CC.intConditionId,0)
			,@strRulesDesc = strConditionDesc 
	FROM 
	tblCTContractCondition CC 
	JOIN tblCTCondition C ON C.intConditionId =CC.intConditionId 
	WHERE  CC.intContractHeaderId    = @intContractHeaderId 
	   AND UPPER(strConditionName)	 ='RULES'
	
	SELECT  @intGeneralId	 = ISNULL(CC.intConditionId,0)
			,@strGeneralDesc = strConditionDesc 
	FROM 
	tblCTContractCondition CC 
	JOIN tblCTCondition C ON C.intConditionId =CC.intConditionId 
	WHERE  CC.intContractHeaderId    = @intContractHeaderId 
	   AND UPPER(strConditionName)	 ='GENERAL'

	SELECT	 
			 intContractHeaderId			=  CH.intContractHeaderId
			,blbHeaderLogo					=  dbo.fnSMGetCompanyLogo('Header')
		    ,strCaption						=  'Contract NO.' + CH.strContractNumber
		    
			,strSellerAddress				=   CASE 
													 WHEN CH.intContractTypeId = 1 THEN  LTRIM(RTRIM(EY.strEntityName)) + ', ' + CHAR(13)+CHAR(10) +
																						 ISNULL(LTRIM(RTRIM(EY.strEntityAddress)),'') + ', ' + CHAR(13)+CHAR(10) +
																						 ISNULL(LTRIM(RTRIM(EY.strEntityCity)),'') + 
																						 ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityState)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityState)) END,'') + 
																						 ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityZipCode)) END,'') +
																						 ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityCountry)) END,'')

													 ELSE								@strCompanyName + ', '  + CHAR(13)+CHAR(10) + 							
																						ISNULL(@strAddress,'') + ', ' + CHAR(13)+CHAR(10) +
																						ISNULL(@strCity,'') + ISNULL(', '+@strState,'') + ISNULL(', '+@strZip,'') + ISNULL(', '+@strCountry,'')
											   END 
												
			,strBuyerAddress				=   CASE 
													 WHEN CH.intContractTypeId = 1 THEN  @strCompanyName + ', '  + CHAR(13)+CHAR(10) + 							
																						 ISNULL(@strAddress,'') + ', ' + CHAR(13)+CHAR(10) +
																						 ISNULL(@strCity,'') + ISNULL(', '+@strState,'') + ISNULL(', '+@strZip,'') + ISNULL(', '+@strCountry,'')

													 ELSE								LTRIM(RTRIM(EY.strEntityName)) + ', ' + CHAR(13)+CHAR(10) +
																						ISNULL(LTRIM(RTRIM(EY.strEntityAddress)),'') + ', ' + CHAR(13)+CHAR(10) +
																						ISNULL(LTRIM(RTRIM(EY.strEntityCity)),'') + 
																						ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityState)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityState)) END,'') + 
																						ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityZipCode)) END,'') +
																						ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityCountry)) END,'')
											   END
			
			,strSeller					    = CASE WHEN CH.intContractTypeId = 1 THEN LTRIM(RTRIM(EY.strEntityName)) ELSE @strCompanyName END
			
			,strBuyer					    = CASE WHEN CH.intContractTypeId = 1 THEN @strCompanyName ELSE LTRIM(RTRIM(EY.strEntityName)) END

			,strQuantity					= dbo.fnRemoveTrailingZeroes(CH.dblQuantity)+' '+UM.strUnitMeasure+' NET'			
			
			,strWeightConditionLabel	    = CASE WHEN @intWeightConditionId >0      THEN 'WEIGHT QUALITY AND PACKING' ELSE NULL END 
			,strWeightConditionDesc			= CASE WHEN @intWeightConditionId >0      THEN  @strWeightConditionDesc     ELSE NULL END
			 
			,strDestinationLable			= CASE WHEN @intDestinationConditionId >0 THEN 'DESTINATION'				ELSE NULL END
			,strDestinationDesc				= CASE WHEN @intDestinationConditionId >0 THEN @strDestinationDesc			ELSE NULL END

			,strContainerclauseLabel	    = CASE WHEN @intContainerclauseId >0	  THEN 'CONTAINER CLAUSE'			ELSE NULL END 
			,strContainerclauseDesc			= CASE WHEN @intContainerclauseId >0	  THEN  @strContainerclauseDesc		ELSE NULL END

			,strPaymentLabel				= CASE WHEN @intPaymentId >0			  THEN 'PAYMENT'					ELSE NULL END 
			,strPaymentDesc					= CASE WHEN @intPaymentId >0			  THEN @strPaymentDesc				ELSE NULL END

			,strInsuranceLabel				= CASE WHEN @intInsuranceId >0			  THEN 'INSURANCE'					ELSE NULL END 
			,strInsuranceDesc				= CASE WHEN @intInsuranceId >0			  THEN @strInsuranceDesc			ELSE NULL END
											  
			,strForcemajeureLabel			= CASE WHEN @intForcemajeureId >0		  THEN 'FORCE MAJEURE'				ELSE NULL END 
			,strForcemajeureDesc			= CASE WHEN @intForcemajeureId >0		  THEN @strForcemajeureDesc			ELSE NULL END
											  
			,strTaxationLabel				= CASE WHEN @intTaxationId >0			  THEN 'TAXATION'					ELSE NULL END 
			,strTaxationDesc				= CASE WHEN @intTaxationId >0			  THEN @strTaxationDesc				ELSE NULL END
											  
			,strLicencesLabel				= CASE WHEN @intLicencesId >0			  THEN 'LICENCES'					ELSE NULL END 
			,strLicencesDesc				= CASE WHEN @intLicencesId >0			  THEN @strLicencesDesc				ELSE NULL END
											  
			,strArbitrationLabel			= CASE WHEN @intArbitrationId >0		  THEN 'ARBITRATION'				ELSE NULL END 
			,strArbitrationDesc				= CASE WHEN @intArbitrationId >0		  THEN @strArbitrationDesc			ELSE NULL END
											  
			,strRulesLabel				    = CASE WHEN @intRulesId >0				  THEN 'RULES'						ELSE NULL END 
			,strRulesDesc					= CASE WHEN @intRulesId >0				  THEN @strRulesDesc				ELSE NULL END
											  
			,strGeneralLabel				= CASE WHEN @intGeneralId >0			  THEN 'GENERAL'					ELSE NULL END 
			,strGeneralDesc					= CASE WHEN @intGeneralId >0			  THEN @strGeneralDesc				ELSE NULL END
			,strOrigin						= SQ.strCountry
			,strContractDocuments		    = @strContractDocuments 
			,strPriceText					= CASE 
													WHEN ISNULL(SQ.strFixationBy,'') <> '' AND CH.intPricingTypeId = 2 THEN SQ.strFixationBy +'''s Call vs '+dbo.fnRemoveTrailingZeroes(SQ.dblTotalNoOfLots)+' lots(s) of '+SQ.strFutMarketName + ' futures' 
													ELSE NULL 
											  END 
	
	FROM	tblCTContractHeader CH
	JOIN    tblICCommodityUnitMeasure  CU ON CU.intCommodityUnitMeasureId =CH.intCommodityUOMId
	JOIN    tblICUnitMeasure		   UM ON UM.intUnitMeasureId = CU.intUnitMeasureId

	JOIN	tblCTContractType	TP	ON	TP.intContractTypeId	=	CH.intContractTypeId
	JOIN	vyuCTEntity			EY	ON	EY.intEntityId			=	CH.intEntityId	AND
										EY.strEntityType		=	(CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END)	
    JOIN	(
				SELECT		     intRowNum			 = ROW_NUMBER() OVER (PARTITION BY CD.intContractHeaderId ORDER BY CD.intContractSeq ASC) 
							    ,intContractHeaderId = CD.intContractHeaderId
								,strCountry			 = Country.strCountry
							    ,strFixationBy		 = CD.strFixationBy
							    ,strFutMarketName	 = MA.strFutMarketName							
							    ,dblTotalNoOfLots     = (SELECT SUM(dblNoOfLots) FROM tblCTContractDetail WHERE intContractHeaderId = @intContractHeaderId)
				FROM		    tblCTContractDetail		CD
				LEFT JOIN		tblSMCity				City	ON	City.intCityId				=	CD.intLoadingPortId			
				LEFT JOIN		tblSMCountry			Country	ON	Country.intCountryID		=	City.intCountryId
				LEFT JOIN		tblRKFutureMarket		MA		ON	MA.intFutureMarketId		=	CD.intFutureMarketId		
			)SQ	ON	SQ.intContractHeaderId	=	CH.intContractHeaderId	AND  SQ.intRowNum = 1
	WHERE	CH.intContractHeaderId	=	@intContractHeaderId
	
	

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
