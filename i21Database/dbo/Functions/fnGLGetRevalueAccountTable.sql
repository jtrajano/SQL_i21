CREATE FUNCTION [dbo].[fnGLGetRevalueAccountTable]()
RETURNS TABLE
AS
RETURN
(
	SELECT 'AP'		strModule,'Payables' strType, [intAccountsPayableUnrealizedId] AccountId , OffSet = 0 FROM tblSMMultiCurrency UNION ALL
	SELECT 'AR'		strModule,'Receivables' strType, [intAccountsReceivableUnrealizedId] AccountId , OffSet = 0 FROM tblSMMultiCurrency UNION ALL
	SELECT 'INV'	strModule,'Payables' strType, [intInventoryUnrealizedId] AccountId , OffSet = 0 FROM tblSMMultiCurrency UNION ALL
	SELECT 'INV'	strModule,'Receivables' strType, [intInventoryUnrealizedId] AccountId , OffSet = 0 FROM tblSMMultiCurrency UNION ALL
	SELECT 'CT'		strModule,'Payables' strType, [intContractPurchaseUnrealizedId] AccountId , OffSet = 0 FROM tblSMMultiCurrency UNION ALL
	SELECT 'CT'		strModule,'Receivables' strType, [intContractSaleUnrealizedId] AccountId , OffSet = 0 FROM tblSMMultiCurrency UNION ALL
	SELECT 'CM'		strModule,'Receivables' strType, intCashManagementUnrealizedId AccountId , OffSet = 0 FROM tblSMMultiCurrency UNION ALL
	SELECT 'FA'		strModule,'Receivables' strType, [intFixedAssetsUnrealizedId] AccountId , OffSet = 0 FROM tblSMMultiCurrency UNION ALL
	SELECT 'CM Forwards'	strModule, 'Payables' strType, [intGainOnForwardUnrealizedId] AccountId , OffSet = 0 FROM tblSMMultiCurrency UNION ALL
	SELECT 'CM Forwards'	strModule, 'Receivables' strType, [intGainOnForwardUnrealizedId] AccountId , OffSet = 0 FROM tblSMMultiCurrency UNION ALL
	SELECT 'CM In-Transit'	strModule, 'Receivables' strType, [intCashManagementUnrealizedId] AccountId , OffSet = 0 FROM tblSMMultiCurrency UNION ALL
	SELECT 'CM Swaps'		strModule, 'Payables' strType, [intGainOnSwapUnrealizedId] AccountId , OffSet = 0 FROM tblSMMultiCurrency UNION ALL
	SELECT 'CM Swaps'		strModule, 'Receivables' strType, [intGainOnSwapUnrealizedId] AccountId , OffSet = 0 FROM tblSMMultiCurrency UNION ALL
	SELECT 'GL'		strModule, 'General Ledger' strType, [intGainOnGLUnrealizedId] AccountId , OffSet = 0 FROM tblSMMultiCurrency UNION ALL

	SELECT 'AP'		strModule,'Payables' strType, [intAccountsPayableOffsetId] AccountId , OffSet = 1 FROM tblSMMultiCurrency UNION ALL
	SELECT 'AR'		strModule,'Receivables' strType, [intAccountsReceivableOffsetId] AccountId , OffSet = 1 FROM tblSMMultiCurrency UNION ALL
	SELECT 'INV'	strModule,'Payables' strType, [intInventoryOffsetId] AccountId , OffSet = 1 FROM tblSMMultiCurrency UNION ALL
	SELECT 'INV'	strModule,'Receivables' strType, [intInventoryOffsetId] AccountId , OffSet = 1 FROM tblSMMultiCurrency UNION ALL
	SELECT 'CT'		strModule,'Payables' strType, [intContractPurchaseOffsetId] AccountId , OffSet = 1 FROM tblSMMultiCurrency UNION ALL
	SELECT 'CT'		strModule,'Receivables' strType, [intContractSaleOffsetId] AccountId , OffSet = 1 FROM tblSMMultiCurrency UNION ALL
	SELECT 'CM'		strModule,'Receivables' strType, intCashManagementOffsetId AccountId , OffSet = 1 FROM tblSMMultiCurrency UNION ALL
	SELECT 'FA'		strModule,'Receivables' strType, [intFixedAssetsOffsetId] AccountId , OffSet = 1 FROM tblSMMultiCurrency UNION ALL
	SELECT 'CM Forwards'	strModule,'Payables' strType, [intGainOnForwardOffsetId] AccountId , OffSet = 1 FROM tblSMMultiCurrency UNION ALL
	SELECT 'CM Forwards'	strModule,'Receivables' strType, [intGainOnForwardOffsetId] AccountId , OffSet = 1 FROM tblSMMultiCurrency UNION ALL
	SELECT 'CM In-Transit'	strModule,'Receivables' strType, [intCashManagementOffsetId] AccountId , OffSet = 1 FROM tblSMMultiCurrency UNION ALL
	SELECT 'CM Swaps'		strModule,'Payables' strType, [intGainOnSwapOffsetId] AccountId , OffSet = 1 FROM tblSMMultiCurrency UNION ALL
	SELECT 'CM Swaps'		strModule,'Receivables' strType, [intGainOnSwapOffsetId] AccountId , OffSet = 1 FROM tblSMMultiCurrency UNION ALL
	SELECT 'GL'		strModule, 'General Ledger' strType, [intGainOnGLUnrealizedOffsetId] AccountId , OffSet = 1 FROM tblSMMultiCurrency
)