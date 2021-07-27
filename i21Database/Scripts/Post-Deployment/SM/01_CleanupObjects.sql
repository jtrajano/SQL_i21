PRINT 'Begin SM Clean up Objects - Drop obsolete objects'
GO

IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspDMMergeTables'))
       DROP PROCEDURE uspDMMergeTables;
GO

IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspSMSyncTables'))
       DROP PROCEDURE uspSMSyncTables;
GO

IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspSMReplicationRemoteConfiguration'))
       DROP PROCEDURE uspSMReplicationRemoteConfiguration;
GO

IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspSMReplicationPullSubscription'))
       DROP PROCEDURE uspSMReplicationPullSubscription;
GO

IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspSMReplicationMainConfiguration'))
       DROP PROCEDURE uspSMReplicationMainConfiguration;
GO

IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspSMReplicationDropPullSubscription'))
       DROP PROCEDURE uspSMReplicationDropPullSubscription;
GO

IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspSMReplicationDropPublication'))
       DROP PROCEDURE uspSMReplicationDropPublication;
GO

IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspSMReplicationAddSubscriptionForRemote'))
       DROP PROCEDURE uspSMReplicationAddSubscriptionForRemote;
GO

IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspSMReplicatonDropPublication'))
       DROP PROCEDURE uspSMReplicatonDropPublication;
GO

IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspSMReplicationDropPublication'))
       DROP PROCEDURE uspSMReplicationDropPublication;
GO
IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspIUAuditLogs'))
       DROP PROCEDURE uspIUAuditLogs;
GO
IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspSMCreateReIndexMaintenancePlan'))
       DROP PROCEDURE uspSMCreateReIndexMaintenancePlan;
GO

IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspSMValidateRemoteDBServer'))
       DROP PROCEDURE uspSMValidateRemoteDBServer;
GO

IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspSMErrorMessages'))
       DROP PROCEDURE uspSMErrorMessages;
GO


IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspSMReplicatonDropPublication'))
       DROP PROCEDURE uspSMReplicatonDropPublication;
GO

IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspSMValidateRemoteDBServer'))
       DROP PROCEDURE uspSMValidateRemoteDBServer;
GO

IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspIUAuditLogs'))
       DROP PROCEDURE uspIUAuditLogs;
GO

IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspSMCreateReIndexMaintenancePlan'))
		DROP PROCEDURE uspSMCreateReIndexMaintenancePlan;
GO

--remove only for sql azure
IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspSMCreateAttachmentFromFile'))
BEGIN
	DECLARE @edition NVARCHAR(100)
	SELECT @edition = CASE ServerProperty('Edition')
        WHEN 'SQL Azure' THEN 'Azure'
        WHEN 'Azure SQL Edge Developer' THEN 'Azure'
        WHEN 'Azure SQL Edge' THEN 'Azure'
        ELSE 'Normal'
    END
	 IF ISNULL(@edition, '') = 'Azure'
	 BEGIN
		DROP PROCEDURE uspSMCreateAttachmentFromFile;
	 END
END
GO
IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspSPAuditLogs'))
       DROP PROCEDURE uspSPAuditLogs;
GO
IF EXISTS(SELECT top 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'dbo.uspSMCreateAuditLogMigrationPlan'))
       DROP PROCEDURE uspSMCreateAuditLogMigrationPlan;
GO



PRINT 'End SM Clean up Objects - Drop obsolete objects'
GO



PRINT 'Begin Customer Portal Clean up Objects - Drop obsolete objects'
GO


IF OBJECT_ID('vyuCPAgcrdMst','v') IS NOT NULL
	DROP VIEW vyuCPAgcrdMst;
GO
IF OBJECT_ID('vyuCPAgcusMst','v') IS NOT NULL
	DROP VIEW vyuCPAgcusMst;
GO
IF OBJECT_ID('vyuCPBABusinessSummary','v') IS NOT NULL
	DROP VIEW vyuCPBABusinessSummary;
