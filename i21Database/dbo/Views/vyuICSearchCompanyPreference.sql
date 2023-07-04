CREATE VIEW [dbo].[vyuICSearchCompanyPreference]
--Fixing to right view name vyuICGetCompanyPreference(not use) to vyuICSearchCompanyPreference
AS

SELECT 
	ic.intCompanyPreferenceId,
ic.intInheritSetup,
ic.intSort,
ic.intConcurrencyId,
ic.strLotCondition,
ic.strReceiptType,
ic.intReceiptSourceType,
ic.intShipmentOrderType,
ic.intShipmentSourceType,
ic.strOriginLineOfBusiness,
ic.strOriginLastTask,
ic.strIRUnpostMode,
ic.strReturnPostMode,
ic.strReceiptReportFormat,
ic.strPickListReportFormat,
ic.strBOLReportFormat,
ic.strTransferReportFormat,
ic.strCountSheetReportFormat,
ic.ysnMigrateNewInventoryTransaction,
ic.dtmDateCreated,
ic.dtmDateModified,
ic.intCreatedByUserId,
ic.intModifiedByUserId,
ic.ysnIsCountSheetMultiFilter,
ic.ysnPriceFixWarningInReceipt,
ic.ysnValidateReceiptTotal,
ic.intItemIdHolderForReceiptImport,
ic.ysnUpdateSMTransaction,
ic.ysnUpdateInventoryTransactionAccountId,
ic.strSingleOrMultipleLots,
ic.ysnInitialFamilyClassAdjustment,
ic.ysnUpdateJournalLineDescription,
ic.ysnEnableIntraCompanyTransfer,
ic.ysnSkipICGLValidation

	-- Get the company preference from the other modules that is related with IC. 
	,ysnImposeReversalTransaction = CAST(0 AS BIT) --rk.ysnImposeReversalTransaction
	,i.strItemNo
	,(SELECT ysnEnable FROM tblSMStartingNumber WHERE intStartingNumberId = '185') AS ysnEnable
	,strEnableIntraCompanyTransfer = CASE WHEN ic.ysnEnableIntraCompanyTransfer = 1 THEN 'Yes' ELSE 'No' END 
FROM 
	tblICCompanyPreference ic
	OUTER APPLY (
		SELECT TOP 1 
			rk.*
		FROM 
			tblRKCompanyPreference rk
	) rk 
	LEFT JOIN tblICItem i 
		ON i.intItemId = ic.intItemIdHolderForReceiptImport
	 
	 