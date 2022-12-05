CREATE PROCEDURE dbo.uspApiSchemaTransformVendorTaxException (    
    @guiApiUniqueId UNIQUEIDENTIFIER,    
    @guiLogId UNIQUEIDENTIFIER    
)    
AS    
    
-- Log Error  
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

--strVendorId

SELECT    
      guiApiImportLogDetailId   = NEWID()    
    , guiApiImportLogId         = @guiLogId    
    , strField                  = 'VendorEntityNo'    
    , strValue                  = vte.strVendorId    
    , strLogLevel               = 'Error'    
    , strStatus                 = 'Failed'    
    , intRowNo                  = vte.intRowNumber    
    , strMessage                = 'Vendor Entity No does not exists.'    
    
FROM tblApiSchemaVendorTaxException vte    
LEFT JOIN tblAPVendor v ON vte.strVendorId = v.strVendorId  
WHERE v.intEntityId IS NULL  
AND vte.guiApiUniqueId = @guiApiUniqueId   

--strLocationName 
UNION  
SELECT    
      guiApiImportLogDetailId   = NEWID()    
    , guiApiImportLogId         = @guiLogId    
    , strField                  = 'VendorLocation'    
    , strValue                  = vte.strLocationName    
    , strLogLevel               = 'Error'    
    , strStatus                 = 'Failed'      
    , intRowNo                  = vte.intRowNumber    
    , strMessage                = 'Entity Location does not exists.'    
    
FROM tblApiSchemaVendorTaxException vte   
LEFT JOIN (  
 SELECT e.strEntityNo, e.intEntityId, el.intEntityLocationId FROM tblEMEntity e  
 INNER JOIN tblEMEntityLocation el ON e.intEntityId = el.intEntityId AND el.ysnActive = 1  
)  
el ON vte.strVendorId = el.strEntityNo  
WHERE vte.guiApiUniqueId = @guiApiUniqueId  
AND el.intEntityLocationId IS NULL 

UNION 
--strTaxGroup
SELECT    
     guiApiImportLogDetailId   = NEWID()    
    ,guiApiImportLogId         = @guiLogId    
    ,strField                  = 'TaxGroup'    
    ,strValue                  = vte.strTaxGroup    
    ,strLogLevel               = 'Error'    
    ,strStatus                 = 'Failed'     
    ,intRowNo                  = vte.intRowNumber    
    ,strMessage                = 'Tax Group does not exists.'    
    
FROM tblApiSchemaVendorTaxException vte    
LEFT JOIN tblSMTaxGroup tg ON vte.strTaxGroup = tg.strTaxGroup   
WHERE vte.guiApiUniqueId = @guiApiUniqueId AND tg.intTaxGroupId IS NULL


UNION 
--strTaxCode
SELECT    
     guiApiImportLogDetailId   = NEWID()    
    ,guiApiImportLogId         = @guiLogId    
    ,strField                  = 'TaxCode'    
    ,strValue                  = vte.strTaxCode    
    ,strLogLevel               = 'Error'    
    ,strStatus                 = 'Failed'     
    ,intRowNo                  = vte.intRowNumber    
    ,strMessage                = 'Tax Code does not exists.'    
    
FROM tblApiSchemaVendorTaxException vte    
LEFT JOIN tblSMTaxCode tc ON vte.strTaxCode = tc.strTaxCode   
WHERE vte.guiApiUniqueId = @guiApiUniqueId AND tc.intTaxCodeId IS NULL

UNION 
--strTaxCode
SELECT    
     guiApiImportLogDetailId   = NEWID()    
    ,guiApiImportLogId         = @guiLogId    
    ,strField                  = 'TaxClass'    
    ,strValue                  = vte.strTaxClass    
    ,strLogLevel               = 'Error'    
    ,strStatus                 = 'Failed'     
    ,intRowNo                  = vte.intRowNumber    
    ,strMessage                = 'Tax Class does not exists.'    
    
