CREATE VIEW [dbo].[vyuARPaymentMethodForReceivePayments]
AS 

SELECT
	ROW_NUMBER() OVER(ORDER BY intPaymentMethodID DESC) AS intId
	,intPaymentMethodID 
	,strPaymentMethod
	,ysnActive
	,intEntityCardInfoId = NULL
	,intEntityId = 0 
FROM tblSMPaymentMethod
WHERE strPaymentMethod <> 'Credit Card' and ysnActive = 1

UNION ALL 
SELECT
	ROW_NUMBER() OVER(ORDER BY intEntityCardInfoId) + (SELECT COUNT(*) FROM tblSMPaymentMethod WHERE strPaymentMethod <> 'Credit Card' and ysnActive = 1) AS intId  
	,11
	,strCreditCardNumber
	,ysnActive
	,intEntityCardInfoId
	,intEntityId
FROM tblEMEntityCardInformation
WHERE strToken is not null
and  DATEADD(month ,1 , CAST(REPLACE(strCardExpDate,'/','/01/') as datetime)) >= CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME)