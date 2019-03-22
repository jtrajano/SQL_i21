CREATE VIEW [dbo].[vyuETBEExportTaxCode]  
AS 

SELECT 
	 category = A.intTaxCodeId
	 ,tax = B.dblRate
	 ,header = '' COLLATE Latin1_General_CI_AS
	 ,"type" = A.strTaxCode
FROM tblSMTaxCode A
CROSS APPLY (SELECT * FROM fnGetTaxCodeRateDetails(A.intTaxCodeId,GETDATE(), NULL, NULL, NULL, NULL)) B

GO