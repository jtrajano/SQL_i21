CREATE PROCEDURE uspICInventoryTransferReport @xmlParam NVARCHAR(MAX) = NULL
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
	v.*
	, CASE WHEN Location.strUseLocationAddress IS NULL OR
          Location.strUseLocationAddress = 'No' OR
          Location.strUseLocationAddress = '' OR
          Location.strUseLocationAddress = 'Always' 
	 THEN 
          (SELECT
				CASE 
					WHEN strAddress IS NULL OR strAddress = ' '
					THEN ''
					ELSE strAddress 
				 END + 
				 CASE 
					WHEN strCity IS NULL OR strCity = ' '
					THEN ''
					WHEN strAddress IS NULL OR strAddress = ' '
					THEN strCity
					ELSE', ' + strCity 
				 END + 
				 CASE 
					WHEN strState IS NULL OR strState = ' '
					THEN ''
					ELSE ', ' + strState 
				 END + 
				 CASE
					WHEN strZip IS NULL OR strZip = ' '
					THEN ''
					ELSE ', ' + strZip 
				 END + 
				 CASE 
					WHEN strCountry IS NULL OR strCountry = ' '
					THEN ''
					ELSE ', ' + strCountry
				 END
		   FROM    tblSMCompanySetup) 
	WHEN Location.strUseLocationAddress = 'Yes' 
	THEN 
	CASE 
					WHEN Location.strAddress IS NULL OR Location.strAddress = ' '
					THEN ''
					ELSE Location.strAddress 
				 END + 
				 CASE 
					WHEN Location.strCity IS NULL OR Location.strCity = ' '
					THEN ''
					WHEN Location.strAddress IS NULL OR Location.strAddress = ' '
					THEN Location.strCity
					ELSE', ' + Location.strCity 
				 END + 
				 CASE 
					WHEN Location.strStateProvince IS NULL OR Location.strStateProvince = ' '
					THEN ''
					ELSE ', ' + Location.strStateProvince 
				 END + 
				 CASE
					WHEN Location.strZipPostalCode IS NULL OR Location.strZipPostalCode = ' '
					THEN ''
					ELSE ', ' + Location.strZipPostalCode 
				 END + 
				 CASE 
					WHEN Location.strCountry IS NULL OR Location.strCountry = ' '
					THEN ''
					ELSE ', ' + Location.strCountry
				 END
	
	WHEN Location.strUseLocationAddress = 'Letterhead' 
	THEN '' END AS strCompanyAddress
	, ysnHasHeaderLogo = CAST(@HasHeaderLogo AS BIT)
FROM [vyuICGetInventoryTransferDetail] v
	LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = v.intFromLocationId
WHERE v.strTransferNo = @strTransferNo
ORDER BY dtmTransferDate DESC