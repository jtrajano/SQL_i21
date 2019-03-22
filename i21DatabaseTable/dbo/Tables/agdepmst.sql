CREATE TABLE [dbo].[agdepmst] (
    [agdep_rev_dt]         INT             NOT NULL,
    [agdep_batch_no]       SMALLINT        NOT NULL,
    [agdep_loc_no]         CHAR (3)        NOT NULL,
    [agdep_calc_amt_1]     DECIMAL (11, 2) NULL,
    [agdep_calc_amt_2]     DECIMAL (11, 2) NULL,
    [agdep_calc_amt_3]     DECIMAL (11, 2) NULL,
    [agdep_calc_amt_4]     DECIMAL (11, 2) NULL,
    [agdep_calc_amt_5]     DECIMAL (11, 2) NULL,
    [agdep_calc_amt_6]     DECIMAL (11, 2) NULL,
    [agdep_calc_amt_7]     DECIMAL (11, 2) NULL,
    [agdep_calc_amt_8]     DECIMAL (11, 2) NULL,
    [agdep_calc_amt_9]     DECIMAL (11, 2) NULL,
    [agdep_dep_amt]        DECIMAL (11, 2) NULL,
    [agdep_over_short_amt] DECIMAL (11, 2) NULL,
    [agdep_user_id]        CHAR (16)       NULL,
    [agdep_user_rev_dt]    CHAR (8)        NULL,
    [A4GLIdentity]         NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_agdepmst] PRIMARY KEY NONCLUSTERED ([agdep_rev_dt] ASC, [agdep_batch_no] ASC, [agdep_loc_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iagdepmst0]
    ON [dbo].[agdepmst]([agdep_rev_dt] ASC, [agdep_batch_no] ASC, [agdep_loc_no] ASC);

