CREATE PROCEDURE uspApiSchemaTransformCategoryVendor
 @guiApiUniqueId UNIQUEIDENTIFIER,  
 @guiLogId UNIQUEIDENTIFIER  
AS  
  
--Check overwrite settings  

ALTER TABLE tblApiSchemaTransformCategoryVendor
ALTER COLUMN ysnUpdatePrice NVARCHAR(3) NULL
  
DECLARE @ysnAllowOverwrite BIT = 0  
  
SELECT @ysnAllowOverwrite = CAST(varPropertyValue AS BIT)  
FROM tblApiSchemaTransformProperty  
WHERE   
guiApiUniqueId = @guiApiUniqueId  
AND  
strPropertyName = 'Overwrite'  
  
--Filter Category imported  
  
DECLARE @tblFilteredCategoryVendor TABLE(  
     intKey INT NOT NULL
    ,guiApiUniqueId UNIQUEIDENTIFIER NOT NULL
    ,intRowNumber INT NULL  
	,strCategory NVARCHAR(200) COLLATE Latin1_General_CI_AS NOT NULL
	,strVendor	NVARCHAR(200) COLLATE Latin1_General_CI_AS NOT NULL
 	,strLocation  NVARCHAR(200)  COLLATE Latin1_General_CI_AS NULL 
	,strVendorCategory	NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL 
	,ysnAddOrderingUPCtoPricebook NVARCHAR(3)					
	,ysnUpdateExistingRecords NVARCHAR(3)
	,ysnAddNewRecords NVARCHAR(3)			
	,ysnUpdatePrice	NVARCHAR(3)						
	,strDefaultFamily NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL 
	,strDefaultSellClass NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL 
	,strDefaultOrderClass NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL 
	,strComments NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL 
)  
INSERT INTO @tblFilteredCategoryVendor  
(  
	 intKey  
    ,guiApiUniqueId  
    ,intRowNumber  
 	,strCategory       
	,strVendor
	,strLocation       
	,strVendorCategory	    
	,ysnAddOrderingUPCtoPricebook 					
	,ysnUpdateExistingRecords 
	,ysnAddNewRecords 			
	,ysnUpdatePrice							
	,strDefaultFamily     
	,strDefaultSellClass     
	,strDefaultOrderClass     
	,strComments             

)  
SELECT   
  intKey  
 ,guiApiUniqueId  
 ,intRowNumber  
 ,strCategory       
 ,strVendor
 ,strLocation       
 ,strVendorCategory	    
 ,ysnAddOrderingUPCtoPricebook				
 ,ysnUpdateExistingRecords
 ,ysnAddNewRecords	
 ,ysnUpdatePrice					
 ,strDefaultFamily     
 ,strDefaultSellClass     
 ,strDefaultOrderClass     
 ,strComments              

FROM  tblApiSchemaTransformCategoryVendor  
WHERE guiApiUniqueId = @guiApiUniqueId;  
  
----Create Error Table  
  
--DECLARE @tblErrorCategoryVendor TABLE(  
-- strVendor NVARCHAR(100) COLLATE Latin1_General_CI_AS ,  
-- strFieldValue NVARCHAR(100) COLLATE Latin1_General_CI_AS ,  
-- intRowNumber INT NULL,  
-- intErrorType INT  
--)  
  
---- Error Types  
---- 1 - Duplicate Imported Category Vendor
  
----Validate Records  
  
--INSERT INTO @tblErrorCategoryVendor  
--(  
-- strVendor,  
-- strFieldValue,  
-- intRowNumber,   
-- intErrorType  
--)  
--SELECT -- Duplicate Imported Category Location
-- strVendor = DuplicateImportCategory.strVendor,  
-- strFieldValue = DuplicateImportCategory.strVendor,  
-- intRowNumber = DuplicateImportCategory.intRowNumber,  
-- intErrorType = 1  
--FROM  
--(  
-- SELECT   
--  strVendor,  
--  intRowNumber,  
--  RowNumber = ROW_NUMBER() OVER(PARTITION BY strVendor ORDER BY strVendor)  
-- FROM @tblFilteredCategoryVendor 
--) AS DuplicateImportCategory  
--WHERE RowNumber > 1  
----UNION  
----SELECT -- Existing Cateogry  
---- strCategory = FilteredCategoryVendor.strCategory,  
---- strFieldValue = FilteredCategoryVendor.strCategory,  
---- intRowNumber = FilteredCategoryVendor.intRowNumber,  
---- intErrorType = 2  
----FROM  @tblFilteredCategoryVendor FilteredCategoryVendor   
----	INNER JOIN tblICCategoryVendor CategoryVendor  
----		ON FilteredCategoryVendor.strCategory = CategoryVendor.intCategoryId --need to replish this validation..
----		AND @ysnAllowOverwrite = 0  
----UNION  
----SELECT  
---- strCategoryCode = FilteredCategory.strCategoryCode,  
---- strFieldValue = FilteredCategory.strLineOfBusiness,  
---- intRowNumber = FilteredCategory.intRowNumber,  
---- intErrorType = 3  
----FROM  
----@tblFilteredCategory FilteredCategory  
----LEFT JOIN  
----tblSMLineOfBusiness LineOfBusiness  
----ON  
----FilteredCategory.strLineOfBusiness = LineOfBusiness.strLineOfBusiness  
----WHERE  
----LineOfBusiness.intLineOfBusinessId IS NULL  
  