GO
IF OBJECT_ID('vyuCPBillingAccountPayments','v') IS NOT NULL
	DROP VIEW vyuCPBillingAccountPayments;
GO
IF OBJECT_ID('vyuCPContracts','v') IS NOT NULL
	DROP VIEW vyuCPContracts;
GO
IF OBJECT_ID('vyuCPCurrentCashBids','v') IS NOT NULL
	DROP VIEW vyuCPCurrentCashBids;
GO
IF OBJECT_ID('vyuCPCustomer','v') IS NOT NULL
	DROP VIEW vyuCPCustomer;
GO
IF OBJECT_ID('vyuCPDatabaseDate','v') IS NOT NULL
	DROP VIEW vyuCPDatabaseDate;
GO
IF OBJECT_ID('vyuCPGABusinessSummary','v') IS NOT NULL
	DROP VIEW vyuCPGABusinessSummary;
GO
IF OBJECT_ID('vyuCPGAContractOption','v') IS NOT NULL
	DROP VIEW vyuCPGAContractOption;
GO
IF OBJECT_ID('vyuCPGAContractDetail','v') IS NOT NULL
	DROP VIEW vyuCPGAContractDetail;
GO
IF OBJECT_ID('vyuCPGAContractHistory','v') IS NOT NULL
	DROP VIEW vyuCPGAContractHistory;
GO
IF OBJECT_ID('vyuCPGAContracts','v') IS NOT NULL
	DROP VIEW vyuCPGAContracts;
GO
IF OBJECT_ID('vyuCPGASettlementsReports','v') IS NOT NULL
	DROP VIEW vyuCPGASettlementsReports;
GO
IF OBJECT_ID('vyuCPInvoicesCredits','v') IS NOT NULL
	DROP VIEW vyuCPInvoicesCredits;
GO
IF OBJECT_ID('vyuCPInvoicesCreditsReports','v') IS NOT NULL
	DROP VIEW vyuCPInvoicesCreditsReports;
GO
IF OBJECT_ID('vyuCPOptions','v') IS NOT NULL
	DROP VIEW vyuCPOptions;
GO
IF OBJECT_ID('vyuCPOrders','v') IS NOT NULL
	DROP VIEW vyuCPOrders;
GO
IF OBJECT_ID('vyuCPPayments','v') IS NOT NULL
	DROP VIEW vyuCPPayments;
GO
IF OBJECT_ID('vyuCPPaymentsDetails','v') IS NOT NULL
	DROP VIEW vyuCPPaymentsDetails;
GO
IF OBJECT_ID('vyuCPPendingInvoices','v') IS NOT NULL
	DROP VIEW vyuCPPendingInvoices;
GO
IF OBJECT_ID('vyuCPPendingPayments','v') IS NOT NULL
	DROP VIEW vyuCPPendingPayments;
GO
IF OBJECT_ID('vyuCPPrepaidCredits','v') IS NOT NULL
	DROP VIEW vyuCPPrepaidCredits;
GO
IF OBJECT_ID('vyuCPProductionHistory','v') IS NOT NULL
	DROP VIEW vyuCPProductionHistory;
GO
IF OBJECT_ID('vyuCPPurchaseDetail','v') IS NOT NULL
	DROP VIEW vyuCPPurchaseDetail;
GO
IF OBJECT_ID('vyuCPPurchaseMain','v') IS NOT NULL
	DROP VIEW vyuCPPurchaseMain;
GO
IF OBJECT_ID('vyuCPPurchases','v') IS NOT NULL
	DROP VIEW vyuCPPurchases;
GO
IF OBJECT_ID('vyuCPPurchasesDetail','v') IS NOT NULL
	DROP VIEW vyuCPPurchasesDetail;
GO
IF OBJECT_ID('vyuCPSettlements','v') IS NOT NULL
	DROP VIEW vyuCPSettlements;
GO
IF OBJECT_ID('vyuCPStorage','v') IS NOT NULL
	DROP VIEW vyuCPStorage;
GO




PRINT 'End Customer Portal Clean up Objects - Drop obsolete objects'
GO