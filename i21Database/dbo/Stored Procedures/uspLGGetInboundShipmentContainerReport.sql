CREATE PROCEDURE [dbo].[uspLGGetInboundShipmentContainerReport]
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

SELECT DISTINCT LC.strContainerNumber,
		LV.strBLNumber,
		LC.strMarks,
		LDV.*,
		LC.dblQuantity AS dblContainerContractQty,
		CD.strCustomerContract,
		CD.dtmContractDate,
		CD.strContractBasis,
		CD.strContractBasisDescription,
		CD.strApprovalBasis,
		LDV.strPContractNumber  + '/' +  CONVERT(NVARCHAR,LDV.intPContractSeq) AS strContractNumberWithSeq
FROM vyuLGLoadDetailView LDV
JOIN vyuLGLoadView LV ON LV.intLoadId = LDV.intLoadId
JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadDetailId = LDV.intLoadDetailId
JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = LDCL.intLoadContainerId
LEFT JOIN tblLGLoadWarehouseContainer LWC ON LWC.intLoadContainerId = LC.intLoadContainerId
LEFT JOIN tblLGLoadWarehouse LW ON LW.intLoadWarehouseId = LWC.intLoadWarehouseId
LEFT JOIN vyuCTContractDetailView CD ON CD.intContractDetailId = LDV.intPContractDetailId
WHERE LDV.strLoadNumber = @xmlParam	

UNION

SELECT DISTINCT LC.strContainerNumber,
		LV.strBLNumber,
		LC.strMarks,
		LDV.*,
		LC.dblQuantity AS dblContainerContractQty,
		CD.strCustomerContract,
		CD.dtmContractDate,
		CD.strContractBasis,
		CD.strContractBasisDescription,
		CD.strApprovalBasis,
		LDV.strPContractNumber  + '/' +  CONVERT(NVARCHAR,LDV.intPContractSeq) AS strContractNumberWithSeq
FROM vyuLGLoadDetailView LDV
JOIN vyuLGLoadView LV ON LV.intLoadId = LDV.intLoadId
JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadDetailId = LDV.intLoadDetailId
JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = LDCL.intLoadContainerId
LEFT JOIN tblLGLoadWarehouseContainer LWC ON LWC.intLoadContainerId = LC.intLoadContainerId
LEFT JOIN tblLGLoadWarehouse LW ON LW.intLoadWarehouseId = LWC.intLoadWarehouseId
LEFT JOIN vyuCTContractDetailView CD ON CD.intContractDetailId = LDV.intPContractDetailId
WHERE LW.strDeliveryNoticeNumber = @xmlParam	

END
