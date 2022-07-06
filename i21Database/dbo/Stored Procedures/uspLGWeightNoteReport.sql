CREATE PROCEDURE [dbo].[uspLGWeightNoteReport]
	@xmlParam NVARCHAR(MAX) = NULL
AS
BEGIN
	-- Sanitize the @xmlParam   
	IF LTRIM(RTRIM(@xmlParam)) = ''   
	 SET @xmlParam = NULL   
  
	-- Declare the variables.  
	DECLARE @intContainerId AS NVARCHAR(MAX)
  
	-- Declare the variables for the XML parameter  
	DECLARE @xmlDocumentId AS INT  
    
	-- Create a table variable to hold the XML data.     
	DECLARE @temp_xml_table TABLE (  
	 [fieldname] NVARCHAR(50)  
	 ,condition NVARCHAR(20)        
	 ,[from] NVARCHAR(max)  
	 ,[to] NVARCHAR(max)  
	 ,[join] NVARCHAR(10)  
	 ,[begingroup] NVARCHAR(50)  
	 ,[endgroup] NVARCHAR(50)  
	 ,[datatype] NVARCHAR(50)  
	)  
  
	-- Prepare the XML   
	EXEC sp_xml_preparedocument @xmlDocumentId output, @xmlParam  
  
	-- Insert the XML to the xml table.     
	INSERT INTO @temp_xml_table  
	SELECT *  
	FROM OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2)  
	WITH (  
	 [fieldname] nvarchar(50)  
	 , condition nvarchar(20)  
	 , [from] nvarchar(max)  
	 , [to] nvarchar(max)  
	 , [join] nvarchar(10)  
	 , [begingroup] nvarchar(50)  
	 , [endgroup] nvarchar(50)  
	 , [datatype] nvarchar(50)  
	)  
  
	-- Gather the variables values from the xml table.   
	SELECT @intContainerId = [from]  
	FROM @temp_xml_table   
	WHERE [fieldname] = 'intContainerId' 

	-- Get Container Ids
	DECLARE @containerIds Id
	INSERT INTO @containerIds (intId) SELECT CONVERT(INT, Item) FROM [dbo].fnSplitString(@intContainerId, ',')

	-- Report Query:  
	SELECT
		LC.intLoadContainerId
		,strContractNumber = CH.strContractNumber + '/' + CAST(CD.intContractSeq AS NVARCHAR(10))
		,strSupplier = E.strName
		,strAttn = EC.strName
		,strSupplierReference = CH.strCustomerContract
		,strItemDescription = I.strDescription
		,dtmReceiptDate = ISNULL(PC.dtmReceiptDate, IR.dtmReceiptDate)
		,LC.strContainerNumber
		,LC.strMarks
		,LC.strSealNumber
		,strWarehouse = IR.strStorageLocation
		,IR.dblQuantity
		,IR.strQtyUOM
		,dblDamagedQty = ISNULL(DBags.dblDamagedQty, 0)
		,dblDamagedNet = ISNULL(DBags.dblDamagedNet, 0)
		,dblSlackQty = ISNULL(SBags.dblSlackQty, 0)
		,dblNet = ISNULL(PC.dblReceivedNetWt, IR.dblNet)
		,IR.strWeightUOM
		,blbFooterLogo = Footer.blbFile
	FROM 
		tblLGLoadContainer LC
		INNER JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadContainerId = LC.intLoadContainerId
		INNER JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = LDCL.intLoadDetailId
		INNER JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
		LEFT JOIN tblLGPendingClaim PC ON PC.intLoadContainerId = LC.intLoadContainerId
		LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
		LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
		LEFT JOIN tblEMEntity E ON E.intEntityId = CH.intEntityId
		LEFT JOIN tblEMEntityToContact ETC ON ETC.intEntityId = E.intEntityId AND ETC.ysnDefaultContact = 1
		LEFT JOIN tblEMEntity EC ON EC.intEntityId = ISNULL(CH.intEntityContactId, ETC.intEntityContactId)
		LEFT JOIN tblICItem I ON I.intItemId = CD.intItemId
		OUTER APPLY (SELECT TOP 1 
						iri.intInventoryReceiptItemId
						,ir.strReceiptNumber
						,ir.dtmReceiptDate
						,dblQuantity = iri.dblOpenReceive
						,strQtyUOM = um.strUnitMeasure
						,strWeightUOM = wum.strUnitMeasure
						,iri.dblNet
						,strStorageLocation = clsl.strSubLocationName 
					 FROM tblICInventoryReceiptItem iri 
						INNER JOIN tblICInventoryReceipt ir ON ir.intInventoryReceiptId = iri.intInventoryReceiptId
						LEFT JOIN tblICItemUOM uom ON uom.intItemUOMId = iri.intUnitMeasureId
						LEFT JOIN tblICUnitMeasure um ON um.intUnitMeasureId = uom.intUnitMeasureId
						LEFT JOIN tblICItemUOM wuom ON wuom.intItemUOMId = iri.intWeightUOMId
						LEFT JOIN tblICUnitMeasure wum ON wuom.intUnitMeasureId = wum.intUnitMeasureId
						LEFT JOIN tblSMCompanyLocationSubLocation clsl ON clsl.intCompanyLocationSubLocationId = iri.intSubLocationId
					WHERE ir.ysnPosted = 1 AND iri.intOrderId = CH.intContractHeaderId 
						AND ir.strReceiptType <> 'Inventory Return'
						AND iri.intContainerId = LC.intLoadContainerId
					ORDER BY ir.dtmReceiptDate DESC) IR
		OUTER APPLY (SELECT dblDamagedQty = SUM(ISNULL(dblQuantity, 0))
							,dblDamagedNet = SUM(ISNULL(iril.dblGrossWeight, 0) - ISNULL(iril.dblTareWeight, 0)) 
					 FROM tblICLot lot 
						INNER JOIN tblICInventoryReceiptItemLot iril ON iril.intLotId = lot.intLotId
					 WHERE iril.intInventoryReceiptItemId = IR.intInventoryReceiptItemId AND lot.strCondition = 'Damaged') DBags
		OUTER APPLY (SELECT dblSlackQty = SUM(dblQuantity) FROM tblICLot lot 
						INNER JOIN tblICInventoryReceiptItemLot iril ON iril.intLotId = lot.intLotId
						WHERE iril.intInventoryReceiptItemId = IR.intInventoryReceiptItemId AND lot.strCondition = 'Slack') SBags
		OUTER APPLY (SELECT TOP 1 blbFile FROM dbo.vyuSMCompanyLogo WHERE strComment = 'Weight Note Footer') Footer
	WHERE LC.intLoadContainerId IN (SELECT intId FROM @containerIds)
END
GO
