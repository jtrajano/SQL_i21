﻿CREATE PROCEDURE [dbo].[uspLGGetShippingInstructionSalesInfoReport]
		@xmlParam NVARCHAR(MAX) = NULL  
AS
BEGIN
	DECLARE @intReferenceNumber			INT,
			@xmlDocumentId				INT 
			
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
    
	SELECT	@intReferenceNumber = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intReferenceNumber' 

SELECT 
	SICQ.intShippingInstructionId,
	SICQ.intContractDetailId,
	CT.strContractNumber,
	CT.intContractSeq,
	SICQ.dblQuantity,
	UOM.strUnitMeasure,
	CT.strItemDescription

FROM	tblLGShippingInstructionContractQty SICQ
JOIN	tblLGShippingInstruction SI ON SI.intShippingInstructionId = SICQ.intShippingInstructionId
JOIN	vyuCTContractDetailView CT ON CT.intContractDetailId = SICQ.intContractDetailId
JOIN	tblICUnitMeasure UOM ON UOM.intUnitMeasureId = SICQ.intUnitMeasureId
WHERE 	SI.intReferenceNumber = @intReferenceNumber and SICQ.intPurchaseSale = 2
END

