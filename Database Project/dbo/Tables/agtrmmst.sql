CREATE TABLE [dbo].[agtrmmst] (
    [agtrm_key_n]            TINYINT         NOT NULL,
    [agtrm_desc]             CHAR (15)       NULL,
    [agtrm_disc_pct]         DECIMAL (4, 2)  NULL,
    [agtrm_disc_days]        SMALLINT        NULL,
    [agtrm_disc_rev_dt]      INT             NULL,
    [agtrm_net_days]         SMALLINT        NULL,
    [agtrm_net_rev_dt]       INT             NULL,
    [agtrm_age_ind]          CHAR (1)        NULL,
    [agtrm_cutoff_days]      SMALLINT        NULL,
    [agtrm_roll_terms_yn]    CHAR (1)        NULL,
    [agtrm_proximo_yn]       CHAR (1)        NULL,
    [agtrm_eft_yn]           CHAR (1)        NULL,
    [agtrm_send_to_et_yn]    CHAR (1)        NULL,
    [agtrm_et_discount_type] CHAR (1)        NULL,
    [agtrm_et_discount_rate] DECIMAL (12, 6) NULL,
    [agtrm_et_override_yn]   CHAR (1)        NULL,
    [agtrm_user_id]          CHAR (16)       NULL,
    [agtrm_user_rev_dt]      INT             NULL,
    [A4GLIdentity]           NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_agtrmmst] PRIMARY KEY NONCLUSTERED ([agtrm_key_n] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iagtrmmst0]
    ON [dbo].[agtrmmst]([agtrm_key_n] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[agtrmmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[agtrmmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[agtrmmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[agtrmmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[agtrmmst] TO PUBLIC
    AS [dbo];

