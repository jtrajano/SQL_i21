CREATE TABLE [dbo].[gltotmst] (
    [gltot_yr]          SMALLINT        NOT NULL,
    [gltot_acct1_8]     INT             NOT NULL,
    [gltot_acct9_16]    INT             NOT NULL,
    [gltot_type]        CHAR (1)        NOT NULL,
    [gltot_bgt_type]    CHAR (1)        NOT NULL,
    [gltot_beg_amt]     DECIMAL (12, 2) NULL,
    [gltot_amt_1]       DECIMAL (12, 2) NULL,
    [gltot_amt_2]       DECIMAL (12, 2) NULL,
    [gltot_amt_3]       DECIMAL (12, 2) NULL,
    [gltot_amt_4]       DECIMAL (12, 2) NULL,
    [gltot_amt_5]       DECIMAL (12, 2) NULL,
    [gltot_amt_6]       DECIMAL (12, 2) NULL,
    [gltot_amt_7]       DECIMAL (12, 2) NULL,
    [gltot_amt_8]       DECIMAL (12, 2) NULL,
    [gltot_amt_9]       DECIMAL (12, 2) NULL,
    [gltot_amt_10]      DECIMAL (12, 2) NULL,
    [gltot_amt_11]      DECIMAL (12, 2) NULL,
    [gltot_amt_12]      DECIMAL (12, 2) NULL,
    [gltot_amt_13]      DECIMAL (12, 2) NULL,
    [gltot_beg_units]   DECIMAL (18, 4) NULL,
    [gltot_units_1]     DECIMAL (18, 4) NULL,
    [gltot_units_2]     DECIMAL (18, 4) NULL,
    [gltot_units_3]     DECIMAL (18, 4) NULL,
    [gltot_units_4]     DECIMAL (18, 4) NULL,
    [gltot_units_5]     DECIMAL (18, 4) NULL,
    [gltot_units_6]     DECIMAL (18, 4) NULL,
    [gltot_units_7]     DECIMAL (18, 4) NULL,
    [gltot_units_8]     DECIMAL (18, 4) NULL,
    [gltot_units_9]     DECIMAL (18, 4) NULL,
    [gltot_units_10]    DECIMAL (18, 4) NULL,
    [gltot_units_11]    DECIMAL (18, 4) NULL,
    [gltot_units_12]    DECIMAL (18, 4) NULL,
    [gltot_units_13]    DECIMAL (18, 4) NULL,
    [gltot_user_id]     CHAR (16)       NULL,
    [gltot_user_rev_dt] INT             NULL,
    [A4GLIdentity]      NUMERIC (9)     IDENTITY (1, 1) NOT NULL
);


GO
CREATE UNIQUE CLUSTERED INDEX [Igltotmst0]
    ON [dbo].[gltotmst]([gltot_yr] ASC, [gltot_acct1_8] ASC, [gltot_acct9_16] ASC, [gltot_type] ASC, [gltot_bgt_type] ASC);

