
CREATE VIEW [dbo].[vyuCFTransactionTax]
AS
SELECT 
cfTransTax.intTransactionTaxId,
cfTransTax.intTransactionId, 
cfTransTax.dblTaxOriginalAmount, 
cfTransTax.dblTaxCalculatedAmount,
cfTransTax.dblTaxRate,
ismTaxClass.intTaxClassId,
ismTaxCode.intTaxCodeId,
ismTaxClass.strTaxClass,
ismTaxCode.strTaxCode,
cfCard.intAccountId,
cfCard.intCardId
FROM dbo.tblCFTransactionTax AS cfTransTax 
INNER JOIN dbo.tblSMTaxCode AS ismTaxCode ON cfTransTax.intTaxCodeId = ismTaxCode.intTaxCodeId 
INNER JOIN dbo.tblSMTaxClass AS ismTaxClass ON ismTaxCode.intTaxClassId = ismTaxClass.intTaxClassId
INNER JOIN dbo.tblCFTransaction AS cfTrans ON cfTransTax.intTransactionId = cfTrans.intTransactionId
INNER JOIN dbo.tblCFCard AS cfCard ON cfTrans.intCardId = cfCard.intCardId