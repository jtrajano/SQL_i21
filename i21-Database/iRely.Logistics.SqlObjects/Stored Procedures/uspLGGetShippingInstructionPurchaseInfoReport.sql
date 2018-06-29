CREATE PROCEDURE [dbo].[uspLGGetShippingInstructionPurchaseInfoReport]
		@xmlParam NVARCHAR(MAX) = NULL  
AS
BEGIN
	--DECLARE @intReferenceNumber			INT,
	--		@xmlDocumentId				INT 
			
	--IF	LTRIM(RTRIM(@xmlParam)) = ''   
	--	SET @xmlParam = NULL   
      
	--DECLARE @temp_xml_table TABLE 
	--(  
	--		[fieldname]		NVARCHAR(50),  
	--		condition		NVARCHAR(20),        
	--		[from]			NVARCHAR(50), 
	--		[to]			NVARCHAR(50),  
	--		[join]			NVARCHAR(10),  
	--		[begingroup]	NVARCHAR(50),  
	--		[endgroup]		NVARCHAR(50),  
	--		[datatype]		NVARCHAR(50) 
	--)  
  
	--EXEC sp_xml_preparedocument @xmlDocumentId output, @xmlParam  
  
	--INSERT INTO @temp_xml_table  
	--SELECT	*  
	--FROM	OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2)  
	--WITH (  
	--			[fieldname]		NVARCHAR(50),  
	--			condition		NVARCHAR(20),        
	--			[from]			NVARCHAR(50), 
	--			[to]			NVARCHAR(50),  
	--			[join]			NVARCHAR(10),  
	--			[begingroup]	NVARCHAR(50),  
	--			[endgroup]		NVARCHAR(50),  
	--			[datatype]		NVARCHAR(50)  
	--)  
    
	--SELECT	@intReferenceNumber = [from]
	--FROM	@temp_xml_table   
	--WHERE	[fieldname] = 'intReferenceNumber' 

SELECT L.intLoadId,
	   LD.intPContractDetailId AS intContractDetailId,
	   CT.strContractNumber,
	   CT.intContractSeq,
	   LD.dblQuantity,
	   UM.strUnitMeasure,
	   CASE WHEN ISNULL(CT.strContractItemName,'') = '' THEN CT.strItemDescription ELSE CT.strContractItemName END AS strItemDescription,
	   CT.strCustomerContract AS strPCustomerContract
FROM tblLGLoad L
JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = LD.intItemUOMId
LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
LEFT JOIN vyuCTContractDetailView CT ON CT.intContractDetailId = LD.intPContractDetailId
WHERE L.intLoadId = @xmlParam and L.intPurchaseSale IN (1,3)
END
