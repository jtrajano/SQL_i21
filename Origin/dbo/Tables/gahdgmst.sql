CREATE TABLE [dbo].[gahdgmst] (
    [gahdg_com_cd]          CHAR (3)        NOT NULL,
    [gahdg_broker_no]       CHAR (10)       NOT NULL,
    [gahdg_hedge_yyyymm]    INT             NOT NULL,
    [gahdg_rev_dt]          INT             NOT NULL,
    [gahdg_ref]             CHAR (6)        NOT NULL,
    [gahdg_seq]             SMALLINT        NOT NULL,
    [gahdg_loc_no]          CHAR (3)        NULL,
    [gahdg_exposure_yyyymm] INT             NULL,
    [gahdg_bot_prc]         DECIMAL (9, 5)  NULL,
    [gahdg_bot_basis]       DECIMAL (9, 5)  NULL,
    [gahdg_bot]             CHAR (1)        NULL,
    [gahdg_bot_option]      CHAR (5)        NULL,
    [gahdg_comment]         CHAR (30)       NULL,
    [gahdg_long_short_ind]  CHAR (1)        NULL,
    [gahdg_un_hdg]          DECIMAL (11, 3) NULL,
    [gahdg_un_hdg_bal]      DECIMAL (11, 3) NULL,
    [gahdg_offset_yn]       CHAR (1)        NULL,
    [gahdg_offset_rev_dt]   INT             NULL,
    [gahdg_offset_ref]      CHAR (6)        NULL,
    [gahdg_offset_seq]      SMALLINT        NULL,
    [gahdg_orig_prc]        DECIMAL (9, 5)  NULL,
    [gahdg_orig_basis]      DECIMAL (9, 5)  NULL,
    [gahdg_avg_basis]       DECIMAL (9, 5)  NULL,
    [gahdg_user_id]         CHAR (16)       NULL,
    [gahdg_user_rev_dt]     INT             NULL,
    [A4GLIdentity]          NUMERIC (9)     IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_gahdgmst] PRIMARY KEY NONCLUSTERED ([gahdg_com_cd] ASC, [gahdg_broker_no] ASC, [gahdg_hedge_yyyymm] ASC, [gahdg_rev_dt] ASC, [gahdg_ref] ASC, [gahdg_seq] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Igahdgmst0]
    ON [dbo].[gahdgmst]([gahdg_com_cd] ASC, [gahdg_broker_no] ASC, [gahdg_hedge_yyyymm] ASC, [gahdg_rev_dt] ASC, [gahdg_ref] ASC, [gahdg_seq] ASC);


GO
CREATE NONCLUSTERED INDEX [Igahdgmst1]
    ON [dbo].[gahdgmst]([gahdg_rev_dt] ASC, [gahdg_ref] ASC, [gahdg_seq] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[gahdgmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[gahdgmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[gahdgmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[gahdgmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[gahdgmst] TO PUBLIC
    AS [dbo];

