CREATE TABLE [dbo].[gadscmst] (
    [gadsc_currency]       CHAR (3)       NOT NULL,
    [gadsc_loc_no]         CHAR (3)       NOT NULL,
    [gadsc_disc_schd_no]   TINYINT        NOT NULL,
    [gadsc_com_cd]         CHAR (3)       NOT NULL,
    [gadsc_stor_type]      CHAR (1)       NOT NULL,
    [gadsc_disc_cd]        CHAR (2)       NOT NULL,
    [gadsc_seq_no]         SMALLINT       NOT NULL,
    [gadsc_desc]           CHAR (20)      NULL,
    [gadsc_shrk_what]      CHAR (1)       NULL,
    [gadsc_disc_calc]      CHAR (1)       NULL,
    [gadsc_def_reading]    DECIMAL (7, 3) NULL,
    [gadsc_min_reading]    DECIMAL (7, 3) NULL,
    [gadsc_max_reading]    DECIMAL (7, 3) NULL,
    [gadsc_from_reading]   DECIMAL (7, 3) NULL,
    [gadsc_thru_reading]   DECIMAL (7, 3) NULL,
    [gadsc_increment]      DECIMAL (7, 3) NULL,
    [gadsc_increment_disc] DECIMAL (9, 6) NULL,
    [gadsc_increment_pct]  DECIMAL (7, 4) NULL,
    [gadsc_accum_disc]     DECIMAL (9, 6) NULL,
    [gadsc_accum_pct]      DECIMAL (7, 4) NULL,
    [gadsc_user_id]        CHAR (16)      NULL,
    [gadsc_user_rev_dt]    INT            NULL,
    [A4GLIdentity]         NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_gadscmst] PRIMARY KEY NONCLUSTERED ([gadsc_currency] ASC, [gadsc_loc_no] ASC, [gadsc_disc_schd_no] ASC, [gadsc_com_cd] ASC, [gadsc_stor_type] ASC, [gadsc_disc_cd] ASC, [gadsc_seq_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Igadscmst0]
    ON [dbo].[gadscmst]([gadsc_currency] ASC, [gadsc_loc_no] ASC, [gadsc_disc_schd_no] ASC, [gadsc_com_cd] ASC, [gadsc_stor_type] ASC, [gadsc_disc_cd] ASC, [gadsc_seq_no] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[gadscmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[gadscmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[gadscmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[gadscmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[gadscmst] TO PUBLIC
    AS [dbo];

