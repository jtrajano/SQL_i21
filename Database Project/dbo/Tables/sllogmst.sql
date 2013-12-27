CREATE TABLE [dbo].[sllogmst] (
    [sllog_tran_rev_dt]  INT         NOT NULL,
    [sllog_tran_time]    INT         NOT NULL,
    [sllog_tran_file_id] CHAR (3)    NOT NULL,
    [sllog_tran_seq]     SMALLINT    NOT NULL,
    [sllog_function]     CHAR (1)    NULL,
    [sllog_tran_rec_key] CHAR (40)   NULL,
    [sllog_user_id]      CHAR (16)   NULL,
    [A4GLIdentity]       NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_sllogmst] PRIMARY KEY NONCLUSTERED ([sllog_tran_rev_dt] ASC, [sllog_tran_time] ASC, [sllog_tran_file_id] ASC, [sllog_tran_seq] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Isllogmst0]
    ON [dbo].[sllogmst]([sllog_tran_rev_dt] ASC, [sllog_tran_time] ASC, [sllog_tran_file_id] ASC, [sllog_tran_seq] ASC);


GO
CREATE NONCLUSTERED INDEX [Isllogmst1]
    ON [dbo].[sllogmst]([sllog_tran_file_id] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[sllogmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[sllogmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[sllogmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[sllogmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[sllogmst] TO PUBLIC
    AS [dbo];

