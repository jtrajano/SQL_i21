CREATE PROCEDURE [dbo].[uspLGGetShippingInstructionSalesInfoReport]
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
	   CH.strContractNumber,
	   CD.intContractSeq,
	   LD.dblQuantity,
	   UM.strUnitMeasure,
	   CASE WHEN ISNULL(IC.strContractItemName,'') = '' THEN I.strDescription ELSE IC.strContractItemName END AS strItemDescription,
	   CH.strCustomerContract AS strSCustomerContract
FROM tblLGLoad L
JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intSContractDetailId
JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
LEFT JOIN tblICItemContract IC ON IC.intItemContractId = CD.intItemContractId
LEFT JOIN tblICItem I ON I.intItemId = CD.intItemId
LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = LD.intItemUOMId
LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
WHERE L.intLoadId = @xmlParam and L.intPurchaseSale IN (2,3)
END

