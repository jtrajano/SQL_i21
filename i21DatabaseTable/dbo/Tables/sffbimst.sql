CREATE TABLE [dbo].[sffbimst] (
    [sffbi_cus_no]      CHAR (10)   NOT NULL,
    [sffbi_farm_id]     CHAR (10)   NOT NULL,
    [sffbi_barn_id]     CHAR (15)   NOT NULL,
    [sffbi_comment]     CHAR (30)   NULL,
    [sffbi_user_id]     CHAR (16)   NULL,
    [sffbi_user_rev_dt] INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_sffbimst] PRIMARY KEY NONCLUSTERED ([sffbi_cus_no] ASC, [sffbi_farm_id] ASC, [sffbi_barn_id] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Isffbimst0]
    ON [dbo].[sffbimst]([sffbi_cus_no] ASC, [sffbi_farm_id] ASC, [sffbi_barn_id] ASC);

