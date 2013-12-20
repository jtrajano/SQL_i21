CREATE TABLE [dbo].[agclrmst] (
    [agclr_key]        CHAR (10)   NOT NULL,
    [agclr_name]       CHAR (50)   NULL,
    [agclr_rev_dt]     INT         NULL,
    [agclr_act_rev_dt] INT         NULL,
    [agclr_act_type]   CHAR (20)   NULL,
    [agclr_delete_yn]  CHAR (1)    NULL,
    [A4GLIdentity]     NUMERIC (9) IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [k_agclrmst] PRIMARY KEY NONCLUSTERED ([agclr_key] ASC)
);


GO
CREATE UNIQUE CLUSTERED INDEX [Iagclrmst0]
    ON [dbo].[agclrmst]([agclr_key] ASC);

