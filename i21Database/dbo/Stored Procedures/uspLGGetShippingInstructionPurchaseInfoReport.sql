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
	   CH.strContractNumber,
	   CD.intContractSeq,
	   LD.dblQuantity,
	   UM.strUnitMeasure,
	   CASE WHEN ISNULL(IC.strContractItemName,'') = '' THEN IM.strDescription ELSE IC.strContractItemName END AS strItemDescription,
	   CH.strCustomerContract AS strPCustomerContract,
	   CD.strItemSpecification,
	   CH.strContractNumber + ' / ' + LTRIM(CD.intContractSeq) AS strContractNumberWithSeq,
	   LTRIM(dbo.fnRemoveTrailingZeroes(LD.dblQuantity)) + ' ' + UM.strUnitMeasure AS strQtyInformation,
	   CASE WHEN ISNULL(CD.strItemSpecification,'') = '' THEN '' ELSE CH.strContractNumber + ' / ' + LTRIM(CD.intContractSeq) + ' ;' + CD.strItemSpecification END AS strContractWithItemSpecification,
	   CD.dtmStartDate,
	   CD.dtmEndDate,
	   strItemOrigin = ItemOrigin.strDescription,
	   strContractCertifications =
			STUFF((SELECT ',' + ICC.strCertificationName
			FROM tblCTContractCertification CTC
			LEFT JOIN tblICCertification ICC ON ICC.intCertificationId = CTC.intCertificationId
			WHERE CTC.intContractDetailId = CD.intContractDetailId FOR XML PATH('')), 1, 1, '')
FROM tblLGLoad L
JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = LD.intItemUOMId
LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
LEFT JOIN tblICItem IM ON IM.intItemId = CD.intItemId
LEFT JOIN tblICItemContract	IC ON IC.intItemContractId = CD.intItemContractId
LEFT JOIN tblICCommodityAttribute ItemOrigin ON ItemOrigin.intCommodityAttributeId = IM.intOriginId
WHERE L.intLoadId = @xmlParam and L.intPurchaseSale IN (1,3)
END