FROM tblApiSchemaVendorTaxException vte    
LEFT JOIN tblSMTaxClass tclass ON vte.strTaxClass = tclass.strTaxClass   
WHERE vte.guiApiUniqueId = @guiApiUniqueId AND tclass.intTaxClassId IS NULL


UNION
--strItemNo
SELECT    
     guiApiImportLogDetailId   = NEWID()    
    ,guiApiImportLogId         = @guiLogId    
    ,strField                  = 'ItemNo'    
    ,strValue                  = vte.strItemNo    
    ,strLogLevel               = 'Error'    
    ,strStatus                 = 'Failed'    
    ,intRowNo                  = vte.intRowNumber    
    ,strMessage                = 'Item No does not exists.'    
    
FROM tblApiSchemaVendorTaxException vte    
LEFT JOIN tblICItem i ON vte.strItemNo = i.strItemNo   
WHERE vte.guiApiUniqueId = @guiApiUniqueId AND i.intItemId IS NULL 


UNION

--strCategoryCode
SELECT    
     guiApiImportLogDetailId   = NEWID()    
    ,guiApiImportLogId         = @guiLogId    
    ,strField                  = 'CategoryCode'    
    ,strValue                  = vte.strCategoryCode    
    ,strLogLevel               = 'Error'    
    ,strStatus                 = 'Failed'    
    ,intRowNo                  = vte.intRowNumber    
    ,strMessage                = 'Category Code does not exists.'    
    
FROM tblApiSchemaVendorTaxException vte    
LEFT JOIN tblICCategory cat ON vte.strCategoryCode = cat.strCategoryCode   
WHERE vte.guiApiUniqueId = @guiApiUniqueId AND cat.intCategoryId IS NULL 
    
INSERT INTO tblAPVendorTaxException (
 
	 intEntityVendorId 
    ,intItemId    
    ,intCategoryId
	,intTaxCodeId
	,intTaxClassId
	,strState
	,strException
	,dtmStartDate
	,dtmEndDate
	,intEntityVendorLocationId
	,guiApiUniqueId    
	,intRowNumber   
)    
    
SELECT    
	 v.intEntityId
	,intItemId
	,c.intCategoryId
	,tcode.intTaxCodeId
	,tclass.intTaxClassId
	,vte.strState
	,vte.strException
	,vte.dtmStartDate
	,vte.dtmEndDate
    ,el.intEntityLocationId    
	,@guiApiUniqueId   
    ,vte.intRowNumber 
FROM tblApiSchemaVendorTaxException vte    
  
INNER JOIN tblAPVendor v ON vte.strVendorId = v.strVendorId    
LEFT JOIN tblICItem i ON vte.strItemNo = i.strItemNo   
LEFT JOIN tblICCategory c ON vte.strCategoryCode = c.strCategoryCode  
LEFT JOIN tblSMTaxCode tcode ON vte.strTaxCode = tcode.strTaxCode
LEFT JOIN tblSMTaxClass tclass ON vte.strTaxCode = tclass.strTaxClass
LEFT JOIN (  
 SELECT e.strEntityNo, e.intEntityId, el.strLocationName, el.intEntityLocationId FROM tblEMEntity e  
 INNER JOIN tblEMEntityLocation el ON e.intEntityId = el.intEntityId AND el.ysnActive = 1 AND e.intEntityId IS NOT NULL 
)  
el ON vte.strLocationName = el.strLocationName  
WHERE vte.guiApiUniqueId = @guiApiUniqueId    
     
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
    , strField                  = 'intAPVendorTaxExceptionId'    
    , strValue                  = vte.intAPVendorTaxExceptionId -- This can be a transaction number or any value that you want to assign to this field    
    , strLogLevel               = 'Info'    
    , strStatus                 = 'Success'    
    , intRowNo                  = vte.intRowNumber 
    , strMessage                = 'The record was imported successfully.'    
FROM tblAPVendorTaxException vte    
WHERE     
    -- APPLY THE FILTER FOR guiApiUniqueId TO GET ONLY THE RECORDS RELATED TO THIS IMPORT SESSION.    
     vte.guiApiUniqueId = @guiApiUniqueId  