CREATE TABLE [dbo].[jdaudmst] (
    [jdaud_file]        CHAR (8)    NOT NULL,
    [jdaud_program]     CHAR (8)    NOT NULL,
    [jdaud_key]         CHAR (50)   NOT NULL,
    [jdaud_function]    CHAR (1)    NOT NULL,
    [jdaud_old_data]    CHAR (1600) NULL,
    [jdaud_new_data]    CHAR (1600) NULL,
    [jdaud_timestamp]   CHAR (25)   NOT NULL,
    [jdaud_user_id]     CHAR (16)   NULL,
    [jdaud_user_rev_dt] INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL
);




GO
CREATE CLUSTERED INDEX [Ijdaudmst0]
    ON [dbo].[jdaudmst]([jdaud_file] ASC);


GO
CREATE NONCLUSTERED INDEX [Ijdaudmst1]
    ON [dbo].[jdaudmst]([jdaud_program] ASC);


GO
CREATE NONCLUSTERED INDEX [Ijdaudmst2]
    ON [dbo].[jdaudmst]([jdaud_key] ASC);


GO
CREATE NONCLUSTERED INDEX [Ijdaudmst3]
    ON [dbo].[jdaudmst]([jdaud_function] ASC);


GO
CREATE NONCLUSTERED INDEX [Ijdaudmst4]
    ON [dbo].[jdaudmst]([jdaud_timestamp] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[jdaudmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[jdaudmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[jdaudmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[jdaudmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[jdaudmst] TO PUBLIC
    AS [dbo];

