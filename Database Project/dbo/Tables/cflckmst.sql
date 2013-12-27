CREATE TABLE [dbo].[cflckmst] (
    [cflck_card_no]          CHAR (16)   NOT NULL,
    [cflck_ar_cus_no]        CHAR (10)   NOT NULL,
    [cflck_lock_activate_la] CHAR (1)    NULL,
    [cflck_rev_dt]           INT         NULL,
    [cflck_time_hhmm]        SMALLINT    NULL,
    [A4GLIdentity]           NUMERIC (9) IDENTITY (1, 1) NOT NULL
);




GO
CREATE UNIQUE CLUSTERED INDEX [Icflckmst0]
    ON [dbo].[cflckmst]([cflck_card_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Icflckmst1]
    ON [dbo].[cflckmst]([cflck_ar_cus_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[cflckmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[cflckmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[cflckmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[cflckmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[cflckmst] TO PUBLIC
    AS [dbo];

