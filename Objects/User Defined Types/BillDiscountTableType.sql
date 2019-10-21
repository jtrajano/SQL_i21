CREATE TYPE [dbo].[BillDiscountTableType] AS TABLE
(
    [intCustomerStorageId]		INT                 NOT NULL,
    [intEntityId]				INT                 NOT NULL,
	[intItemId]					INT                 NOT NULL,
    [intCompanyLocationId]		INT                 NOT NULL,
    [intDiscountScheduleCodeId]	INT					NOT NULL,
	[intDiscountItemId]			INT				    NOT NULL,	
	[dblOpenBalance]			NUMERIC(18,6)       NULL,
	[dblDiscountDue]			NUMERIC(18,6)       NULL,
	[dblDiscountPaid]			NUMERIC(18,6)       NULL,
	[dblDiscountUnpaid]			NUMERIC(18,6)       NULL,
	[dblDiscountTotal]			NUMERIC(18,6)       NULL
)