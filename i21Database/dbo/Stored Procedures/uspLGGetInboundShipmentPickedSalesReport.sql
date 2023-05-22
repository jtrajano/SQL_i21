CREATE PROCEDURE [dbo].[uspLGGetInboundShipmentPickedSalesReport]
		@xmlParam NVARCHAR(MAX) = NULL,
		@xmlParam2 INT = NULL 
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

SELECT 
	L.strLoadNumber
	,PLD.intContainerId
	,PLD.intLotId
	,LC.strContainerNumber
	,strSContractNumber = SCH.strContractNumber
	,intSContractSeq = SCD.intContractSeq
	,strSItemNo = SIM.strItemNo
	,strSItemDescription = SIM.strDescription
	,strSItemDescriptionSpecification = SIM.strDescription + ' - ' + ISNULL(SCD.strItemSpecification,'')
	,ALD.dblSAllocatedQty
	,ALD.intSUnitMeasureId
	,PLD.dblSalePickedQty
	,strSItemUOM = SUOM.strUnitMeasure
	,ALD.dblPAllocatedQty
	,ALD.intPUnitMeasureId
	,strPItemUOM = PUOM.strUnitMeasure
	,strPContractNumber = SCH.strContractNumber
	,intPContractSeq = SCD.intContractSeq
FROM tblLGLoadContainer LC
	INNER JOIN tblLGLoad L ON L.intLoadId = LC.intLoadId
	INNER JOIN tblLGPickLotDetail PLD ON PLD.intContainerId = LC.intLoadContainerId
	INNER JOIN tblLGPickLotHeader PLH ON PLH.intPickLotHeaderId = PLD.intPickLotHeaderId
	LEFT JOIN tblLGAllocationDetail ALD ON ALD.intAllocationDetailId = PLD.intAllocationDetailId
	LEFT JOIN tblCTContractDetail SCD ON SCD.intContractDetailId = ALD.intSContractDetailId
	LEFT JOIN tblCTContractHeader SCH ON SCH.intContractHeaderId = SCD.intContractHeaderId
	LEFT JOIN tblCTContractDetail PCD ON PCD.intContractDetailId = ALD.intPContractDetailId
	LEFT JOIN tblCTContractHeader PCH ON PCH.intContractHeaderId = PCD.intContractHeaderId
	LEFT JOIN tblICUnitMeasure SUOM ON SUOM.intUnitMeasureId = ALD.intSUnitMeasureId
	LEFT JOIN tblICUnitMeasure PUOM ON PUOM.intUnitMeasureId = ALD.intPUnitMeasureId
	LEFT JOIN tblICItem SIM ON SIM.intItemId = SCD.intItemId
WHERE 
	PLH.intType = 2
	AND L.strLoadNumber = @xmlParam	
	AND (ISNULL(@xmlParam2, 0) = 0 
	OR (ISNULL(@xmlParam2, 0) > 0 AND @xmlParam2 = PLH.intCustomerEntityId)
	OR (ISNULL(@xmlParam2, 0) < 0 AND PLH.intCustomerEntityId IS NULL))

END
