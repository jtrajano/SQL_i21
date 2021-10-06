CREATE PROCEDURE uspICInventoryTransferDetailReportMPCT 
	@xmlParam NVARCHAR(MAX) = NULL
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON


DECLARE @intInventoryTransferId INT 
DECLARE @query NVARCHAR(MAX);
DECLARE @xmlDocumentId AS INT;

-- Sanitize the @xmlParam 
IF LTRIM(RTRIM(@xmlParam)) = '' 
BEGIN	
	SELECT 
		strTransferNo
		,dtmTransferDate
		,strCarrier
		,strAttn
		,dtmDeliveryDate
		,strPONumber
		,strSupplierRef
		,strItemNo
		,strItemDescription
		,strMotherLotNumber
		,strLotNumber
		,strContainerNumber
		,strMarks
		,dblQuantity
		,strQuantityUOM
		,dblWeight
		,strWeightUOM
		,dtmReceiptDate		
		,CAST(0 AS BIT) ysnHasHeaderLogo 
		,strWarehouse
		,strDeliveryInstructions
		,strApproxValue
		,strDescription
		,strCondition = CAST(NULL AS NVARCHAR(MAX)) 
	FROM 
		vyuICGetInventoryTransferDetailReportMPCT 
	WHERE 
		1 = 0 --RETURN NOTHING TO RETURN SCHEMA
END

-- Create a table variable to hold the XML data. 		
DECLARE @temp_xml_table TABLE (
	id INT IDENTITY(1,1)
	,[fieldname] NVARCHAR(50)
	,condition NVARCHAR(40)      
	,[from] NVARCHAR(50)
	,[to] NVARCHAR(50)
	,[join] NVARCHAR(10)
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
	, [condition] nvarchar(40)
	, [from] nvarchar(50)
	, [to] nvarchar(50)
	, [join] nvarchar(10)
	, [datatype] nvarchar(50)
)

DECLARE @strTransferNo NVARCHAR(100)

SELECT 
	@strTransferNo = [from]
FROM 
	@temp_xml_table
WHERE 
	[fieldname] = 'strTransferNo'


IF EXISTS(SELECT 1 FROM @temp_xml_table)
BEGIN
	SELECT 
		@intInventoryTransferId = CASE WHEN ISNULL([from],'') = '' THEN NULL ELSE [from] END
	FROM @temp_xml_table WHERE [fieldname] = 'intInventoryTransferId'
END

DECLARE @HasHeaderLogo BIT

IF EXISTS(SELECT TOP 1 1 FROM vyuSMCompanyLogo WHERE strComment = 'HeaderLogo')
	SET @HasHeaderLogo = 1
ELSE
	SET @HasHeaderLogo = 0

DECLARE @strCondition AS NVARCHAR(MAX) 
SELECT 
	@strCondition = ISNULL(@strCondition, '') + ISNULL(c.strDescription, '') 
FROM 
	tblICInventoryTransfer t INNER JOIN tblICInventoryTransferCondition c
		ON t.intInventoryTransferId = c.intInventoryTransferId
WHERE
	t.strTransferNo = @strTransferNo
ORDER BY
	c.intInventoryTransferConditionId ASC 
	
SELECT 
	strTransferNo
	,dtmTransferDate
	,strCarrier
	,strAttn	
	,dtmDeliveryDate
	,strPONumber
	,strSupplierRef
	,strItemNo
	,strItemDescription
	,strMotherLotNumber
	,strLotNumber
	,strContainerNumber
	,strMarks
	,dblQuantity
	,strQuantityUOM
	,dblWeight
	,strWeightUOM
	,dtmReceiptDate
	,ysnHasHeaderLogo = CAST(@HasHeaderLogo AS BIT)
	,strWarehouse
	,strDeliveryInstructions
	,strApproxValue
	,strDescription
	,strCondition = @strCondition
FROM 
	vyuICGetInventoryTransferDetailReportMPCT v
WHERE 
	v.strTransferNo = @strTransferNo
ORDER BY 
	dtmDeliveryDate ASC
	,intInventoryTransferDetailId ASC 