CREATE TABLE [dbo].[sllcmmst] (
    [sllcm_lead_id]     CHAR (10)   NOT NULL,
    [sllcm_loc_id]      CHAR (10)   NOT NULL,
    [sllcm_type]        CHAR (3)    NOT NULL,
    [sllcm_seq_no]      SMALLINT    NOT NULL,
    [sllcm_comment]     CHAR (70)   NULL,
    [sllcm_user_id]     CHAR (16)   NULL,
    [sllcm_user_rev_dt] INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_sllcmmst] PRIMARY KEY NONCLUSTERED ([sllcm_lead_id] ASC, [sllcm_loc_id] ASC, [sllcm_type] ASC, [sllcm_seq_no] ASC)
);




GO
CREATE UNIQUE CLUSTERED INDEX [Isllcmmst0]
    ON [dbo].[sllcmmst]([sllcm_lead_id] ASC, [sllcm_loc_id] ASC, [sllcm_type] ASC, [sllcm_seq_no] ASC);


GO
GRANT UPDATE
    ON OBJECT::[dbo].[sllcmmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[sllcmmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[sllcmmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[sllcmmst] TO PUBLIC
    AS [dbo];


GO
GRANT DELETE
    ON OBJECT::[dbo].[sllcmmst] TO PUBLIC
    AS [dbo];

