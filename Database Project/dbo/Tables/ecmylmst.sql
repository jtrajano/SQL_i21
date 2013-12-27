CREATE TABLE [dbo].[ecmylmst] (
    [ecmyl_username]      CHAR (20)   NOT NULL,
    [ecmyl_link_sequence] SMALLINT    NOT NULL,
    [ecmyl_page_id]       SMALLINT    NULL,
    [ecmyl_system]        CHAR (2)    NULL,
    [ecmyl_user_id]       CHAR (16)   NULL,
    [ecmyl_user_rev_dt]   INT         NULL,
    [A4GLIdentity]        NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_ecmylmst] PRIMARY KEY NONCLUSTERED ([ecmyl_username] ASC, [ecmyl_link_sequence] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iecmylmst0]
    ON [dbo].[ecmylmst]([ecmyl_username] ASC, [ecmyl_link_sequence] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ecmylmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ecmylmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[ecmylmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ecmylmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ecmylmst] TO PUBLIC
    AS [dbo];

