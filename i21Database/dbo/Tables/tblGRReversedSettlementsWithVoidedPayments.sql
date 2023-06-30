CREATE TABLE [dbo].[tblGRReversedSettlementsWithVoidedPayments]
(
	intReversedSettlementsWithVoidedPaymentsId INT IDENTITY(1,1)
	,strSettleStorageTicket NVARCHAR(40) COLLATE Latin1_General_CI_AS
	,strBillId NVARCHAR(40) COLLATE Latin1_General_CI_AS
	,dblUnits DECIMAL(18,6)
	,strPaymentRecordNo NVARCHAR(40) COLLATE Latin1_General_CI_AS
	,intItemId INT
	,intCommodityId INT
	,intCommodityStockUOMId INT
	,intCompanyLocationId INT
	,dtmVoucherCreated DATETIME
	,dtmPaymentDate DATETIME
	,dtmVoidPaymentDate DATETIME
	,dtmReversalDate DATETIME DEFAULT(GETDATE())
)

GO

CREATE NONCLUSTERED INDEX [IX_tblGRReversedSettlementsWithVoidedPayments]
	ON [dbo].[tblGRReversedSettlementsWithVoidedPayments] ([strSettleStorageTicket],[dblUnits],[dtmVoucherCreated],[dtmPaymentDate],[dtmVoidPaymentDate])
GO