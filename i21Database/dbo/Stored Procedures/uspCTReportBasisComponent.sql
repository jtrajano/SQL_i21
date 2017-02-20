﻿CREATE PROCEDURE [dbo].[uspCTReportBasisComponent]
	@xmlParam NVARCHAR(MAX) = NULL  
AS
	DECLARE @intContractDetailId NVARCHAR(MAX),
			@xmlDocumentId	INT

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
    
	SELECT	@intContractDetailId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intContractDetailId'

	SELECT  CD.strContractNumber + ' - ' + LTRIM(CD.intContractSeq) strContractSeq,
			CD.strERPPONumber,
			CD.dtmStartDate,
			CD.dtmEndDate,
			CD.strCustomerVendor,
			CD.strItemNo,
			CD.dblDetailQuantity,
			CD.strItemUOM,
			CD.dblNetWeight,
			CD.strWeightUOM,

			CD.strContractItemName, 
			CD.strContractItemNo,
			CD.strFutMarketName, 
			CD.strFutureMonth,
			CD.dblFutures,
			CD.strCurrency,
			BI.strItemNo	AS strComponentItem,
			CC.dblRate,
			CD.strPriceUOM,
			CD.dblBasis,
			CD.dblCashPrice
	FROM	vyuCTSearchContractDetail	CD
	JOIN	tblCTContractCost			CC	ON	CC.intContractDetailId	=	CD.intContractDetailId
	JOIN	tblICItem					BI	ON	BI.intItemId			=	CC.intItemId
	WHERE	CC.ysnBasis	=	1 
	AND		CD.intContractDetailId IN (SELECT * FROM dbo.fnSplitString(@intContractDetailId,','))