CREATE TABLE [dbo].[ecxrfmst] (
    [ecxrf_username]    CHAR (20)   NOT NULL,
    [ecxrf_cus_no]      CHAR (10)   NOT NULL,
    [ecxrf_expire_dt]   INT         NULL,
    [ecxrf_user_id]     CHAR (16)   NULL,
    [ecxrf_user_rev_dt] INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_ecxrfmst] PRIMARY KEY NONCLUSTERED ([ecxrf_username] ASC, [ecxrf_cus_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Iecxrfmst0]
    ON [dbo].[ecxrfmst]([ecxrf_username] ASC, [ecxrf_cus_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[ecxrfmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[ecxrfmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[ecxrfmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[ecxrfmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[ecxrfmst] TO PUBLIC
    AS [dbo];

