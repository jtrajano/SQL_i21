CREATE PROCEDURE [dbo].[uspApiSchemaTransformCustomerPricing] (
      @guiApiUniqueId UNIQUEIDENTIFIER
    , @guiLogId UNIQUEIDENTIFIER
)
AS

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET ANSI_WARNINGS OFF
SET XACT_ABORT ON

-- Validate Entity No and Customer Name
INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Entity No.'
    , strValue = SCSP.strEntityNo
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SCSP.intRowNumber
    , strMessage = 'Customer No. or Customer Name must have a value.'
FROM tblApiSchemaCustomerPricing SCSP
WHERE SCSP.guiApiUniqueId = @guiApiUniqueId
AND RTRIM(LTRIM(ISNULL(SCSP.strEntityNo, ''))) = '' 
AND RTRIM(LTRIM(ISNULL(SCSP.strCustomerName, ''))) = '' 

INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
	  guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Entity No'
    , strValue = SCSP.strEntityNo
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SCSP.intRowNumber
    , strMessage = 'Customer No. ('+ SCSP.strEntityNo + ') does not exists.'
FROM tblApiSchemaCustomerPricing SCSP
WHERE SCSP.guiApiUniqueId = @guiApiUniqueId
AND RTRIM(LTRIM(ISNULL(SCSP.strEntityNo, ''))) <> '' 
AND NOT EXISTS (SELECT TOP 1 NULL FROM tblARCustomer C WHERE C.strCustomerNumber = SCSP.strEntityNo)

INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
	  guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Customer Name'
    , strValue = SCSP.strCustomerName
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SCSP.intRowNumber
    , strMessage = 'Customer Name ('+ SCSP.strCustomerName + ') does not exists.'
FROM tblApiSchemaCustomerPricing SCSP
WHERE SCSP.guiApiUniqueId = @guiApiUniqueId
AND RTRIM(LTRIM(ISNULL(SCSP.strCustomerName, ''))) <> '' 
AND NOT EXISTS (SELECT TOP 1 NULL FROM tblEMEntity C WHERE C.strName = SCSP.strCustomerName)

INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
	  guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Customer Name'
    , strValue = SCSP.strCustomerName
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SCSP.intRowNumber
    , strMessage = 'Customer No. and Customer Name does not match.'
FROM tblApiSchemaCustomerPricing SCSP
WHERE SCSP.guiApiUniqueId = @guiApiUniqueId
AND RTRIM(LTRIM(ISNULL(SCSP.strEntityNo, ''))) <> '' 
AND RTRIM(LTRIM(ISNULL(SCSP.strCustomerName, ''))) <> '' 
AND SCSP.strCustomerName <> (SELECT TOP 1 E.strName 
							 FROM tblARCustomer C 
									INNER JOIN
								  tblEMEntity E
							 ON C.intEntityId = E.intEntityId
						     WHERE C.strCustomerNumber = SCSP.strEntityNo)

--Validate Customer Location
INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Customer Location'
    , strValue = SCSP.strCustomerLocation
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SCSP.intRowNumber
    , strMessage = 'Customer Location ('+ SCSP.strCustomerLocation + ') does not exists.'
FROM tblApiSchemaCustomerPricing SCSP
WHERE SCSP.guiApiUniqueId = @guiApiUniqueId
AND RTRIM(LTRIM(ISNULL(SCSP.strCustomerLocation, ''))) <> ''
AND RTRIM(LTRIM(ISNULL(SCSP.strEntityNo, ''))) <> ''
AND NOT EXISTS (SELECT TOP 1 NULL 
				FROM tblEMEntity E
					INNER JOIN tblEMEntityLocation EL 
				ON E.intEntityId = EL.intEntityId
				WHERE E.strEntityNo = SCSP.strEntityNo AND
					RTRIM(LTRIM(LOWER(EL.strLocationName))) = RTRIM(LTRIM(LOWER(SCSP.strCustomerLocation))))

INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Customer Location'
    , strValue = SCSP.strCustomerLocation
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SCSP.intRowNumber
    , strMessage = 'Customer Location ('+ SCSP.strCustomerLocation + ') does not exists.'
