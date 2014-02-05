CREATE TABLE [dbo].[gachrmst] (
    [gachr_currency]        CHAR (3)       NOT NULL,
    [gachr_loc_no]          CHAR (3)       NOT NULL,
    [gachr_com_cd]          CHAR (3)       NOT NULL,
    [gachr_stor_type]       TINYINT        NOT NULL,
    [gachr_stor_schd_no]    TINYINT        NOT NULL,
    [gachr_desc]            CHAR (20)      NULL,
    [gachr_in_un_chrg]      DECIMAL (9, 6) NULL,
    [gachr_allow_days]      SMALLINT       NULL,
    [gachr_type_chrg]       CHAR (1)       NULL,
    [gachr_init_beg_rev_dt] INT            NULL,
    [gachr_init_end_rev_dt] INT            NULL,
    [gachr_init_days]       SMALLINT       NULL,
    [gachr_init_un_chrg]    DECIMAL (9, 6) NULL,
    [gachr_next_days]       SMALLINT       NULL,
    [gachr_next_un_chrg]    DECIMAL (9, 6) NULL,
    [gachr_after_un_chrg]   DECIMAL (9, 6) NULL,
    [gachr_restart_yn]      CHAR (1)       NULL,
    [gachr_user_id]         CHAR (16)      NULL,
    [gachr_user_rev_dt]     INT            NULL,
    [A4GLIdentity]          NUMERIC (9)    IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_gachrmst] PRIMARY KEY NONCLUSTERED ([gachr_currency] ASC, [gachr_loc_no] ASC, [gachr_com_cd] ASC, [gachr_stor_type] ASC, [gachr_stor_schd_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Igachrmst0]
    ON [dbo].[gachrmst]([gachr_currency] ASC, [gachr_loc_no] ASC, [gachr_com_cd] ASC, [gachr_stor_type] ASC, [gachr_stor_schd_no] ASC);

