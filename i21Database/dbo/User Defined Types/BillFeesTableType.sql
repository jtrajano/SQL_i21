CREATE TYPE [dbo].[BillFeesTableType] AS TABLE
(
    [intCustomerStorageId]		INT                 NOT NULL,
    [intEntityId]				INT                 NOT NULL,
	[intItemId]					INT                 NOT NULL,
    [intCompanyLocationId]		INT                 NOT NULL,
	[dblOpenBalance]			NUMERIC(18,6)       NULL,
	[dblFeesDue]				NUMERIC(18,6)       NULL,
	[dblFeesPaid]				NUMERIC(18,6)       NULL,
	[dblFeesUnpaid]				NUMERIC(18,6)       NULL,
	[dblFeesTotal]				NUMERIC(18,6)       NULL
)