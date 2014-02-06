CREATE TABLE [dbo].[sfmvhmst] (
    [sfmvh_cus_no]      CHAR (10)   NOT NULL,
    [sfmvh_from_grp_id] CHAR (14)   NOT NULL,
    [sfmvh_seq_no]      TINYINT     NOT NULL,
    [sfmvh_to_grp_id]   CHAR (14)   NOT NULL,
    [sfmvh_to_stg_id]   CHAR (10)   NULL,
    [sfmvh_curr_head]   INT         NULL,
    [sfmvh_move_head]   INT         NULL,
    [sfmvh_move_rev_dt] INT         NULL,
    [sfmvh_comment]     CHAR (30)   NULL,
    [sfmvh_user_id]     CHAR (16)   NULL,
    [sfmvh_user_rev_dt] INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_sfmvhmst] PRIMARY KEY NONCLUSTERED ([sfmvh_cus_no] ASC, [sfmvh_from_grp_id] ASC, [sfmvh_seq_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Isfmvhmst0]
    ON [dbo].[sfmvhmst]([sfmvh_cus_no] ASC, [sfmvh_from_grp_id] ASC, [sfmvh_seq_no] ASC);


GO
CREATE NONCLUSTERED INDEX [Isfmvhmst1]
    ON [dbo].[sfmvhmst]([sfmvh_from_grp_id] ASC);


GO
CREATE NONCLUSTERED INDEX [Isfmvhmst2]
    ON [dbo].[sfmvhmst]([sfmvh_to_grp_id] ASC);


GO
GRANT DELETE
    ON OBJECT::[dbo].[sfmvhmst] TO PUBLIC
    AS [dbo];


GO
GRANT INSERT
    ON OBJECT::[dbo].[sfmvhmst] TO PUBLIC
    AS [dbo];


GO
GRANT REFERENCES
    ON OBJECT::[dbo].[sfmvhmst] TO PUBLIC
    AS [dbo];


GO
GRANT SELECT
    ON OBJECT::[dbo].[sfmvhmst] TO PUBLIC
    AS [dbo];


GO
GRANT UPDATE
    ON OBJECT::[dbo].[sfmvhmst] TO PUBLIC
    AS [dbo];

