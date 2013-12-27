CREATE TABLE [dbo].[sscurmst] (
    [sscur_key]            CHAR (3)        NOT NULL,
    [sscur_desc]           CHAR (20)       NULL,
    [sscur_no_dec]         TINYINT         NULL,
    [sscur_daily_rt]       DECIMAL (15, 8) NULL,
    [sscur_min_rt]         DECIMAL (15, 8) NULL,
    [sscur_max_rt]         DECIMAL (15, 8) NULL,
    [sscur_eom_rev_dt]     INT             NULL,
    [sscur_eom_rt]         DECIMAL (15, 8) NULL,
    [sscur_prv_eom_rev_dt] INT             NULL,
    [sscur_prv_eom_rt]     DECIMAL (15, 8) NULL,
    [sscur_chk_lit]        CHAR (20)       NULL,
    [sscur_user_id]        CHAR (16)       NULL,
    [sscur_user_rev_dt]    INT             NULL,
    [A4GLIdentity]         NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_sscurmst] PRIMARY KEY NONCLUSTERED ([sscur_key] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Isscurmst0]
    ON [dbo].[sscurmst]([sscur_key] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[sscurmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[sscurmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[sscurmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[sscurmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[sscurmst] TO PUBLIC
    AS [dbo];