--INSERT INTO tblApiImportLogDetail   
--(  
-- guiApiImportLogDetailId,  
-- guiApiImportLogId,  
-- strField,  
-- strValue,  
-- strLogLevel,  
-- strStatus,  
-- intRowNo,  
-- strMessage  
--)  

---- Error Types  
---- 1 - Duplicate Imported Category Vendor


--SELECT  
-- guiApiImportLogDetailId = NEWID(),  
-- guiApiImportLogId = @guiLogId,  
-- strField = CASE  
--			   WHEN ErrorCategoryVendor.intErrorType IN(1)  
--			   THEN 'Vendor'  
--			   ELSE 'Error'  
--		    END,  

-- strValue = ErrorCategoryVendor.strFieldValue,  
-- strLogLevel =  CASE  
--				  WHEN ErrorCategoryVendor.intErrorType IN(1,2)  
--				  THEN 'Warning'  
--				  ELSE 'Error'  
--				 END,  
-- strStatus = CASE  
--			  WHEN ErrorCategoryVendor.intErrorType IN(1,2)  
--			  THEN 'Skipped'  
--			  ELSE 'Failed'  
--			 END,  

-- intRowNo = ErrorCategoryVendor.intRowNumber, 
 
-- strMessage = CASE  
--			  WHEN ErrorCategoryVendor.intErrorType = 1  
--			  THEN 'Duplicate imported category Location: ' + ErrorCategory.strFieldValue + '.'  
--			  WHEN ErrorCategory.intErrorType = 2  
--			  THEN 'Category Location: ' + ErrorCategory.strFieldValue + ' already exists and overwrite is not enabled.'  
--			  ELSE 'Line of Business: ' + ErrorCategory.strFieldValue + ' does not exist.'  
--			 END  
--FROM @tblErrorCategoryVendor ErrorCategoryVendor  
--WHERE ErrorCategoryVendor.intErrorType IN(1, 2, 3)  
  
--Filter Category to be removed  
  
--DELETE   
--FilteredCategoryVendor  
--FROM   
-- @tblFilteredCategoryVendor FilteredCategoryVendor  
-- INNER JOIN @tblErrorCategoryVendor ErrorCategoryVendor  
--  ON FilteredCategoryVendor.intRowNumber = ErrorCategoryVendor.intRowNumber  
--WHERE ErrorCategoryVendor.intErrorType IN(1, 2, 3)  
  
--Crete Output Table  
  


DECLARE @tblCategoryVendorOutput TABLE(  
 strCategory NVARCHAR(100) COLLATE Latin1_General_CI_AS ,  
 strAction NVARCHAR(100) COLLATE Latin1_General_CI_AS   
)  
  
--Transform and Insert statement  
--select * from tblSMCompanyLocation
--select * from  tblICCategoryVendor 
  
;MERGE INTO tblICCategoryVendor AS TARGET  
USING  
(  
 SELECT  
   guiApiUniqueId				= FilteredCategoryVendor.guiApiUniqueId
  ,intRowNumber				    = FilteredCategoryVendor.intRowNumber
  ,strCategory					= FilteredCategoryVendor.strCategory
  ,intCategoryId				= Category.intCategoryId
  ,intCategoryLocationId		= CatLoc.intCategoryLocationId
  ,strLocation					= CompanyLocation.strLocationName
  ,strVendorDepartment			= FilteredCategoryVendor.strVendorCategory
  ,ysnAddOrderingUPC			= CASE WHEN LOWER(FilteredCategoryVendor.ysnAddOrderingUPCtoPricebook) = 'yes' THEN 1 ELSE 0 END
  ,ysnUpdateExistingRecords		= CASE WHEN LOWER(FilteredCategoryVendor.ysnUpdateExistingRecords) = 'yes' THEN 1 ELSE 0 END
  ,ysnAddNewRecords				= CASE WHEN LOWER(FilteredCategoryVendor.ysnAddNewRecords) = 'yes' THEN 1 ELSE 0 END
  ,ysnUpdatePrice				= CASE WHEN LOWER(FilteredCategoryVendor.ysnUpdatePrice) = 'yes' THEN 1 ELSE 0 END
  ,strComments					= FilteredCategoryVendor.strComments
  ,strVendor					= Vendor.strVendorId
  ,intVendorId					= Vendor.intEntityId

  --select * from tblICCategoryLocation
 FROM @tblFilteredCategoryVendor FilteredCategoryVendor  
 LEFT JOIN tblICCategory Category
	ON FilteredCategoryVendor.strCategory = Category.strDescription
 LEFT JOIN tblSMCompanyLocation CompanyLocation  
	ON FilteredCategoryVendor.strLocation = CompanyLocation.strLocationName
 LEFT JOIN tblICCategoryLocation CatLoc
	ON Category.intCategoryId = CatLoc.intCategoryId
	AND CompanyLocation.intCompanyLocationId = CatLoc.intLocationId
 LEFT JOIN tblAPVendor Vendor
	ON FilteredCategoryVendor.strVendor = Vendor.strVendorId
 
) AS SOURCE  
ON TARGET.intCategoryId = SOURCE.intCategoryId
WHEN MATCHED AND @ysnAllowOverwrite = 1   
THEN  
 UPDATE SET  
	 guiApiUniqueId = SOURCE.guiApiUniqueId
	,intRowNumber	= SOURCE.intRowNumber	
	,intCategoryId = SOURCE.intCategoryId
	,intCategoryLocationId = SOURCE.intCategoryLocationId
	,intVendorId = SOURCE.intVendorId
	,intVendorSetupId = NULL
	,strVendorDepartment = SOURCE.strVendorDepartment
	,ysnAddOrderingUPC = SOURCE.ysnAddOrderingUPC
	,ysnUpdateExistingRecords = SOURCE.ysnUpdateExistingRecords
	,ysnAddNewRecords = SOURCE.ysnAddNewRecords
	,ysnUpdatePrice = SOURCE.ysnUpdatePrice
	,intFamilyId = NULL
	,intSellClassId = NULL
	,intOrderClassId = NULL
	,strComments = SOURCE.strComments
    ,dtmDateModified = GETUTCDATE()  
