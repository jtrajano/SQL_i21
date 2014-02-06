CREATE TABLE [dbo].[agmanmst] (
    [agman_itm_mfg_id]  CHAR (10)   NOT NULL,
    [agman_itm_desc]    CHAR (25)   NULL,
    [agman_user_id]     CHAR (16)   NULL,
    [agman_user_rev_dt] INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_agmanmst] PRIMARY KEY NONCLUSTERED ([agman_itm_mfg_id] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iagmanmst0]
    ON [dbo].[agmanmst]([agman_itm_mfg_id] ASC);

