CREATE PROCEDURE [dbo].[uspCTReportAmendment]
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
			@strSequenceHistoryId	     NVARCHAR(MAX),
			@xmlDocumentId			     INT,
			@strAmendmentNumber			 NVARCHAR(50),
			@intMinContractHeaderId		 INT
			
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

	DECLARE @tblSequenceHistoryId TABLE
	(
	  intSequenceAmendmentLogId INT
	)  
    DECLARE @tblAmendment TABLE
	(
	   intContractHeaderId INT
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
	SELECT	@strSequenceHistoryId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'strSequenceHistoryId'

	INSERT INTO @tblSequenceHistoryId
	(
	  intSequenceAmendmentLogId
	)
	SELECT strValues FROM dbo.fnARGetRowsFromDelimitedValues(@strSequenceHistoryId)
	
	WHILE 
				EXISTS(
						SELECT 1 FROM tblCTSequenceAmendmentLog SH 
						JOIN @tblSequenceHistoryId tblSequenceHistory ON tblSequenceHistory.intSequenceAmendmentLogId = SH.intSequenceAmendmentLogId
						WHERE SH.strAmendmentNumber IS NULL 
					  )
	BEGIN
					  
					  INSERT INTO @tblAmendment(intContractHeaderId)
					  SELECT DISTINCT SH.intContractHeaderId 
					  FROM tblCTSequenceAmendmentLog SH 
					  JOIN @tblSequenceHistoryId tblSequenceHistory ON tblSequenceHistory.intSequenceAmendmentLogId = SH.intSequenceAmendmentLogId
					  WHERE SH.strAmendmentNumber IS NULL

					  SELECT @intMinContractHeaderId=MIN(intContractHeaderId) FROM @tblAmendment
					  
					  WHILE @intMinContractHeaderId >0
					  BEGIN
								SET @strAmendmentNumber=NULL

								SELECT @strAmendmentNumber = strPrefix+LTRIM(intNumber)
								FROM tblSMStartingNumber
								WHERE [strTransactionType] = N'Amendment Number'

								UPDATE tblSMStartingNumber
								SET intNumber = intNumber + 1
								WHERE [strTransactionType] = N'Amendment Number'

								UPDATE tblCTSequenceAmendmentLog
								SET strAmendmentNumber=@strAmendmentNumber
								FROM tblCTSequenceAmendmentLog SH 
								JOIN @tblSequenceHistoryId tblSequenceHistory ON tblSequenceHistory.intSequenceAmendmentLogId = SH.intSequenceAmendmentLogId
								WHERE SH.strAmendmentNumber IS NULL AND SH.intContractHeaderId = @intMinContractHeaderId

								SELECT @intMinContractHeaderId=MIN(intContractHeaderId) FROM @tblAmendment WHERE intContractHeaderId >@intMinContractHeaderId
					  END
	   

	END

	SELECT	@strCompanyName	=	CASE WHEN LTRIM(RTRIM(strCompanyName)) = '' THEN NULL ELSE LTRIM(RTRIM(strCompanyName)) END,
			@strAddress		=	CASE WHEN LTRIM(RTRIM(strAddress)) = '' THEN NULL ELSE LTRIM(RTRIM(strAddress)) END,
			@strCounty		=	CASE WHEN LTRIM(RTRIM(strCounty)) = '' THEN NULL ELSE LTRIM(RTRIM(strCounty)) END,
			@strCity		=	CASE WHEN LTRIM(RTRIM(strCity)) = '' THEN NULL ELSE LTRIM(RTRIM(strCity)) END,
			@strState		=	CASE WHEN LTRIM(RTRIM(strState)) = '' THEN NULL ELSE LTRIM(RTRIM(strState)) END,
			@strZip			=	CASE WHEN LTRIM(RTRIM(strZip)) = '' THEN NULL ELSE LTRIM(RTRIM(strZip)) END,
			@strCountry		=	CASE WHEN LTRIM(RTRIM(strCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(strCountry)) END
	FROM	tblSMCompanySetup

	SELECT	DISTINCT
			strC =   
					 CASE	
					 		WHEN	CH.intContractTypeId  =	1	THEN	'BUYER'
					 		WHEN	CH.intContractTypeId  =	2   THEN	'SELLER'
					 END

		    ,strD = 
					 CASE	
							WHEN	CH.intContractTypeId  =	1   THEN	'SELLER'
					 		WHEN	CH.intContractTypeId  =	2   THEN	'BUYER'
					 END

		    ,strA  =  @strCompanyName + ', '  + CHAR(13)+CHAR(10) +
					 ISNULL(@strAddress,'') + ', ' + CHAR(13)+CHAR(10) +
					 ISNULL(@strCity,'') + ISNULL(', '+@strState,'') + ISNULL(', '+@strZip,'') + ISNULL(', '+@strCountry,'')

			,strB = LTRIM(RTRIM(AH.strEntityName)) + ', ' + CHAR(13)+CHAR(10) +
			        ISNULL(LTRIM(RTRIM(EY.strEntityAddress)),'') + ', ' + CHAR(13)+CHAR(10) +
			        ISNULL(LTRIM(RTRIM(EY.strEntityCity)),'') + 
			        ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityState)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityState)) END,'') + 
			        ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityZipCode)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityZipCode)) END,'') + 
			        ISNULL(', '+CASE WHEN LTRIM(RTRIM(EY.strEntityCountry)) = '' THEN NULL ELSE LTRIM(RTRIM(EY.strEntityCountry)) END,'')
			

			,strHeaderTitle     =   CASE	
										WHEN	AH.intContractTypeId  =	1	THEN	'Purchase Contract Amendment'
										WHEN	AH.intContractTypeId  =	2   THEN	'Sale Contract Amendment'
								    END
			
			,dtmContractDate    =  Convert(Nvarchar,GetDATE(),101)
			,strContractNumber  = AH.strContractNumber
			,AccountNum		    = EY.strVendorAccountNum
			,strAmendmentNumber = AH.strAmendmentNumber
			,strConfirmMessage  = 'We Confirm ADJUSTMENT from you as follows:'
			,strAmendmentText   = TX.strAmendmentText
			,dtmHistoryCreated  = AH.dtmHistoryCreated
			,intContractSeq     = CD.intContractSeq
			,strItemChanged	    = AH.strItemChanged
			,strOldValue        = AH.strOldValue
			,strNewValue	    = AH.strNewValue
			,strE			    = @strCompanyName
			,strF		        = AH.strEntityName	
			,blbHeaderLogo		= dbo.fnSMGetCompanyLogo('Header')

	FROM	vyuCTAmendmentHistory AH
	JOIN tblCTContractHeader					CH ON CH.intContractHeaderId = AH.intContractHeaderId
	JOIN	vyuCTEntity							EY	ON	EY.intEntityId						=		AH.intEntityId			AND
														-------------------------------------------------------------------------------------------
														--Comment this code and replaced it with a CASE-WHEN statement to improve cardinality. 
														--EY.strEntityType					=		(CASE WHEN AH.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END) LEFT
														-------------------------------------------------------------------------------------------
														1 = (
															CASE 
																WHEN AH.intContractTypeId = 1 AND EY.strEntityType  = 'Vendor' THEN 1 
																WHEN AH.intContractTypeId <> 1 AND EY.strEntityType = 'Customer' THEN 1 
																ELSE 0
															END
														)
	JOIN @tblSequenceHistoryId tblSequenceHistory ON tblSequenceHistory.intSequenceAmendmentLogId = AH.intSequenceAmendmentLogId
	LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = AH.intContractDetailId
	LEFT JOIN tblCTContractText	  TX ON	TX.intContractTextId   = CH.intContractTextId

END TRY

BEGIN CATCH

	SET @ErrMsg = 'uspCTReportAmendment - ' + ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH