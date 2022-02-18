CREATE PROCEDURE [dbo].[uspApiSchemaTransformCustomerLocation] (
      @guiApiUniqueId UNIQUEIDENTIFIER
    , @guiLogId UNIQUEIDENTIFIER
)
AS

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET ANSI_WARNINGS OFF
SET XACT_ABORT ON

-- Validate Entity No
INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Entity No.'
    , strValue = SCL.strEntityNo
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SCL.intRowNumber
    , strMessage = 'Entity No. is blank.'
FROM tblApiSchemaCustomerLocation SCL
WHERE SCL.guiApiUniqueId = @guiApiUniqueId
AND RTRIM(LTRIM(ISNULL(SCL.strEntityNo, ''))) = '' 

INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
	  guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Entity No'
    , strValue = SCL.strEntityNo
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SCL.intRowNumber
    , strMessage = 'Entity No. ('+ SCL.strEntityNo + ') does not exists.'
FROM tblApiSchemaCustomerLocation SCL
WHERE SCL.guiApiUniqueId = @guiApiUniqueId
AND RTRIM(LTRIM(ISNULL(SCL.strEntityNo, ''))) <> '' 
AND NOT EXISTS (SELECT TOP 1 NULL FROM tblEMEntity EM WHERE EM.strEntityNo = SCL.strEntityNo)

--Validate Location
INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Location'
    , strValue = SCL.strLocationName
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SCL.intRowNumber
    , strMessage = 'Location is blank.'
FROM tblApiSchemaCustomerLocation SCL
WHERE SCL.guiApiUniqueId = @guiApiUniqueId
AND RTRIM(LTRIM(ISNULL(SCL.strLocationName, ''))) = ''

--Validate Address
--Validate strCity                
--Validate Country            
--Validate County		         
--Validate State       
--Validate ZipCode
--Validate Phone
--Validate Fax
--Validate PricingLevel
--Validate Notes
--Validate OregonFacilityNumber


--Validate Ship Via
INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Ship Via'
    , strValue = SCL.strShipVia
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SCL.intRowNumber
    , strMessage = 'Ship Via ('+ SCL.strShipVia + ') does not exists.'
FROM tblApiSchemaCustomerLocation SCL
WHERE SCL.guiApiUniqueId = @guiApiUniqueId
AND RTRIM(LTRIM(ISNULL(SCL.strShipVia, ''))) <> '' 
AND NOT EXISTS (SELECT TOP 1 NULL
				FROM tblSMShipVia S
						INNER JOIN 
					tblEMEntity E
				ON S.intEntityId = E.intEntityId
				WHERE S.strShipVia = SCL.strShipVia)

--Validate Terms
INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Terms'
    , strValue = SCL.strTerms
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SCL.intRowNumber
    , strMessage = 'Terms ('+ SCL.strTerms + ') does not exists.'
FROM tblApiSchemaCustomerLocation SCL
WHERE SCL.guiApiUniqueId = @guiApiUniqueId
AND RTRIM(LTRIM(ISNULL(SCL.strTerms, ''))) <> '' 
AND NOT EXISTS (SELECT TOP 1 NULL
				FROM tblSMTerm
				WHERE strTerm = SCL.strTerms)

--Validate Warehouse
INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Warehouse'
    , strValue = SCL.strWarehouse
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SCL.intRowNumber
    , strMessage = 'Warehouse ('+ SCL.strWarehouse + ') does not exists.'
FROM tblApiSchemaCustomerLocation SCL
WHERE SCL.guiApiUniqueId = @guiApiUniqueId
AND RTRIM(LTRIM(ISNULL(SCL.strWarehouse, ''))) <> '' 
AND NOT EXISTS (SELECT TOP 1 NULL
				FROM tblEMEntityLocation
				WHERE strLocationName = SCL.strWarehouse)

--Validate Salesperson
INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Salesperson'
    , strValue = SCL.strSalesperson
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SCL.intRowNumber
    , strMessage = 'Salesperson ('+ SCL.strSalesperson + ') does not exists.'
FROM tblApiSchemaCustomerLocation SCL
WHERE SCL.guiApiUniqueId = @guiApiUniqueId
AND RTRIM(LTRIM(ISNULL(SCL.strSalesperson, ''))) <> ''
AND NOT EXISTS (SELECT TOP 1 NULL 
				FROM tblEMEntity E
					INNER JOIN (SELECT intEntityId FROM tblEMEntityType WHERE strType = 'Salesperson') ET
				ON E.intEntityId = ET.intEntityId
				WHERE E.strEntityNo = SCL.strSalesperson)

--Validate County Tax Code

--Validate Freight Terms
INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Freight Terms'
    , strValue = SCL.strFreightTerm
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SCL.intRowNumber
    , strMessage = 'Freight Terms ('+ SCL.strFreightTerm + ') does not exists.'
FROM tblApiSchemaCustomerLocation SCL
WHERE SCL.guiApiUniqueId = @guiApiUniqueId
AND RTRIM(LTRIM(ISNULL(SCL.strFreightTerm, ''))) <> '' 
AND NOT EXISTS (SELECT TOP 1 NULL
				FROM tblSMFreightTerms
				WHERE strFreightTerm = SCL.strFreightTerm)


--Validate Tax Group
INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Tax Group'
    , strValue = SCL.strTaxGroup
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SCL.intRowNumber
    , strMessage = 'Tax Group ('+ SCL.strTaxGroup + ') does not exists.'
FROM tblApiSchemaCustomerLocation SCL
WHERE SCL.guiApiUniqueId = @guiApiUniqueId
AND RTRIM(LTRIM(ISNULL(SCL.strTaxGroup, ''))) <> '' 
AND NOT EXISTS (SELECT TOP 1 NULL
				FROM tblSMTaxGroup
				WHERE strTaxGroup = SCL.strTaxGroup)

--Validate Tax Class
INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Tax Class'
    , strValue = SCL.strTaxClass
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SCL.intRowNumber
    , strMessage = 'Tax Class ('+ SCL.strTaxClass + ') does not exists.'
FROM tblApiSchemaCustomerLocation SCL
WHERE SCL.guiApiUniqueId = @guiApiUniqueId
AND RTRIM(LTRIM(ISNULL(SCL.strTaxClass, ''))) <> '' 
AND NOT EXISTS (SELECT TOP 1 NULL
				FROM tblSMTaxClass
				WHERE strTaxClass = SCL.strTaxClass)


--Validate Longitude
INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Longitude'
    , strValue = SCL.strLongitude
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SCL.intRowNumber
    , strMessage = 'Longtitude should be numeric.'
FROM tblApiSchemaCustomerLocation SCL
WHERE SCL.guiApiUniqueId = @guiApiUniqueId
AND RTRIM(LTRIM(ISNULL(SCL.strLongitude, ''))) <> '' 
AND ISNUMERIC(SCL.strLongitude) <> 1

--Validate Latitude
INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Latitude'
    , strValue = SCL.strLatitude
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SCL.intRowNumber
    , strMessage = 'Latitude should be numeric.'
FROM tblApiSchemaCustomerLocation SCL
WHERE SCL.guiApiUniqueId = @guiApiUniqueId
AND RTRIM(LTRIM(ISNULL(SCL.strLatitude, ''))) <> '' 
AND ISNUMERIC(SCL.strLatitude) <> 1

--Validate Time Zone
--Validate Check Payee Name


--Validate Default Currency
INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Default Currency'
    , strValue = SCL.strDefaultCurrency
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SCL.intRowNumber
    , strMessage = 'Default Currency ('+ SCL.strDefaultCurrency + ') does not exists.'
FROM tblApiSchemaCustomerLocation SCL
WHERE SCL.guiApiUniqueId = @guiApiUniqueId
AND RTRIM(LTRIM(ISNULL(SCL.strDefaultCurrency, ''))) <> '' 
AND NOT EXISTS (SELECT TOP 1 NULL
				FROM tblSMCurrency
				WHERE strCurrency = SCL.strDefaultCurrency)

--Validate Vendor Link
INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Vendor Link'
    , strValue = SCL.strVendorLink
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SCL.intRowNumber
    , strMessage = 'Vendor ('+ SCL.strVendorLink + ') does not exists.'
FROM tblApiSchemaCustomerLocation SCL
WHERE SCL.guiApiUniqueId = @guiApiUniqueId
AND RTRIM(LTRIM(ISNULL(SCL.strVendorLink, ''))) <> '' 
AND NOT EXISTS (SELECT TOP 1 NULL 
				FROM tblEMEntity E
					INNER JOIN (SELECT intEntityId FROM tblEMEntityType WHERE strType = 'Vendor') ET
				ON E.intEntityId = ET.intEntityId
				WHERE E.strEntityNo = SCL.strVendorLink)

--Validate Location Type
INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Location Type'
    , strValue = SCL.strLocationType
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SCL.intRowNumber
    , strMessage = 'Location Type ('+ SCL.strLocationType + ') does not exists. Use one in IN (Location, Farm)'
FROM tblApiSchemaCustomerLocation SCL
WHERE SCL.guiApiUniqueId = @guiApiUniqueId
AND RTRIM(LTRIM(ISNULL(SCL.strLocationType, ''))) <> '' 
AND SCL.strLocationType NOT IN ('Location', 'Farm')

--Validate Farm Acres
INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Farm Acres'
    , strValue = SCL.strFarmAcres
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SCL.intRowNumber
    , strMessage = 'Farm Acres should be numeric.'
FROM tblApiSchemaCustomerLocation SCL
WHERE SCL.guiApiUniqueId = @guiApiUniqueId
AND RTRIM(LTRIM(ISNULL(SCL.strFarmAcres, ''))) <> '' 
AND ISNUMERIC(SCL.strFarmAcres) <> 1

--Validate 1099 Form
INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = '1099 Form'
    , strValue = SCL.str1099Form
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SCL.intRowNumber
    , strMessage = '1099 Type ('+ SCL.str1099Form + ') does not exists. Use one in IN (None, 1099-MISC, 1099-INT, 1099-B, 1099-PATR, 1099-DIV)'
FROM  tblApiSchemaCustomerLocation SCL
WHERE SCL.guiApiUniqueId = @guiApiUniqueId
AND RTRIM(LTRIM(ISNULL(SCL.str1099Form, ''))) <> ''
AND SCL.str1099Form NOT IN ('None', '1099-MISC', '1099-INT', '1099-B', '1099-PATR', '1099-DIV')

--Validate 1099 Types

INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = '1099 Types'
    , strValue = SCL.str1099Type
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SCL.intRowNumber
    , strMessage = '1099 Type ('+ SCL.str1099Type + ') does not exists. Use one in IN (Crop Insurance Proceeds, Direct Sales, Excess Golden Parachute Payments, Fishing Boat Proceeds, Gross Proceeds Paid to an Attorney, Medical and Health Care Payments, Nonemployee Compensation, Other Income, Rents, Royalties Substitute Payments in Lieu of Dividends or Interest, Federal Income Tax Withheld)'
FROM  tblApiSchemaCustomerLocation SCL
WHERE SCL.guiApiUniqueId = @guiApiUniqueId
AND RTRIM(LTRIM(ISNULL(SCL.str1099Type, ''))) <> ''
AND SCL.str1099Type NOT IN ('Crop Insurance Proceeds, Direct Sales', 'Excess Golden Parachute Payments', 'Fishing Boat Proceeds', 'Gross Proceeds Paid to an Attorney', 'Medical and Health Care Payments', 'Nonemployee Compensation, Other Income', 'Rents', 'Royalties Substitute Payments in Lieu of Dividends or Interest', 'Federal Income Tax Withheld')


--Validate Federal Tax id

--Validate W9 Signed
INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      guiApiImportLogDetailId = NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'W9 Signed'
    , strValue = SCL.strW9Signed
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = SCL.intRowNumber
    , strMessage = 'W9 Signed ('+ SCL.strW9Signed +') is invalid, please try Month/Day/Year Format e.g. 12/01/2015.'
FROM tblApiSchemaCustomerLocation SCL
WHERE SCL.guiApiUniqueId = @guiApiUniqueId
AND RTRIM(LTRIM(ISNULL(SCL.strW9Signed, ''))) <> ''
AND ISDATE(SCL.strW9Signed) <> 1


--Validate Origin Link Customer

-- TRANSFORM
DECLARE @intEntityId			INT			
	   ,@intCurrencyId			INT	
	   ,@intShipViaId			INT	
	   ,@intTermsId			    INT	
	   ,@intWarehouseId			INT	
	   ,@intSalesPersonId		INT	
	   ,@intFreightTermId		INT	
	   ,@intCountyTaxCodeId		INT	
	   ,@intTaxGroupId		    INT	
	   ,@intTaxClassId		    INT
	   ,@intVendorLinkId	    INT	

DECLARE  
		@strEntityNo			      NVARCHAR(100) 		
		,@strLocationName         	  NVARCHAR(100)
		,@strAddress       			  NVARCHAR(100)
		,@strCity          			  NVARCHAR(100)
		,@strCountry       			  NVARCHAR(100)
		,@strCounty		  			  NVARCHAR(100)
		,@strState         			  NVARCHAR(100)
		,@strZipCode       			  NVARCHAR(100)
		,@strPhone         			  NVARCHAR(100)
		,@strFax           			  NVARCHAR(100)
		,@strPricingLevel  			  NVARCHAR(100)
		,@strNotes         			  NVARCHAR(100)
		,@strOregonFacilityNumber 	  NVARCHAR(100)
		,@strShipVia         		  NVARCHAR(100)
		,@strTerms           		  NVARCHAR(100)
		,@strWarehouse       		  NVARCHAR(100)
		,@strSalesperson     		  NVARCHAR(100)
		,@strDefaultLocation 		  NVARCHAR(100)
		,@strFreightTerm	    	  NVARCHAR(100)
		,@strCountyTaxCode   		  NVARCHAR(100)
		,@strTaxGroup				  NVARCHAR(100)
		,@strTaxClass				  NVARCHAR(100)
		,@strActive					  NVARCHAR(100)
		,@strLongitude       		  NVARCHAR(100)
		,@strLatitude        		  NVARCHAR(100)
		,@strTimezone        		  NVARCHAR(100)
		,@strCheckPayeeName  		  NVARCHAR(100)
		,@strDefaultCurrency 		  NVARCHAR(100)
		,@strVendorLink				  NVARCHAR(100)
		,@strLocationDescription	  NVARCHAR(100)
		,@strLocationType             NVARCHAR(100)
		,@strFarmFieldNumber      	  NVARCHAR(100)
		,@strFarmFieldDescription	  NVARCHAR(100)
		,@strFarmFSANumber			  NVARCHAR(100)
		,@strFarmSplitNumber		  NVARCHAR(100)
		,@strFarmSplitType			  NVARCHAR(100)
		,@strFarmAcres				  NVARCHAR(100)
		,@strFieldMapFile			  NVARCHAR(100)
		,@strPrint1099           	  NVARCHAR(100)
		,@str1099Name             	  NVARCHAR(100)
		,@str1099Form             	  NVARCHAR(100)
		,@str1099Type            	  NVARCHAR(100)
		,@strFederalTaxId        	  NVARCHAR(100)
		,@strW9Signed           	  NVARCHAR(100)
		,@strOriginLinkCustomer		  NVARCHAR(100)
		,@intRowNumber				  INT

DECLARE cursorSC CURSOR LOCAL FAST_FORWARD
FOR
SELECT   strEntityNo			    
		,strLocationName         	
		,strAddress       			
		,strCity          			
		,strCountry       			
		,strCounty		  			
		,strState         			
		,strZipCode       			
		,strPhone         			
		,strFax           			
		,strPricingLevel  			
		,strNotes         			
		,strOregonFacilityNumber 	
		,strShipVia         		
		,strTerms           		
		,strWarehouse       		
		,strSalesperson     		
		,strDefaultLocation 		
		,strFreightTerm	    	 
		,strCountyTaxCode   	
		,strTaxGroup			
		,strTaxClass			
		,strActive				
		,strLongitude       	
		,strLatitude        	
		,strTimezone        	
		,strCheckPayeeName  	
		,strDefaultCurrency 	
		,strVendorLink			
		,strLocationDescription	 
		,strLocationType         
		,strFarmFieldNumber      
		,strFarmFieldDescription
		,strFarmFSANumber		
		,strFarmSplitNumber		 
		,strFarmSplitType		
		,strFarmAcres			
		,strFieldMapFile		
		,strPrint1099           
		,str1099Name             
		,str1099Form            
		,str1099Type            
		,strFederalTaxId        
		,strW9Signed           	
		,strOriginLinkCustomer	
		,intRowNumber			
FROM	tblApiSchemaCustomerLocation SC
WHERE	guiApiUniqueId = @guiApiUniqueId
AND		intRowNumber NOT IN (SELECT intRowNo FROM tblApiImportLogDetail WHERE guiApiImportLogId = @guiLogId)

OPEN cursorSC;

FETCH NEXT FROM cursorSC INTO 
	     @strEntityNo			     
		,@strLocationName        
		,@strAddress       		
		,@strCity          		
		,@strCountry       		
		,@strCounty		  		
		,@strState         		
		,@strZipCode       		
		,@strPhone         		
		,@strFax           		
		,@strPricingLevel  		
		,@strNotes         			
		,@strOregonFacilityNumber 	
		,@strShipVia         		
		,@strTerms           		
		,@strWarehouse       		
		,@strSalesperson     		
		,@strDefaultLocation 		
		,@strFreightTerm	    	
		,@strCountyTaxCode   		
		,@strTaxGroup				
		,@strTaxClass				
		,@strActive					
		,@strLongitude       		
		,@strLatitude        		
		,@strTimezone        		
		,@strCheckPayeeName  		
		,@strDefaultCurrency 		
		,@strVendorLink				
		,@strLocationDescription	
		,@strLocationType           
		,@strFarmFieldNumber      	
		,@strFarmFieldDescription	
		,@strFarmFSANumber			
		,@strFarmSplitNumber		
		,@strFarmSplitType			
		,@strFarmAcres				
		,@strFieldMapFile			
		,@strPrint1099           	
		,@str1099Name             	
		,@str1099Form             	
		,@str1099Type            	
		,@strFederalTaxId        	
		,@strW9Signed           	
		,@strOriginLinkCustomer		
		,@intRowNumber				
