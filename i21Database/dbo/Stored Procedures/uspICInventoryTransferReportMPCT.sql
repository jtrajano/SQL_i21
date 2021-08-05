CREATE PROCEDURE uspICInventoryTransferReportMPCT @xmlParam NVARCHAR(MAX) = NULL
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF


DECLARE @intInventoryTransferId INT 
DECLARE @query NVARCHAR(MAX);
DECLARE @xmlDocumentId AS INT;

-- Sanitize the @xmlParam 
IF LTRIM(RTRIM(@xmlParam)) = '' 
BEGIN
--SET @xmlParam = NULL 
	SELECT *, CAST(0 AS BIT) ysnHasHeaderLogo FROM [vyuICGetInventoryTransferDetail] WHERE intInventoryTransferId = 1 --RETURN NOTHING TO RETURN SCHEMA
END

-- Create a table variable to hold the XML data. 		
DECLARE @temp_xml_table TABLE (
	id INT IDENTITY(1,1)
	,[fieldname] NVARCHAR(50)
	,condition NVARCHAR(20)      
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
	, [condition] nvarchar(20)
	, [from] nvarchar(50)
	, [to] nvarchar(50)
	, [join] nvarchar(10)
	, [datatype] nvarchar(50)
)

DECLARE @strTransferNo NVARCHAR(100)
SELECT @strTransferNo = [from]
FROM @temp_xml_table
WHERE [fieldname] = 'strTransferNo'


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

SELECT 
	dtmDeliveryDate 
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
	

	
	, ysnHasHeaderLogo = CAST(@HasHeaderLogo AS BIT)
FROM 
	[vyuICGetInventoryTransferDetail] v
	LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = v.intFromLocationId
WHERE 
	v.strTransferNo = @strTransferNo
ORDER BY 
	dtmTransferDate DESC