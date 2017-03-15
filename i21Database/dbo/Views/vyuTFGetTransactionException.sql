CREATE VIEW [dbo].[vyuTFGetTransactionException]
	AS

SELECT TE.* 
	, PC.strProductCode
	, strProductCodeDescription = PC.strDescription
FROM tblTFTransactionException TE
LEFT JOIN tblTFProductCode PC ON PC.intProductCodeId = TE.intProductCodeId