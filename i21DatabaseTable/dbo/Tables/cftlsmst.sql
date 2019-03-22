CREATE TABLE [dbo].[cftlsmst] (
    [cftls_state_code]  TINYINT     NOT NULL,
    [cftls_state_name]  CHAR (20)   NULL,
    [cftls_postal_code] CHAR (2)    NULL,
    [cftls_user_id]     CHAR (16)   NULL,
    [cftls_user_rev_dt] INT         NULL,
    [A4GLIdentity]      NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_cftlsmst] PRIMARY KEY NONCLUSTERED ([cftls_state_code] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Icftlsmst0]
    ON [dbo].[cftlsmst]([cftls_state_code] ASC);

