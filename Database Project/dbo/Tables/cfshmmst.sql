CREATE TABLE [dbo].[cfshmmst] (
    [cfshm_host_no]     CHAR (6)    NOT NULL,
    [cfshm_host_name]   CHAR (35)   NULL,
    [cfshm_user_id]     CHAR (16)   NULL,
    [cfshm_user_rev_dt] INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_cfshmmst] PRIMARY KEY NONCLUSTERED ([cfshm_host_no] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Icfshmmst0]
    ON [dbo].[cfshmmst]([cfshm_host_no] ASC);

