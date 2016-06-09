CREATE PROCEDURE [dbo].[uspCTReportCleanCost]
	
	@xmlParam NVARCHAR(MAX) = NULL  
	
AS

BEGIN TRY
	
	DECLARE @ErrMsg NVARCHAR(MAX)
	
	 

	DECLARE @intCleanCostId	INT,
			@xmlDocumentId	INT,
			@blbFile		VARBINARY(MAX)
			
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
    
	SELECT	@intCleanCostId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intCleanCostId' 

	SELECT	@blbFile	=	B.blbFile 
	FROM	tblSMAttachment A 
	JOIN	tblSMUpload		B ON A.intAttachmentId = B.intAttachmentId
	WHERE	A.strScreen = 'SystemManager.CompanyPreference'
	AND		A.strComment = 'Header'

	SELECT		CC.*,
				CH.strContractNumber + ' - ' + LTRIM(CD.intContractSeq)  AS	strSequenceNumber,
				EY.strName,
				IR.strReceiptNumber,
				LG.strLoadNumber,
				@blbFile blbFile
	FROM		tblCTCleanCost CC
	LEFT JOIN	tblCTContractDetail		CD	ON	CD.intContractDetailId		=	CC.intContractDetailId
	LEFT JOIN	tblCTContractHeader		CH	ON	CH.intContractHeaderId		=	CD.intContractHeaderId
	LEFT JOIN	tblEMEntity				EY	ON	EY.intEntityId				=	CC.intEntityId
	LEFT JOIN	tblICInventoryReceipt	IR	ON	IR.intInventoryReceiptId	=	CC.intInventoryReceiptId
	LEFT JOIN	tblLGLoad				LG	ON	LG.intLoadId				=	CC.intShipmentId
	WHERE		CC.intCleanCostId	=	@intCleanCostId
	
END TRY

BEGIN CATCH
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  	
	--<?xml version="1.0" encoding="utf-16"?><xmlparam><filters><filter><fieldname>intCleanCostId</fieldname><condition>Equal To</condition><from>7</from><to /><join>And</join><begingroup /><endgroup /><datatype>Integer</datatype></filter></filters><options /></xmlparam>
END CATCH
GO