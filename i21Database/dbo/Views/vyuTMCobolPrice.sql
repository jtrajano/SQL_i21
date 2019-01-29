CREATE VIEW [dbo].[vyuTMCobolPrice]  
AS  
SELECT intId = ROW_NUMBER() OVER (ORDER BY LastUpdateDate DESC)
, strCustomerNumber = CustomerNumber  COLLATE Latin1_General_CI_AS      
,strSiteNumber = SiteNumber  COLLATE Latin1_General_CI_AS      
,dblPrice = Price
,intLastUpdateDate = CAST(LastUpdateDate AS INT)
,intLastUpdateTime = CAST(LastUpdateTime AS INT) 
,strLastUpdateDate = LastUpdateDate COLLATE Latin1_General_CI_AS      
,strLastUpdateTime = LastUpdateTime COLLATE Latin1_General_CI_AS      
FROM tblTMCOBOLPRICE