WHEN NOT MATCHED THEN  
 INSERT  
 (  
     guiApiUniqueId 
	,intRowNumber	
	,intCategoryId
	,intCategoryLocationId
	,intVendorId 
	,intVendorSetupId 
	,strVendorDepartment
	,ysnAddOrderingUPC 
	,ysnUpdateExistingRecords
	,ysnAddNewRecords 
	,ysnUpdatePrice
	,intFamilyId
	,intSellClassId
	,intOrderClassId
	,strComments
    ,dtmDateCreated
 )  
 VALUES  
 (  
   guiApiUniqueId
  ,intRowNumber  
  ,intCategoryId
  ,intCategoryLocationId
  ,intVendorId 
  ,NULL --intVendorSetupId 
  ,strVendorDepartment
  ,ysnAddOrderingUPC 
  ,ysnUpdateExistingRecords
  ,ysnAddNewRecords 
  ,ysnUpdatePrice
  ,NULL --intFamilyId
  ,NUll-- intSellClassId
  ,NULL --intOrderClassId
  ,strComments
  ,GETUTCDATE()  
 );
--OUTPUT INSERTED.intCategoryId, $action AS strAction INTO @tblCategoryVendorOutput;  
  
--Log skipped items when overwrite is not enabled.  
  
--INSERT INTO tblApiImportLogDetail   
--(  
-- guiApiImportLogDetailId,  
-- guiApiImportLogId,  
-- strField,  
-- strValue,  
-- strLogLevel,  
-- strStatus,  
-- intRowNo,  
-- strMessage  
--)  
--SELECT  
-- guiApiImportLogDetailId = NEWID(),  
-- guiApiImportLogId = @guiLogId,  
-- strField = 'Category Code',  
-- strValue = FilteredCategoryVendor.strCategory,  
-- strLogLevel = 'Warning',  
-- strStatus = 'Skipped',  
-- intRowNo = FilteredCategoryVendor.intRowNumber,  
-- strMessage = 'Category: ' + FilteredCategoryVendor.strCategory + ' already exists and overwrite is not enabled.'  
--FROM @tblFilteredCategoryVendor FilteredCategoryVendor  
--LEFT JOIN @tblCategoryVendorOutput CategoryVendorOutput  
-- ON FilteredCategoryVendor.strCategory = CategoryVendorOutput.strCategoryCode  
--WHERE CategoryVendorOutput.strCategoryCode IS NULL
-- Log successful imports
INSERT INTO tblApiImportLogDetail (
      guiApiImportLogDetailId
    , guiApiImportLogId
    , strField
    , strValue
    , strLogLevel
    , strStatus
    , intRowNo
    , strMessage
)
SELECT
      guiApiImportLogDetailId   = NEWID()
    , guiApiImportLogId         = @guiLogId
    , strField                  = 'Category XRef'
    , strValue                  = CL.intCategoryVendorId -- This can be a transaction number or any value that you want to assign to this field
    , strLogLevel               = 'Info'
    , strStatus                 = 'Success'
    , intRowNo                  = CL.intRowNumber
    , strMessage                = 'The record was imported successfully.'
FROM tblICCategoryVendor CL
    -- APPLY THE FILTER FOR guiApiUniqueId TO GET ONLY THE RECORDS RELATED TO THIS IMPORT SESSION.
    WHERE CL.guiApiUniqueId = @guiApiUniqueId
