CREATE VIEW [dbo].[vyuSMBEExportTaxCode]  
AS 

SELECT 
	 category = A.intTaxCodeId
	 ,tax = B.dblRate
	 ,header = ''
	 ,"type" = A.strTaxCode
FROM tblSMTaxCode A
CROSS APPLY (SELECT * FROM fnGetTaxCodeRateDetails(A.intTaxCodeId,GETDATE()))B

GO