CREATE TABLE [dbo].[prvspmst] (
    [prvsp_type]          CHAR (1)       NOT NULL,
    [prvsp_pay_type]      CHAR (1)       NOT NULL,
    [prvsp_part_time]     TINYINT        NOT NULL,
    [prvsp_years]         DECIMAL (5, 3) NOT NULL,
    [prvsp_hours]         DECIMAL (5, 2) NULL,
    [prvsp_desc]          CHAR (25)      NULL,
    [prvsp_carryover_hrs] DECIMAL (6, 2) NULL,
    [prvsp_max_balance]   DECIMAL (6, 2) NULL,
    [prvsp_user_id]       CHAR (16)      NULL,
    [prvsp_user_rev_dt]   INT            NULL,
    [A4GLIdentity]        NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_prvspmst] PRIMARY KEY NONCLUSTERED ([prvsp_type] ASC, [prvsp_pay_type] ASC, [prvsp_part_time] ASC, [prvsp_years] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iprvspmst0]
    ON [dbo].[prvspmst]([prvsp_type] ASC, [prvsp_pay_type] ASC, [prvsp_part_time] ASC, [prvsp_years] ASC);

