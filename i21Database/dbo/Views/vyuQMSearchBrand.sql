CREATE VIEW [dbo].[vyuQMSearchBrand]
AS
SELECT B.intBrandId		
     , B.strBrandCode				
     , B.strBrandName
     , B.intManufacturerId		
     , M.strManufacturer
FROM tblICBrand B
LEFT JOIN tblICManufacturer M ON B.intManufacturerId = M.intManufacturerId