WHILE @@FETCH_STATUS = 0
BEGIN

	--@intEntityId
	SELECT TOP 1 @intEntityId = intEntityId
	FROM tblEMEntity
	WHERE strEntityNo = RTRIM(LTRIM(@strEntityNo))

	--@intCurrencyId
	SELECT TOP 1 @intCurrencyId = C.intCurrencyID 
	FROM tblSMCurrency C
	WHERE C.strCurrency = @strDefaultCurrency

	--@intShipViaId
	SELECT TOP 1 @intShipViaId = S.intEntityId
	FROM tblSMShipVia S
		INNER JOIN 
		tblEMEntity E
	ON S.intEntityId = E.intEntityId
	WHERE S.strShipVia = @strShipVia

	--@intTermsId
	SELECT TOP 1 @intTermsId = C.intTermID 
	FROM tblSMTerm C
	WHERE C.strTerm = @strTerms

	--@intWarehouseId
	SELECT TOP 1 @intWarehouseId = intEntityLocationId
	FROM tblEMEntityLocation 
	WHERE strLocationName = @strWarehouse

	--@intSalesPersonId
	SELECT TOP 1 @intSalesPersonId = E.intEntityId 
	FROM tblEMEntity E
		INNER JOIN (SELECT intEntityId FROM tblEMEntityType WHERE strType = 'Salesperson') ET
	ON E.intEntityId = ET.intEntityId
	WHERE E.strName = @strSalesperson

	--@intFreightTermId
	SELECT TOP 1 @intFreightTermId = intFreightTermId
	FROM tblSMFreightTerms 
	WHERE strFreightTerm = @strFreightTerm

	--@intTaxGroupId
	SELECT TOP 1 @intTaxGroupId = intTaxGroupId
	FROM tblSMTaxGroup
	WHERE strTaxGroup = @strTaxGroup

	--@intTaxClassId
	SELECT TOP 1 @intTaxClassId = intTaxClassId
	FROM tblSMTaxClass
	WHERE strTaxClass = @strTaxClass

	--@intVendorLinkId
	SELECT TOP 1 @intVendorLinkId = E.intEntityId
	FROM tblEMEntity E
		INNER JOIN (SELECT intEntityId FROM tblEMEntityType WHERE strType = 'Vendor') ET
	ON E.intEntityId = ET.intEntityId
	WHERE E.strEntityNo = @strVendorLink


	INSERT INTO tblEMEntityLocation(
		 [intEntityId]          
		,[strLocationName]          
		,[strAddress]               
		,[strCity]                  
		,[strCountry]               
		,[strCounty]		           
		,[strState]                 
		,[strZipCode]               
		,[strPhone]                 
		,[strFax]                   
		,[strPricingLevel]          
		,[strNotes]                 
		,[strOregonFacilityNumber]  
		,[intShipViaId]             
		,[intTermsId]               
		,[intWarehouseId]           
		,[intSalespersonId]         
		,[ysnDefaultLocation]       
		,[intFreightTermId]	       
		,[intCountyTaxCodeId]       
		,[intTaxGroupId]			 
		,[intTaxClassId]			   
		,[ysnActive]				   
		,[dblLongitude]             
		,[dblLatitude]              
		,[strTimezone]              
		,[strCheckPayeeName]        
		,[intDefaultCurrencyId]     
		,[intVendorLinkId]          
		,[strLocationDescription]	
		,[strLocationType]            
		,[strFarmFieldNumber]       
		,[strFarmFieldDescription]	
		,[strFarmFSANumber]			
		,[strFarmSplitNumber]		
		,[strFarmSplitType]			
		,[dblFarmAcres]				
		,[imgFieldMapFile]			
		,[strFieldMapFile]			
		,[ysnPrint1099]             
		,[str1099Name]              
		,[str1099Form]              
		,[str1099Type]              
		,[strFederalTaxId]          
		,[dtmW9Signed]              
		,[strOriginLinkCustomer]    
		,[intConcurrencyId]			
		,[guiApiUniqueId]
	)
	SELECT
		@intEntityId
	   ,@strLocationName
	   ,@strAddress
	   ,@strCity
	   ,@strCountry
	   ,@strCounty
	   ,@strState
	   --,CASE WHEN ISNULL(@strDeviation, '') <> '' AND ISNUMERIC(@strDeviation) = 1 THEN CAST(@strDeviation AS FLOAT) ELSE 0 END
	   ,@strZipCode
	   --,CAST(@strBeginDate AS DATETIME)
	   --,CASE WHEN ISNULL(@strEndDate, '') <> '' AND ISDATE(@strEndDate) = 1 THEN CAST(@strEndDate AS DATETIME) ELSE NULL END
	   ,@strPhone
	   ,@strFax
	   ,@strPricingLevel
	   ,@strNotes
	   ,@strOregonFacilityNumber
	   ,@intShipViaId
	   ,@intTermsId
	   ,@intWarehouseId
	   ,@intSalesPersonId
	   ,(CASE WHEN LOWER(ISNULL(@strDefaultLocation, '')) IN ( '1','y','yes','true') THEN 1 ELSE 0 END)
	   ,@intFreightTermId
	   ,NULL
	   ,@intTaxGroupId
	   ,@intTaxClassId
	   ,(CASE WHEN LOWER(ISNULL(@strActive, '')) IN ( '1','y','yes','true') THEN 1 ELSE 0 END)
	   ,CASE WHEN ISNULL(@strLongitude, '') <> '' AND ISNUMERIC(@strLongitude) = 1 THEN CAST(@strLongitude AS FLOAT) ELSE 0 END
	   ,CASE WHEN ISNULL(@strLatitude, '') <> '' AND ISNUMERIC(@strLatitude) = 1 THEN CAST(@strLatitude AS FLOAT) ELSE 0 END
	   ,@strTimezone
	   ,@strCheckPayeeName
	   ,@intCurrencyId
	   ,@intVendorLinkId
	   ,@strLocationDescription
	   ,@strLocationType
	   ,@strFarmFieldNumber
	   ,@strFarmFieldDescription
	   ,@strFarmFSANumber
	   ,@strFarmSplitNumber
	   ,@strFarmSplitType
	   ,CASE WHEN ISNULL(@strFarmAcres, '') <> '' AND ISNUMERIC(@strFarmAcres) = 1 THEN CAST(@strFarmAcres AS FLOAT) ELSE 0 END
	   ,NULL
	   ,NULL
	   ,(CASE WHEN LOWER(ISNULL(@strPrint1099, '')) IN ( '1','y','yes','true') THEN 1 ELSE 0 END)
	   ,@str1099Name
	   ,@str1099Form
	   ,@str1099Type
	   ,@strFederalTaxId
	   ,CAST(@strW9Signed AS DATETIME)
	   ,@strOriginLinkCustomer
	   ,1
	   ,@guiApiUniqueId

	INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
	SELECT
		  guiApiImportLogDetailId = NEWID()
		, guiApiImportLogId = @guiLogId
		, strField = 'Customer No. - Location Name'
		, strValue = @strEntityNo + ' - ' + @strLocationName
		, strLogLevel = 'Info'
		, strStatus = 'Success'
		, intRowNo = @intRowNumber
		, strMessage = 'The record was imported successfully.'
	FROM tblApiSchemaCustomerLocation SC
	WHERE guiApiUniqueId = @guiApiUniqueId AND SC.intRowNumber = @intRowNumber
	

	FETCH NEXT FROM cursorSC INTO 
          @strEntityNo			     
		,@strLocationName        
		,@strAddress       		
		,@strCity          		
		,@strCountry       		
		,@strCounty		  		
		,@strState         		
		,@strZipCode       		
		,@strPhone         		
		,@strFax           		
		,@strPricingLevel  		
		,@strNotes         			
		,@strOregonFacilityNumber 	
		,@strShipVia         		
		,@strTerms           		
		,@strWarehouse       		
		,@strSalesperson     		
		,@strDefaultLocation 		
		,@strFreightTerm	    	
		,@strCountyTaxCode   		
		,@strTaxGroup				
		,@strTaxClass				
		,@strActive					
		,@strLongitude       		
		,@strLatitude        		
		,@strTimezone        		
		,@strCheckPayeeName  		
		,@strDefaultCurrency 		
		,@strVendorLink				
		,@strLocationDescription	
		,@strLocationType           
		,@strFarmFieldNumber      	
		,@strFarmFieldDescription	
		,@strFarmFSANumber			
		,@strFarmSplitNumber		
		,@strFarmSplitType			
		,@strFarmAcres				
		,@strFieldMapFile			
		,@strPrint1099           	
		,@str1099Name             	
		,@str1099Form             	
		,@str1099Type            	
		,@strFederalTaxId        	
		,@strW9Signed           	
		,@strOriginLinkCustomer		
		,@intRowNumber	
END

CLOSE cursorSC;
DEALLOCATE cursorSC;

-- FINALIZE
DECLARE @intTotalRowsImported INT

SET @intTotalRowsImported = (
    SELECT COUNT(*) 
    FROM tblEMEntityLocation
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