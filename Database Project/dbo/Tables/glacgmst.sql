CREATE TABLE [dbo].[glacgmst] (
    [glacg_beg1_8]            INT         NOT NULL,
    [glacg_end1_8]            INT         NULL,
    [glacg_description]       CHAR (30)   NULL,
    [glacg_type]              CHAR (1)    NOT NULL,
    [glacg_normal_dc]         CHAR (1)    NULL,
    [glacg_saf_category]      CHAR (1)    NULL,
    [glacg_ratio_category]    CHAR (1)    NULL,
    [glacg_cashflow_category] CHAR (1)    NULL,
    [glacg_user_id]           CHAR (16)   NULL,
    [glacg_user_rev_dt]       INT         NULL,
    [A4GLIdentity]            NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_glacgmst] PRIMARY KEY NONCLUSTERED ([glacg_beg1_8] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iglacgmst0]
    ON [dbo].[glacgmst]([glacg_beg1_8] ASC);


GO
CREATE UNIQUE NONCLUSTERED INDEX [Iglacgmst1]
    ON [dbo].[glacgmst]([glacg_type] ASC, [glacg_beg1_8] ASC);

