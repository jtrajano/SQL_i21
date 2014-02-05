CREATE TABLE [dbo].[sldocmst] (
    [sldoc_slsmn_id]       CHAR (3)       NOT NULL,
    [sldoc_rev_dt]         INT            NOT NULL,
    [sldoc_hhmm]           DECIMAL (4, 2) NOT NULL,
    [sldoc_type]           CHAR (1)       NOT NULL,
    [sldoc_tie_breaker]    SMALLINT       NOT NULL,
    [sldoc_slnam_key]      CHAR (10)      NOT NULL,
    [sldoc_slloc_key]      CHAR (10)      NOT NULL,
    [sldoc_allotted_hours] DECIMAL (4, 2) NULL,
    [sldoc_wrk_slsmn_id]   CHAR (3)       NULL,
    [sldoc_note1]          CHAR (60)      NULL,
    [sldoc_note2]          CHAR (60)      NULL,
    [sldoc_for_rev_ser]    INT            NULL,
    [sldoc_for_rev_sw]     INT            NULL,
    [sldoc_for_rev_hw]     INT            NULL,
    [sldoc_deal_stat_cmnt] CHAR (36)      NULL,
    [sldoc_sec_access_yn]  CHAR (1)       NULL,
    [sldoc_user_id]        CHAR (16)      NULL,
    [sldoc_user_rev_dt]    INT            NULL,
    [A4GLIdentity]         NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_sldocmst] PRIMARY KEY NONCLUSTERED ([sldoc_slsmn_id] ASC, [sldoc_rev_dt] ASC, [sldoc_hhmm] ASC, [sldoc_type] ASC, [sldoc_tie_breaker] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Isldocmst0]
    ON [dbo].[sldocmst]([sldoc_slsmn_id] ASC, [sldoc_rev_dt] ASC, [sldoc_hhmm] ASC, [sldoc_type] ASC, [sldoc_tie_breaker] ASC);


GO
CREATE NONCLUSTERED INDEX [Isldocmst1]
    ON [dbo].[sldocmst]([sldoc_slnam_key] ASC, [sldoc_slloc_key] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[sldocmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[sldocmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[sldocmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[sldocmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[sldocmst] TO PUBLIC
    AS [dbo];

