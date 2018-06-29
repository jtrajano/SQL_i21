CREATE VIEW [dbo].[vyuSMTaxableByOtherTaxes]
AS 
SELECT b.intID as intTaxableByOtherTaxesId
,a.intTaxCodeId
,c.strTaxCode
FROM tblSMTaxCode a
CROSS APPLY fnGetRowsFromDelimitedValues(a.strTaxableByOtherTaxes) b 
INNER JOIN tblSMTaxCode c ON b.intID = c.intTaxCodeId


