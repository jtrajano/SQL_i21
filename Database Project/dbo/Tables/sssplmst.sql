CREATE TABLE [dbo].[sssplmst] (
    [ssspl_bill_to_cus] CHAR (10)      NOT NULL,
    [ssspl_split_no]    CHAR (4)       NOT NULL,
    [ssspl_rec_type]    CHAR (1)       NOT NULL,
    [ssspl_desc]        CHAR (60)      NULL,
    [ssspl_exc_class]   CHAR (3)       NULL,
    [ssspl_cus_no_1]    CHAR (10)      NULL,
    [ssspl_cus_no_2]    CHAR (10)      NULL,
    [ssspl_cus_no_3]    CHAR (10)      NULL,
    [ssspl_cus_no_4]    CHAR (10)      NULL,
    [ssspl_cus_no_5]    CHAR (10)      NULL,
    [ssspl_cus_no_6]    CHAR (10)      NULL,
    [ssspl_cus_no_7]    CHAR (10)      NULL,
    [ssspl_cus_no_8]    CHAR (10)      NULL,
    [ssspl_cus_no_9]    CHAR (10)      NULL,
    [ssspl_cus_no_10]   CHAR (10)      NULL,
    [ssspl_cus_no_11]   CHAR (10)      NULL,
    [ssspl_cus_no_12]   CHAR (10)      NULL,
    [ssspl_pct_1]       DECIMAL (7, 3) NULL,
    [ssspl_pct_2]       DECIMAL (7, 3) NULL,
    [ssspl_pct_3]       DECIMAL (7, 3) NULL,
    [ssspl_pct_4]       DECIMAL (7, 3) NULL,
    [ssspl_pct_5]       DECIMAL (7, 3) NULL,
    [ssspl_pct_6]       DECIMAL (7, 3) NULL,
    [ssspl_pct_7]       DECIMAL (7, 3) NULL,
    [ssspl_pct_8]       DECIMAL (7, 3) NULL,
    [ssspl_pct_9]       DECIMAL (7, 3) NULL,
    [ssspl_pct_10]      DECIMAL (7, 3) NULL,
    [ssspl_pct_11]      DECIMAL (7, 3) NULL,
    [ssspl_pct_12]      DECIMAL (7, 3) NULL,
    [ssspl_option_1]    CHAR (1)       NULL,
    [ssspl_option_2]    CHAR (1)       NULL,
    [ssspl_option_3]    CHAR (1)       NULL,
    [ssspl_option_4]    CHAR (1)       NULL,
    [ssspl_option_5]    CHAR (1)       NULL,
    [ssspl_option_6]    CHAR (1)       NULL,
    [ssspl_option_7]    CHAR (1)       NULL,
    [ssspl_option_8]    CHAR (1)       NULL,
    [ssspl_option_9]    CHAR (1)       NULL,
    [ssspl_option_10]   CHAR (1)       NULL,
    [ssspl_option_11]   CHAR (1)       NULL,
    [ssspl_option_12]   CHAR (1)       NULL,
    [ssspl_acres]       DECIMAL (7, 2) NULL,
    [ssspl_user_id]     CHAR (16)      NULL,
    [ssspl_user_rev_dt] INT            NULL,
    [A4GLIdentity]      NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_sssplmst] PRIMARY KEY NONCLUSTERED ([ssspl_bill_to_cus] ASC, [ssspl_split_no] ASC, [ssspl_rec_type] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Isssplmst0]
    ON [dbo].[sssplmst]([ssspl_bill_to_cus] ASC, [ssspl_split_no] ASC, [ssspl_rec_type] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[sssplmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[sssplmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[sssplmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[sssplmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[sssplmst] TO PUBLIC
    AS [dbo];

