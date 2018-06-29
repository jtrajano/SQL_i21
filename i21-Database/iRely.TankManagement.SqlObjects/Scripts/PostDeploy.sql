:r .\PostDeployment\DefaultData\1_PreferenceCompany.sql
:r .\PostDeployment\DefaultData\2_EventType.sql
:r .\PostDeployment\DefaultData\3_DeviceType.sql
:r .\PostDeployment\DefaultData\4_MeterType.sql
:r .\PostDeployment\DefaultData\5_FillMethodType.sql
:r .\PostDeployment\DefaultData\6_InventoryStatusType.sql
:r .\PostDeployment\DefaultData\7_WorkStatusType.sql
:r .\PostDeployment\DefaultData\8_WorkToDoItem.sql
:r .\PostDeployment\DefaultData\9_WorkCloseReason.sql
:r .\PostDeployment\DefaultData\10_RegulatorType.sql
:r .\PostDeployment\DefaultData\11_ApplianceType.sql
:r .\PostDeployment\DefaultData\12_BudgetCalculation.sql
:r .\PostDeployment\DefaultData\13_GlobalJulianCalendar.sql
:r .\PostDeployment\Tables\tblTMCOBOLWRITE.sql

----TM Reports
:r .\PostDeployment\Reports\FieldSelection\DeliveryFill.sql
:r .\PostDeployment\Reports\Layout\DeliveryFill.sql
:r .\PostDeployment\Reports\DataSource\DeliveryFill.sql
:r .\PostDeployment\Reports\DefaultCriteria\DeliveryFill.sql
:r .\PostDeployment\Reports\SubReportSettings\DeliveryFill.sql

:r .\PostDeployment\Reports\FieldSelection\DeviceLeaseDetail.sql
:r .\PostDeployment\Reports\Layout\DeviceLeaseDetail.sql
:r .\PostDeployment\Reports\DataSource\DeviceLeaseDetail.sql
:r .\PostDeployment\Reports\DefaultCriteria\DeviceLeaseDetail.sql

:r .\PostDeployment\Reports\Layout\DeviceActions.sql
:r .\PostDeployment\Reports\DataSource\DeviceActions.sql
	 
:r .\PostDeployment\Reports\Layout\ProductTotals.sql
:r .\PostDeployment\Reports\DataSource\ProductTotals.sql
	 
:r .\PostDeployment\Reports\DataSource\CustomerListByRoute.sql
:r .\PostDeployment\Reports\Layout\CustomerListByRoute.sql
:r .\PostDeployment\Reports\DefaultCriteria\CustomerListByRoute.sql
	 
:r .\PostDeployment\Reports\DataSource\GasCheckLeakcheck.sql
:r .\PostDeployment\Reports\Layout\WithGasCheckSubReport.sql
:r .\PostDeployment\Reports\Layout\WithLeakCheckSubReport.sql
:r .\PostDeployment\Reports\Layout\WithoutGasCheckSubReport.sql
:r .\PostDeployment\Reports\Layout\WithoutLeakCheckSubReport.sql
	 
:r .\PostDeployment\Reports\DataSource\OpenCallEntries.sql
:r .\PostDeployment\Reports\DataSource\EfficiencyReport.sql
:r .\PostDeployment\Reports\Layout\EfficiencyReport.sql
:r .\PostDeployment\Reports\Layout\WorkOrder.sql
:r .\PostDeployment\Reports\DataSource\CallEntryPrintOut.sql
:r .\PostDeployment\Reports\Layout\CallEntryPrintOut.sql
:r .\PostDeployment\4_MigrateLeaseIdFromDeviceToLeaseDeviceTable.sql
:r .\PostDeployment\5_ObsoletingSeasonReset.sql

:r ".\PostDeployment\Integration\dbo\Stored Procedures\uspTMRecreateAccountStatusView.sql"
:r ".\PostDeployment\Integration\dbo\Stored Procedures\uspTMRecreateCommentsView.sql"
:r ".\PostDeployment\Integration\dbo\Stored Procedures\uspTMRecreateContractView.sql"
:r ".\PostDeployment\Integration\dbo\Stored Procedures\uspTMRecreateOriginOptionView.sql"
:r ".\PostDeployment\Integration\dbo\Stored Procedures\uspTMRecreateCTLMSTView.sql"
:r ".\PostDeployment\Integration\dbo\Stored Procedures\uspTMRecreateItemView.sql"
:r ".\PostDeployment\Integration\dbo\Stored Procedures\uspTMRecreateInvoiceView.sql"
:r ".\PostDeployment\Integration\dbo\Stored Procedures\uspTMRecreateLocaleTaxView.sql"
:r ".\PostDeployment\Integration\dbo\Stored Procedures\uspTMRecreateLocationView.sql"
:r ".\PostDeployment\Integration\dbo\Stored Procedures\uspTMRecreateCustomerView.sql"
:r ".\PostDeployment\Integration\dbo\Stored Procedures\uspTMRecreateSalesPersonView.sql"
:r ".\PostDeployment\Integration\dbo\Stored Procedures\uspTMRecreateTermsView.sql"
:r ".\PostDeployment\Integration\dbo\Stored Procedures\TwoPartDeliveryFillReport.sql"
:r ".\PostDeployment\Integration\dbo\Stored Procedures\uspTMGetConsumptionWithGasCheck.sql"
:r ".\PostDeployment\Integration\dbo\Stored Procedures\uspTMGetConsumptionWithLeakCheck.sql"
:r ".\PostDeployment\Integration\dbo\Stored Procedures\uspTMGetConsumptionWithoutLeakCheck.sql"
:r ".\PostDeployment\Integration\dbo\Stored Procedures\uspTMGetConsumptionWithoutGasCheck.sql"
:r ".\PostDeployment\Integration\dbo\Views\vyuTMOriginDegreeOption.sql"
:r ".\PostDeployment\Integration\dbo\Functions\fnTMGetContractForCustomer.sql"

:r ".\PostDeployment\Integration\dbo\Stored Procedures\uspTMAlterCobolWrite.sql"
:r ".\PostDeployment\2_DataTransferAndCorrection.sql" 
:r ".\PostDeployment\Integration\dbo\Stored Procedures\uspTMRecreateBudgetCalculationItemPricingView.sql"

:r ".\PostDeployment\Integration\dbo\Stored Procedures\uspTMRecreateLeaseSearchView.sql"
:r ".\PostDeployment\Integration\dbo\Functions\fnTMGetSpecialPricing.sql"
:r ".\PostDeployment\Integration\dbo\Functions\fnTMGetSpecialPricingPrice.sql"

:r ".\PostDeployment\3_PopulateLocatioinIdOnSiteForOriginIntegrated.sql"