FROM tblApiSchemaCustomerPricing SCSP
WHERE SCSP.guiApiUniqueId = @guiApiUniqueId
AND RTRIM(LTRIM(ISNULL(SCSP.strCustomerLocation, ''))) <> ''
AND RTRIM(LTRIM(ISNULL(SCSP.strCustomerName, ''))) <> ''
AND NOT EXISTS (SELECT TOP 1 NULL 
				FROM tblEMEntity E
					INNER JOIN tblEMEntityLocation EL 
				ON E.intEntityId = EL.intEntityId
				WHERE E.strName = SCSP.strCustomerName AND
					RTRIM(LTRIM(LOWER(EL.strLocationName))) = RTRIM(LTRIM(LOWER(SCSP.strCustomerLocation))))


--Validate Price Basis
INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Price Basis'
    , strValue = SCSP.strPriceBasis
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SCSP.intRowNumber
    , strMessage = 'Price Basis ('+ SCSP.strPriceBasis + ') does not exists. Use one in IN (Maximum, Fixed, Inventory Cost + Pct, Inventory Cost + Amt, Sell - Pct, Sell - Amt, Fixed Rack + Amount, Vendor Rack + Amt, Transport Rack + Amt, Link, Origin Rack + Amt)'
FROM tblApiSchemaCustomerPricing SCSP
WHERE SCSP.guiApiUniqueId = @guiApiUniqueId
AND RTRIM(LTRIM(ISNULL(SCSP.strPriceBasis, ''))) <> '' 
AND SCSP.strPriceBasis NOT IN ('Maximum', 'Fixed', 'Inventory Cost + Pct', 'Inventory Cost + Amt', 'Sell - Pct', 'Sell - Amt', 'Fixed Rack + Amount', 'Vendor Rack + Amt', 'Transport Rack + Amt', 'Link', 'Origin Rack + Amt')


--Validate Cost to Use
INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Cost to Use'
    , strValue = SCSP.strCostToUse
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SCSP.intRowNumber
    , strMessage = 'Cost to Use ('+ SCSP.strCostToUse + ') does not exists. Use one in IN (Last, Average, Standard, Vendor, Jobber)'
FROM tblApiSchemaCustomerPricing SCSP
WHERE SCSP.guiApiUniqueId = @guiApiUniqueId
AND RTRIM(LTRIM(ISNULL(SCSP.strCostToUse, ''))) <> ''
AND SCSP.strCostToUse NOT IN ('Last', 'Average', 'Standard', 'Vendor', 'Jobber')

--Validate Vendor Number
INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Origin Vendor No.'
    , strValue = SCSP.strCostToUse
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SCSP.intRowNumber
    , strMessage = 'Origin Vendor No. ('+ SCSP.strVendorNumber + ') does not exists.'
FROM tblApiSchemaCustomerPricing SCSP
WHERE SCSP.guiApiUniqueId = @guiApiUniqueId
AND RTRIM(LTRIM(ISNULL(SCSP.strVendorNumber, ''))) <> ''
AND NOT EXISTS (SELECT TOP 1 NULL 
				FROM tblEMEntity E
					INNER JOIN (SELECT intEntityId FROM tblEMEntityType WHERE strType = 'Vendor') ET
				ON E.intEntityId = ET.intEntityId
				WHERE E.strEntityNo = SCSP.strVendorNumber)

--Validate Vendor Location
INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Origin Vendor Location'
    , strValue = SCSP.strVendorLocation
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SCSP.intRowNumber
    , strMessage = 'Origin Vendor Location ('+ SCSP.strVendorLocation + ') does not exists.'
FROM tblApiSchemaCustomerPricing SCSP
WHERE SCSP.guiApiUniqueId = @guiApiUniqueId
AND RTRIM(LTRIM(ISNULL(SCSP.strVendorLocation, ''))) <> ''
AND NOT EXISTS (SELECT TOP 1 NULL 
				FROM tblEMEntity E
					INNER JOIN (SELECT intEntityId FROM tblEMEntityType WHERE strType = 'Vendor') ET
				ON E.intEntityId = ET.intEntityId
					INNER JOIN tblEMEntityLocation EL 
				ON E.intEntityId = EL.intEntityId
				WHERE E.strEntityNo = SCSP.strVendorNumber AND
					  RTRIM(LTRIM(LOWER(EL.strLocationName))) = RTRIM(LTRIM(LOWER(SCSP.strVendorLocation))))

--Validate Item
INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Item No.'
    , strValue = SCSP.strItem
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SCSP.intRowNumber
    , strMessage = 'Item No. ('+ SCSP.strItem + ') does not exists.'
FROM tblApiSchemaCustomerPricing SCSP
WHERE SCSP.guiApiUniqueId = @guiApiUniqueId
AND RTRIM(LTRIM(ISNULL(SCSP.strItem, ''))) <> ''
AND NOT EXISTS (SELECT TOP 1 NULL 
				FROM tblICItem I
				WHERE I.strItemNo = SCSP.strItem)

