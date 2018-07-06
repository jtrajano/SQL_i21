CREATE VIEW [dbo].[vyuSMTaxableByOtherTaxes]
AS 
SELECT	intTaxableByOtherTaxesId, intTaxCodeId, strTaxCode,
		strTaxCodes = STUFF((SELECT	', ' + strTaxCode
				FROM	(SELECT b.intID as intTaxableByOtherTaxesId
						   ,a.intTaxCodeId
						   ,c.strTaxCode
						   FROM tblSMTaxCode a
						   CROSS APPLY fnGetRowsFromDelimitedValues(a.strTaxableByOtherTaxes) b 
						   INNER JOIN tblSMTaxCode c ON b.intID = c.intTaxCodeId) AS B2
				WHERE B2.intTaxCodeId = B1.intTaxCodeId	
				ORDER BY strTaxCode
				FOR XML	PATH('')
				), 1, 1, '')
FROM (SELECT b.intID as intTaxableByOtherTaxesId
		,a.intTaxCodeId
		,c.strTaxCode
		FROM tblSMTaxCode a
		CROSS APPLY fnGetRowsFromDelimitedValues(a.strTaxableByOtherTaxes) b 
		INNER JOIN tblSMTaxCode c ON b.intID = c.intTaxCodeId) AS B1


