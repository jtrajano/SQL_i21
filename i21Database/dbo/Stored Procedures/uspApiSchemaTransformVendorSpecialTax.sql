CREATE PROCEDURE dbo.uspApiSchemaTransformVendorSpecialTax (    
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
    , strValue                  = vst.strVendorId    
    , strLogLevel               = 'Error'    
    , strStatus                 = 'Failed'    
    , intRowNo                  = vst.intRowNumber    
    , strMessage                = 'Vendor Entity No does not exists.'    
    
FROM tblApiSchemaVendorSpecialTax vst    
LEFT JOIN tblAPVendor v ON vst.strVendorId = v.strVendorId  
WHERE v.intEntityId IS NULL  
AND vst.guiApiUniqueId = @guiApiUniqueId   
  
-- Entity  
UNION  
SELECT    
      guiApiImportLogDetailId   = NEWID()    
    , guiApiImportLogId         = @guiLogId    
    , strField                  = 'VendorTaxEntityNo'    
    , strValue                  = vst.strEntityNo    
    , strLogLevel               = 'Warning'    
    , strStatus                 = 'Ignored'    
    , intRowNo                  = vst.intRowNumber    
    , strMessage                = 'The Vendor Tax Entity No does not exists.'    
    
FROM tblApiSchemaVendorSpecialTax vst    
LEFT JOIN tblEMEntity e ON vst.strEntityNo = e.strEntityNo   
WHERE vst.guiApiUniqueId = @guiApiUniqueId AND e.intEntityId IS NULL 
  
--strLocationName 
UNION

SELECT    
      guiApiImportLogDetailId   = NEWID()    
    , guiApiImportLogId         = @guiLogId    
    , strField                  = 'VendorLocation'    
    , strValue                  = vst.strLocationName    
    , strLogLevel               = 'Error'    
    , strStatus                 = 'Failed'      
    , intRowNo                  = vst.intRowNumber    
    , strMessage                = 'Entity Location does not exists.'    
    
FROM tblApiSchemaVendorSpecialTax vst   
LEFT JOIN (  
 SELECT e.strEntityNo, e.intEntityId FROM tblEMEntity e  
 INNER JOIN tblEMEntityLocation el ON e.intEntityId = el.intEntityId AND el.ysnActive = 1  
)  
el ON vst.strEntityNo = el.strEntityNo  
WHERE vst.guiApiUniqueId = @guiApiUniqueId  
AND el.intEntityId IS NULL 


UNION
--strTaxGroup
SELECT    
     guiApiImportLogDetailId   = NEWID()    
    ,guiApiImportLogId         = @guiLogId    
    ,strField                  = 'TaxGroup'    
    ,strValue                  = vst.strTaxGroup    
    ,strLogLevel               = 'Error'    
    ,strStatus                 = 'Failed'     
    ,intRowNo                  = vst.intRowNumber    
    ,strMessage                = 'Tax Group does not exists.'    
    
FROM tblApiSchemaVendorSpecialTax vst    
LEFT JOIN tblSMTaxGroup tg ON vst.strTaxGroup = tg.strTaxGroup   
WHERE vst.guiApiUniqueId = @guiApiUniqueId AND tg.intTaxGroupId IS NULL

UNION

--strItemNo
SELECT    
     guiApiImportLogDetailId   = NEWID()    
    ,guiApiImportLogId         = @guiLogId    
    ,strField                  = 'ItemNo'    
    ,strValue                  = vst.strItemNo    
    ,strLogLevel               = 'Error'    
    ,strStatus                 = 'Failed'    
    ,intRowNo                  = vst.intRowNumber    
    ,strMessage                = 'Item No does not exists.'    
    
FROM tblApiSchemaVendorSpecialTax vst    
LEFT JOIN tblICItem i ON vst.strItemNo = i.strItemNo   
WHERE vst.guiApiUniqueId = @guiApiUniqueId AND i.intItemId IS NULL 


UNION

--strCategoryCode
SELECT    
     guiApiImportLogDetailId   = NEWID()    
    ,guiApiImportLogId         = @guiLogId    
    ,strField                  = 'CategoryCode'    
    ,strValue                  = vst.strCategoryCode    
    ,strLogLevel               = 'Error'    
    ,strStatus                 = 'Failed'    
    ,intRowNo                  = vst.intRowNumber    
    ,strMessage                = 'Category Code does not exists.'    
    
FROM tblApiSchemaVendorSpecialTax vst    
LEFT JOIN tblICCategory i ON vst.strCategoryCode = i.strCategoryCode   
WHERE vst.guiApiUniqueId = @guiApiUniqueId AND i.intCategoryId IS NULL 

IF EXISTS (SELECT 1 FROM tblApiImportLogDetail WHERE strLogLevel = 'Error' AND guiApiImportLogId = @guiLogId)
BEGIN
	RETURN;
END
    
INSERT INTO tblAPVendorSpecialTax (
	 guiApiUniqueId    
	,intRowNumber    
	,intEntityVendorId    
	,intTaxEntityVendorId    
	,intTaxGroupId    
	,intEntityVendorLocationId    
    ,intItemId    
    ,intCategoryId
)    
    
SELECT    
     @guiApiUniqueId   
    ,vst.intRowNumber    
	,v.intEntityId    
	,e.intEntityId    
	,tg.intTaxGroupId    
    ,el.intEntityLocationId    
	,i.intItemId    
	,c.intCategoryId    
FROM tblApiSchemaVendorSpecialTax vst    
  
INNER JOIN tblAPVendor v ON vst.strVendorId = v.strVendorId    
LEFT JOIN tblICItem i ON vst.strItemNo = i.strItemNo  
LEFT JOIN tblEMEntity e ON e.strEntityNo = vst.strEntityNo AND e.ysnActive = 1  
LEFT JOIN tblEMEntityLocation el   
ON el.strLocationName = vst.strLocationName AND el.intEntityId = e.intEntityId AND el.ysnActive = 1  
LEFT JOIN tblICCategory c ON vst.strCategoryCode = c.strCategoryCode  
LEFT JOIN tblSMTaxGroup tg ON vst.strTaxGroup = tg.strTaxGroup  
WHERE vst.guiApiUniqueId = @guiApiUniqueId    
     
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
    , strField                  = 'intAPVendorSpecialTax'    
    , strValue                  = vst.intAPVendorSpecialTaxId -- This can be a transaction number or any value that you want to assign to this field    
    , strLogLevel               = 'Info'    
    , strStatus                 = 'Success'    
    , intRowNo                  = vst.intRowNumber    
    , strMessage                = 'The record was imported successfully.'    
FROM tblAPVendorSpecialTax vst    
WHERE     
    -- APPLY THE FILTER FOR guiApiUniqueId TO GET ONLY THE RECORDS RELATED TO THIS IMPORT SESSION.    
     vst.guiApiUniqueId = @guiApiUniqueId  