--Validate Item Category
INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Item Category'
    , strValue = SCSP.strCategory
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SCSP.intRowNumber
    , strMessage = 'Item Category ('+ SCSP.strCategory + ') does not exists.'
FROM tblApiSchemaCustomerPricing SCSP
WHERE SCSP.guiApiUniqueId = @guiApiUniqueId
AND RTRIM(LTRIM(ISNULL(SCSP.strCategory, ''))) <> ''
AND NOT EXISTS (SELECT TOP 1 NULL 
				FROM tblICCategory I
				WHERE I.strCategoryCode = SCSP.strCategory)

--Validate Customer Group

--Validate Deviation
INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Deviation'
    , strValue = SCSP.strDeviation
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SCSP.intRowNumber
    , strMessage = 'Deviation should be numeric.'
FROM tblApiSchemaCustomerPricing SCSP
WHERE SCSP.guiApiUniqueId = @guiApiUniqueId
AND RTRIM(LTRIM(ISNULL(SCSP.strDeviation, ''))) <> ''
AND ISNUMERIC(SCSP.strDeviation) <> 1

--Validate Line Note

--Validate Begin Date
INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Begin Date'
    , strValue = SCSP.strBeginDate
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SCSP.intRowNumber
    , strMessage = 'Begin Date is blank'
FROM tblApiSchemaCustomerPricing SCSP
WHERE SCSP.guiApiUniqueId = @guiApiUniqueId
AND RTRIM(LTRIM(ISNULL(SCSP.strBeginDate, ''))) = ''

INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Begin Date'
    , strValue = SCSP.strBeginDate
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SCSP.intRowNumber
    , strMessage = 'Begin Date ('+ SCSP.strBeginDate +') is invalid, please try Month/Day/Year Format e.g. 12/01/2015.'
FROM tblApiSchemaCustomerPricing SCSP
WHERE SCSP.guiApiUniqueId = @guiApiUniqueId
AND RTRIM(LTRIM(ISNULL(SCSP.strBeginDate, ''))) <> ''
AND ISDATE(SCSP.strBeginDate) <> 1

--Validate End Date
INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'End Date'
    , strValue = SCSP.strEndDate
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SCSP.intRowNumber
    , strMessage = 'End Date ('+ SCSP.strEndDate +') is invalid, please try Month/Day/Year Format e.g. 12/01/2015.'
FROM tblApiSchemaCustomerPricing SCSP
WHERE SCSP.guiApiUniqueId = @guiApiUniqueId
AND RTRIM(LTRIM(ISNULL(SCSP.strEndDate, ''))) <> ''
AND ISDATE(SCSP.strEndDate) <> 1


--Validate Rack Vendor Number
INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Fixed Rack Vendor No.'
    , strValue = SCSP.strRackVendorNumber
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SCSP.intRowNumber
    , strMessage = 'Fixed Rack Vendor No. ('+ SCSP.strRackVendorNumber + ') does not exists.'
FROM tblApiSchemaCustomerPricing SCSP
WHERE SCSP.guiApiUniqueId = @guiApiUniqueId
AND RTRIM(LTRIM(ISNULL(SCSP.strRackVendorNumber, ''))) <> ''
AND NOT EXISTS (SELECT TOP 1 NULL 
				FROM tblAPVendor V
				WHERE V.strVendorId = SCSP.strRackVendorNumber)


--Validate Rack Item
INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Fixed Rack Item No.'
    , strValue = SCSP.strRackItemNumber
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SCSP.intRowNumber
    , strMessage = 'Fixed Rack Item No. ('+ SCSP.strRackItemNumber + ') does not exists.'
FROM tblApiSchemaCustomerPricing SCSP
WHERE SCSP.guiApiUniqueId = @guiApiUniqueId
AND RTRIM(LTRIM(ISNULL(SCSP.strRackItemNumber, ''))) <> ''
AND NOT EXISTS (SELECT TOP 1 NULL 
				FROM tblICItem I
				WHERE I.strItemNo = SCSP.strRackItemNumber)

--Validate Rack Location
INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Fixed Rack Vendor Location'
    , strValue = SCSP.strRackLocation
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SCSP.intRowNumber
    , strMessage = 'Fixed Rack Vendor Location ('+ SCSP.strRackLocation + ') does not exists.'
FROM tblApiSchemaCustomerPricing SCSP
WHERE SCSP.guiApiUniqueId = @guiApiUniqueId
AND RTRIM(LTRIM(ISNULL(SCSP.strRackLocation, ''))) <> ''
AND NOT EXISTS (SELECT TOP 1 NULL 
				FROM tblEMEntityLocation EL
				WHERE RTRIM(LTRIM(LOWER(EL.strLocationName))) = RTRIM(LTRIM(LOWER(SCSP.strRackLocation))))

--Validate Currency
INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Currency'
    , strValue = SCSP.strCurrency
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SCSP.intRowNumber
    , strMessage = 'Currency ('+ SCSP.strCurrency + ') does not exists.'
FROM tblApiSchemaCustomerPricing SCSP
WHERE SCSP.guiApiUniqueId = @guiApiUniqueId
AND RTRIM(LTRIM(ISNULL(SCSP.strCurrency, ''))) <> ''
AND NOT EXISTS (SELECT TOP 1 NULL 
				FROM tblSMCurrency C
				WHERE C.strCurrency = SCSP.strCurrency)


--Validate Class

--Validate Program
INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Program'
    , strValue = SCSP.strProgram
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SCSP.intRowNumber
    , strMessage = 'Program ('+ SCSP.strProgram + ') does not exists.'
FROM tblApiSchemaCustomerPricing SCSP
WHERE SCSP.guiApiUniqueId = @guiApiUniqueId
AND RTRIM(LTRIM(ISNULL(SCSP.strProgram, ''))) <> ''
AND NOT EXISTS (SELECT TOP 1 NULL 
				FROM tblVRProgram P
				WHERE P.strProgram = SCSP.strProgram)

--Validate Program Type
--Validate Invoice Type

-- TRANSFORM
DECLARE @intEntityId			INT
	   ,@intEntityVendorId		INT
	   ,@intItemId				INT
	   ,@intRackVendorId		INT
	   ,@intRackItemId			INT
	   ,@intEntityLocationId	INT
	   ,@intRackLocationId		INT
	   ,@intCustomerLocationId	INT = NULL
	   ,@intCategoryId			INT				
	   ,@intCurrencyId			INT	
	   ,@intProgramId			INT

DECLARE  
	 @strEntityNo			      NVARCHAR(100) 
	,@strCustomerName			  NVARCHAR(100) 
	,@strCustomerLocation		  NVARCHAR(100) 
	,@strPriceBasis				  NVARCHAR(100) 
	,@strCostToUse				  NVARCHAR(100)	
	,@strVendorNumber			  NVARCHAR(100)	
	,@strVendorLocation			  NVARCHAR(100)	
	,@strItem					  NVARCHAR(100)	
	,@strCategory			      NVARCHAR(100)	
	,@strCustomerGroup			  NVARCHAR(100) 
	,@strDeviation				  NVARCHAR(100) 
	,@strLineNote				  NVARCHAR(100) 
	,@strBeginDate				  NVARCHAR(100) 
	,@strEndDate				  NVARCHAR(100) 
	,@strRackVendorNumber		  NVARCHAR(100)	
	,@strRackItemNumber			  NVARCHAR(100)	
	,@strRackLocation			  NVARCHAR(100)	
	,@strCurrency				  NVARCHAR(100)	
	,@strClass					  NVARCHAR(100) 
	,@strProgram				  NVARCHAR(100)	
	,@strProgramType			  NVARCHAR(100)	
	,@strInvoiceType			  NVARCHAR(100) 
	,@intRowNumber				  INT

DECLARE cursorSC CURSOR LOCAL FAST_FORWARD
FOR
SELECT   strEntityNo	
		,strCustomerName
		,strCustomerLocation	
		,strPriceBasis			
		,strCostToUse			
		,strVendorNumber		
		,strVendorLocation		
		,strItem				
		,strCategory			
		,strCustomerGroup		
		,strDeviation			
		,strLineNote			
		,strBeginDate			
		,strEndDate				
		,strRackVendorNumber	
		,strRackItemNumber		
		,strRackLocation		
		,strCurrency			
		,strClass				
		,strProgram				
		,strProgramType			
		,strInvoiceType			
		,intRowNumber			
FROM	tblApiSchemaCustomerPricing SC
WHERE	guiApiUniqueId = @guiApiUniqueId
AND		intRowNumber NOT IN (SELECT intRowNo FROM tblApiImportLogDetail WHERE guiApiImportLogId = @guiLogId)

OPEN cursorSC;

