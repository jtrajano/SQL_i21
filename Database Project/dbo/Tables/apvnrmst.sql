CREATE TABLE [dbo].[apvnrmst] (
    [apvnr_vnd_no]      CHAR (10)       NOT NULL,
    [apvnr_yyyy]        SMALLINT        NOT NULL,
    [apvnr_ivc_amt]     DECIMAL (11, 2) NULL,
    [apvnr_chk_amt]     DECIMAL (11, 2) NULL,
    [apvnr_disc_amt]    DECIMAL (11, 2) NULL,
    [apvnr_wthhld_amt]  DECIMAL (11, 2) NULL,
    [apvnr_oth_dr_amt]  DECIMAL (11, 2) NULL,
    [apvnr_oth_cr_amt]  DECIMAL (11, 2) NULL,
    [apvnr_1099_amt]    DECIMAL (11, 2) NULL,
    [apvnr_user_id]     CHAR (16)       NULL,
    [apvnr_user_rev_dt] INT             NULL,
    [A4GLIdentity]      NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_apvnrmst] PRIMARY KEY NONCLUSTERED ([apvnr_vnd_no] ASC, [apvnr_yyyy] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iapvnrmst0]
    ON [dbo].[apvnrmst]([apvnr_vnd_no] ASC, [apvnr_yyyy] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[apvnrmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[apvnrmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[apvnrmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[apvnrmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[apvnrmst] TO PUBLIC
    AS [dbo];

