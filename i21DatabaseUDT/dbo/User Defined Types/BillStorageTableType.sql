CREATE TYPE [dbo].[BillStorageTableType] AS TABLE
(
    [intCustomerStorageId]  INT                 NOT NULL,
    [intEntityId]           INT                 NOT NULL,
    [intCompanyLocationId]  INT                 NOT NULL,
    [dblOpenBalance]        NUMERIC(18,6)       NULL,
    [intStorageTypeId]      INT                 NOT NULL,
    [dblNewStorageDue]      NUMERIC(18,6)       NULL,
    [intItemId]             INT                 NOT NULL,
    [intStorageScheduleId]  INT                 NOT NULL
)