CREATE TABLE [dbo].[premhmst] (
    [premh_emp]         CHAR (10)   NOT NULL,
    [premh_period_date] INT         NOT NULL,
    [premh_time]        INT         NOT NULL,
    [premh_field_id]    CHAR (20)   NULL,
    [premh_old_data]    CHAR (30)   NULL,
    [premh_new_data]    CHAR (30)   NULL,
    [premh_user_id]     CHAR (16)   NULL,
    [premh_user_rev_dt] INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_premhmst] PRIMARY KEY NONCLUSTERED ([premh_emp] ASC, [premh_period_date] ASC, [premh_time] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Ipremhmst0]
    ON [dbo].[premhmst]([premh_emp] ASC, [premh_period_date] ASC, [premh_time] ASC);

