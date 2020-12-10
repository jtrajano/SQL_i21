CREATE VIEW [dbo].[vyuETExportCustomerTaxExemption]  
AS  


SELECT 'Customer' strExemptType
		,B.ysnTaxExempt
		,ISNULL(A.intCustomerTaxingTaxExceptionId,0) intCustomerTaxingTaxExceptionId
		,ISNULL(A.intEntityCustomerId,0) intEntityCustomerId
		,ISNULL(A.intItemId,0) intItemId
		,ISNULL(A.intCategoryId,0) intCategoryId
		,ISNULL(A.intTaxCodeId,0) intTaxCodeId
		,ISNULL(A.intTaxClassId,0) intTaxClassId
		,A.strState
		,REPLACE(CONVERT(NVARCHAR(50),A.dtmStartDate,101),'/','')  dtmStartDate
		,REPLACE(CONVERT(NVARCHAR(50),A.dtmEndDate,101),'/','') dtmEndDate
		,B.strCustomerNumber
		,C.strItemNo
		,ETTaxMap.strTaxCodeReference
		,TClass.strTaxClass	
		,intTaxGroupId  = 0
FROM tblARCustomerTaxingTaxException A
INNER JOIN tblARCustomer B ON A.intEntityCustomerId = B.intEntityId
LEFT JOIN tblICItem C ON A.intItemId = C.intItemId
INNER JOIN tblSMTaxClass TClass ON TClass.intTaxClassId = A.intTaxClassId
INNER JOIN tblSMTaxCode TCode ON TClass.intTaxClassId = TCode.intTaxClassId
LEFT JOIN tblETExportTaxCodeMapping ETTaxMap ON ETTaxMap.intTaxCodeId = TCode.intTaxCodeId
WHERE CAST(GETDATE() AS DATE) BETWEEN CAST(ISNULL(A.[dtmStartDate], GETDATE()) AS DATE) AND CAST(ISNULL(A.[dtmEndDate], GETDATE()) AS DATE)

UNION 

SELECT 'Category'
		,0
		,0
		,0
		,0
		,ISNULL(SMTGCE.intCategoryId,0)
		,ISNULL(SMTGC.intTaxCodeId,0)
		,0
		,''
		,REPLACE(CONVERT(NVARCHAR(50),GETDATE(),101),'/','') -- dd/MM/yyyy format
		,REPLACE(CONVERT(NVARCHAR(50),GETDATE(),101),'/','') -- dd/MM/yyyy format
		,''
		,''
		,strTaxCodeReference = ''
		,''
		,TaxGroupId = ISNULL(SMTGC.intTaxGroupId,0)
FROM tblSMTaxGroupCodeCategoryExemption SMTGCE
INNER JOIN tblSMTaxGroupCode SMTGC ON SMTGCE.[intTaxGroupCodeId] = SMTGC.[intTaxGroupCodeId]

UNION
SELECT ''
		,0
		,0
		,0
		,0
		,0
		,0
		,0
		,strState = ''
		,REPLACE(CONVERT(NVARCHAR(50),GETDATE(),101),'/','') -- dd/MM/yyyy format
		,REPLACE(CONVERT(NVARCHAR(50),GETDATE(),101),'/','') -- dd/MM/yyyy format
		,strCustomerNumber = ''
		,strItemNo = ''
		,strTaxCodeReference = ''
		,''
		,TaxGroupId = 0

		GO