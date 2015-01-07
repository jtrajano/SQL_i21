CREATE VIEW [dbo].[vyuTMCobolPrice]  
AS  
SELECT intId = ROW_NUMBER() OVER (ORDER BY LastUpdateDate DESC)
, strCustomerNumber = CustomerNumber
,strSiteNumber = SiteNumber
,dblPrice = Price
,intLastUpdateDate = CAST(LastUpdateDate AS INT)
,intLastUpdateTime = CAST(LastUpdateTime AS INT) 
,strLastUpdateDate = LastUpdateDate
,strLastUpdateTime = LastUpdateTime
FROM tblTMCOBOLPRICE