FETCH NEXT FROM cursorSC INTO 
	  @strEntityNo	
	,@strCustomerName
	,@strCustomerLocation		
	,@strPriceBasis				
	,@strCostToUse				
	,@strVendorNumber			
	,@strVendorLocation			
	,@strItem					
	,@strCategory			   
	,@strCustomerGroup			
	,@strDeviation				
	,@strLineNote				
	,@strBeginDate				
	,@strEndDate				
	,@strRackVendorNumber		
	,@strRackItemNumber			
	,@strRackLocation			
	,@strCurrency				
	,@strClass					
	,@strProgram				
	,@strProgramType			
	,@strInvoiceType			
	,@intRowNumber				
WHILE @@FETCH_STATUS = 0
BEGIN

	--@intEntityId
	SELECT TOP 1 @intEntityId = intEntityId
	FROM tblARCustomer
	WHERE strCustomerNumber = RTRIM(LTRIM(@strEntityNo))

	IF @intEntityId IS NULL
	BEGIN
		--@intCustomerLocationId
		SELECT TOP 1 @intCustomerLocationId = EL.intEntityLocationId 
		FROM tblEMEntity E
			INNER JOIN tblEMEntityLocation EL 
		ON E.intEntityId = EL.intEntityId
		WHERE E.strName = @strCustomerName AND
			RTRIM(LTRIM(LOWER(EL.strLocationName))) = RTRIM(LTRIM(LOWER(@strCustomerLocation)))

		SELECT TOP 1 @intEntityId = E.intEntityId
		FROM tblEMEntity E
		WHERE E.strName = @strCustomerName
	END
	ELSE
	BEGIN
		--@intCustomerLocationId
		SELECT TOP 1 @intCustomerLocationId = EL.intEntityLocationId 
		FROM tblEMEntity E
			INNER JOIN tblEMEntityLocation EL 
		ON E.intEntityId = EL.intEntityId
		WHERE E.strEntityNo = @strEntityNo AND
			RTRIM(LTRIM(LOWER(EL.strLocationName))) = RTRIM(LTRIM(LOWER(@strCustomerLocation)))

	END

	--@intEntityVendorId
	SELECT TOP 1 @intEntityVendorId = E.intEntityId
	FROM tblEMEntity E
		INNER JOIN (SELECT intEntityId FROM tblEMEntityType WHERE strType = 'Vendor') ET
	ON E.intEntityId = ET.intEntityId
	WHERE E.strEntityNo = @strVendorNumber

	--@intItemId
	SELECT TOP 1 @intItemId = I.intItemId 
	FROM tblICItem I
	WHERE I.strItemNo = @strItem

	--@intRackVendorId
	SELECT TOP 1 @intRackVendorId = V.intEntityId 
	FROM tblAPVendor V
	WHERE V.strVendorId = @strVendorNumber

	--@intRackItemId
	SELECT TOP 1 @intRackItemId = I.intItemId 
	FROM tblICItem I
	WHERE I.strItemNo = @strRackItemNumber

	--@intEntityLocationId
	SELECT TOP 1 @intEntityLocationId = EL.intEntityLocationId 
	FROM tblEMEntity E
		INNER JOIN (SELECT intEntityId FROM tblEMEntityType WHERE strType = 'Vendor') ET
	ON E.intEntityId = ET.intEntityId
		INNER JOIN tblEMEntityLocation EL 
	ON E.intEntityId = EL.intEntityId
	WHERE E.strEntityNo = @strVendorNumber AND
		  RTRIM(LTRIM(LOWER(EL.strLocationName))) = RTRIM(LTRIM(LOWER(@strVendorLocation)))

	--@intRackLocationId
	SELECT TOP 1 @intRackLocationId = EL.intEntityLocationId 
	FROM tblEMEntityLocation EL
	WHERE RTRIM(LTRIM(LOWER(EL.strLocationName))) = RTRIM(LTRIM(LOWER(@strRackLocation)))

	--@intCategoryId
	SELECT TOP 1 @intCategoryId = I.intCategoryId 
	FROM tblICCategory I
	WHERE I.strCategoryCode = @strCategory

	--@intCurrencyId
	SELECT TOP 1 @intCurrencyId = C.intCurrencyID 
	FROM tblSMCurrency C
	WHERE C.strCurrency = @strCurrency

	--@intProgramId
	SELECT TOP 1 @intProgramId = P.intProgramId 
	FROM tblVRProgram P
	WHERE P.strProgram = @strProgram

	INSERT INTO tblARCustomerSpecialPrice(
		 [intEntityCustomerId]      
		,[intEntityVendorId]			
		,[intItemId]					
		,[strClass]					
		,[strPriceBasis]				
		,[strCustomerGroup]			
		,[strCostToUse]				
		,[dblDeviation]				
		,[strLineNote]				
		,[dtmBeginDate]				
		,[dtmEndDate]				
		,[intRackVendorId]			
		,[intRackItemId]				
		,[intEntityLocationId]		
		,[intRackLocationId]			
		,[intCustomerLocationId]		
		,[strInvoiceType]			
		,[intCategoryId]				
		,[intCurrencyId]				
		,[intProgramId]				
		,[strProgramType]			
		,[intCompanyId]				
		,[intConcurrencyId]			
		,[guiApiUniqueId]
	)
	SELECT
		@intEntityId
	   ,@intEntityVendorId
	   ,@intItemId
	   ,@strClass
	   ,[dbo].[fnARGetPriceBasis](@strPriceBasis)
	   ,@strCustomerGroup
	   ,@strCostToUse
	   ,CASE WHEN ISNULL(@strDeviation, '') <> '' AND ISNUMERIC(@strDeviation) = 1 THEN CAST(@strDeviation AS FLOAT) ELSE 0 END
	   ,@strLineNote
	   ,CAST(@strBeginDate AS DATETIME)
	   ,CASE WHEN ISNULL(@strEndDate, '') <> '' AND ISDATE(@strEndDate) = 1 THEN CAST(@strEndDate AS DATETIME) ELSE NULL END
	   ,@intRackVendorId
	   ,@intRackItemId
	   ,@intEntityLocationId
	   ,@intRackLocationId
	   ,@intCustomerLocationId
	   ,@strInvoiceType
	   ,@intCategoryId
	   ,@intCurrencyId
	   ,@intProgramId
	   ,@strProgramType
	   ,NULL
	   ,1
	   ,@guiApiUniqueId

	INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
	SELECT
		  guiApiImportLogDetailId = NEWID()
		, guiApiImportLogId = @guiLogId
		, strField = CASE WHEN @strEntityNo IS NULL OR @strEntityNo = '' THEN 'Customer Name ' ELSE 'Customer No. ' END + ' - Begin Date' + CASE WHEN @strPriceBasis IS NULL OR @strPriceBasis = '' THEN '' ELSE ' - Price Basis' END 
		, strValue = CASE WHEN @strEntityNo IS NULL OR @strEntityNo = '' THEN @strCustomerName ELSE @strEntityNo  END + ' - ' + @strBeginDate + CASE WHEN @strPriceBasis IS NULL OR @strPriceBasis = '' THEN '' ELSE ' - ' + @strPriceBasis END
		, strLogLevel = 'Info'
		, strStatus = 'Success'
		, intRowNo = @intRowNumber
		, strMessage = 'The record was imported successfully.'
	FROM tblApiSchemaCustomerPricing SCSP
	WHERE guiApiUniqueId = @guiApiUniqueId AND SCSP.intRowNumber = @intRowNumber
	

	FETCH NEXT FROM cursorSC INTO 
          @strEntityNo			   
		,@strCustomerName
		,@strCustomerLocation
		,@strPriceBasis				
		,@strCostToUse				
		,@strVendorNumber			
		,@strVendorLocation			
		,@strItem					
		,@strCategory			   
		,@strCustomerGroup			
		,@strDeviation				
		,@strLineNote				
		,@strBeginDate				
		,@strEndDate				
		,@strRackVendorNumber		
		,@strRackItemNumber			
		,@strRackLocation			
		,@strCurrency				
		,@strClass					
		,@strProgram				
		,@strProgramType			
		,@strInvoiceType			
		,@intRowNumber	
END

CLOSE cursorSC;
DEALLOCATE cursorSC;

-- FINALIZE
DECLARE @intTotalRowsImported INT

SET @intTotalRowsImported = (
    SELECT COUNT(*) 
    FROM tblARCustomerSpecialPrice
    WHERE guiApiUniqueId = @guiApiUniqueId
)

UPDATE tblApiImportLog
SET 
      strStatus = 'Completed'
    , strResult = CASE WHEN @intTotalRowsImported = 0 THEN 'Failed' ELSE 'Success' END
    , intTotalRecordsCreated = @intTotalRowsImported
    , intTotalRowsImported = @intTotalRowsImported
    , dtmImportFinishDateUtc = GETUTCDATE()
WHERE guiApiImportLogId = @guiLogId

GO