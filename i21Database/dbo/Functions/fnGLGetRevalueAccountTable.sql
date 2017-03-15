CREATE FUNCTION [dbo].[fnGLGetRevalueAccountTable]()
RETURNS TABLE
AS

RETURN
(
	-- Add the T-SQL statements to compute the return value here
	SELECT 'AP'		strModule,'Payables' strType, [intAccountsPayableUnrealizedId] AccountId , OffSet = 0 FROM tblSMMultiCurrency UNION ALL
	SELECT 'AR'		strModule,'Receivables' strType, [intAccountsReceivableUnrealizedId] AccountId , OffSet = 0 FROM tblSMMultiCurrency UNION ALL
	SELECT 'INV'	strModule,'Payables' strType, [intInventoryUnrealizedId] AccountId , OffSet = 0 FROM tblSMMultiCurrency UNION ALL
	SELECT 'INV'	strModule,'Receivables' strType, [intInventoryUnrealizedId] AccountId , OffSet = 0 FROM tblSMMultiCurrency UNION ALL
	SELECT 'CT'		strModule,'Payables' strType, [intContractPurchaseUnrealizedId] AccountId , OffSet = 0 FROM tblSMMultiCurrency UNION ALL
	SELECT 'CT'		strModule,'Receivables' strType, [intContractSaleUnrealizedId] AccountId , OffSet = 0 FROM tblSMMultiCurrency UNION ALL

	SELECT 'AP'		strModule,'Payables' strType, [intAccountsPayableOffsetId] AccountId , OffSet = 1 FROM tblSMMultiCurrency UNION ALL
	SELECT 'AR'		strModule,'Receivables' strType, [intAccountsReceivableOffsetId] AccountId , OffSet = 1 FROM tblSMMultiCurrency UNION ALL
	SELECT 'INV'	strModule,'Payables' strType, [intInventoryOffsetId] AccountId , OffSet = 1 FROM tblSMMultiCurrency UNION ALL
	SELECT 'INV'	strModule,'Receivables' strType, [intInventoryOffsetId] AccountId , OffSet = 1 FROM tblSMMultiCurrency UNION ALL
	SELECT 'CT'		strModule,'Payables' strType, [intContractPurchaseOffsetId] AccountId , OffSet = 1 FROM tblSMMultiCurrency UNION ALL
	SELECT 'CT'		strModule,'Receivables' strType, [intContractSaleOffsetId] AccountId , OffSet = 1 FROM tblSMMultiCurrency 

	--SELECT 'AP'		strModule,'Payables' strType, 1 AccountId , OffSet = 0 FROM tblSMMultiCurrency UNION ALL
	--SELECT 'AR'		strModule,'Receivables' strType, 2  AccountId , OffSet = 0 FROM tblSMMultiCurrency UNION ALL
	--SELECT 'INV'	strModule,'Payables' strType, 3 AccountId , OffSet = 0 FROM tblSMMultiCurrency UNION ALL
	--SELECT 'INV'	strModule,'Receivables' strType, 4 AccountId , OffSet = 0 FROM tblSMMultiCurrency UNION ALL
	--SELECT 'CT'		strModule,'Payables' strType, 5 AccountId , OffSet = 0 FROM tblSMMultiCurrency UNION ALL
	--SELECT 'CT'		strModule,'Receivables' strType, 6 AccountId , OffSet = 0 FROM tblSMMultiCurrency UNION ALL

	--SELECT 'AP'		strModule,'Payables' strType, 7 AccountId , OffSet = 1 FROM tblSMMultiCurrency UNION ALL
	--SELECT 'AR'		strModule,'Receivables' strType, 8 AccountId , OffSet = 1 FROM tblSMMultiCurrency UNION ALL
	--SELECT 'INV'	strModule,'Payables' strType, 9 AccountId , OffSet = 1 FROM tblSMMultiCurrency UNION ALL
	--SELECT 'INV'	strModule,'Receivables' strType, 10 AccountId , OffSet = 1 FROM tblSMMultiCurrency UNION ALL
	--SELECT 'CT'		strModule,'Payables' strType, 11 AccountId , OffSet = 1 FROM tblSMMultiCurrency UNION ALL
	--SELECT 'CT'		strModule,'Receivables' strType, 12 AccountId , OffSet = 1 FROM tblSMMultiCurrency

)


